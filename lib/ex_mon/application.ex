defmodule ExMon.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link([ExMon.Game], strategy: :one_for_one, name: ExMon.Supervisor)
  end
end
