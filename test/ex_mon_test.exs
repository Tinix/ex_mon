defmodule ExMonTest do
  use ExUnit.Case
  alias ExMon.Player

  import ExUnit.CaptureIO

  describe "create_player/4" do
    test "returns a player" do
      expected_response = %Player{
        life: 100,
        moves: %{move_avg: :punch, move_heal: :heal, move_rnd: :kick},
        name: "Tinix"
      }

      assert expected_response == ExMon.create_player("Tinix", :kick, :punch, :heal)
    end
  end

  describe "start_game/1" do
    test "when the game is started returns a message" do
      player = Player.build("Tinix", :kick, :punch, :heal)

      messages =
        capture_io(fn ->
          assert ExMon.start_game(player) == :ok
        end)

      assert messages =~ "The game is started!"
      assert messages =~ "status: :started"
      assert messages =~ "turn: :player"
    end
  end

  describe "make_move/1" do
    test "when the move is valid, do the move and the computer makes a move" do
      player = Player.build("Tinix", :kick, :punch, :heal)
      ExMon.start_game(player)

      messages =
        capture_io(fn ->
          ExMon.make_move(:kick)
        end)

      assert messages =~ "The player attacked the computer"
      assert messages =~ "It's computer turn"
      assert messages =~ "It's player turn"
      assert messages =~ "status: :continue"
    end
  end
end
