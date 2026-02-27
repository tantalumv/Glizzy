import gleam/string
import gleeunit
import lustre/element
import ui/button

pub fn main() {
  gleeunit.main()
}

pub fn button_renders_with_text_test() {
  let result =
    button.button([], [element.text("Click me")])
    |> element.to_readable_string

  assert string.contains(result, "Click me")
  assert string.contains(result, "<button")
}

pub fn button_has_default_classes_test() {
  let result =
    button.button([], [element.text("Test")])
    |> element.to_readable_string

  assert string.contains(result, "rounded-md")
  assert string.contains(result, "font-medium")
}

pub fn button_variant_default_test() {
  let attr = button.variant(button.Default)

  let element_with_attr = button.button([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-primary")
}

pub fn button_variant_secondary_test() {
  let attr = button.variant(button.Secondary)

  let element_with_attr = button.button([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-secondary")
}

pub fn button_variant_destructive_test() {
  let attr = button.variant(button.Destructive)

  let element_with_attr = button.button([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-destructive")
}

pub fn button_size_small_test() {
  let attr = button.size(button.Small)

  let element_with_attr = button.button([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-8")
  assert string.contains(result, "text-xs")
}

pub fn button_size_medium_test() {
  let attr = button.size(button.Medium)

  let element_with_attr = button.button([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-10")
}

pub fn button_size_large_test() {
  let attr = button.size(button.Large)

  let element_with_attr = button.button([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-11")
  assert string.contains(result, "px-8")
}

pub fn button_icon_size_test() {
  let attr = button.icon()

  let element_with_attr = button.button([attr], [element.text("X")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "h-9")
  assert string.contains(result, "w-9")
}
