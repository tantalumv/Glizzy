//// Tailwind CSS Helper Functions
////
//// Reusable helper functions for common Tailwind CSS patterns.
//// These helpers provide type-safe, DRY alternatives to repeated class strings.
////
//// Example usage:
//// ```gleam
//// import lib/tailwind
////
//// // Instead of: h2([class("text-xl font-semibold")], [text("Title")])
//// tailwind.section_heading("My Title")
////
//// // Instead of: div([class("space-y-4")], [...])
//// tailwind.vstack_md([...])
//// ```

import gleam/int
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h2, label as html_label, p}

// ============================================================================
// Typography Helpers
// ============================================================================

/// Section heading - used 38 times
/// Replaces: h2([class("text-xl font-semibold")], [text("Title")])
pub fn section_heading(label: String) -> Element(a) {
  h2([class("text-xl font-semibold")], [text(label)])
}

/// Section heading with custom content
pub fn section_heading_custom(elements: List(Element(a))) -> Element(a) {
  h2([class("text-xl font-semibold")], elements)
}

/// Section description - used 30+ times
/// Replaces: p([class("text-sm text-muted-foreground")], [...])
pub fn section_description(elements: List(Element(a))) -> Element(a) {
  p([class("text-sm text-muted-foreground")], elements)
}

/// Section description with single text
pub fn section_description_text(label: String) -> Element(a) {
  p([class("text-sm text-muted-foreground")], [text(label)])
}

/// Helper text - used 20+ times
/// Replaces: p([class("text-xs text-muted-foreground mt-2")], [...])
pub fn helper_text(elements: List(Element(a))) -> Element(a) {
  p([class("text-xs text-muted-foreground mt-2")], elements)
}

/// Helper text with single text
pub fn helper_text_text(label: String) -> Element(a) {
  p([class("text-xs text-muted-foreground mt-2")], [text(label)])
}

/// Helper text with ID and single text
pub fn helper_text_id(id: String, label: String) -> Element(a) {
  p([class("text-xs text-muted-foreground mt-2"), attribute("id", id)], [text(label)])
}

// ============================================================================
// Layout Helpers - Vertical Spacing (Stack)
// ============================================================================

/// Vertical spacing container (small) - space-y-2
pub fn vstack_sm(elements: List(Element(a))) -> Element(a) {
  div([class("space-y-2")], elements)
}

/// Vertical spacing container (medium) - space-y-4
pub fn vstack_md(elements: List(Element(a))) -> Element(a) {
  div([class("space-y-4")], elements)
}

/// Vertical spacing container (large) - space-y-6
pub fn vstack_lg(elements: List(Element(a))) -> Element(a) {
  div([class("space-y-6")], elements)
}

/// Vertical spacing container (extra large) - space-y-8
pub fn vstack_xl(elements: List(Element(a))) -> Element(a) {
  div([class("space-y-8")], elements)
}

// ============================================================================
// Layout Helpers - Horizontal Wrap (Cluster)
// ============================================================================

/// Horizontal wrap container (small) - flex flex-wrap gap-2
pub fn hwrap_sm(elements: List(Element(a))) -> Element(a) {
  div([class("flex flex-wrap gap-2")], elements)
}

/// Horizontal wrap container (medium) - flex flex-wrap gap-4
pub fn hwrap_md(elements: List(Element(a))) -> Element(a) {
  div([class("flex flex-wrap gap-4")], elements)
}

/// Horizontal wrap container (large) - flex flex-wrap gap-6
pub fn hwrap_lg(elements: List(Element(a))) -> Element(a) {
  div([class("flex flex-wrap gap-6")], elements)
}

// ============================================================================
// Layout Helpers - Vertical Flex
// ============================================================================

/// Vertical flex container (small) - flex flex-col gap-2
pub fn vflex_sm(elements: List(Element(a))) -> Element(a) {
  div([class("flex flex-col gap-2")], elements)
}

/// Vertical flex container (medium) - flex flex-col gap-4
pub fn vflex_md(elements: List(Element(a))) -> Element(a) {
  div([class("flex flex-col gap-4")], elements)
}

/// Vertical flex container (large) - flex flex-col gap-6
pub fn vflex_lg(elements: List(Element(a))) -> Element(a) {
  div([class("flex flex-col gap-6")], elements)
}

// ============================================================================
// Layout Helpers - Row (Horizontal with Center Alignment)
// ============================================================================

/// Row with centered items (small gap) - flex items-center gap-1
pub fn row_sm(elements: List(Element(a))) -> Element(a) {
  div([class("flex items-center gap-1")], elements)
}

