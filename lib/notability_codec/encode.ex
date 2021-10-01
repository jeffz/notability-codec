defmodule NotabilityCodec.Encode do
  def to_svg(
        page_width,
        curves_points,
        curves_num_points,
        curves_colors,
        curves_width,
        curves_fractional_widths
      ) do
    str = "<svg viewBox=\"0 0 #{page_width} 2000\">"

    # s =
    # curves_points
    # |> Enum.map(fn {x, y} -> "L #{Float.round(x, 2)} #{Float.round(y, 2)}" end)
    # |> Enum.join(" ")

    curves_starts = [
      0
      | Enum.scan(curves_num_points, 0, fn num_points, acc ->
          num_points + acc
        end)
    ]

    points_in_curves =
      curves_num_points
      |> Enum.with_index()
      |> Enum.map(fn {num_points, ind} ->
        Enum.slice(curves_points, Enum.at(curves_starts, ind), num_points)
      end)

    fractional_widths_starts = [
      0
      | Enum.scan(curves_num_points, 0, fn num_points, acc ->
          Kernel.max(Integer.floor_div(num_points, 3) + 1, 2) + acc
        end)
    ]

    IO.puts("\n🔥 fractional_widths_starts")
    IO.inspect(fractional_widths_starts)

    fractional_widths_in_curves =
      curves_num_points
      |> Enum.map(fn num_points -> Kernel.max(Integer.floor_div(num_points, 3) + 1, 2) end)
      |> Enum.with_index()
      |> Enum.map(fn {num_fractional_widths, ind} ->
        Enum.slice(
          curves_fractional_widths,
          Enum.at(fractional_widths_starts, ind),
          num_fractional_widths
        )
      end)

    IO.puts("\n🔥 fractional_widths_in_curves")
    IO.inspect(fractional_widths_in_curves)

    IO.puts("\n🔥 length(fractional_widths_in_curves")
    IO.inspect(length(fractional_widths_in_curves))

    paths =
      Enum.zip([points_in_curves, curves_colors, curves_width, fractional_widths_in_curves])
      |> Enum.map(&to_path(&1))
      |> Enum.join("")

    # curves_num_points
    # |> Enum.map(fn num_points -> Kernel.max(Integer.floor_div(num_points, 3) + 1, 2) end)
    # |> IO.inspect()
    # |> Enum.sum()
    # |> IO.inspect()

    output = str <> paths <> "</svg>"
    File.write("out.html", output)
  end

  def to_path({points, color, stroke_width, fractional_widths}) do
    {a, b, g, r} = color
    opacityPerc = a/255

    fractional_widths_str = fractional_widths |> Enum.join(" ")

    IO.puts("\n🔥 fractional_widths_str")
    IO.inspect(fractional_widths_str)

    str =
      "<path stroke-width=\"#{stroke_width}\" stroke=\"rgba(#{r}, #{g}, #{b}, #{a})\" fill=\"none\" opacity=\"#{opacityPerc}\" stroke-profile=\"#{
        fractional_widths_str
      }\" d=\""

    s =
      points
      |> Enum.map(fn {x, y} -> "L #{Float.round(x, 2)} #{Float.round(y, 2)}" end)
      |> Enum.join(" ")

    {x_0, y_0} = List.first(points)

    str <> "M #{Float.round(x_0, 2)} #{Float.round(y_0, 2)} " <> s <> " \"/>"
  end
end
