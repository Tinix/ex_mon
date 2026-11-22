defmodule ExMon do
  alias ExMon.{Game, Player}
  alias ExMon.Game.Status

  @computer_name "Robotinix"

  def create_player(name, move_rnd, move_avg, move_heal) do
    case Player.build(name, move_rnd, move_avg, move_heal) do
      %Player{} = player ->
        player

      {:error, reason} = error ->
        Status.print_error(reason)
        error
    end
  end

  def start_game(player) do
    computer = Player.build(@computer_name, :punch, :kick, :heal)

    case Game.start(computer, player) do
      {:ok, result, game} ->
        if result == :replaced, do: Status.print_replaced()
        Status.print_round(game)

      {:error, reason} = error ->
        Status.print_error(reason)
        error
    end
  end

  def make_move(move) do
    case Game.play(move) do
      {:ok, events, game} ->
        Enum.each(events, &Status.print_event/1)
        Status.print_round(game)

      {:error, reason, game} ->
        report_error(reason, move, game)
        {:error, reason}
    end
  end

  defp report_error(:invalid_move, move, game), do: Status.print_invalid_move(move, game)
  defp report_error(:game_over, _move, game), do: Status.print_round(game)
  defp report_error(reason, _move, _game), do: Status.print_error(reason)
end
