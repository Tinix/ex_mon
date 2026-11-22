defmodule ExMon.Game.Status do
  alias ExMon.Player

  @move_order [:move_rnd, :move_avg, :move_heal]

  def print_round(%{player: player, computer: computer} = game) do
    width = max(String.length(player.name), String.length(computer.name))

    IO.puts("""

    ===== #{headline(game)} =====
    #{life_line(player, width)}
    #{life_line(computer, width)}
    #{next_step(game)}
    """)
  end

  def print_event(%{actor: actor, move: move, amount: amount, game: game}) do
    user = Map.fetch!(game, actor)
    name = Map.fetch!(user.moves, move)

    IO.puts("#{user.name} used #{name}: #{effect(move, actor, amount, game)}")
  end

  def print_replaced, do: IO.puts("The previous game was discarded.")

  def print_invalid_move(input, %{player: player}) do
    IO.puts("Invalid move: #{inspect(input)}. Your moves: #{move_names(player)}")
  end

  def print_error(reason), do: IO.puts(error_text(reason))

  defp headline(%{status: :started}), do: "The game has started!"
  defp headline(%{status: :continue}), do: "Your turn!"
  defp headline(%{status: :game_over} = game), do: "Game over: #{winner(game).name} wins!"

  defp winner(%{player: %{life: 0}, computer: computer}), do: computer
  defp winner(%{player: player}), do: player

  defp life_line(player, width),
    do: "#{String.pad_trailing(player.name, width)}  #{life(player)}"

  defp life(player), do: "#{player.life}/#{Player.max_life()}"

  defp next_step(%{status: :game_over}), do: "Use ExMon.start_game/1 to start a new game."
  defp next_step(%{player: player}), do: "Your moves: #{move_names(player)}"

  defp move_names(%{moves: moves}),
    do: Enum.map_join(@move_order, ", ", &inspect(Map.fetch!(moves, &1)))

  defp effect(:move_heal, actor, amount, game),
    do: "restored #{amount} life (#{life(Map.fetch!(game, actor))})."

  defp effect(_attack, :player, amount, %{computer: target}), do: damage(target, amount)
  defp effect(_attack, :computer, amount, %{player: target}), do: damage(target, amount)

  defp damage(target, amount), do: "#{amount} damage to #{target.name} (#{life(target)})."

  defp error_text(:game_not_started),
    do: "There is no game in progress. Use ExMon.start_game/1 first."

  defp error_text(:not_your_turn), do: "It is not your turn."
  defp error_text(:invalid_player), do: "Invalid player. Create one with ExMon.create_player/4."
  defp error_text(:invalid_name), do: "The player name must be a non-empty string."
  defp error_text(:invalid_moves), do: "Move names must be non-empty atoms or strings."
  defp error_text(:duplicate_moves), do: "The moves must have three different names."
end
