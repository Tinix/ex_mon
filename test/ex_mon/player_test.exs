defmodule ExMon.PlayerTest do
  use ExUnit.Case, async: true

  alias ExMon.Player

  doctest Player

  describe "build/4" do
    test "creates a player with full life and the three moves" do
      assert Player.build("Tinix", :kick, :punch, :heal) == %Player{
               name: "Tinix",
               life: 100,
               moves: %{move_rnd: :kick, move_avg: :punch, move_heal: :heal}
             }
    end

    test "accepts strings as move names" do
      assert %Player{} = Player.build("Tinix", "kick", "punch", "heal")
    end

    test "rejects invalid names" do
      for name <- [nil, "", "   ", :tinix, 42, <<255>>] do
        assert Player.build(name, :kick, :punch, :heal) == {:error, :invalid_name}
      end
    end

    test "rejects invalid move names in any position" do
      for move <- [nil, true, false, "", " ", :"", 1, {:kick}, <<255>>] do
        assert Player.build("T", move, :punch, :heal) == {:error, :invalid_moves}
        assert Player.build("T", :kick, move, :heal) == {:error, :invalid_moves}
        assert Player.build("T", :kick, :punch, move) == {:error, :invalid_moves}
      end
    end

    test "rejects duplicated move names" do
      assert Player.build("T", :a, :a, :heal) == {:error, :duplicate_moves}
      assert Player.build("T", :a, :b, :a) == {:error, :duplicate_moves}
      assert Player.build("T", :kick, "kick", :heal) == {:error, :duplicate_moves}
    end
  end
end
