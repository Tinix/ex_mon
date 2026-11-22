defmodule ExMon.Game.Actions do
  @moduledoc """
  The rules of a round, as pure functions over the game state.
  """

  alias ExMon.{Game, Player}
  alias ExMon.Game.Actions.{Attack, Heal}

  @computer_moves [:move_avg, :move_rnd, :move_heal]

  @typedoc "Picks one element from a range or a list."
  @type random :: (Enumerable.t() -> term())

  @typedoc "One action of the round, with the game as it was right after it."
  @type event :: %{
          actor: Game.side(),
          move: Player.move(),
          amount: non_neg_integer(),
          game: Game.state()
        }

  @doc """
  Resolves the player's move and the computer's response.

  `amount` in each event is the life that really changed, after applying the limits.
  """
  @spec play_round(Game.state() | nil, term(), random()) ::
          {:ok, [event()], Game.state()} | {:error, Game.error()}
  def play_round(nil, _input, _random), do: {:error, :game_not_started}
  def play_round(%{status: :game_over}, _input, _random), do: {:error, :game_over}

  def play_round(%{turn: :player, player: player} = game, input, random) do
    with {:ok, move} <- fetch_move(player.moves, input) do
      {event, game} = act(game, move, random)
      {events, game} = computer_turn(game, random)

      {:ok, [event | events], game}
    end
  end

  def play_round(_game, _input, _random), do: {:error, :not_your_turn}

  defp fetch_move(moves, input) do
    Enum.find_value(moves, {:error, :invalid_move}, fn {move, name} ->
      if name === input, do: {:ok, move}
    end)
  end

  defp computer_turn(%{status: :game_over} = game, _random), do: {[], game}

  defp computer_turn(game, random) do
    {event, game} = act(game, random.(@computer_moves), random)
    {[event], game}
  end

  defp act(%{turn: actor} = game, :move_heal, random) do
    before = Map.fetch!(game, actor)
    healed = Heal.restore(before, Heal.power(random))
    game = advance(%{game | actor => healed})

    {%{actor: actor, move: :move_heal, amount: healed.life - before.life, game: game}, game}
  end

  defp act(%{turn: actor} = game, move, random) do
    target = opponent(actor)
    before = Map.fetch!(game, target)
    wounded = Attack.hit(before, Attack.power(move, random))
    game = advance(%{game | target => wounded})

    {%{actor: actor, move: move, amount: before.life - wounded.life, game: game}, game}
  end

  defp advance(%{player: %{life: 0}} = game), do: %{game | status: :game_over}
  defp advance(%{computer: %{life: 0}} = game), do: %{game | status: :game_over}
  defp advance(%{turn: actor} = game), do: %{game | status: :continue, turn: opponent(actor)}

  defp opponent(:player), do: :computer
  defp opponent(:computer), do: :player
end
