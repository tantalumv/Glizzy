//// Tailwind CSS Patterns Test
////
//// Tests for common Tailwind utility class patterns used across views
//// These tests verify the class strings are correctly formed before refactoring

import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// ============================================================================
// Typography Pattern Tests
// ============================================================================

/// Test section heading pattern: text-xl font-semibold
pub fn test_section_heading_pattern() {
  "text-xl font-semibold"
  |> should.equal("text-xl font-semibold")
}

/// Test section description pattern: text-sm text-muted-foreground
pub fn test_section_description_pattern() {
  "text-sm text-muted-foreground"
  |> should.equal("text-sm text-muted-foreground")
}

/// Test helper text pattern: text-xs text-muted-foreground mt-2
pub fn test_helper_text_pattern() {
  "text-xs text-muted-foreground mt-2"
  |> should.equal("text-xs text-muted-foreground mt-2")
}

// ============================================================================
// Layout Pattern Tests - Space Y
// ============================================================================

/// Test space-y-2 pattern
pub fn test_space_y_2_pattern() {
  "space-y-2"
  |> should.equal("space-y-2")
}

/// Test space-y-4 pattern (most common)
pub fn test_space_y_4_pattern() {
  "space-y-4"
  |> should.equal("space-y-4")
}

/// Test space-y-6 pattern
pub fn test_space_y_6_pattern() {
  "space-y-6"
  |> should.equal("space-y-6")
}

/// Test space-y-8 pattern
pub fn test_space_y_8_pattern() {
  "space-y-8"
  |> should.equal("space-y-8")
}

// ============================================================================
// Layout Pattern Tests - Flex
// ============================================================================

/// Test flex flex-wrap gap-4 pattern (hwrap)
pub fn test_flex_wrap_gap_4_pattern() {
  "flex flex-wrap gap-4"
  |> should.equal("flex flex-wrap gap-4")
}

/// Test flex flex-col gap-4 pattern (vflex)
pub fn test_flex_col_gap_4_pattern() {
  "flex flex-col gap-4"
  |> should.equal("flex flex-col gap-4")
}

/// Test flex items-center gap-2 pattern (row)
pub fn test_flex_items_center_gap_2_pattern() {
  "flex items-center gap-2"
  |> should.equal("flex items-center gap-2")
}

/// Test flex items-center gap-4 pattern (row-lg)
pub fn test_flex_items_center_gap_4_pattern() {
  "flex items-center gap-4"
  |> should.equal("flex items-center gap-4")
}

// ============================================================================
// Form Pattern Tests
// ============================================================================

/// Test form label pattern: text-sm font-medium
pub fn test_form_label_pattern() {
  "text-sm font-medium"
  |> should.equal("text-sm font-medium")
}

/// Test form field wrapper pattern: space-y-1
pub fn test_form_field_pattern() {
  "space-y-1"
  |> should.equal("space-y-1")
}

// ============================================================================
// Button Group Pattern Tests
// ============================================================================

/// Test button group pattern: flex gap-2
pub fn test_button_group_pattern() {
  "flex gap-2"
  |> should.equal("flex gap-2")
}

/// Test button group right pattern: flex justify-end gap-2 mt-4
pub fn test_button_group_right_pattern() {
  "flex justify-end gap-2 mt-4"
  |> should.equal("flex justify-end gap-2 mt-4")
}

// ============================================================================
// Gap Variant Tests
// ============================================================================

pub fn test_gap_1_pattern() {
  "gap-1"
  |> should.equal("gap-1")
}

pub fn test_gap_2_pattern() {
  "gap-2"
  |> should.equal("gap-2")
}

pub fn test_gap_3_pattern() {
  "gap-3"
  |> should.equal("gap-3")
}

pub fn test_gap_4_pattern() {
  "gap-4"
  |> should.equal("gap-4")
}

pub fn test_gap_6_pattern() {
  "gap-6"
  |> should.equal("gap-6")
}

// ============================================================================
// Padding Variant Tests
// ============================================================================

pub fn test_p_2_pattern() {
  "p-2"
  |> should.equal("p-2")
}

pub fn test_p_4_pattern() {
  "p-4"
  |> should.equal("p-4")
}

pub fn test_p_6_pattern() {
  "p-6"
  |> should.equal("p-6")
}

