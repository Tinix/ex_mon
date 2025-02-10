defmodule ExMon.GameTest do
  use ExUnit.Case

  alias ExMon.{Game, Player}

  describe "start/2" do
    test "starts the game state" do
      player = Player.build("Tinix", :kick, :punch, :heal)
      computer = Player.build("Robotinix", :kick, :punch, :heal)

      assert {:ok, _pid} = Game.start(computer, player)
    end
  end

  describe "info/0" do
    test "returns the current game state" do
      player = Player.build("Tinix", :kick, :punch, :heal)
      computer = Player.build("Robotinix", :kick, :punch, :heal)

      Game.start(computer, player)

      experected_response = %{
        computer: %Player{
          life: 100,
          moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
          name: "Robotinix"
        },
        player: %Player{
          life: 100,
          moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
          name: "Tinix"
        },
        status: :started,
        turn: :player
      }

      assert experected_response == Game.info()
    end
  end

  describe "update/1" do
    test "updates the game state" do
      player = Player.build("Tinix", :kick, :punch, :heal)
      computer = Player.build("Robotinix", :kick, :punch, :heal)

      Game.start(computer, player)

      experected_response = %{
        computer: %Player{
          life: 100,
          moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
          name: "Robotinix"
        },
        player: %Player{
          life: 100,
          moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
          name: "Tinix"
        },
        status: :started,
        turn: :player
      }

      assert experected_response == Game.info()

      new_state = %{
        computer: %Player{
          life: 87,
          moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
          name: "Robotinix"
        },
        player: %Player{
          life: 91,
          moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
          name: "Tinix"
        },
        status: :started,
        turn: :player
      }

      Game.update(new_state)

      experected_response = %{new_state | turn: :computer, status: :continue}

      assert experected_response == Game.info()
    end
  end
end
