//// Color Picker State Management (TEA Pattern)
////
//// Provides state management for color picker components including:
//// - Color value tracking (HSL)
//// - Drag state for slider and area
//// - Input validation
////
//// ## Usage
////
//// ```gleam
//// import gleam_community/colour
//// import lustre_utils/color_picker as cp
////
//// // Initialize with a color
//// let model = cp.init(colour.purple)
////
//// // Update with messages
//// let model = cp.update(model, cp.HueChanged(180.0))
//// let model = cp.update(model, cp.AreaPointerDown(50.0, 60.0))
////
//// // Query state
//// cp.hue(model)           // 180.0
//// cp.saturation(model)    // 50.0
//// cp.lightness(model)     // 60.0
//// cp.to_hex(model)        // "#xxxxxx"
//// ```

import gleam/float
import gleam/result
import gleam_community/colour

// ============================================================================
// Types
// ============================================================================

pub type Model {
  Model(
    color: colour.Color,
    input_value: String,
    dragging_slider: Bool,
    dragging_area: Bool,
    is_open: Bool,
  )
}

pub type Msg {
  // Input
  InputChanged(String)
  InputCommitted(String)
  // Hue Slider
  HueChanged(Float)
  SliderPointerDown(Float)
  SliderPointerMove(Float)
  SliderPointerUp
  SliderKeyDown(String)
  // Color Area (Saturation/Lightness)
  AreaChanged(Float, Float)
  AreaPointerDown(Float, Float)
  AreaPointerMove(Float, Float)
  AreaPointerUp
  AreaKeyDown(String)
  // Swatches
  SwatchSelected(colour.Color)
  // Popover
  ToggleOpen
  Open
  Close
}

// ============================================================================
// Init
// ============================================================================

pub fn init(color: colour.Color) -> Model {
  Model(
    color: color,
    input_value: "#" <> colour.to_rgb_hex_string(color),
    dragging_slider: False,
    dragging_area: False,
    is_open: False,
  )
}

pub fn init_from_hex(hex: String) -> Model {
  let color = colour.from_rgb_hex_string(hex) |> result.unwrap(colour.purple)
  init(color)
}

// ============================================================================
// Update
// ============================================================================

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    // Input changed (live validation)
    InputChanged(value) -> Model(..model, input_value: value)

    // Input committed (on blur) - parse and update color
    InputCommitted(value) -> {
      case colour.from_rgb_hex_string(value) {
        Ok(new_color) ->
          Model(
            ..model,
            color: new_color,
            input_value: "#" <> colour.to_rgb_hex_string(new_color),
          )
        Error(_) -> Model(..model, input_value: value)
      }
    }

    // Hue slider changed
    HueChanged(hue) -> {
      let #(_h, s, l, _a) = colour.to_hsla(model.color)
      case colour.from_hsl(hue /. 360.0, s, l) {
        Ok(new_color) ->
          Model(
            ..model,
            color: new_color,
            input_value: "#" <> colour.to_rgb_hex_string(new_color),
          )
        Error(_) -> model
      }
    }

    // Slider pointer down
    SliderPointerDown(hue) ->
      update(Model(..model, dragging_slider: True), HueChanged(hue))

    // Slider pointer move (only when dragging)
    SliderPointerMove(hue) ->
      case model.dragging_slider {
        True -> update(model, HueChanged(hue))
        False -> model
      }

    // Slider pointer up
    SliderPointerUp -> Model(..model, dragging_slider: False)

    // Keyboard navigation for hue slider
    SliderKeyDown(key) -> {
      let #(h, _s, _l, _a) = colour.to_hsla(model.color)
      let hue_val = h *. 360.0
      case key {
        "ArrowLeft" -> update(model, HueChanged(hue_val -. 1.0))
        "ArrowRight" -> update(model, HueChanged(hue_val +. 1.0))
        _ -> model
      }
    }

    // Area changed (saturation, lightness as percentages)
    AreaChanged(saturation, lightness) -> {
      let #(h, _s, _l, _a) = colour.to_hsla(model.color)
      case colour.from_hsl(h, saturation /. 100.0, lightness /. 100.0) {
        Ok(new_color) ->
          Model(
            ..model,
            color: new_color,
            input_value: "#" <> colour.to_rgb_hex_string(new_color),
          )
        Error(_) -> model
      }
    }

    // Area pointer down
    AreaPointerDown(saturation, lightness) ->
      update(
        Model(..model, dragging_area: True),
        AreaChanged(saturation, lightness),
      )

    // Area pointer move (only when dragging)
    AreaPointerMove(saturation, lightness) ->
      case model.dragging_area {
        True -> update(model, AreaChanged(saturation, lightness))
        False -> model
      }

    // Area pointer up
    AreaPointerUp -> Model(..model, dragging_area: False)

    // Keyboard navigation for color area
    AreaKeyDown(key) -> {
      let #(_h, s, l, _a) = colour.to_hsla(model.color)
      let sat = s *. 100.0
      let light = l *. 100.0
      case key {
        "ArrowUp" -> update(model, AreaChanged(sat, light +. 2.0))
        "ArrowDown" -> update(model, AreaChanged(sat, light -. 2.0))
        "ArrowLeft" -> update(model, AreaChanged(sat -. 2.0, light))
        "ArrowRight" -> update(model, AreaChanged(sat +. 2.0, light))
        _ -> model
      }
    }

    // Swatch selected
    SwatchSelected(new_color) ->
      Model(
        ..model,
        color: new_color,
        input_value: "#" <> colour.to_rgb_hex_string(new_color),
      )

    // Toggle popover
    ToggleOpen -> Model(..model, is_open: !model.is_open)
    Open -> Model(..model, is_open: True)
    Close -> Model(..model, is_open: False)
  }
}

