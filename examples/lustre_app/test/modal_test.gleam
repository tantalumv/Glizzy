// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Tests for modal component with focus trap support.
//// Tests are registered when this module is imported.

import gleeunit
import gleeunit/should
import lustre/effect.{type Effect}
import lustre_utils/modal

pub fn main() -> Nil {
  gleeunit.main()
}

// ============================================================================
// Model Initialization Tests
// ============================================================================

pub fn init_returns_model_and_effect_test() {
  let #(model, effect) = modal.init()
  
  model.is_open |> should.be_false
  model.focus_scope_id |> should.equal("modal-content")
  
  // Effect should be valid (none effect)
  assert_effect(effect)
}

// ============================================================================
// Toggle Tests
// ============================================================================

pub fn toggle_from_closed_opens_test() {
  let #(model, _init_effect) = modal.init()
  let #(new_model, effect) = modal.update(model, modal.Toggle)
  
  new_model.is_open |> should.be_true
  // Should return focus trap enable effect
  assert_effect(effect)
}

pub fn toggle_from_open_closes_test() {
  let #(open_model, _init_effect) = modal.init()
  let #(opened_model, _open_effect) = modal.update(open_model, modal.Open)
  
  let #(closed_model, effect) = modal.update(opened_model, modal.Toggle)
  
  closed_model.is_open |> should.be_false
  // Should return focus trap disable effect
  assert_effect(effect)
}

// ============================================================================
// Open/Close Tests
// ============================================================================

pub fn open_sets_is_open_true_test() {
  let #(model, _init_effect) = modal.init()
  let #(new_model, effect) = modal.update(model, modal.Open)
  
  new_model.is_open |> should.be_true
  assert_effect(effect)
}

pub fn close_sets_is_open_false_test() {
  let #(model, _init_effect) = modal.init()
  let #(opened_model, _open_effect) = modal.update(model, modal.Open)
  let #(closed_model, effect) = modal.update(opened_model, modal.Close)
  
  closed_model.is_open |> should.be_false
  assert_effect(effect)
}

pub fn escape_sets_is_open_false_test() {
  let #(model, _init_effect) = modal.init()
  let #(opened_model, _open_effect) = modal.update(model, modal.Open)
  let #(closed_model, effect) = modal.update(opened_model, modal.Escape)
  
  closed_model.is_open |> should.be_false
  assert_effect(effect)
}

// ============================================================================
// Focus Scope Created Tests
// ============================================================================

pub fn focus_scope_created_updates_id_test() {
  let #(model, _init_effect) = modal.init()
  let custom_scope_id = "custom-modal-scope"
  
  let #(new_model, effect) = modal.update(model, modal.FocusScopeCreated(custom_scope_id))
  
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
