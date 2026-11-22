defmodule ExMon.InputValidationTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ExMon.{Game, GameCase, Player}

  setup do
    GameCase.reset_game()
    %{player: Player.build("Tinix", :kick, :punch, :heal)}
  end

  test "create_player/4 explains what is wrong" do
    output =
      capture_io(fn ->
        assert ExMon.create_player("T", :a, :a, :a) == {:error, :duplicate_moves}
      end)

    assert output =~ "three different names"
  end

  test "start_game/1 rejects anything that is not a valid player", %{player: player} do
    invalid = [
      nil,
      "Juan",
      %{},
      {:error, :invalid_name},
      %{player | life: 0},
      %{player | life: -5},
      %{player | life: 500},
      %{player | life: 50.0},
      %{player | name: nil},
      %{player | moves: nil},
      %{player | moves: %{move_rnd: :kick}}
    ]

    for value <- invalid do
      output =
        capture_io(fn -> assert ExMon.start_game(value) == {:error, :invalid_player} end)

      assert output =~ "Invalid player"
      assert Game.info() == nil
    end
  end

  test "an invalid player does not discard the game in progress", %{player: player} do
    capture_io(fn ->
      ExMon.start_game(player)
      ExMon.start_game(nil)
    end)

    assert Game.info().player == player
  end

  test "any kind of invalid move is reported without crashing", %{player: player} do
    capture_io(fn -> ExMon.start_game(player) end)
    before = Game.info()

    for move <- [{:a}, %{}, self(), [:a], nil, "kick", :move_avg, <<255>>] do
      output = capture_io(fn -> ExMon.make_move(move) end)

      assert output =~ "Invalid move"
      assert Game.info() == before
    end
  end
end
