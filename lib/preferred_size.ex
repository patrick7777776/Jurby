defmodule Jurby.PreferredSize do
  @default_font_size 20
  @default_font :roboto

  def preferred_size?(%Scenic.Primitive{data: {Scenic.Component.Button, text}} = button) do
    styles = Map.get(button, :styles, %{})

    font = @default_font
    font_size = styles[:button_font_size] || @default_font_size
    fm = Scenic.Cache.Static.FontMetrics.get!(font)
    ascent = FontMetrics.ascent(font_size, fm)
    fm_width = FontMetrics.width(text, font_size, fm)

    width =
      case styles[:width] do
        width when is_number(width) and width > 0 -> width
        _ -> fm_width + ascent + ascent
      end

    height =
      case styles[:height] do
        height when is_number(height) and height > 0 -> height
        _ -> font_size + ascent
      end

    {width, height, []}
  end

  def preferred_size?(%Scenic.Primitive{data: {Scenic.Component.Input.Slider, _}} = slider) do
    styles = Map.get(slider, :styles, %{})
    {styles[:width] || 300, 18, []}
  end

  def preferred_size?(
        %Scenic.Primitive{data: {Scenic.Component.Input.Dropdown, {items, _}}} = dropdown
      ) do
    styles = Map.get(dropdown, :styles, %{})

    fm = Scenic.Cache.Static.FontMetrics.get!(@default_font)
    ascent = FontMetrics.ascent(@default_font_size, fm)

    fm_width =
      Enum.reduce(items, 0, fn {text, _}, w ->
        width = FontMetrics.width(text, @default_font_size, fm)

        max(w, width)
      end)

    width =
      case styles[:width] do
        width when is_number(width) and width > 0 -> width
        _ -> fm_width + ascent * 3
      end

    height =
      case styles[:height] do
        height when is_number(height) and height > 0 -> height
        _ -> @default_font_size + ascent
      end

    {width, height, []}
  end

  def preferred_size?(%Scenic.Primitive{
        data: {width, height},
        module: Scenic.Primitive.Rectangle
      }) do
    {width, height, []}
  end

  def preferred_size?(
        %Scenic.Primitive{data: {Scenic.Component.Input.TextField, _text}} = text_field
      ) do
    styles = Map.get(text_field, :styles, %{})

    {styles[:width] || styles[:w] || 240, styles[:height] || styles[:h] || 33,
     [hug_width: :weak, limit_width: :ignore, resist_width: :strong]}
  end

  def preferred_size?(
        %Scenic.Primitive{
          data: text,
          module: Scenic.Primitive.Text
        } = t
      ) do
    # for now assume one line of text only...

    styles = Map.get(t, :styles, %{})
    font = styles[:font] || @default_font
    font_size = styles[:font_size] || @default_font_size
    fm = Scenic.Cache.Static.FontMetrics.get!(font)
    ascent = FontMetrics.ascent(font_size, fm)

    width = FontMetrics.width(text, font_size, fm)

    width =
      case styles[:width] do
        width when is_number(width) and width > 0 -> width
        _ -> width
      end

    height =
      case styles[:height] do
        height when is_number(height) and height > 0 -> height
        _ -> font_size + ascent
      end

    {width, height, []}
  end

  def preferred_size?(_widget) do
    {40, 20}
  end
end
