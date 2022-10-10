defmodule Hello.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.User

  schema "users" do
    field :bio, :string
    field :email, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :bio])
    |> validate_required([:name, :email, :bio])
    |> validate_length(:bio, min: 2)
    |> validate_length(:bio, max: 140)
    |> validate_format(:email, ~r/@/)
  end
end
