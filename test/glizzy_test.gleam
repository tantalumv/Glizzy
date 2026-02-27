//// Glizzy UI Component Tests
////

import gleeunit
import glizzy_badge_test
import glizzy_button_test
import glizzy_checkbox_test
import glizzy_input_test
import glizzy_switch_test

pub fn main() {
  glizzy_button_test.main()
  glizzy_badge_test.main()
  glizzy_input_test.main()
  glizzy_checkbox_test.main()
  glizzy_switch_test.main()
  gleeunit.main()
}
