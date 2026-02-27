import gleam/string
import gleeunit
import lustre/element
import ui/badge

pub fn main() {
  gleeunit.main()
}

pub fn badge_renders_with_text_test() {
  let result =
    badge.badge([], [element.text("New")])
    |> element.to_readable_string

  assert string.contains(result, "New")
  assert string.contains(result, "<span")
}

pub fn badge_has_default_classes_test() {
  let result =
    badge.badge([], [element.text("Test")])
    |> element.to_readable_string

  assert string.contains(result, "rounded-full")
  assert string.contains(result, "inline-flex")
}

pub fn badge_variant_default_test() {
  let attr = badge.variant(badge.Default)

  let element_with_attr = badge.badge([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-primary")
}

pub fn badge_variant_secondary_test() {
  let attr = badge.variant(badge.Secondary)

  let element_with_attr = badge.badge([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-secondary")
}

pub fn badge_variant_destructive_test() {
  let attr = badge.variant(badge.Destructive)

  let element_with_attr = badge.badge([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "bg-destructive")
}

pub fn badge_variant_outline_test() {
  let attr = badge.variant(badge.Outline)

  let element_with_attr = badge.badge([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "border")
}

pub fn badge_size_small_test() {
  let attr = badge.size(badge.Small)

  let element_with_attr = badge.badge([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "px-2")
  assert string.contains(result, "text-xs")
}

pub fn badge_size_medium_test() {
  let attr = badge.size(badge.Medium)

  let element_with_attr = badge.badge([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "px-2.5")
}

pub fn badge_size_large_test() {
  let attr = badge.size(badge.Large)

  let element_with_attr = badge.badge([attr], [element.text("Test")])
  let result = element_with_attr |> element.to_readable_string

  assert string.contains(result, "px-3")
  assert string.contains(result, "text-base")
}
