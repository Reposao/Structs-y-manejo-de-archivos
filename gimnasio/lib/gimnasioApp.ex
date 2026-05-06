defmodule GimnasioApp do
  use Application

  def start(_type, _args) do
    children = [
      {Task, fn -> Menu.main() end}
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: GimnasioApp.Supervisor
    )
  end
end
