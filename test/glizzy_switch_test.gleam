import gleam/string
import gleeunit
import lustre/element
import ui/switch

pub fn main() {
  gleeunit.main()
}

pub fn switch_renders_with_label_test() {
  let result =
    switch.switch([], [element.text("Enable")])
    |> element.to_readable_string

  assert string.contains(result, "Enable")
  assert string.contains(result, "<input")
  assert string.contains(result, "type=\"checkbox\"")
}

pub fn switch_has_hidden_checkbox_class_test() {
  let result =
    switch.switch([], [element.text("Test")])
    |> element.to_readable_string

  assert string.contains(result, "sr-only")
}

pub fn switch_has_visual_classes_test() {
  let result =
    switch.switch([], [element.text("Test")])
    |> element.to_readable_string

  assert string.contains(result, "rounded-full")
  assert string.contains(result, "transition-colors")
  assert string.contains(result, "h-6")
  assert string.contains(result, "w-11")
}

pub fn switch_variant_default_test() {
  let attr = switch.variant(switch.Default)

  let element_with_attr = switch.switch([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-primary")
}

pub fn switch_variant_muted_test() {
  let attr = switch.variant(switch.Muted)

  let element_with_attr = switch.switch([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-muted")
}

pub fn switch_size_small_test() {
  let attr = switch.size(switch.Small)

  let element_with_attr = switch.switch([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-5")
  assert string.contains(result, "w-9")
}

pub fn switch_size_medium_test() {
  let attr = switch.size(switch.Medium)

  let element_with_attr = switch.switch([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-6")
  assert string.contains(result, "w-11")
}

pub fn switch_size_large_test() {
  let attr = switch.size(switch.Large)

  let element_with_attr = switch.switch([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-7")
}
