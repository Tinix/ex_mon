defmodule ExMon.Game.Status do
  def print_round_message(%{status: :started} = info) do
    IO.puts("\n===== The game is started! =====\n")
    IO.inspect(info)
    IO.puts("==============================\n")
  end

  def print_round_message(%{status: :continue, turn: player} = info) do
    IO.puts("\n===== It's #{player} turn! =====\n")
    IO.inspect(info)
    IO.puts("==============================\n")
  end

  def print_round_message(%{status: :game_over} = info) do
    IO.puts("\n===== The game is over! =====\n")
    IO.inspect(info)
    IO.puts("==============================\n")
  end

  def print_replaced_message do
    IO.puts("\n===== The previous game was discarded. =====\n")
  end

  def print_error_message(reason), do: IO.puts("\n===== #{error_text(reason)} =====\n")

  def print_wrong_move_message(move) do
    IO.puts("\n===== Invalid move: #{inspect(move)}! =====\n")
  end

  def print_move_message(%{actor: actor, move: :move_heal, game: game}) do
    life = Map.fetch!(game, actor).life
    IO.puts("\n===== The #{actor} healed itself to #{life} life of points. =====\n")
  end

  def print_move_message(%{actor: :player, amount: damage}) do
    IO.puts(
      "\n===== The player attacked the computer dealing #{damage} points of damage. =====\n"
    )
  end

  def print_move_message(%{actor: :computer, amount: damage}) do
    IO.puts(
      "\n===== The computer attacked the player dealing #{damage} points of damage. =====\n"
    )
  end

  defp error_text(:game_not_started),
    do: "There is no game in progress. Use ExMon.start_game/1 first."

  defp error_text(:not_your_turn), do: "It is not your turn."

  defp error_text(:invalid_player),
    do: "Invalid player. Create one with ExMon.create_player/4."

  defp error_text(:invalid_name), do: "The player name must be a non-empty string."

  defp error_text(:invalid_moves), do: "Move names must be non-empty atoms or strings."
  defp error_text(:duplicate_moves), do: "The moves must have three different names."
end
