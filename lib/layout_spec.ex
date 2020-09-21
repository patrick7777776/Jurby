defmodule Jurby.LayoutSpec do
  alias Scenic.Graph
  alias Jurby.LayoutSpec
  alias Jurby.Space
  import Jurby.Container
  import Jurby.Widget
  import Jurby.PreferredSize, only: [preferred_size?: 1]

  defstruct type: nil, items: [], opts: []

  def hbox(items, opts \\ []), do: new(:hbox, items, opts)

  def vbox(items, opts \\ []), do: new(:vbox, items, opts)

  defp new(type, items, opts) do
    %LayoutSpec{
      type: type,
      items: items,
      opts: opts
    }
  end

  # yields root_id + map id -> container/widget
  def create_container_hierarchy(graph, spec) do
    ccaw(graph, spec, %{})
  end

  defp ccaw(graph, %Jurby.LayoutSpec{type: type, items: items, opts: opts}, map) do
    container_id = opts[:id] || make_ref()

    # process items
    {item_ids, map} =
      Enum.reduce(items, {[], map}, fn item, {item_acc, map} ->
        {item_id, m2} = ccaw(graph, item, map)
        {[item_id | item_acc], m2}
      end)

    item_ids = Enum.reverse(item_ids)

    container = container(container_id, type, item_ids, opts)
    {container_id, Map.put(map, container_id, container)}
  end

  defp ccaw(_graph, %Space{id: id} = space, map) do
    {id, Map.put(map, id, space)}
  end

  defp ccaw(graph, id, map) do
    case Graph.get(graph, id) do
      [primitive_or_component] ->
        {w, h, opts} = preferred_size?(primitive_or_component)
        {id, Map.put(map, id, widget(id, w, h, opts))}

      _ ->
        {nil, map}
    end
  end
end
