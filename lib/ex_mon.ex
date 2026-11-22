defmodule ExMon do
  @moduledoc """
  A turn-based battle game played from IEx against the computer.

  Create a player, start a game and make moves until someone's life reaches zero:

      player = ExMon.create_player("Ada", :kick, :punch, :heal)
      ExMon.start_game(player)
      ExMon.make_move(:kick)

  There is one game at a time on each node. Every function prints what happened
  and returns a value that can be pattern matched.
  """

  alias ExMon.{Game, Player}
  alias ExMon.Game.Status

  @computer_name "Robotinix"

  @doc """
  Creates a player with full life and a name for each of the three moves.

  The arguments after `name` are, in order, the names of:

    * the random attack (10 to 35 damage)
    * the average attack (18 to 25 damage)
    * the heal (18 to 25 life)

  Move names are atoms or strings and must be different from each other.
  Invalid input prints the problem and returns `{:error, reason}`.

  ## Examples

      iex> player = ExMon.create_player("Ada", :kick, :punch, :heal)
      iex> {player.name, player.life, player.moves.move_rnd}
      {"Ada", 100, :kick}

  """
  @spec create_player(term(), term(), term(), term()) ::
          Player.t() | {:error, Player.error()}
  def create_player(name, move_rnd, move_avg, move_heal) do
    case Player.build(name, move_rnd, move_avg, move_heal) do
      %Player{} = player ->
        player

      {:error, reason} = error ->
        Status.print_error(reason)
        error
    end
  end

  @doc """
  Starts a game against the computer. The player always moves first.

  A game in progress is replaced, and a message says so. Returns `:ok`, or
  `{:error, :invalid_player}` without touching the current game.
  """
  @spec start_game(term()) :: :ok | {:error, :invalid_player}
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

  @doc """
  Plays one round: the player's move followed by the computer's.

  `move` is one of the names given to `create_player/4`, with the same type.
  The computer does not move if the player's move ends the game.

  Returns `:ok`, or one of these errors without changing the game:

    * `{:error, :game_not_started}`
    * `{:error, :game_over}`
    * `{:error, :invalid_move}`
    * `{:error, :not_your_turn}`
  """
  @spec make_move(term()) :: :ok | {:error, Game.error()}
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
