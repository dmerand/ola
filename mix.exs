defmodule Ola.MixProject do
  use Mix.Project

  def project do
    [
      app: :ola,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      licenses: ["MIT"],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ola.Application, []},
      registered: [Ola.Dictionary]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "0.28.0", only: :dev, runtime: :false},
    ]
  end
end
