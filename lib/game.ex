defmodule ExMon.Game do
  use Agent
  alias ExMon.Player

  def start_link(_opts), do: Agent.start_link(fn -> nil end, name: __MODULE__)

  def start(computer, player) do
    game = %{computer: computer, player: player, turn: :player, status: :started}

    Agent.get_and_update(__MODULE__, fn previous -> {{:ok, start_result(previous)}, game} end)
  end

  def info do
    Agent.get(__MODULE__, & &1)
  end

  def update(state) do
    Agent.update(__MODULE__, fn _ -> update_game_status(state) end)
  end

  def player, do: Map.get(info(), :player)
  def turn, do: Map.get(info(), :turn)
  def fetch_player(player), do: Map.get(info(), player)

  defp start_result(%{status: status}) when status != :game_over, do: :replaced
  defp start_result(_previous), do: :started

  defp update_game_status(
         %{player: %Player{life: player_life}, computer: %Player{life: computer_life}} = state
       )
       when player_life == 0 or computer_life == 0,
       do: Map.put(state, :status, :game_over)

  defp update_game_status(state) do
    state
    |> Map.put(:status, :continue)
    |> update_turn()
  end

  defp update_turn(%{turn: :player} = state), do: Map.put(state, :turn, :computer)
  defp update_turn(%{turn: :computer} = state), do: Map.put(state, :turn, :player)
end
