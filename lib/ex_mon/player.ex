defmodule ExMon.Player do
  @moduledoc """
  The player struct and the rules for a valid player.
  """

  @required_keys [:life, :moves, :name]
  @max_life 100

  @enforce_keys @required_keys
  defstruct @required_keys

  @type move :: :move_rnd | :move_avg | :move_heal
  @type move_name :: atom() | String.t()
  @type error :: :invalid_name | :invalid_moves | :duplicate_moves
  @type t :: %__MODULE__{
          life: non_neg_integer(),
          name: String.t(),
          moves: %{move_rnd: move_name(), move_avg: move_name(), move_heal: move_name()}
        }

  @doc "Returns the maximum life, which is also the starting life."
  @spec max_life() :: pos_integer()
  def max_life, do: @max_life

  @doc """
  Builds a player with full life, or explains why it cannot.

  ## Examples

      iex> ExMon.Player.build("Ada", :kick, :kick, :heal)
      {:error, :duplicate_moves}

  """
  @spec build(term(), term(), term(), term()) :: t() | {:error, error()}
  def build(name, move_rnd, move_avg, move_heal) do
    moves = %{move_rnd: move_rnd, move_avg: move_avg, move_heal: move_heal}

    with :ok <- validate_name(name),
         :ok <- validate_moves(moves) do
      %__MODULE__{life: @max_life, moves: moves, name: name}
    end
  end

  @doc """
  Tells whether the value is a player that can start a game.

  Players are plain structs, so they can be edited by hand after being built.
  """
  @spec valid?(term()) :: boolean()
  def valid?(%__MODULE__{life: life, moves: moves, name: name})
      when is_integer(life) and life in 1..@max_life do
    validate_name(name) == :ok and validate_moves(moves) == :ok
  end

  def valid?(_other), do: false

  defp validate_name(name) do
    if present_text?(name), do: :ok, else: {:error, :invalid_name}
  end

  defp validate_moves(%{move_rnd: random, move_avg: average, move_heal: heal} = moves)
       when map_size(moves) == 3 do
    names = [random, average, heal]

    cond do
      not Enum.all?(names, &move_name?/1) -> {:error, :invalid_moves}
      names |> Enum.uniq_by(&to_string/1) |> length() < 3 -> {:error, :duplicate_moves}
      true -> :ok
    end
  end

  defp validate_moves(_moves), do: {:error, :invalid_moves}

  defp move_name?(name) when name in [nil, true, false], do: false
  defp move_name?(name) when is_atom(name), do: present_text?(Atom.to_string(name))
  defp move_name?(name), do: present_text?(name)

  defp present_text?(text) when is_binary(text),
    do: String.valid?(text) and String.trim(text) != ""

  defp present_text?(_other), do: false
end
