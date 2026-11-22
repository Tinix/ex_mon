defmodule ExMon.Game.Actions.Attack do
  alias ExMon.{Game, Player}
  alias ExMon.Game.Status

  @move_avg_power 18..25
  @move_rnd_power 10..35

  def attack_opponent(opponent, move, random \\ &Enum.random/1) do
    damage = power(move, random)

    opponent
    |> Game.fetch_player()
    |> hit(damage)
    |> update_game(opponent, damage)
  end

  def power(:move_avg, random), do: random.(@move_avg_power)
  def power(:move_rnd, random), do: random.(@move_rnd_power)

  def hit(%Player{life: life} = player, damage), do: %{player | life: max(life - damage, 0)}

  defp update_game(player, opponent, damage) do
    Game.info()
    |> Map.put(opponent, player)
    |> Game.update()

    Status.print_move_message(opponent, :attack, damage)
  end
end
