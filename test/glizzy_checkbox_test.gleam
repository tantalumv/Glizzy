import gleam/string
import gleeunit
import lustre/element
import ui/checkbox

pub fn main() {
  gleeunit.main()
}

pub fn checkbox_renders_with_label_test() {
  let result =
    checkbox.checkbox([], [element.text("I agree")])
    |> element.to_readable_string

  assert string.contains(result, "I agree")
  assert string.contains(result, "<input")
  assert string.contains(result, "type=\"checkbox\"")
}

pub fn checkbox_has_default_classes_test() {
  let result =
    checkbox.checkbox([], [element.text("Test")])
    |> element.to_readable_string

  assert string.contains(result, "h-4")
  assert string.contains(result, "w-4")
  assert string.contains(result, "rounded")
}

pub fn checkbox_variant_default_test() {
  let attr = checkbox.variant(checkbox.Default)

  let element_with_attr = checkbox.checkbox([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "border-gray-300")
}

pub fn checkbox_variant_muted_test() {
  let attr = checkbox.variant(checkbox.Muted)

  let element_with_attr = checkbox.checkbox([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "border-input")
  assert string.contains(result, "text-muted-foreground")
}

pub fn checkbox_size_small_test() {
  let attr = checkbox.size(checkbox.Small)

  let element_with_attr = checkbox.checkbox([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-3")
  assert string.contains(result, "w-3")
}

pub fn checkbox_size_medium_test() {
  let attr = checkbox.size(checkbox.Medium)

  let element_with_attr = checkbox.checkbox([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-4")
}

pub fn checkbox_size_large_test() {
  let attr = checkbox.size(checkbox.Large)

  let element_with_attr = checkbox.checkbox([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-5")
}
