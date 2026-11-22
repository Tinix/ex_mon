defmodule ExMon.Game.StatusTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias ExMon.Game.Status
  alias ExMon.Player

  setup do
    %{
      game: %{
        player: Player.build("Tinix", :kick, :punch, :heal),
        computer: Player.build("Robotinix", :punch, :kick, :heal),
        status: :started,
        turn: :player
      }
    }
  end

  test "the round summary shows both lives and the available moves", %{game: game} do
    output = capture_io(fn -> Status.print_round(game) end)

    assert output =~ "The game has started!"
    assert output =~ ~r"Tinix +100/100"
    assert output =~ ~r"Robotinix +100/100"
    assert output =~ "Your moves: :kick, :punch, :heal"
    refute output =~ "%{"
  end

  test "a game in progress says it is the player's turn", %{game: game} do
    output = capture_io(fn -> Status.print_round(%{game | status: :continue}) end)

    assert output =~ "Your turn!"
  end

  test "the end announces that the player won", %{game: game} do
    game = %{game | status: :game_over, computer: %{game.computer | life: 0}}
    output = capture_io(fn -> Status.print_round(game) end)

    assert output =~ "Game over: Tinix wins!"
    refute output =~ "Your moves"
  end

  test "the end announces that the computer won", %{game: game} do
    game = %{game | status: :game_over, player: %{game.player | life: 0}}

    assert capture_io(fn -> Status.print_round(game) end) =~ "Game over: Robotinix wins!"
  end

  test "an attack names who hit whom", %{game: game} do
    game = %{game | computer: %{game.computer | life: 80}}
    event = %{actor: :player, move: :move_rnd, amount: 20, game: game}

    assert capture_io(fn -> Status.print_event(event) end) =~
             "Tinix used kick: 20 damage to Robotinix (80/100)."
  end

  test "a computer attack uses its own move name", %{game: game} do
    event = %{actor: :computer, move: :move_avg, amount: 18, game: game}

    assert capture_io(fn -> Status.print_event(event) end) =~
             "Robotinix used kick: 18 damage to Tinix"
  end

  test "healing shows the life restored", %{game: game} do
    event = %{actor: :player, move: :move_heal, amount: 0, game: game}

    assert capture_io(fn -> Status.print_event(event) end) =~
             "Tinix used heal: restored 0 life (100/100)."
  end
end
