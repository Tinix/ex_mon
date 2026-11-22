defmodule ExMon.Game.Actions.AttackTest do
  use ExUnit.Case, async: true

  alias ExMon.Game.Actions.Attack
  alias ExMon.Player

  describe "power/2" do
    test "the average move rolls between 18 and 25" do
      assert Attack.power(:move_avg, &Enum.min/1) == 18
      assert Attack.power(:move_avg, &Enum.max/1) == 25
    end

    test "the random move rolls between 10 and 35" do
      assert Attack.power(:move_rnd, &Enum.min/1) == 10
      assert Attack.power(:move_rnd, &Enum.max/1) == 35
    end
  end

  describe "hit/2" do
    setup do
      %{player: Player.build("Tinix", :kick, :punch, :heal)}
    end

    test "subtracts the damage", %{player: player} do
      assert Attack.hit(player, 30).life == 70
    end

    test "can take life to exactly zero", %{player: player} do
      assert Attack.hit(%{player | life: 20}, 20).life == 0
    end

    test "never takes life below zero", %{player: player} do
      assert Attack.hit(%{player | life: 3}, 35).life == 0
    end
  end
end
