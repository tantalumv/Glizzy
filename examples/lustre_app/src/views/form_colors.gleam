// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Color Controls View
////
//// Renders color picker components: color field, color slider, color area, and color swatches.

import gleam/float
import gleam/int
import gleam/list
import types.{type Model, type Msg, ColorPickerMsg}
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, none, text}
import lustre/element/html
import lustre/event
import lib/tailwind
import gleam_community/colour
import lustre_utils/color_picker as cp_utils
import ui/color_area
import ui/color_field
import ui/color_slider
import ui/color_swatch_picker
import ui/size

pub fn view_color_controls(model: Model) -> Element(Msg) {
  let cp_model = model.color_picker
  let is_valid = cp_utils.is_valid_input(cp_model)
  let hue = cp_utils.hue(cp_model)
  let saturation = cp_utils.saturation(cp_model)
  let lightness = cp_utils.lightness(cp_model)
  let input_val = cp_utils.input_value(cp_model)
  let color = cp_utils.color(cp_model)

  tailwind.vstack_md([
    tailwind.section_heading("Color Inputs"),
    tailwind.gap_4([
      html.div(
        [
          class("space-y-2"),
          attribute("data-testid", "color-field-block"),
        ],
        [
          html.label([class("text-sm font-medium")], [text("Color field")]),
          color_field.color_field([], [
            color_field.input(
              [
                attribute("value", input_val),
                event.on_input(fn(val) {
                  ColorPickerMsg(cp_utils.InputChanged(val))
                }),
                event.on_blur(ColorPickerMsg(cp_utils.InputCommitted(input_val))),
              ]
              |> list.append(case is_valid {
                True -> []
                False -> [color_field.invalid()]
              }),
            ),
            color_field.swatch([
              attribute("style", "background-color: " <> input_val),
            ]),
          ]),
          tailwind.helper_text_text("Type hex values (e.g., #a855f7). Live preview shown in swatch."),
          case is_valid {
            True -> none()
            False ->
              html.p([class("text-xs text-destructive mt-1")], [
                text("Invalid color format"),
              ])
          },
        ],
      ),
      html.div(
        [
          class("space-y-2"),
          attribute("data-testid", "color-slider-block"),
        ],
        [
          html.label([class("text-sm font-medium")], [text("Color slider")]),
          html.div([class("relative h-4")], [
            color_slider.track([
              attribute("id", "color-slider-track"),
            ]),
            color_slider.slider_input([
              attribute("data-testid", "color-slider"),
              attribute("role", "slider"),
              attribute("aria-label", "Color hue"),
              attribute("aria-valuemin", "0"),
              attribute("aria-valuemax", "360"),
              attribute("aria-valuenow", float.to_string(hue)),
              attribute("value", float.to_string(hue)),
              attribute("style", "position: absolute; inset: 0; width: 100%; height: 100%; margin: 0; pointer-events: none; opacity: 0"),
              event.on_input(fn(val) {
                case float.parse(val) {
                  Ok(h) -> ColorPickerMsg(cp_utils.HueChanged(h))
                  Error(_) -> ColorPickerMsg(cp_utils.HueChanged(0.0))
                }
              }),
              event.on_keydown(fn(key) {
                ColorPickerMsg(cp_utils.SliderKeyDown(key))
              }),
            ]),
          ]),
          tailwind.helper_text_text("Drag slider or use arrow keys. Current: " <> int.to_string(float.round(hue)) <> "°"),
        ],
      ),
      html.div(
        [
          class("space-y-2"),
          attribute("data-testid", "color-area-block"),
        ],
        [
          html.label([class("text-sm font-medium")], [text("Color area")]),
          color_area.color_area(
            [
              attribute("id", "color-area-surface"),
              attribute("data-testid", "color-area"),
              attribute("aria-label", "Color area"),
              color_area.background(hue),
              color_area.size(size.Medium),
              attribute("tabindex", "0"),
              event.on_keydown(fn(key) {
                ColorPickerMsg(cp_utils.AreaKeyDown(key))
              }),
            ],
            [
              color_area.thumb([
                attribute(
                  "style",
                  "position: absolute; left: "
                    <> float.to_string(saturation)
                    <> "%; "
                    <> "top: "
                    <> float.to_string(100.0 -. lightness)
                    <> "%",
                ),
              ]),
            ],
          ),
          tailwind.helper_text_text("Drag or use arrow keys. S: " <> int.to_string(float.round(saturation)) <> "% L: " <> int.to_string(float.round(lightness)) <> "%"),
        ],
      ),
    ]),
    html.div([class("grid gap-4 md:grid-cols-3")], [
      html.div(
        [
          class("space-y-2"),
          attribute("data-testid", "color-swatches-block"),
        ],
        [
          html.label([class("text-sm font-medium")], [text("Color swatches")]),
          color_swatch_picker.color_swatch_picker([], [
            color_swatch_picker.swatch_option(
              [
                attribute("style", "background-color: #ef2929"),
                attribute("aria-checked", case color == colour.light_red {
                  True -> "true"
                  False -> "false"
                }),
                attribute("aria-label", "Light red"),
                event.on_click(ColorPickerMsg(cp_utils.SwatchSelected(colour.light_red))),
              ],
              [],
            ),
            color_swatch_picker.swatch_option(
              [
                attribute("style", "background-color: #3465a4"),
                attribute("aria-checked", case color == colour.blue {
                  True -> "true"
                  False -> "false"
                }),
                attribute("aria-label", "Blue"),
                event.on_click(ColorPickerMsg(cp_utils.SwatchSelected(colour.blue))),
              ],
              [],
            ),
            color_swatch_picker.swatch_option(
              [
                attribute("style", "background-color: #4e9a06"),
                attribute(
                  "aria-checked",
                  case color == colour.dark_green {
                    True -> "true"
                    False -> "false"
                  },
                ),
                attribute("aria-label", "Dark green"),
                event.on_click(ColorPickerMsg(cp_utils.SwatchSelected(colour.dark_green))),
              ],
              [],
            ),
            color_swatch_picker.swatch_option(
              [
                attribute("style", "background-color: #c17d11"),
                attribute("aria-checked", case color == colour.brown {
                  True -> "true"
                  False -> "false"
                }),
                attribute("aria-label", "Brown"),
                event.on_click(ColorPickerMsg(cp_utils.SwatchSelected(colour.brown))),
              ],
              [],
            ),
          ]),
        ],
      ),
    ]),
  ])
}

pub fn view(model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    view_color_controls(model),
  ])
}
