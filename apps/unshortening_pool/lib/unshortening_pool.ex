defmodule UnshorteningPool do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      :poolboy.child_spec(pool_name(), poolboy_config(), [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UnshorteningPool.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp pool_name, do: UnshorteningPool

  defp poolboy_config do
    [
      {:name, {:local, pool_name}},
      {:worker_module, UnshorteningPool.Worker},
      {:size, 5},
      {:max_overflow, 10}
    ]
  end

  def map(enum) do
    UnshorteningPool.Mapper.map_through_pool(enum, pool_name)
  end
end