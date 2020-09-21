defmodule Jurby.Modifier do
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components
  alias Jurby.Container
  alias Jurby.Widget
  alias Jurby.Space
  import Furlong.Solver

  @default_font_size 20
  @default_font :roboto

  def set_position_and_size(
        %Scenic.Primitive{module: Scenic.Primitive.Rectangle} = p,
        x,
        y,
        w,
        h
      ) do
    rectangle(p, {w, h}, translate: {x, y})
  end

  def set_position_and_size(
        %Scenic.Primitive{module: Scenic.Primitive.Text, data: text} = p,
        x,
        y,
        _w,
        _h
      ) do
    styles = Map.get(p, :styles, %{})
    font = styles[:font] || @default_font
    font_size = styles[:font_size] || @default_font_size
    fm = Scenic.Cache.Static.FontMetrics.get!(font)
    ascent = FontMetrics.ascent(font_size, fm)
    text(p, text, translate: {x, ascent + y})
  end

  def set_position_and_size(
        %Scenic.Primitive{data: {Scenic.Component.Button, text}} = p,
        x,
        y,
        w,
        h
      ) do
    button(p, text, translate: {x, y}, width: w, height: h)
  end

  def set_position_and_size(
        %Scenic.Primitive{data: {Scenic.Component.Input.Slider, data}} = p,
        x,
        y,
        w,
        h
      ) do
    slider(p, data, translate: {x, y}, width: w, height: h)
  end

  def set_position_and_size(
        %Scenic.Primitive{data: {Scenic.Component.Input.Dropdown, data}} = p,
        x,
        y,
        w,
        h
      ) do
    dropdown(p, data, translate: {x, y}, width: w, height: h)
  end

  def set_position_and_size(
        %Scenic.Primitive{data: {Scenic.Component.Input.TextField, text}} = p,
        x,
        y,
        w,
        h
      ) do
    text_field(p, text, translate: {x, y}, width: w, height: h)
  end

  def set_position_and_size(p, _x, _y, _w, _h) do
    p
  end

  def set_positions_and_sizes(graph, system, cw_map, root_id) do
    case Map.get(cw_map, root_id) do
      nil -> graph
      root -> spas(graph, root, cw_map, system)
    end
  end

  def spas(graph, %Container{children: item_ids}, map, system) do
    Enum.reduce(item_ids, graph, fn item_id, graph ->
      item = Map.fetch!(map, item_id)
      spas(graph, item, map, system)
    end)
  end

  def spas(graph, %Widget{id: id} = widget, _map, system) do
    # look up in graph, and if exists, modify, else ignore

    case Graph.get(graph, id) do
      [_primitive_or_component] ->
        x = value?(system, widget.left)
        y = value?(system, widget.top)
        w = value?(system, widget.width)
        h = value?(system, widget.height)
        Graph.modify(graph, id, fn p -> set_position_and_size(p, x, y, w, h) end)

      _ ->
        graph
    end
  end

  def spas(graph, %Space{id: _id}, _map, _system) do
    graph
  end
end
