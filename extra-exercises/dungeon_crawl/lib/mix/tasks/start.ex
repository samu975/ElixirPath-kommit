defmodule Mix.Tasks.Start do
  use Mix.Task
  def run(_), do: DungeonCrawl.Cli.Main.start_game
end
