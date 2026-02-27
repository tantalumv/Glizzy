// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/float

// ============================================================================
// Color Slider Helpers (x position to hue)
// ============================================================================

/// Convert x position to hue value (0-360 degrees)
/// The slider spans the full hue spectrum from 0 to 360 degrees
pub fn x_to_hue(x: Float, width: Float) -> Float {
  case width >. 0.0 {
    True -> {
      let ratio = x /. width
      ratio *. 360.0
      |> float.max(0.0)
      |> float.min(360.0)
    }
    False -> 0.0
  }
}

/// Convert hue to x position for thumb placement
pub fn hue_to_x(hue: Float, width: Float) -> Float {
  case width >. 0.0 {
    True -> {
      let ratio = hue /. 360.0
      ratio *. width
      |> float.max(0.0)
      |> float.min(width)
    }
    False -> 0.0
  }
}

/// Adjust hue by a delta value with sensitivity control
/// Useful for drag-based hue adjustment using delta_x from move events
pub fn hue_by_delta(hue: Float, delta_x: Float, sensitivity: Float) -> Float {
  let new_hue = hue +. delta_x *. sensitivity
  // Wrap hue to 0-360 range
  case new_hue <. 0.0 {
    True -> 360.0 +. new_hue
    False ->
      case new_hue >. 360.0 {
        True -> new_hue -. 360.0
        False -> new_hue
      }
  }
}

// ============================================================================
// Color Area Helpers (x,y position to saturation/lightness)
// ============================================================================

/// Convert x,y position to saturation and lightness values
/// X axis represents saturation (0-100%)
/// Y axis represents lightness (0-100%, inverted - top is light, bottom is dark)
pub fn xy_to_saturation_lightness(
  x: Float,
  y: Float,
  width: Float,
  height: Float,
) -> #(Float, Float) {
  let saturation = case width >. 0.0 {
    True -> {
      let ratio = x /. width
      ratio *. 100.0
      |> float.max(0.0)
      |> float.min(100.0)
    }
    False -> 0.0
  }

  // Invert Y axis: top (y=0) = light (100%), bottom (y=height) = dark (0%)
  let lightness = case height >. 0.0 {
    True -> {
      let ratio = 1.0 -. { y /. height }
      ratio *. 100.0
      |> float.max(0.0)
      |> float.min(100.0)
    }
    False -> 0.0
  }

  #(saturation, lightness)
}

/// Convert saturation and lightness to x,y position for thumb placement
pub fn saturation_lightness_to_xy(
  saturation: Float,
  lightness: Float,
  width: Float,
  height: Float,
) -> #(Float, Float) {
  let x = case width >. 0.0 {
    True -> {
      let ratio = saturation /. 100.0
      ratio *. width
      |> float.max(0.0)
      |> float.min(width)
    }
    False -> 0.0
  }

  // Invert Y axis for display
  let y = case height >. 0.0 {
    True -> {
      let ratio = 1.0 -. { lightness /. 100.0 }
      ratio *. height
      |> float.max(0.0)
      |> float.min(height)
    }
    False -> 0.0
  }

  #(x, y)
}

/// Adjust saturation and lightness by delta values with sensitivity control
/// Useful for drag-based color adjustment using delta_x/delta_y from move events
pub fn saturation_lightness_by_delta(
  saturation: Float,
  lightness: Float,
  delta_x: Float,
  delta_y: Float,
  sensitivity: Float,
) -> #(Float, Float) {
  let new_saturation =
    saturation +. delta_x *. sensitivity
    |> float.max(0.0)
    |> float.min(100.0)

  let new_lightness =
    lightness +. delta_y *. sensitivity
    |> float.max(0.0)
    |> float.min(100.0)

  #(new_saturation, new_lightness)
}
