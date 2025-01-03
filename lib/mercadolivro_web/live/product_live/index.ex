defmodule MercadolivroWeb.ProductLive.Index do
  use MercadolivroWeb, :live_view

  alias Mercadolivro.Store
  alias Mercadolivro.Store.Product
  alias Mercadolivro.Constants

    embed_templates "components/*"

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Store.subscribe_to_product_events()
    cart_items = Store.list_cart_items(session["cart_id"])

    socket =
      socket
      |> assign(:cart_id, session["cart_id"])
      |> assign(:genres, Constants.product_genres())
      |> assign(:empty_list, false)
      |> assign(:selected_genre, "")
      |> stream(:products, Store.list_products())
      |> stream(:cart_items, cart_items)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Store.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({MercadolivroWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_info({:product_updated, updated_product}, socket) do
    {:noreply, stream_insert(socket, :products, updated_product)}
  end

  @impl true
  def handle_info({:product_created, created_product}, socket) do
    {:noreply, stream_insert(socket, :products, created_product)}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Store.get_product!(id)
    {:ok, _} = Store.delete_product(product)

    {:noreply, stream_delete(socket, :products, product)}
  end

  @impl true
  def handle_event("add_to_cart", %{"id" => id}, socket) do
    product = Store.get_product!(id)

    Store.add_item_to_cart(socket.assigns.cart_id, product)

    Process.send_after(self(), :clear_flash, 2500)

    {:noreply, socket |> put_flash(:info, "Added to cart")}
  end

  @impl true
  def handle_event("select-genre", %{"genre" => genre}, socket) do
    socket =
    socket
    |> assign(:selected_genre, genre)
    |> stream(:products, [], reset: true)
    |> stream(:products, Store.list_products(genre: genre))
    # IO.inspect(Store.list_products(genre: genre) === [])
    # IO.inspect(socket.assigns.streams.products.inserts)

    cond do
      (socket.assigns.streams.products.inserts) === [] ->
        IO.inspect("empty")
        socket = assign(socket, empty_list: true)
        {:noreply, socket}
      true ->
        IO.inspect("not empty")
        socket = assign(socket, empty_list: false)
        {:noreply, socket}
    end

  end

  @impl true
  def handle_event("clear-genre", _, socket) do
    socket =
    socket
    |> assign(:selected_genre, "")
    |> assign(:empty_list, false)
    |> stream(:products, [], reset: true)
    |> stream(:products, Store.list_products())
  {:noreply, socket}
  end
end
