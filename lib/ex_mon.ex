defmodule ExMon do
  alias ExMon.{Game, Player}
  alias ExMon.Game.Status

  @computer_name "Robotinix"

  def create_player(name, move_rnd, move_avg, move_heal) do
    case Player.build(name, move_rnd, move_avg, move_heal) do
      %Player{} = player ->
        player

      {:error, reason} = error ->
        Status.print_error_message(reason)
        error
    end
  end

  def start_game(player) do
    computer = Player.build(@computer_name, :punch, :kick, :heal)

    case Game.start(computer, player) do
      {:ok, result, game} ->
        if result == :replaced, do: Status.print_replaced_message()
        Status.print_round_message(game)

      {:error, reason} = error ->
        Status.print_error_message(reason)
        error
    end
  end

  def make_move(move) do
    case Game.play(move) do
      {:ok, events, _game} ->
        Enum.each(events, &print_event/1)

      {:error, :invalid_move, _game} ->
        Status.print_wrong_move_message(move)

      {:error, :game_over, game} ->
        Status.print_round_message(game)

      {:error, reason, _game} ->
        Status.print_error_message(reason)
        {:error, reason}
    end
  end

  defp print_event(%{game: game} = event) do
    Status.print_move_message(event)
    Status.print_round_message(game)
  end
end
