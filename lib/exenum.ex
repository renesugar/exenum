###=========================================================================
### File: ExEnum.ex
###
### A simple enumeration library for Elixir.
###
### Author(s):
###   - Enrique Fernandez <efcasado(at)gmail.com>
###=========================================================================
defmodule ExEnum do

  ##== Preamble ===========================================================
  @moduledoc """
  A simple enumeration library for Elixir.

  Just add **use ExEnum, from: [ ... ]** to your module and it will
  automagically acquire the following functionality:

  - Ability to list all the values in the enumeration
  - Ability to check if an arbitrary value belongs to the enumeration
  - Ability to access a value from the enumeration via a dedicated accessor
  function
  - Ability to list all the keys that can be used to access each of the
  enumeration values

  This functionality is realised by means of the following functions:
  **values/0**, **is_valid?/1**, **keys/0** and **\<key>/0**. Note that
  your module will have as many **\<key>/0** functions as enumeration
  values are in the `use ExEnum, from: [ ... ]` clause.

  ## Example(s)

  ```elixir
  defmodule Planet do
    use ExEnum, from: [
      "MERCURY",
      "VENUS",
      "EARTH",
      "MARS",
      "JUPITER",
      "SATURN",
      "URANUS",
      "NEPTUNE"
    ]
  end

  Planet._MERCURY
  # => "MERCURY"

  Planet.values
  # => ["MERCURY", "VENUS", "EARTH", "MARS", "JUPITER",
  #     "SATURN", "URANUS", "NEPTUNE"]

  Planet.keys
  # => [:_MERCURY, :_VENUS, :_EARTH, :_MARS, :_JUPITER,
  #     :SATURN, :_URANUS, :_NEPTUNE]

  Planet.is_valid?("PLUTO")
  # => false
  ```

  ```elixir
  defmodule Direction do
    use ExEnum, from: [
      {:north, 1},
      {:east, 2},
      {:south, 3},
      {:west, 4}
    ]
  end

  Direction.north
  # => 1

  Direction.values
  # => [1, 2, 3, 4]

  Direction.keys
  # => [:north, :east, :south, :west]

  Planets.is_valid?(:north_east)
  # => false
  ```
  """

  
  ##== API ================================================================

  # Callback invoked by `use`.
  defmacro __using__(opts) do
    data = opts[:from]

    kvs = Enum.map(
      data,
      fn({k, v}) -> {k, v}
        (v) ->
          k = to_fname(v)
        {k, v}
      end)

    ks = Keyword.keys(kvs)
    vs = Keyword.values(kvs)

    ks_f = quote do: def keys(), do: unquote(ks)
    vs_f = quote do: def values(), do: unquote(vs)
    iv_f =
      Enum.reduce(
        vs,
        [quote do: def is_valid?(_), do: false],
        fn(v, acc) ->
          f = quote do: def is_valid?(unquote(v)), do: true
          [f| acc]
        end)

    fs   =
      Enum.map(
        kvs,
        fn
          {k, v} ->
            quote do: def unquote(k)(), do: unquote(v)
        end)
    
    List.flatten([ks_f, vs_f, iv_f, fs])
  end

  
  ##== Auxiliary functions ================================================

  defp to_fname(atom) when is_atom(atom) do
    atom
  end
  defp to_fname(str) do
    String.to_atom("_" <> to_string(str))
  end

end
