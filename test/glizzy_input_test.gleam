import gleam/string
import gleeunit
import lustre/element
import ui/input

pub fn main() {
  gleeunit.main()
}

pub fn input_renders_correctly_test() {
  let result =
    input.input([])
    |> element.to_readable_string

  assert string.contains(result, "<input")
  assert string.contains(result, "type=\"text\"")
}

pub fn input_has_default_classes_test() {
  let result =
    input.input([])
    |> element.to_readable_string

  assert string.contains(result, "rounded-md")
  assert string.contains(result, "border")
  assert string.contains(result, "h-10")
}

pub fn input_variant_default_test() {
  let attr = input.variant(input.Default)

  let element_with_attr = input.input([attr])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "border-input")
  assert string.contains(result, "bg-background")
}

pub fn input_variant_muted_test() {
  let attr = input.variant(input.Muted)

  let element_with_attr = input.input([attr])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "border-input")
  assert string.contains(result, "bg-muted")
}

pub fn input_size_small_test() {
  let attr = input.size(input.Small)

  let element_with_attr = input.input([attr])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-8")
  assert string.contains(result, "text-xs")
}

pub fn input_size_medium_test() {
  let attr = input.size(input.Medium)

  let element_with_attr = input.input([attr])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-10")
}

pub fn input_size_large_test() {
  let attr = input.size(input.Large)

  let element_with_attr = input.input([attr])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-11")
  assert string.contains(result, "text-base")
}
