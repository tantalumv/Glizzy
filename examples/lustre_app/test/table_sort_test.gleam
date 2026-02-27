// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import lustre_utils/table as table_utils

pub fn main() -> Nil {
  gleeunit.main()
}

// ============================================================================
// SortDirection Type Tests
// ============================================================================

pub fn sort_direction_ascending_exists_test() {
  table_utils.Ascending
  |> should.equal(table_utils.Ascending)
}

pub fn sort_direction_descending_exists_test() {
  table_utils.Descending
  |> should.equal(table_utils.Descending)
}

// ============================================================================
// Model Initialization Tests
// ============================================================================

pub fn table_init_has_no_sort_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)

  table_utils.sort_column(model)
  |> should.equal(None)
}

pub fn table_init_has_ascending_default_direction_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)

  table_utils.sort_direction(model)
  |> should.equal(table_utils.Ascending)
}

// ============================================================================
// aria_sort Attribute Tests
// ============================================================================

pub fn aria_sort_returns_none_for_unsorted_column_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)

  table_utils.aria_sort(model, 0)
  |> should.equal("none")
}

pub fn aria_sort_returns_ascending_for_sorted_column_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  table_utils.aria_sort(sorted_model, 0)
  |> should.equal("ascending")
}

pub fn aria_sort_returns_descending_for_descending_column_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  // Toggle twice to get descending
  let sorted_model = model
  |> table_utils.update(table_utils.ToggleSort(0))
  |> table_utils.update(table_utils.ToggleSort(0))

  table_utils.aria_sort(sorted_model, 0)
  |> should.equal("descending")
}

pub fn aria_sort_returns_none_for_different_column_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  // Column 1 should still be "none" when column 0 is sorted
  table_utils.aria_sort(sorted_model, 1)
  |> should.equal("none")
}

// ============================================================================
// is_column_sorted Tests
// ============================================================================

pub fn is_column_sorted_false_for_unsorted_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)

  table_utils.is_column_sorted(model, 0)
  |> should.equal(False)
}

pub fn is_column_sorted_true_for_sorted_column_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  table_utils.is_column_sorted(sorted_model, 0)
  |> should.equal(True)
}

pub fn is_column_sorted_false_for_other_column_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  table_utils.is_column_sorted(sorted_model, 1)
  |> should.equal(False)
}

// ============================================================================
// ToggleSort Message Tests
// ============================================================================

pub fn toggle_sort_first_click_sets_ascending_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Bob", "bob@example.com", "User"], ["Alice", "alice@example.com", "Admin"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  table_utils.sort_column(sorted_model)
  |> should.equal(Some(0))

  table_utils.sort_direction(sorted_model)
  |> should.equal(table_utils.Ascending)
}

pub fn toggle_sort_second_click_sets_descending_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Bob", "bob@example.com", "User"], ["Alice", "alice@example.com", "Admin"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = model
  |> table_utils.update(table_utils.ToggleSort(0))
  |> table_utils.update(table_utils.ToggleSort(0))

  table_utils.sort_column(sorted_model)
  |> should.equal(Some(0))

  table_utils.sort_direction(sorted_model)
  |> should.equal(table_utils.Descending)
}

pub fn toggle_sort_third_click_returns_to_ascending_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Bob", "bob@example.com", "User"], ["Alice", "alice@example.com", "Admin"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = model
  |> table_utils.update(table_utils.ToggleSort(0))
  |> table_utils.update(table_utils.ToggleSort(0))
  |> table_utils.update(table_utils.ToggleSort(0))

  table_utils.sort_direction(sorted_model)
  |> should.equal(table_utils.Ascending)
}

pub fn toggle_sort_different_column_resets_to_ascending_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = model
  |> table_utils.update(table_utils.ToggleSort(0))
  |> table_utils.update(table_utils.ToggleSort(1))

  table_utils.sort_column(sorted_model)
  |> should.equal(Some(1))

  table_utils.sort_direction(sorted_model)
  |> should.equal(table_utils.Ascending)
}

// ============================================================================
// SetSort Message Tests
// ============================================================================

pub fn set_sort_explicitly_sets_ascending_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.SetSort(0, table_utils.Ascending))

  table_utils.sort_column(sorted_model)
  |> should.equal(Some(0))

  table_utils.sort_direction(sorted_model)
  |> should.equal(table_utils.Ascending)
}

pub fn set_sort_explicitly_sets_descending_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.SetSort(0, table_utils.Descending))

  table_utils.sort_direction(sorted_model)
  |> should.equal(table_utils.Descending)
}

// ============================================================================
// ClearSort Message Tests
// ============================================================================

pub fn clear_sort_removes_sort_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let cleared_model = model
  |> table_utils.update(table_utils.ToggleSort(0))
  |> table_utils.update(table_utils.ClearSort)

  table_utils.sort_column(cleared_model)
  |> should.equal(None)
}

// ============================================================================
// Sort Data Reordering Tests
// ============================================================================

pub fn sort_by_name_ascending_reorders_rows_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Charlie", "charlie@example.com", "User"], ["Alice", "alice@example.com", "Admin"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  // First row should be Alice after ascending sort
  let first_row = table_utils.data(sorted_model) |> get_first_row
  first_row
  |> should.equal(["Alice", "alice@example.com", "Admin"])
}

pub fn sort_by_name_descending_reorders_rows_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"], ["Charlie", "charlie@example.com", "User"], ["Bob", "bob@example.com", "User"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = model
  |> table_utils.update(table_utils.ToggleSort(0))
  |> table_utils.update(table_utils.ToggleSort(0))

  // First row should be Charlie after descending sort
  let first_row = table_utils.data(sorted_model) |> get_first_row
  first_row
  |> should.equal(["Charlie", "charlie@example.com", "User"])
}

pub fn sort_preserves_all_columns_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Bob", "bob@example.com", "User"], ["Alice", "alice@example.com", "Admin"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  // Should still have 2 rows
  table_utils.rows(sorted_model)
  |> should.equal(2)

  // Should still have 3 columns
  table_utils.cols(sorted_model)
  |> should.equal(3)
}

// ============================================================================
// Edge Cases
// ============================================================================

pub fn sort_empty_table_test() {
  let columns = ["Name", "Email", "Role"]
  let data: List(List(String)) = []
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  // Should not crash, should still have no rows
  table_utils.rows(sorted_model)
  |> should.equal(0)
}

pub fn sort_single_row_table_test() {
  let columns = ["Name", "Email", "Role"]
  let data = [["Alice", "alice@example.com", "Admin"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  // Should still have 1 row
  table_utils.rows(sorted_model)
  |> should.equal(1)
}

pub fn sort_with_identical_values_test() {
  let columns = ["Name", "Role"]
  let data = [["Alice", "Admin"], ["Alice", "User"], ["Alice", "Guest"]]
  let model = table_utils.init(columns, data, False)
  let sorted_model = table_utils.update(model, table_utils.ToggleSort(0))

  // Should still have 3 rows (stable sort)
  table_utils.rows(sorted_model)
  |> should.equal(3)
}

// ============================================================================
// Helper Functions
// ============================================================================

fn get_first_row(data: List(List(String))) -> List(String) {
  case data {
    [] -> []
    [first, ..] -> first
  }
}
