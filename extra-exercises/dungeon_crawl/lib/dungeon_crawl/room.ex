defmodule DungeonCrawl.Room do
  alias DungeonCrawl.Room

  import DungeonCrawl.Room.Action

  defstruct description: nil, actions: []

  def all, do: [
    %Room{
      description: "You found a quiet place. Look safe for a little nap. ",
      actions: [forward(), rest()],
    },
  ]
end
