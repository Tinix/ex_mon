defmodule ExMon.Game.Actions.Attack do
  @moduledoc """
  Damage ranges and how damage is applied.
  """

  alias ExMon.Game.Actions
  alias ExMon.Player

  @move_avg_power 18..25
  @move_rnd_power 10..35

  @doc "Rolls the damage of an attack."
  @spec power(:move_avg | :move_rnd, Actions.random()) :: integer()
  def power(:move_avg, random), do: random.(@move_avg_power)
  def power(:move_rnd, random), do: random.(@move_rnd_power)

  @doc "Applies damage without letting life drop below zero."
  @spec hit(Player.t(), non_neg_integer()) :: Player.t()
  def hit(%Player{life: life} = player, damage), do: %{player | life: max(life - damage, 0)}
end
