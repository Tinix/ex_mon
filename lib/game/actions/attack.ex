defmodule ExMon.Game.Actions.Attack do
  alias ExMon.Player

  @move_avg_power 18..25
  @move_rnd_power 10..35

  def power(:move_avg, random), do: random.(@move_avg_power)
  def power(:move_rnd, random), do: random.(@move_rnd_power)

  def hit(%Player{life: life} = player, damage), do: %{player | life: max(life - damage, 0)}
end
