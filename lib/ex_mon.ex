defmodule ExMon do
  alias ExMon.{Game, Player}
  alias ExMon.Game.{Status, Actions}

  @computer_name "Robotinix"
  @computer_moves [:move_avg, :move_rnd, :move_heal]

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
      {:ok, result} ->
        if result == :replaced, do: Status.print_replaced_message()
        Status.print_round_message(Game.info())

      {:error, reason} = error ->
        Status.print_error_message(reason)
        error
    end
  end

  def make_move(move) do
    case Game.info() do
      nil ->
        Status.print_error_message(:game_not_started)
        {:error, :game_not_started}

      %{status: status} ->
        handle_status(status, move)
    end
  end

  defp handle_status(:game_over, _move), do: Status.print_round_message(Game.info())

  defp handle_status(_other, move) do
    move
    |> Actions.fetch_move()
    |> do_move()

    computer_move(Game.info())
  end

  defp do_move({:error, move}), do: Status.print_wrong_move_message(move)

  defp do_move({:ok, move}) do
    case move do
      :move_heal -> Actions.heal()
      move -> Actions.attack(move)
    end

    Status.print_round_message(Game.info())
  end

  defp computer_move(%{turn: :computer, status: :continue}) do
    move = {:ok, Enum.random(@computer_moves)}
    do_move(move)
  end

  defp computer_move(_), do: :ok
end
