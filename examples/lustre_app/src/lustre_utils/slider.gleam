// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Stateful slider component with keyboard navigation support.
////
//// Follows WAI-ARIA slider pattern with roving tabindex and arrow key navigation.
////
//// ## Usage
////
//// ```gleam
//// import lustre_utils/slider
////
//// let model = slider.init()
//// let new_model = slider.update(model, slider.Increase, current_time)
//// ```

import gleam/int
import gleam/option.{type Option, None, Some}
import lustre_utils/keyboard as keyboard
import ui/slider as ui_slider

// ============================================================================
// Types
// ============================================================================

/// Slider model containing value and state.
pub type Model {
  Model(
    value: Int,
    min: Int,
    max: Int,
    step: Int,
    page_step: Int,
    orientation: ui_slider.Orientation,
    is_focused: Bool,
  )
}

/// Slider messages for state updates.
pub type Msg {
  /// Focus the slider
  Focus
  /// Blur the slider
  Blur
  /// Decrease value by step (ArrowLeft or ArrowDown)
  Decrease
  /// Increase value by step (ArrowRight or ArrowUp)
  Increase
  /// Set to minimum value (Home)
  SetMin
  /// Set to maximum value (End)
  SetMax
  /// Increase value by page step (PageUp)
  PageIncrease
  /// Decrease value by page step (PageDown)
  PageDecrease
  /// Set the slider value directly
  SetValue(Int)
  /// Set minimum value
  SetMinValue(Int)
  /// Set maximum value
  SetMaxValue(Int)
}

// ============================================================================
// Initialization
// ============================================================================

/// Initialize a slider model with default values.
pub fn init() -> Model {
  Model(
    value: 0,
    min: 0,
    max: 100,
    step: 1,
    page_step: 10,
    orientation: ui_slider.Horizontal,
    is_focused: False,
  )
}

/// Initialize a slider with a specific value.
pub fn init_with_value(value: Int) -> Model {
  Model(
    value: value,
    min: 0,
    max: 100,
    step: 1,
    page_step: 10,
    orientation: ui_slider.Horizontal,
    is_focused: False,
  )
}

/// Initialize a slider with custom range.
pub fn init_with_range(min: Int, max: Int, value: Int) -> Model {
  let clamped_value = clamp(value, min, max)
  let range = max - min
  Model(
    value: clamped_value,
    min: min,
    max: max,
    step: 1,
    page_step: int.max(1, range / 10),
    orientation: ui_slider.Horizontal,
    is_focused: False,
  )
}

// ============================================================================
// Update
// ============================================================================

/// Update the slider state based on a message.
pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Focus -> Model(..model, is_focused: True)
    Blur -> Model(..model, is_focused: False)
    Decrease -> {
      let new_value = clamp(model.value - model.step, model.min, model.max)
      Model(..model, value: new_value)
    }
    Increase -> {
      let new_value = clamp(model.value + model.step, model.min, model.max)
      Model(..model, value: new_value)
    }
    SetMin -> Model(..model, value: model.min)
    SetMax -> Model(..model, value: model.max)
    PageIncrease -> {
      let new_value = clamp(model.value + model.page_step, model.min, model.max)
      Model(..model, value: new_value)
    }
    PageDecrease -> {
      let new_value = clamp(model.value - model.page_step, model.min, model.max)
      Model(..model, value: new_value)
    }
    SetValue(v) -> Model(..model, value: clamp(v, model.min, model.max))
    SetMinValue(m) -> {
      let new_min = int.min(m, model.max)
      let new_value = clamp(model.value, new_min, model.max)
      Model(..model, min: new_min, value: new_value)
    }
    SetMaxValue(m) -> {
      let new_max = int.max(m, model.min)
      let new_value = clamp(model.value, model.min, new_max)
      Model(..model, max: new_max, value: new_value)
    }
  }
}

/// Clamp a value between min and max.
fn clamp(value: Int, min: Int, max: Int) -> Int {
  case value {
    v if v < min -> min
    v if v > max -> max
    _ -> value
  }
}

// ============================================================================
// Getters
// ============================================================================

/// Get the current slider value.
pub fn value(model: Model) -> Int {
  model.value
}

/// Get the minimum value.
pub fn min(model: Model) -> Int {
  model.min
}

/// Get the maximum value.
pub fn max(model: Model) -> Int {
  model.max
}

/// Check if the slider is focused.
pub fn is_focused(model: Model) -> Bool {
  model.is_focused
}

/// Get the slider orientation.
pub fn orientation(model: Model) -> ui_slider.Orientation {
  model.orientation
}

/// Get the value as a percentage (0.0 to 1.0).
pub fn value_percent(model: Model) -> Float {
  let range = model.max - model.min
  case range {
    0 -> 0.0
    _ -> int.to_float(model.value - model.min) /. int.to_float(range)
  }
}

// ============================================================================
// Keyboard Navigation
// ============================================================================

/// Keymap for slider keyboard navigation.
/// Follows WAI-ARIA slider pattern:
/// - ArrowLeft/ArrowDown: Decrease value
/// - ArrowRight/ArrowUp: Increase value
/// - Home: Set to minimum value
/// - End: Set to maximum value
/// - PageUp: Increase by larger step
/// - PageDown: Decrease by larger step
pub fn keymap(key_event: keyboard.KeyEvent, orientation: ui_slider.Orientation) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.Home -> Some(SetMin)
    keyboard.End -> Some(SetMax)
    keyboard.PageUp -> Some(PageIncrease)
    keyboard.PageDown -> Some(PageDecrease)
    keyboard.ArrowLeft | keyboard.ArrowDown -> Some(Decrease)
    keyboard.ArrowRight | keyboard.ArrowUp -> Some(Increase)
    _ -> None
  }
}

/// Get the element ID for the slider.
pub fn element_id() -> String {
  "slider"
}
