defmodule ExMon.Game.Actions.HealTest do
  use ExUnit.Case, async: true

  alias ExMon.Game.Actions.Heal
  alias ExMon.Player

  test "power/1 rolls between 18 and 25" do
    assert Heal.power(&Enum.min/1) == 18
    assert Heal.power(&Enum.max/1) == 25
  end

  describe "restore/2" do
    setup do
      %{player: Player.build("Tinix", :kick, :punch, :heal)}
    end

    test "adds life", %{player: player} do
      assert Heal.restore(%{player | life: 50}, 20).life == 70
    end

    test "can reach exactly the maximum", %{player: player} do
      assert Heal.restore(%{player | life: 80}, 20).life == 100
    end

    test "never goes above the maximum", %{player: player} do
      assert Heal.restore(%{player | life: 99}, 25).life == 100
      assert Heal.restore(player, 25).life == 100
    end
  end
end
