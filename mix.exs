defmodule Ola.MixProject do
  use Mix.Project

  def project do
    [
      app: :ola,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/dmerand/ola",
      homepage_url: "https://github.com/dmerand/ola"
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

  defp description do
    "Ola uses Markov chains to make fake-sounding words. It does this by first being trained on a dictionary of real words to emulate."
  end

  defp package do
    [
      name: "ola",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dmerand/ola"}
    ]
  end
end
