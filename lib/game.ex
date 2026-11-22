defmodule ExMon.Game do
  use Agent

  alias ExMon.Game.Actions
  alias ExMon.Player

  def start_link(_opts), do: Agent.start_link(fn -> nil end, name: __MODULE__)

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

  def info, do: Agent.get(__MODULE__, & &1)

  # The whole round runs inside the Agent, so concurrent moves cannot interleave.
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
