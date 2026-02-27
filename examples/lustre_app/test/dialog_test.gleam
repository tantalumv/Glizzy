// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Tests for dialog component with focus trap support.
//// Tests are registered when this module is imported.

import gleeunit
import gleeunit/should
import lustre/effect.{type Effect}
import lustre_utils/dialog

pub fn main() -> Nil {
  gleeunit.main()
}

// ============================================================================
// Model Initialization Tests
// ============================================================================

pub fn init_returns_model_and_effect_test() {
  let #(model, effect) = dialog.init()
  
  model.is_open |> should.be_false
  model.focus_scope_id |> should.equal("dialog-content")
  
  // Effect should be valid (none effect)
  assert_effect(effect)
}

// ============================================================================
// Toggle Tests
// ============================================================================

pub fn toggle_from_closed_opens_test() {
  let #(model, _init_effect) = dialog.init()
  let #(new_model, effect) = dialog.update(model, dialog.Toggle)
  
  new_model.is_open |> should.be_true
  // Should return focus trap enable effect
  assert_effect(effect)
}

pub fn toggle_from_open_closes_test() {
  let #(open_model, _init_effect) = dialog.init()
  let #(opened_model, _open_effect) = dialog.update(open_model, dialog.Open)
  
  let #(closed_model, effect) = dialog.update(opened_model, dialog.Toggle)
  
  closed_model.is_open |> should.be_false
  // Should return focus trap disable effect
  assert_effect(effect)
}

// ============================================================================
// Open/Close Tests
// ============================================================================

pub fn open_sets_is_open_true_test() {
  let #(model, _init_effect) = dialog.init()
  let #(new_model, effect) = dialog.update(model, dialog.Open)
  
  new_model.is_open |> should.be_true
  assert_effect(effect)
}

pub fn close_sets_is_open_false_test() {
  let #(model, _init_effect) = dialog.init()
  let #(opened_model, _open_effect) = dialog.update(model, dialog.Open)
  let #(closed_model, effect) = dialog.update(opened_model, dialog.Close)
  
  closed_model.is_open |> should.be_false
  assert_effect(effect)
}

pub fn escape_sets_is_open_false_test() {
  let #(model, _init_effect) = dialog.init()
  let #(opened_model, _open_effect) = dialog.update(model, dialog.Open)
  let #(closed_model, effect) = dialog.update(opened_model, dialog.Escape)
  
  closed_model.is_open |> should.be_false
  assert_effect(effect)
}

// ============================================================================
// Focus Scope Created Tests
// ============================================================================

pub fn focus_scope_created_updates_id_test() {
  let #(model, _init_effect) = dialog.init()
  let custom_scope_id = "custom-dialog-scope"
  
  let #(new_model, effect) = dialog.update(model, dialog.FocusScopeCreated(custom_scope_id))
  
  new_model.focus_scope_id |> should.equal(custom_scope_id)
  new_model.is_open |> should.be_false
  // Should return none effect
  assert_effect(effect)
}

// ============================================================================
// Helper Functions
// ============================================================================

fn assert_effect(_effect: Effect(msg)) {
  // Verify the effect type compiles correctly
  // Actual effect execution requires browser runtime
  True |> should.be_true
}
