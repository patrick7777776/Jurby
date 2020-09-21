defmodule Jurby.AdditionalConstraints do
  import Furlong.Constraint
  import Furlong.Solver

  def same(anchor, ids) do
    {:same, anchor, ids}
  end

  def add_additional_constraints(system, map, constraint_specs) do
    Enum.reduce(constraint_specs, system, fn c_spec, system -> aac(system, map, c_spec) end)
  end

  defp aac(system, map, {:same, anchor, ids}) do
    ids
    |> Enum.map(fn id -> Map.fetch!(map, id) end)
    |> Enum.map(fn wrapper -> wrapper[anchor] end)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(system, fn [a1, a2], system ->
      add_constraint(system, constraint(a1 == a2))
    end)
  end
end
