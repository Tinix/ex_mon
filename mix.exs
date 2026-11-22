defmodule ExMon.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_mon,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_local_path: "priv/plts",
        flags: [:error_handling, :extra_return, :missing_return, :unmatched_returns]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExMon.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7.19", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.9", only: [:dev, :test], runtime: false}
    ]
  end
end
