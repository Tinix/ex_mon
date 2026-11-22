defmodule ExMon.Game.Actions.Heal do
  alias ExMon.Player

  @heal_power 18..25

  def power(random), do: random.(@heal_power)

  def restore(%Player{life: life} = player, amount),
    do: %{player | life: min(life + amount, Player.max_life())}
end
