defmodule ExMonTest do
  use ExUnit.Case
  alias ExMon.{GameCase, Player}

  import ExUnit.CaptureIO

  doctest ExMon

  setup do
    GameCase.reset_game()
  end

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

      assert messages =~ "The game has started!"
      assert %{status: :started, turn: :player} = ExMon.Game.info()
    end
  end

  describe "make_move/1" do
    setup do
      player = Player.build("Tinix", :kick, :punch, :heal)

      capture_io(fn ->
        ExMon.start_game(player)
        ExMon.make_move(:kick)
      end)

      :ok
    end

    test "when the move is valid, do the move and the computer makes a move" do
      messages =
        capture_io(fn ->
          assert ExMon.make_move(:kick) == :ok
        end)

      assert messages =~ "Tinix used kick"
      assert messages =~ "Robotinix used"
      assert messages =~ "Your turn!"
      assert %{status: :continue} = ExMon.Game.info()
    end

    test "when the move is invalid, returns an error and lists the valid moves" do
      messages =
        capture_io(fn ->
          assert ExMon.make_move(:wrong) == {:error, :invalid_move}
        end)

      assert messages =~ "Invalid move: :wrong. Your moves: :kick, :punch, :heal"
    end
  end

  describe "a complete game" do
    setup do
      capture_io(fn -> ExMon.start_game(Player.build("Tinix", :kick, :punch, :heal)) end)
      :ok
    end

    test "the player can use the average attack" do
      assert capture_io(fn -> ExMon.make_move(:punch) end) =~ "Tinix used punch"
    end

    test "the player can heal" do
      assert capture_io(fn -> ExMon.make_move(:heal) end) =~ "Tinix used heal"
    end

    test "attacking until the end finishes the game" do
      capture_io(fn ->
        Enum.each(1..100, fn _ -> ExMon.make_move(:punch) end)
      end)

      %{status: status, player: player, computer: computer} = ExMon.Game.info()

      assert status == :game_over
      assert 0 in [player.life, computer.life]

      output =
        capture_io(fn -> assert ExMon.make_move(:heal) == {:error, :game_over} end)

      assert output =~ "wins!"
      assert output =~ "start a new game"
    end
  end
end