// ============================================================================
// Query Functions
// ============================================================================

pub fn color(model: Model) -> colour.Color {
  model.color
}

pub fn hue(model: Model) -> Float {
  let #(h, _s, _l, _a) = colour.to_hsla(model.color)
  h *. 360.0
}

pub fn saturation(model: Model) -> Float {
  let #(_h, s, _l, _a) = colour.to_hsla(model.color)
  s *. 100.0
}

pub fn lightness(model: Model) -> Float {
  let #(_h, _s, l, _a) = colour.to_hsla(model.color)
  l *. 100.0
}

pub fn alpha(model: Model) -> Float {
  let #(_h, _s, _l, a) = colour.to_hsla(model.color)
  a *. 100.0
}

pub fn to_hex(model: Model) -> String {
  colour.to_rgb_hex_string(model.color)
}

pub fn to_hex_with_hash(model: Model) -> String {
  "#" <> colour.to_rgb_hex_string(model.color)
}

pub fn input_value(model: Model) -> String {
  model.input_value
}

pub fn is_valid_input(model: Model) -> Bool {
  case colour.from_rgb_hex_string(model.input_value) {
    Ok(_) -> True
    Error(_) -> False
  }
}

pub fn is_open(model: Model) -> Bool {
  model.is_open
}

pub fn is_closed(model: Model) -> Bool {
  !model.is_open
}

pub fn is_dragging_slider(model: Model) -> Bool {
  model.dragging_slider
}

pub fn is_dragging_area(model: Model) -> Bool {
  model.dragging_area
}

pub fn is_dragging(model: Model) -> Bool {
  model.dragging_slider || model.dragging_area
}

// ============================================================================
// Color Conversions
// ============================================================================

pub fn hsl_values(model: Model) -> #(Float, Float, Float) {
  #(hue(model), saturation(model), lightness(model))
}

pub fn hsla_values(model: Model) -> #(Float, Float, Float, Float) {
  #(hue(model), saturation(model), lightness(model), alpha(model))
}

pub fn rgb_values(model: Model) -> #(Int, Int, Int) {
  let #(r, g, b, _a) = colour.to_rgba(model.color)
  #(float.round(r *. 255.0), float.round(g *. 255.0), float.round(b *. 255.0))
}

// ============================================================================
// Helper Functions
// ============================================================================

pub fn set_color(model: Model, new_color: colour.Color) -> Model {
  Model(
    ..model,
    color: new_color,
    input_value: "#" <> colour.to_rgb_hex_string(new_color),
  )
}

pub fn set_hue(model: Model, hue_val: Float) -> Model {
  update(model, HueChanged(hue_val))
}

pub fn set_saturation_lightness(model: Model, sat: Float, light: Float) -> Model {
  update(model, AreaChanged(sat, light))
}
