defmodule Jurby.Widget do
  @behaviour Access
  import Furlong.Util, only: [new_vars: 1]
  alias Jurby.Widget

  defstruct id: nil,
            left: nil,
            top: nil,
            width: nil,
            height: nil,
            right: nil,
            bottom: nil,
            h_mid: nil,
            v_mid: nil,
            preferred_width: nil,
            preferred_height: nil,
            opts: []

  def fetch(%Widget{} = w, key) do
    Map.fetch(w, key)
  end

  def widget(id, preferred_width, preferred_height, opts \\ []) do
    [left, top, width, height, right, bottom, h_mid, v_mid] = new_vars(8)

    %Widget{
      id: id,
      left: left,
      top: top,
      width: width,
      height: height,
      right: right,
      bottom: bottom,
      h_mid: h_mid,
      v_mid: v_mid,
      preferred_width: preferred_width,
      preferred_height: preferred_height,
      opts: opts
    }
  end
end
