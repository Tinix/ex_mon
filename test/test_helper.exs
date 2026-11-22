ExUnit.start()

defmodule ExMon.GameCase do
  @moduledoc false

  # Restarts the supervised game process, so each test starts without a game.
  def reset_game do
    :ok = Supervisor.terminate_child(ExMon.Supervisor, ExMon.Game)
    {:ok, _pid} = Supervisor.restart_child(ExMon.Supervisor, ExMon.Game)
    :ok
  end
end
