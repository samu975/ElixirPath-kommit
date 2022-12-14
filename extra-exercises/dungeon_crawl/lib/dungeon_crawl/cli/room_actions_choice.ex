defmodule DungeonCrawl.Cli.RoomActionsChoice do
  alias Mix.Shell.IO, as: Shell
  import DungeonCrawl.Cli.BaseCommands

  def start(room) do
    room_actions = room.actions
    find_action_by_index = &(Enum.at(room_actions, &1))

    Shell.info(room.description())

    chosen_actions =
      room_actions
      |> Enum.map(&(&1.label))
      |> display_options()
      |> generate_question()
      |> Shell.prompt()
      |> parse_answer()
      |> find_action_by_index.()

      {room, chosen_actions}
  end
end
