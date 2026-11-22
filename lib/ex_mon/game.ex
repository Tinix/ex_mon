defmodule ExMon.Game do
  @moduledoc """
  The supervised process that holds the current game.

  The state only changes through `start/2` and `play/2`.
  """

  use Agent

  alias ExMon.Game.Actions
  alias ExMon.Player

  @type side :: :player | :computer
  @type status :: :started | :continue | :game_over
  @type state :: %{player: Player.t(), computer: Player.t(), status: status(), turn: side()}
  @type error :: :game_not_started | :game_over | :invalid_move | :not_your_turn

  @doc "Starts the process, without a game."
  @spec start_link(term()) :: Agent.on_start()
  def start_link(_opts), do: Agent.start_link(fn -> nil end, name: __MODULE__)

  @doc """
  Starts a new game, saying whether it replaced one that was still in progress.
  """
  @spec start(term(), term()) ::
          {:ok, :started | :replaced, state()} | {:error, :invalid_player}
  def start(computer, player) do
    if Player.valid?(computer) and Player.valid?(player) do
      game = %{computer: computer, player: player, turn: :player, status: :started}

      Agent.get_and_update(__MODULE__, fn previous ->
        {{:ok, start_result(previous), game}, game}
      end)
    else
      {:error, :invalid_player}
    end
  end

  @doc "Returns the current game, or `nil` if there is none."
  @spec info() :: state() | nil
  def info, do: Agent.get(__MODULE__, & &1)

  @doc """
  Plays a whole round as a single operation, so simultaneous moves cannot interleave.

  `random` receives a range or a list and returns one of its elements. It runs
  inside the game process, so it must not raise.
  """
  @spec play(term(), Actions.random()) ::
          {:ok, [Actions.event()], state()} | {:error, error(), state() | nil}
  def play(input, random \\ &Enum.random/1) do
    Agent.get_and_update(__MODULE__, fn game ->
      case Actions.play_round(game, input, random) do
        {:ok, events, new_game} -> {{:ok, events, new_game}, new_game}
        {:error, reason} -> {{:error, reason, game}, game}
      end
    end)
  end

  defp start_result(%{status: status}) when status != :game_over, do: :replaced
  defp start_result(_previous), do: :started
end
