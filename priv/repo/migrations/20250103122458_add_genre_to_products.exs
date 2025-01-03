defmodule Mercadolivro.Repo.Migrations.AddGenreToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :genre, :string
    end
  end
end
