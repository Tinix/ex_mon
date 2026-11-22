defmodule ExMon.TurnSafetyTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ExMon.{Game, GameCase, Player}

  setup do
    GameCase.reset_game()
    player = Player.build("Tinix", :kick, :punch, :heal)
    capture_io(fn -> ExMon.start_game(player) end)
    %{player: player}
  end

  test "simultaneous moves are resolved as separate rounds", %{player: player} do
    for _attempt <- 1..200 do
      output =
        capture_io(fn ->
          ExMon.start_game(player)

          1..2
          |> Enum.map(fn _ -> Task.async(fn -> ExMon.make_move(:kick) end) end)
          |> Task.await_many()
        end)

      assert length(Regex.scan(~r/The player attacked the computer/, output)) == 2
      assert Game.info().turn == :player
    end
  end

  test "the player cannot act during the computer's turn" do
    Agent.update(Game, &%{&1 | status: :continue, turn: :computer})
    before = Game.info()

    capture_io(fn -> assert ExMon.make_move(:kick) == {:error, :not_your_turn} end)

    assert Game.info() == before
  end

  test "the state cannot be overwritten from outside the rules" do
    refute function_exported?(Code.ensure_loaded!(Game), :update, 1)
  end
end