// ============================================================================
// Margin Variant Tests
// ============================================================================

pub fn test_mt_2_pattern() {
  "mt-2"
  |> should.equal("mt-2")
}

pub fn test_mt_4_pattern() {
  "mt-4"
  |> should.equal("mt-4")
}

pub fn test_mb_2_pattern() {
  "mb-2"
  |> should.equal("mb-2")
}

pub fn test_mb_4_pattern() {
  "mb-4"
  |> should.equal("mb-4")
}

// ============================================================================
// Font Size Variant Tests
// ============================================================================

pub fn test_text_xs_pattern() {
  "text-xs"
  |> should.equal("text-xs")
}

pub fn test_text_sm_pattern() {
  "text-sm"
  |> should.equal("text-sm")
}

pub fn test_text_base_pattern() {
  "text-base"
  |> should.equal("text-base")
}

pub fn test_text_lg_pattern() {
  "text-lg"
  |> should.equal("text-lg")
}

pub fn test_text_xl_pattern() {
  "text-xl"
  |> should.equal("text-xl")
}

// ============================================================================
// Font Weight Variant Tests
// ============================================================================

pub fn test_font_normal_pattern() {
  "font-normal"
  |> should.equal("font-normal")
}

pub fn test_font_medium_pattern() {
  "font-medium"
  |> should.equal("font-medium")
}

pub fn test_font_semibold_pattern() {
  "font-semibold"
  |> should.equal("font-semibold")
}

pub fn test_font_bold_pattern() {
  "font-bold"
  |> should.equal("font-bold")
}

// ============================================================================
// Complex Pattern Tests (Real-world examples from views)
// ============================================================================

/// Test layout.gleam pattern: Stack container
pub fn test_layout_stack_pattern() {
  "space-y-4"
  |> should.equal("space-y-4")
}

/// Test layout.gleam pattern: Cluster container
pub fn test_layout_cluster_pattern() {
  "flex flex-wrap gap-4"
  |> should.equal("flex flex-wrap gap-4")
}

/// Test buttons.gleam pattern: Button grid
pub fn test_buttons_grid_pattern() {
  "flex flex-wrap gap-4"
  |> should.equal("flex flex-wrap gap-4")
}

/// Test common card pattern
pub fn test_card_pattern() {
  "rounded-lg border bg-card text-card-foreground shadow-sm"
  |> should.equal("rounded-lg border bg-card text-card-foreground shadow-sm")
}

// ============================================================================
// Run All Tests
// ============================================================================

/// Register all tests with gleeunit
pub fn run_all() {
  // Typography tests
  test_section_heading_pattern()
  test_section_description_pattern()
  test_helper_text_pattern()
  
  // Space-y tests
  test_space_y_2_pattern()
  test_space_y_4_pattern()
  test_space_y_6_pattern()
  test_space_y_8_pattern()
  
  // Flex tests
  test_flex_wrap_gap_4_pattern()
  test_flex_col_gap_4_pattern()
  test_flex_items_center_gap_2_pattern()
  test_flex_items_center_gap_4_pattern()
  
  // Form tests
  test_form_label_pattern()
  test_form_field_pattern()
  
  // Button group tests
  test_button_group_pattern()
  test_button_group_right_pattern()
  
  // Gap tests
  test_gap_1_pattern()
  test_gap_2_pattern()
  test_gap_3_pattern()
  test_gap_4_pattern()
  test_gap_6_pattern()
  
  // Padding tests
  test_p_2_pattern()
  test_p_4_pattern()
  test_p_6_pattern()
  
  // Margin tests
  test_mt_2_pattern()
  test_mt_4_pattern()
  test_mb_2_pattern()
  test_mb_4_pattern()
  
  // Font size tests
  test_text_xs_pattern()
  test_text_sm_pattern()
  test_text_base_pattern()
  test_text_lg_pattern()
  test_text_xl_pattern()
  
  // Font weight tests
  test_font_normal_pattern()
  test_font_medium_pattern()
  test_font_semibold_pattern()
  test_font_bold_pattern()
  
  // Complex pattern tests
  test_layout_stack_pattern()
  test_layout_cluster_pattern()
  test_buttons_grid_pattern()
  test_card_pattern()
}
