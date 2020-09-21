defmodule Jurby.Container do
  @behaviour Access

  alias Jurby.Container
  import Furlong.Util, only: [new_vars: 1]

  defstruct id: nil,
            type: nil,
            opts: [],
            contents_left: nil,
            contents_top: nil,
            contents_width: nil,
            contents_height: nil,
            contents_right: nil,
            contents_bottom: nil,
            contents_h_mid: nil,
            contents_v_mid: nil,
            left: nil,
            top: nil,
            width: nil,
            height: nil,
            right: nil,
            bottom: nil,
            h_mid: nil,
            v_mid: nil,
            children: []

  def fetch(%Container{} = c, key) do
    Map.fetch(c, key)
  end

  def container(id, type, children, opts \\ []) do
    [
      contents_left,
      contents_top,
      contents_width,
      contents_height,
      contents_right,
      contents_bottom,
      contents_h_mid,
      contents_v_mid
    ] = new_vars(8)

    [
      left,
      top,
      width,
      height,
      right,
      bottom,
      h_mid,
      v_mid
    ] = new_vars(8)


    %Container{
      id: id,
      type: type,
      contents_left: contents_left,
      contents_top: contents_top,
      contents_width: contents_width,
      contents_height: contents_height,
      contents_right: contents_right,
      contents_bottom: contents_bottom,
      contents_h_mid: contents_h_mid,
      contents_v_mid: contents_v_mid,
      left: left,
      top: top,
      width: width,
      height: height,
      right: right,
      bottom: bottom,
      h_mid: h_mid,
      v_mid: v_mid,
      children: children,
      opts: opts
    }
  end
end
