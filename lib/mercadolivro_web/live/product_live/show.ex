defmodule MercadolivroWeb.ProductLive.Show do
  use MercadolivroWeb, :live_view

  alias Mercadolivro.Store

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket}

    cart_items = Store.list_cart_items(session["cart_id"])

    socket =
      socket
      |> stream(:cart_items, cart_items)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, Store.get_product!(id))}

  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
