defmodule ExMon.GameLifecycleTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ExMon.{Game, GameCase, Player}

  setup do
    GameCase.reset_game()
    %{player: Player.build("Tinix", :kick, :punch, :heal)}
  end

  test "a move without a game returns a clear error" do
    output =
      capture_io(fn ->
        assert ExMon.make_move(:kick) == {:error, :game_not_started}
      end)

    assert output =~ "There is no game in progress"
  end

  test "starting again replaces the game in progress", %{player: player} do
    capture_io(fn -> ExMon.start_game(player) end)
    output = capture_io(fn -> ExMon.start_game(%{player | name: "Ada"}) end)

    assert Game.info().player.name == "Ada"
    assert output =~ "previous game was discarded"
  end

  test "a new game can start after game over", %{player: player} do
    capture_io(fn ->
      ExMon.start_game(player)
      Enum.each(1..100, fn _ -> ExMon.make_move(:punch) end)
    end)

    assert Game.info().status == :game_over

    output = capture_io(fn -> ExMon.start_game(player) end)

    assert %{status: :started, player: %{life: 100}, computer: %{life: 100}} = Game.info()
    refute output =~ "discarded"
  end

  test "the game outlives the process that started it", %{player: player} do
    {pid, ref} =
      spawn_monitor(fn ->
        capture_io(fn -> ExMon.start_game(player) end)
        exit(:boom)
      end)

    assert_receive {:DOWN, ^ref, :process, ^pid, :boom}, 1_000
    Process.sleep(20)
    assert %{status: :started} = Game.info()
  end
end