/// Row with centered items (medium gap) - flex items-center gap-2
pub fn row_md(elements: List(Element(a))) -> Element(a) {
  div([class("flex items-center gap-2")], elements)
}

/// Row with centered items (large gap) - flex items-center gap-4
pub fn row_lg(elements: List(Element(a))) -> Element(a) {
  div([class("flex items-center gap-4")], elements)
}

// ============================================================================
// Form Helpers
// ============================================================================

/// Form label - used ~15 times
/// Replaces: label([attribute("for", "id"), class("text-sm font-medium")], [...])
pub fn label_for(for_id: String, elements: List(Element(a))) -> Element(a) {
  html_label([attribute("for", for_id), class("text-sm font-medium")], elements)
}

/// Form label with single text
pub fn label_text(for_id: String, content: String) -> Element(a) {
  html_label([attribute("for", for_id), class("text-sm font-medium")], [
    text(content),
  ])
}

/// Form field wrapper - space-y-1
pub fn field(elements: List(Element(a))) -> Element(a) {
  div([class("space-y-1")], elements)
}

// ============================================================================
// Button Group Helpers
// ============================================================================

/// Button row with gap - flex gap-2
pub fn button_group(elements: List(Element(a))) -> Element(a) {
  div([class("flex gap-2")], elements)
}

/// Button row with right alignment - flex justify-end gap-2 mt-4
pub fn button_group_right(elements: List(Element(a))) -> Element(a) {
  div([class("flex justify-end gap-2 mt-4")], elements)
}

// ============================================================================
// Section Helpers
// ============================================================================

/// Complete section with heading and description
pub fn section(
  heading: String,
  description: String,
  content: List(Element(a)),
) -> Element(a) {
  vstack_md([
    section_heading(heading),
    section_description_text(description),
    ..content
  ])
}

/// Section with heading, no description
pub fn section_simple(heading: String, content: List(Element(a))) -> Element(a) {
  vstack_md([section_heading(heading), ..content])
}

// ============================================================================
// Utility Class Helpers
// ============================================================================

/// Text size variants
pub fn text_xs(content: String) -> Element(a) {
  p([class("text-xs")], [text(content)])
}

pub fn text_sm(content: String) -> Element(a) {
  p([class("text-sm")], [text(content)])
}

pub fn text_base(content: String) -> Element(a) {
  p([class("text-base")], [text(content)])
}

pub fn text_lg(content: String) -> Element(a) {
  p([class("text-lg")], [text(content)])
}

pub fn text_xl(content: String) -> Element(a) {
  p([class("text-xl")], [text(content)])
}

/// Font weight variants
pub fn font_normal(content: String) -> Element(a) {
  p([class("font-normal")], [text(content)])
}

pub fn font_medium(content: String) -> Element(a) {
  p([class("font-medium")], [text(content)])
}

pub fn font_semibold(content: String) -> Element(a) {
  p([class("font-semibold")], [text(content)])
}

pub fn font_bold(content: String) -> Element(a) {
  p([class("font-bold")], [text(content)])
}

/// Padding variants
pub fn p_2(element: Element(a)) -> Element(a) {
  div([class("p-2")], [element])
}

pub fn p_4(element: Element(a)) -> Element(a) {
  div([class("p-4")], [element])
}

pub fn p_6(element: Element(a)) -> Element(a) {
  div([class("p-6")], [element])
}

/// Margin variants
pub fn mt_2(element: Element(a)) -> Element(a) {
  div([class("mt-2")], [element])
}

pub fn mt_4(element: Element(a)) -> Element(a) {
  div([class("mt-4")], [element])
}

pub fn mb_2(element: Element(a)) -> Element(a) {
  div([class("mb-2")], [element])
}

pub fn mb_4(element: Element(a)) -> Element(a) {
  div([class("mb-4")], [element])
}

/// Gap variants for containers
pub fn gap_1(elements: List(Element(a))) -> Element(a) {
  div([class("gap-1")], elements)
}

pub fn gap_2(elements: List(Element(a))) -> Element(a) {
  div([class("gap-2")], elements)
}

pub fn gap_3(elements: List(Element(a))) -> Element(a) {
  div([class("gap-3")], elements)
}

pub fn gap_4(elements: List(Element(a))) -> Element(a) {
  div([class("gap-4")], elements)
}

pub fn gap_6(elements: List(Element(a))) -> Element(a) {
  div([class("gap-6")], elements)
}
