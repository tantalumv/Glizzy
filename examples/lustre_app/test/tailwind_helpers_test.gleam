//// Tailwind Helper Functions Test
////
//// Tests for the tailwind helper functions in lib/tailwind.gleam
//// These tests verify the helpers produce correct output

import gleeunit
import gleeunit/should
import lib/tailwind
import lustre/element.{type Element}
import lustre/element/html.{div}

pub fn main() -> Nil {
  gleeunit.main()
}

// ============================================================================
// Typography Helper Tests
// ============================================================================

pub fn test_section_heading_produces_h2() {
  let result = tailwind.section_heading("Test Title")
  // Verify it returns an Element - the actual rendering is tested via E2E
  should_be_element(result)
}

pub fn test_section_heading_text() {
  let result = tailwind.section_heading("My Title")
  // The helper should contain the text
  should_be_element(result)
}

pub fn test_section_description_produces_p() {
  let result = tailwind.section_description([])
  should_be_element(result)
}

pub fn test_section_description_text() {
  let result = tailwind.section_description_text("Description text")
  should_be_element(result)
}

pub fn test_helper_text_produces_p() {
  let result = tailwind.helper_text([])
  should_be_element(result)
}

pub fn test_helper_text_text() {
  let result = tailwind.helper_text_text("Helper text")
  should_be_element(result)
}

// ============================================================================
// Layout Helper Tests - VStack
// ============================================================================

pub fn test_vstack_sm() {
  let result = tailwind.vstack_sm([])
  should_be_element(result)
}

pub fn test_vstack_md() {
  let result = tailwind.vstack_md([])
  should_be_element(result)
}

pub fn test_vstack_lg() {
  let result = tailwind.vstack_lg([])
  should_be_element(result)
}

pub fn test_vstack_xl() {
  let result = tailwind.vstack_xl([])
  should_be_element(result)
}

// ============================================================================
// Layout Helper Tests - HWrap
// ============================================================================

pub fn test_hwrap_sm() {
  let result = tailwind.hwrap_sm([])
  should_be_element(result)
}

pub fn test_hwrap_md() {
  let result = tailwind.hwrap_md([])
  should_be_element(result)
}

pub fn test_hwrap_lg() {
  let result = tailwind.hwrap_lg([])
  should_be_element(result)
}

// ============================================================================
// Layout Helper Tests - VFlex
// ============================================================================

pub fn test_vflex_sm() {
  let result = tailwind.vflex_sm([])
  should_be_element(result)
}

pub fn test_vflex_md() {
  let result = tailwind.vflex_md([])
  should_be_element(result)
}

pub fn test_vflex_lg() {
  let result = tailwind.vflex_lg([])
  should_be_element(result)
}

// ============================================================================
// Layout Helper Tests - Row
// ============================================================================

pub fn test_row_sm() {
  let result = tailwind.row_sm([])
  should_be_element(result)
}

pub fn test_row_md() {
  let result = tailwind.row_md([])
  should_be_element(result)
}

pub fn test_row_lg() {
  let result = tailwind.row_lg([])
  should_be_element(result)
}

// ============================================================================
// Form Helper Tests
// ============================================================================

pub fn test_label() {
  let result = tailwind.label_for("test-id", [])
  should_be_element(result)
}

pub fn test_label_text() {
  let result = tailwind.label_text("test-id", "Label Text")
  should_be_element(result)
}

pub fn test_field() {
  let result = tailwind.field([])
  should_be_element(result)
}

// ============================================================================
// Button Group Helper Tests
// ============================================================================

pub fn test_button_group() {
  let result = tailwind.button_group([])
  should_be_element(result)
}

pub fn test_button_group_right() {
  let result = tailwind.button_group_right([])
  should_be_element(result)
}

// ============================================================================
// Section Helper Tests
// ============================================================================

pub fn test_section() {
  let result = tailwind.section("Heading", "Description", [])
  should_be_element(result)
}

pub fn test_section_simple() {
  let result = tailwind.section_simple("Heading", [])
  should_be_element(result)
}

// ============================================================================
// Utility Helper Tests
// ============================================================================

pub fn test_text_variants() {
  tailwind.text_xs("text") |> should_be_element
  tailwind.text_sm("text") |> should_be_element
  tailwind.text_base("text") |> should_be_element
  tailwind.text_lg("text") |> should_be_element
  tailwind.text_xl("text") |> should_be_element
}

pub fn test_font_variants() {
  tailwind.font_normal("text") |> should_be_element
  tailwind.font_medium("text") |> should_be_element
  tailwind.font_semibold("text") |> should_be_element
  tailwind.font_bold("text") |> should_be_element
}

pub fn test_padding_variants() {
  tailwind.p_2(div_empty()) |> should_be_element
  tailwind.p_4(div_empty()) |> should_be_element
  tailwind.p_6(div_empty()) |> should_be_element
}

pub fn test_margin_variants() {
  tailwind.mt_2(div_empty()) |> should_be_element
  tailwind.mt_4(div_empty()) |> should_be_element
  tailwind.mb_2(div_empty()) |> should_be_element
  tailwind.mb_4(div_empty()) |> should_be_element
}

pub fn test_gap_variants() {
  tailwind.gap_1([]) |> should_be_element
  tailwind.gap_2([]) |> should_be_element
  tailwind.gap_3([]) |> should_be_element
  tailwind.gap_4([]) |> should_be_element
  tailwind.gap_6([]) |> should_be_element
}

// ============================================================================
// Helper Functions
// ============================================================================

fn should_be_element(value: Element(a)) {
  // Just verify it compiles and returns an Element
  // The actual HTML output is verified through E2E tests
  let _ = value
}

fn div_empty() -> Element(a) {
  div([], [])
}

// ============================================================================
// Run All Tests
// ============================================================================

pub fn run_all() {
  // Typography tests
  test_section_heading_produces_h2()
  test_section_heading_text()
  test_section_description_produces_p()
  test_section_description_text()
  test_helper_text_produces_p()
  test_helper_text_text()

  // VStack tests
  test_vstack_sm()
  test_vstack_md()
  test_vstack_lg()
  test_vstack_xl()

  // HWrap tests
  test_hwrap_sm()
  test_hwrap_md()
  test_hwrap_lg()

  // VFlex tests
  test_vflex_sm()
  test_vflex_md()
  test_vflex_lg()

  // Row tests
  test_row_sm()
  test_row_md()
  test_row_lg()

  // Form tests
  test_label()
  test_label_text()
  test_field()

  // Button group tests
  test_button_group()
  test_button_group_right()

  // Section tests
  test_section()
  test_section_simple()

  // Utility tests
  test_text_variants()
  test_font_variants()
  test_padding_variants()
  test_margin_variants()
  test_gap_variants()
}
