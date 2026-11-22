defmodule ExMon.Game.ActionsTest do
  use ExUnit.Case, async: true

  alias ExMon.Game.Actions
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

  # The computer picks `move`; every roll is resolved with `roll`.
  defp random(move, roll \\ &Enum.min/1) do
    fn
      options when is_list(options) ->
        assert move in options
        move

      range ->
        roll.(range)
    end
  end

  defp with_life(game, who, life), do: put_in(game, [who], %{game[who] | life: life})

  describe "the player's move" do
    test "the random attack damages the computer", %{game: game} do
      assert {:ok, [event | _], _} = Actions.play_round(game, :kick, random(:move_heal))
      assert %{actor: :player, move: :move_rnd, amount: 10} = event
      assert event.game.computer.life == 90
      assert event.game.player.life == 100
    end

    test "the average attack damages the computer", %{game: game} do
      assert {:ok, [event | _], _} = Actions.play_round(game, :punch, random(:move_heal))
      assert %{actor: :player, move: :move_avg, amount: 18} = event
      assert event.game.computer.life == 82
    end

    test "healing restores the player and not the computer", %{game: game} do
      game = game |> with_life(:player, 50) |> with_life(:computer, 40)

      assert {:ok, [event | _], _} = Actions.play_round(game, :heal, random(:move_rnd))
      assert %{actor: :player, move: :move_heal, amount: 18} = event
      assert event.game.player.life == 68
      assert event.game.computer.life == 40
    end

    test "healing at full life still uses the turn", %{game: game} do
      assert {:ok, [%{amount: 0}, %{actor: :computer}], _} =
               Actions.play_round(game, :heal, random(:move_rnd))
    end

    test "string move names work", %{game: game} do
      game = %{game | player: Player.build("Tinix", "kick", "punch", "heal")}

      assert {:ok, [%{move: :move_avg} | _], _} =
               Actions.play_round(game, "punch", random(:move_heal))
    end
  end

  describe "the computer's turn" do
    test "can use the random attack", %{game: game} do
      assert {:ok, [_, event], result} = Actions.play_round(game, :heal, random(:move_rnd))
      assert %{actor: :computer, move: :move_rnd, amount: 10} = event
      assert result.player.life == 90
    end

    test "can use the average attack", %{game: game} do
      assert {:ok, [_, event], result} = Actions.play_round(game, :heal, random(:move_avg))
      assert %{actor: :computer, move: :move_avg, amount: 18} = event
      assert result.player.life == 82
    end

    test "can heal itself", %{game: game} do
      game = with_life(game, :computer, 50)

      assert {:ok, [_, event], result} = Actions.play_round(game, :heal, random(:move_heal))
      assert %{actor: :computer, move: :move_heal, amount: 18} = event
      assert result.computer.life == 68
      assert result.player.life == 100
    end

    test "chooses among exactly the three moves", %{game: game} do
      test_process = self()

      spy = fn
        options when is_list(options) ->
          send(test_process, {:options, options})
          hd(options)

        range ->
          Enum.min(range)
      end

      Actions.play_round(game, :kick, spy)

      assert_received {:options, options}
      assert Enum.sort(options) == [:move_avg, :move_heal, :move_rnd]
    end

    test "gives the turn back to the player", %{game: game} do
      assert {:ok, _, %{turn: :player, status: :continue}} =
               Actions.play_round(game, :kick, random(:move_rnd))
    end
  end

  describe "the end of the game" do
    test "a lethal hit ends it before the computer moves", %{game: game} do
      game = with_life(game, :computer, 3)

      assert {:ok, [%{amount: 3}], result} =
               Actions.play_round(game, :kick, random(:move_rnd, &Enum.max/1))

      assert %{status: :game_over, computer: %{life: 0}} = result
    end

    test "the computer can win", %{game: game} do
      game = with_life(game, :player, 10)

      assert {:ok, [_, %{amount: 10}], result} =
               Actions.play_round(game, :kick, random(:move_rnd))

      assert %{status: :game_over, player: %{life: 0}} = result
    end

    test "nobody can act afterwards, not even to heal", %{game: game} do
      game = %{with_life(game, :player, 0) | status: :game_over}

      for move <- [:kick, :punch, :heal, :unknown] do
        assert Actions.play_round(game, move, random(:move_rnd)) == {:error, :game_over}
      end
    end
  end

  describe "rejected moves" do
    test "without a game" do
      assert Actions.play_round(nil, :kick, random(:move_rnd)) == {:error, :game_not_started}
    end

    test "with an unknown name", %{game: game} do
      assert Actions.play_round(game, :wrong, random(:move_rnd)) == {:error, :invalid_move}
    end

    test "out of turn", %{game: game} do
      game = %{game | turn: :computer}

      assert Actions.play_round(game, :kick, random(:move_rnd)) == {:error, :not_your_turn}
    end
  end
end
