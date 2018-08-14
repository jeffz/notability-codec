defmodule NotabilityCodec.Decode do
  # unzips .note file and stores in memory
  def open_note(filename) do
    if File.exists?(filename) do
      filename
      |> :binary.bin_to_list()
      |> :zip.zip_open([:memory])
    else
      {:error, :enoent}
    end
  end

  def get_files(zip_handle) do
    {:ok, files} = :zip.zip_get(zip_handle)
  end

  def read_session(binary_plist) do
    plist_map = binary_plist |> Plist.Binary.parse()

    # I think the only important thing here is objects
    objects = plist_map["$objects"]
    IO.puts("\nobjects")
    IO.inspect(objects)

    page_width =
      objects
      |> Enum.find(fn el -> is_map(el) && Map.has_key?(el, "pageWidthInDocumentCoordsKey") end)
      |> Map.get("pageWidthInDocumentCoordsKey")

    curves_object =
      objects
      |> Enum.filter(fn el -> is_map(el) && Map.has_key?(el, "curvespoints") end)
      |> List.first()

    IO.puts("\n🔥 curves_object")
    IO.inspect(curves_object)

    curves_points =
      curves_object
      |> Map.get("curvespoints")
      |> parse_binary_as_32_bit_float_array
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    curves_num_points =
      curves_object
      |> Map.get("curvesnumpoints")
      |> parse_binary_as_32_bit_integer_array

    # |> Enum.chunk_every(2)
    # |> Enum.map(&List.to_tuple(&1))
    IO.puts("\ncurves_num_points")
    IO.inspect(curves_num_points)

    curves_colors =
      curves_object
      |> Map.get("curvescolors")
      |> parse_binary_as_32_bit_rgba_array

    require IEx

    curves_width =
      curves_object
      |> Map.get("curveswidth")
      |> parse_binary_as_32_bit_float_array

    IO.puts("\n🔥 curves_width")
    IO.inspect(length(curves_width))

    curves_fractional_widths =
      curves_object
      |> Map.get("curvesfractionalwidths")
      |> parse_binary_as_32_bit_float_array()

    IO.puts("\n🔥 curves_fractional_widths")
    IO.inspect(curves_fractional_widths)

    IO.puts("\n🔥 Enum.sum(curves_num_points)")
    IO.inspect(Enum.sum(curves_num_points))

    require(IEx)

    IO.puts("\n🔥 length(curves_num_points)")
    IO.inspect(length(curves_num_points))

    IO.puts("\n🔥 length(curves_points)")
    IO.inspect(length(curves_points))

    IO.puts("\n🔥 length(curves_fractional_widths)")
    IO.inspect(length(curves_fractional_widths))

    IO.puts("\n🔥 length(curves_width))")
    IO.inspect(length(curves_width))

    NotabilityCodec.Encode.to_svg(
      page_width,
      curves_points,
      curves_num_points,
      curves_colors,
      curves_width,
      curves_fractional_widths
    )
  end

  defp parse_binary_as_32_bit_float_array(b) do
    b
    |> :binary.bin_to_list()
    |> Enum.chunk_every(4)
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&:binary.list_to_bin(&1))
    |> Enum.map(fn bin ->
      <<a::float-size(32)>> = bin
      a
    end)
  end

  defp parse_binary_as_32_bit_integer_array(b) do
    b
    |> :binary.bin_to_list()
    |> Enum.chunk_every(4)
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&:binary.list_to_bin(&1))
    |> Enum.map(fn bin ->
      <<a::integer-size(32)>> = bin
      a
    end)
  end

  defp parse_binary_as_32_bit_rgba_array(b) do
    b
    |> :binary.bin_to_list()
    |> Enum.chunk_every(4)
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.map(&List.to_tuple(&1))
  end
end
