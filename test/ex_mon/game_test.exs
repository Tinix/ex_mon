defmodule ExMon.GameTest do
  use ExUnit.Case

  alias ExMon.{Game, GameCase, Player}

  setup do
    GameCase.reset_game()
  end

  describe "start/2" do
    test "starts the game state" do
      player = Player.build("Tinix", :kick, :punch, :heal)
      computer = Player.build("Robotinix", :kick, :punch, :heal)

      assert {:ok, :started, _game} = Game.start(computer, player)
    end
  end

  describe "info/0" do
    test "returns the current game state" do
      player = Player.build("Tinix", :kick, :punch, :heal)
      computer = Player.build("Robotinix", :kick, :punch, :heal)

      Game.start(computer, player)

      expected_response = %{
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

      assert expected_response == Game.info()
    end
  end

  describe "play/2" do
    test "updates the game state" do
      player = Player.build("Tinix", :kick, :punch, :heal)
      computer = Player.build("Robotinix", :kick, :punch, :heal)

      Game.start(computer, player)

      random = fn
        options when is_list(options) -> :move_rnd
        range -> Enum.min(range)
      end

      assert {:ok, [_, _], game} = Game.play(:punch, random)

      assert game == %{
               computer: %{computer | life: 82},
               player: %{player | life: 90},
               status: :continue,
               turn: :player
             }

      assert game == Game.info()
    end
  end
end
