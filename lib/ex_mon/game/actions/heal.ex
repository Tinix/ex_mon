defmodule ExMon.Game.Actions.Heal do
  @moduledoc """
  The healing range and how healing is applied.
  """

  alias ExMon.Player

  @heal_power 18..25

  @doc "Rolls how much life is restored."
  @spec power((Range.t() -> integer())) :: integer()
  def power(random), do: random.(@heal_power)

  @doc "Restores life without going above the maximum."
  @spec restore(Player.t(), non_neg_integer()) :: Player.t()
  def restore(%Player{life: life} = player, amount),
    do: %{player | life: min(life + amount, Player.max_life())}
end
