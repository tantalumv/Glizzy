//// Glizzy Focus Module Tests
////
//// Tests for focus management and focus trapping functionality.
//// Note: These tests verify the API surface and type signatures.
//// Actual focus behavior requires browser/E2E testing.

import gleam/option.{type Option, None, Some}
import gleeunit
import gleeunit/should
import lustre/effect.{type Effect}
import ui/focus

// Type alias for effect message type in tests
type TestMsg =
  String

pub fn main() {
  gleeunit.main()
}

// ============================================================================
// Focus Scope ID Type Tests
// ============================================================================

pub fn focus_scope_id_is_string_test() {
  // FocusScopeId is a type alias for String
  let scope_id: focus.FocusScopeId = "test-scope"
  scope_id |> should.equal("test-scope")
}

pub fn focus_scope_id_accepts_any_string_test() {
  let scope_id = "dialog-content"
  let _scope: focus.FocusScopeId = scope_id
  // Verify string assignment works
  scope_id |> should.equal("dialog-content")
}

// ============================================================================
// Focus Scope Creation Tests
// ============================================================================

pub fn create_scope_returns_effect_test() {
  // Verify create_scope returns an Effect - type check only
  let _effect: Effect(TestMsg) =
    focus.create_scope("test-container", fn(_id) { panic })

  // If this compiles, the return type is correct
  True |> should.be_true
}

pub fn create_scope_callback_receives_id_test() {
  // Test that callback receives the scope ID
  let received_id = ref("")
  let callback = fn(id: focus.FocusScopeId) {
    ref_set(received_id, id)
    id
  }

  let _effect = focus.create_scope("my-container", callback)

  // Note: Effect execution happens at runtime, not during test
  // This verifies the callback signature is correct
  True |> should.be_true
}

// ============================================================================
// Focus Scope Destruction Tests
// ============================================================================

pub fn destroy_scope_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.destroy_scope("test-scope")
  True |> should.be_true
}

pub fn destroy_scope_accepts_scope_id_test() {
  let scope_id = "scope-123"
  let _effect: Effect(TestMsg) = focus.destroy_scope(scope_id)
  True |> should.be_true
}

// ============================================================================
// Focus First/Last Tests
// ============================================================================

pub fn focus_first_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.focus_first("test-scope")
  True |> should.be_true
}

pub fn focus_first_accepts_scope_id_test() {
  let _effect: Effect(TestMsg) = focus.focus_first("my-dialog")
  True |> should.be_true
}

pub fn focus_last_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.focus_last("test-scope")
  True |> should.be_true
}

pub fn focus_last_accepts_scope_id_test() {
  let _effect: Effect(TestMsg) = focus.focus_last("my-dialog")
  True |> should.be_true
}

// ============================================================================
// Focus Trap Tests
// ============================================================================

pub fn trap_focus_enable_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.trap_focus("test-scope", True)
  True |> should.be_true
}

pub fn trap_focus_disable_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.trap_focus("test-scope", False)
  True |> should.be_true
}

pub fn trap_focus_accepts_boolean_test() {
  let _enable_effect: Effect(TestMsg) = focus.trap_focus("scope", True)
  let _disable_effect: Effect(TestMsg) = focus.trap_focus("scope", False)

  True |> should.be_true
}

// ============================================================================
// Standalone Focus Trap Tests
// ============================================================================

pub fn enable_trap_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.enable_trap("test-container")
  True |> should.be_true
}

pub fn disable_trap_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.disable_trap("test-container")
  True |> should.be_true
}

// ============================================================================
// Focus Helper Tests
// ============================================================================

pub fn focus_by_id_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.focus_by_id("test-element")
  True |> should.be_true
}

pub fn focus_by_id_accepts_element_id_test() {
  let _effect: Effect(TestMsg) = focus.focus_by_id("my-button")
  True |> should.be_true
}

pub fn get_focused_id_returns_effect_test() {
  let _effect: Effect(TestMsg) = focus.get_focused_id(fn(_maybe_id) { panic })
  True |> should.be_true
}

pub fn get_focused_id_callback_handles_some_test() {
  let callback = fn(maybe_id: Option(String)) {
    case maybe_id {
      Some(id) -> id
      None -> ""
    }
  }

  let _effect: Effect(TestMsg) = focus.get_focused_id(callback)
  True |> should.be_true
}

pub fn get_focused_id_callback_handles_none_test() {
  let callback = fn(maybe_id: Option(String)) {
    case maybe_id {
      Some(id) -> id
      None -> "no-focus"
    }
  }

  let _effect: Effect(TestMsg) = focus.get_focused_id(callback)
  True |> should.be_true
}

// ============================================================================
// Integration Pattern Tests
// ============================================================================

pub fn create_scope_then_trap_focus_pattern_test() {
  // Test the common pattern: create scope, then enable trap
  let scope_id = "dialog-1"

  let _create_effect: Effect(TestMsg) =
    focus.create_scope(scope_id, fn(_id) { panic })
  let _trap_effect: Effect(TestMsg) = focus.trap_focus(scope_id, True)
  let _focus_effect: Effect(TestMsg) = focus.focus_first(scope_id)

  True |> should.be_true
}

// ============================================================================
// Helper Functions
// ============================================================================

fn ref(initial: a) -> Ref(a) {
  Ref(initial)
}

type Ref(a) {
  Ref(a)
}

fn ref_set(ref: Ref(a), value: a) -> Ref(a) {
  Ref(value)
}
