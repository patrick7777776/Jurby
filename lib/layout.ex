defmodule Layout do
  alias Scenic.Graph
  import Furlong.Constraint
  import Furlong.Solver
  import Jurby.Modifier, only: [set_positions_and_sizes: 4]
  import Jurby.LayoutSpec
  alias Jurby.Container
  alias Jurby.Widget
  alias Jurby.Space
  import Jurby.AdditionalConstraints

  def layout(
        %Graph{} = graph,
        width,
        height,
        spec,
        additional_constraints \\ []
      ) do
    {root_id, cw_map} = create_container_hierarchy(graph, spec)

    system = gather_constraints(root_id, cw_map)

    root = Map.fetch!(cw_map, root_id)

    system =
      system
      |> add_constraint(constraint(root.left == 0))
      |> add_constraint(constraint(root.top == 0))
      |> add_constraint(constraint(root.right == width))
      |> add_constraint(constraint(root.bottom == height))

    system = add_additional_constraints(system, cw_map, additional_constraints)

    set_positions_and_sizes(graph, system, cw_map, root_id)
  end

  defp gather_constraints(root_id, cw_map) do
    system = new()

    case Map.get(cw_map, root_id) do
      nil -> system
      root -> gc(root, cw_map, system, nil)
    end
  end

  defp gc(%Container{children: item_ids, type: type, opts: opts} = c, map, system, _parent_type) do
    # universal container constraints

    left_margin = Keyword.get(opts, :left_margin, 0)
    top_margin = Keyword.get(opts, :top_margin, 0)
    right_margin = Keyword.get(opts, :right_margin, 0)
    bottom_margin = Keyword.get(opts, :bottom_margin, 0)

    system =
      Enum.reduce(
        [
          {constraint(c.right == c.left + c.width), :required},
          {constraint(c.bottom == c.top + c.height), :required},
          {constraint(c.h_mid == c.left + c.width / 2), :required},
          {constraint(c.v_mid == c.top + c.height / 2), :required},
          {constraint(c.contents_left == c.left + left_margin), :required},
          {constraint(c.contents_top == c.top + top_margin), :required},
          {constraint(c.contents_right == c.right - right_margin), :required},
          {constraint(c.contents_bottom == c.bottom - bottom_margin), :required},
          {constraint(c.contents_width == c.contents_right - c.contents_left), :required},
          {constraint(c.contents_height == c.contents_bottom - c.contents_top), :required},
          {constraint(c.contents_h_mid == c.contents_left + c.contents_width / 2), :required},
          {constraint(c.contents_v_mid == c.contents_top + c.contents_height / 2), :required}
        ],
        system,
        fn {con, str}, sys -> add_constraint(sys, con, str) end
      )

    if length(item_ids) > 0 do
      first_id = hd(item_ids)
      last_id = List.last(item_ids)
      first = Map.fetch!(map, first_id)
      last = Map.fetch!(map, last_id)

      {left, contents_left, right, contents_right, top, contents_top, bottom, contents_bottom,
       contents_width} =
        if type == :hbox do
          {:left, :contents_left, :right, :contents_right, :top, :contents_top, :bottom,
           :contents_bottom, :contents_width}
        else
          IO.puts("vbox...")

          {:top, :contents_top, :bottom, :contents_bottom, :left, :contents_left, :right,
           :contents_right, :contents_height}
        end

      # anchor first item in container
      system =
        if Keyword.get(opts, :pin_first, true) do
          add_constraint(system, constraint(first[left] == c[contents_left]), :required)
        else
          add_constraint(system, constraint(first[left] >= c[contents_left]), :required)
        end

      # anchor last item in container
      system =
        if Keyword.get(opts, :pin_last, false) do
          # TODO: why no worky!?
          system
          |> add_constraint(constraint(last[right] == c[contents_right]), :required)
        else
          flex = make_ref()

          system
          |> add_constraint(constraint(last[right] + flex == c[contents_right]), :required)
          |> add_constraint(constraint(flex == c[contents_width]), :medium)
        end

      # chain items together
      system =
        Enum.chunk_every(item_ids, 2, 1, :discard)
        |> Enum.reduce(system, fn [id1, id2], system ->
          item1 = Map.fetch!(map, id1)
          item2 = Map.fetch!(map, id2)
          add_constraint(system, constraint(item1[right] == item2[left] + 1))
        end)

      # TODO: depending on opts, add 'full height/width' constraints or just align with top/left edge
      system =
        Enum.reduce(item_ids, system, fn item_id, system ->
          item = Map.fetch!(map, item_id)

          system
          |> add_constraint(constraint(item[top] == c[contents_top]))
          |> add_constraint(constraint(item[bottom] >= c[contents_top]))
          |> add_constraint(constraint(item[bottom] <= c[contents_bottom]))
        end)

      # collect items' constraints
      system =
        Enum.reduce(item_ids, system, fn item_id, system ->
          case Map.get(map, item_id) do
            nil -> system
            container_or_widget -> gc(container_or_widget, map, system, type)
          end
        end)

      system
    else
      system
    end
  end

  defp gc(%Widget{opts: opts} = w, _map, system, _parent_type) do
    [
      {constraint(w.right == w.left + w.width), :required},
      {constraint(w.bottom == w.top + w.height), :required},
      {constraint(w.h_mid == w.left + w.width / 2), :required},
      {constraint(w.v_mid == w.top + w.height / 2), :required},
      {constraint(w.width == w.preferred_width), Keyword.get(opts, :hug_width, :strong)},
      {constraint(w.height == w.preferred_height), Keyword.get(opts, :hug_height, :strong)},
      {constraint(w.width >= w.preferred_width), Keyword.get(opts, :resist_width, :strong)},
      {constraint(w.height >= w.preferred_height), Keyword.get(opts, :resist_height, :strong)},
      {constraint(w.width <= w.preferred_width), Keyword.get(opts, :limit_width, :ignore)},
      {constraint(w.height <= w.preferred_height), Keyword.get(opts, :limit_height, :ignore)},
      {constraint(w.width >= 0), :strong},
      {constraint(w.height >= 0), :Strong}
    ]
    |> Enum.filter(fn {_, strength} -> strength in [:required, :strong, :medium, :weak] end)
    |> Enum.reduce(system, fn {con, str}, sys -> add_constraint(sys, con, str) end)
  end

  defp gc(%Space{size: size, type: type} = w, _map, system, parent_type) do
    system =
      [
        {constraint(w.right == w.left + w.width), :required},
        {constraint(w.bottom == w.top + w.height), :required},
        {constraint(w.h_mid == w.left + w.width / 2), :required},
        {constraint(w.v_mid == w.top + w.height / 2), :required}
      ]
      |> Enum.reduce(system, fn {con, str}, sys -> add_constraint(sys, con, str) end)

    dim =
      if parent_type == :hbox do
        :width
      else
        :height
      end

    case type do
      :static ->
        system
        |> add_constraint(constraint(w[dim] == size))

      :grow ->
        system
        |> add_constraint(constraint(w[dim] >= size))
        # TODO: should use parent width
        |> add_constraint(constraint(w[dim] >= 10000), :weak)
    end
  end
end
