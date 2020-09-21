defmodule Jurby.Space do
  @behaviour Access
  alias Jurby.Space
  import Furlong.Util, only: [new_vars: 1]

  @default_size 5

  defstruct id: nil,
            size: 0,
            type: nil,
            left: nil,
            top: nil,
            width: nil,
            height: nil,
            right: nil,
            bottom: nil,
            h_mid: nil,
            v_mid: nil

  def space(opts \\ []) do
    id = opts[:id] || make_ref()
    size = opts[:size] || @default_size
    new(id, size, :static)
  end

  def gspace(opts \\ []) do
    id = opts[:id] || make_ref()
    size = opts[:size] || @default_size
    new(id, size, :grow)
  end

  defp new(id, size, type) do
    [left, top, width, height, right, bottom, h_mid, v_mid] = new_vars(8)

    %Space{
      id: id,
      size: size,
      type: type,
      left: left,
      top: top,
      width: width,
      height: height,
      right: right,
      bottom: bottom,
      h_mid: h_mid,
      v_mid: v_mid
    }
  end

  def fetch(%Space{} = s, key) do
    Map.fetch(s, key)
  end
end
