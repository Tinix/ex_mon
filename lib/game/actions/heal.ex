defmodule ExMon.Game.Actions.Heal do
  alias ExMon.{Game, Player}
  alias ExMon.Game.Status

  @heal_power 18..25

  def heal_life(player, random \\ &Enum.random/1) do
    player
    |> Game.fetch_player()
    |> restore(power(random))
    |> update_game(player)
  end

  def power(random), do: random.(@heal_power)

  def restore(%Player{life: life} = player, amount),
    do: %{player | life: min(life + amount, Player.max_life())}

  defp update_game(player_data, player) do
    Game.info()
    |> Map.put(player, player_data)
    |> Game.update()

    Status.print_move_message(player, :heal, player_data.life)
  end
end
