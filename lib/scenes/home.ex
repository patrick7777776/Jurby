defmodule Jurby.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort
  import Layout
  import Jurby.LayoutSpec
  import Jurby.Space
  import Jurby.AdditionalConstraints

  import Scenic.Primitives
  import Scenic.Components

  def init(_, opts) do
    {:ok, %ViewPort.Status{size: {width, height}}} = ViewPort.info(opts[:viewport])

    graph =
      Graph.build(font: :roboto, font_size: 24)
      |> text("Weather API Setup", id: :label_setup, font_size: 36)
      |> text("Latitude:", id: :label_lat)
      |> text("Longtitude:", id: :label_long)
      |> text("Api Key:", id: :label_key)
      |> text("Password:", id: :label_pass)
      |> text_field("", id: :text_lat, width: 550)
      |> text_field("", id: :text_long)
      |> text_field("", id: :text_key)
      |> text_field("", id: :text_pass)
      |> button("OK", id: :btn_ok)
      |> button("Cancel", id: :btn_cancel)
      |> layout(
        width,
        height,
        vbox(
          [
            :label_setup,
            space(size: 10),
            hbox([:label_lat, gspace(), :text_lat], pin_last: true),
            hbox([:label_long, gspace(), :text_long], pin_last: true),
            hbox([:label_key, gspace(), :text_key], pin_last: true),
            hbox([:label_pass, gspace(), :text_pass], pin_last: true),
            space(size: 10),
            hbox([:btn_ok, space(), :btn_cancel], pin_first: false, pin_last: true)
          ],
          id: :main,
          left_margin: 10,
          top_margin: 10,
          right_margin: 10,
          bottom_margin: 10
        ),
        [
          same(:width, [:text_lat, :text_long, :text_key, :text_pass]),
          same(:width, [:btn_ok, :btn_cancel]),
          same(:right, [:btn_cancel, :text_pass])
        ]
      )

    {:ok, graph, push: graph}
  end
end
