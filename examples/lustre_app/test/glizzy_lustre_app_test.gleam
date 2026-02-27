// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Test entry point for gleeunit
//// This module imports all test modules and runs gleeunit.main() once

// Import all test modules - this registers their tests with gleeunit
import combobox_update_test
import dialog_test
import gleeunit
import keyboard_test
import modal_test
import popover_test
import select_update_test

pub fn main() -> Nil {
  // Run all test module mains to register their tests with gleeunit
  keyboard_test.main()
  dialog_test.main()
  modal_test.main()
  popover_test.main()
  select_update_test.main()
  combobox_update_test.main()
  // Run gleeunit ONCE - this executes ALL registered tests
  gleeunit.main()
}
