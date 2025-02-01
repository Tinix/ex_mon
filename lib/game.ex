defmodule ExMon.Game do
  @moduledoc """

  """
  use Agent

  def start(computer, player) do
    initial_state = %{computer: computer, player: player, turn: :player, status: :started}
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def info do
    Agent.get(__MODULE__, & &1)
  end
end
