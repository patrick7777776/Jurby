defmodule Jurby do
  def start(_type, _args) do
    main_viewport_config = Application.get_env(:jurby, :viewport)

    children = [
      {Scenic, viewports: [main_viewport_config]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
