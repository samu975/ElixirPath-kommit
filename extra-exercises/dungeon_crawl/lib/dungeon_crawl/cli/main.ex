defmodule DungeonCrawl.Cli.Main do
  alias Mix.Shell.IO, as: Shell

  def start_game do
    welcome_message()
    Shell.prompt("Press Enter to continue")
    hero_choice()
    crawul(DungeonCrawl.Room.all())
  end

  defp welcome_message do
    Shell.info("== Dungeon Crawl ===")
    Shell.info("You awake in a dungeon full of monsters.")
    Shell.info("You need to survive and find the exit.")
  end

  defp hero_choice do
    DungeonCrawl.Cli.HeroChoice.start()
  end

  defp crawul(rooms) do
    Shell.info("You keep moving forward to the next rooms.")
    Shell.prompt("Press Enter to continue")
    Shell.cmd("clear")

    rooms
    |> Enum.random()
    |> DungeonCrawl.Cli.RoomActionsChoice.start
  end
end
