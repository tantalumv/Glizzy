// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Modal component with focus trap support.
////
//// Provides a modal model with focus scope management for accessibility.
////
//// ## Usage
////
//// ```gleam
//// import lustre/effect.{type Effect}
//// import lustre_utils/modal
//// import lustre_utils/interactions/focus
////
//// type Model {
////   Model(modal: modal.Model)
//// }
////
//// type Msg {
////   ModalMsg(modal.Msg)
//// }
////
//// fn init() -> #(Model, Effect(Msg)) {
////   #(
////     Model(modal: modal.init()),
////     effect.none()
////   )
//// }
////
//// fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
////   case msg {
////     ModalMsg(modal_msg) -> {
////       let #(new_modal, modal_effect) = modal.update(model.modal, modal_msg)
////       #(Model(modal: new_modal), effect.map(modal_effect, ModalMsg))
////     }
////   }
//// }
//// ```

import gleam/option.{type Option, None, Some}
import lustre/effect.{type Effect, batch, none}
import lustre_utils/interactions/focus
import lustre_utils/keyboard as keyboard

pub type Model {
  Model(
    is_open: Bool,
    focus_scope_id: String,
    trigger_element_id: String,
  )
}

pub type Msg {
  Toggle
  Open
  Close
  Escape
  FocusScopeCreated(String)
  TriggerFocusCaptured(String)
}

/// Initialize modal model.
/// Returns model and effect to create focus scope.
pub fn init() -> #(Model, Effect(Msg)) {
  #(
    Model(is_open: False, focus_scope_id: "modal-content", trigger_element_id: ""),
    // Focus scope will be created by parent component
    none()
  )
}

/// Update modal model.
/// Returns updated model and effects for focus management.
pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    Toggle -> case model.is_open {
      True -> update(model, Close)
      False -> update(model, Open)
    }
    Open -> #(
      Model(..model, is_open: True),
      focus_trap_enable(model.focus_scope_id)
    )
    Close -> #(
      Model(..model, is_open: False, trigger_element_id: ""),
      focus_trap_disable_and_restore(model.focus_scope_id, model.trigger_element_id)
    )
    Escape -> #(
      Model(..model, is_open: False, trigger_element_id: ""),
      focus_trap_disable_and_restore(model.focus_scope_id, model.trigger_element_id)
    )
    FocusScopeCreated(scope_id) -> #(
      Model(..model, focus_scope_id: scope_id),
      none()
    )
    TriggerFocusCaptured(element_id) -> #(
      Model(..model, trigger_element_id: element_id),
      none()
    )
  }
}

/// Enable focus trap for the modal.
fn focus_trap_enable(scope_id: String) -> Effect(Msg) {
  batch([
    focus.create_scope(scope_id, FocusScopeCreated),
    focus.trap_focus(scope_id, True),
    focus.focus_first(scope_id),
  ])
}

/// Disable focus trap and restore focus to trigger element.
fn focus_trap_disable_and_restore(scope_id: String, trigger_id: String) -> Effect(Msg) {
  batch([
    focus.trap_focus(scope_id, False),
    focus.focus_by_id(trigger_id),
  ])
}

pub fn is_open(model: Model) -> Bool {
  model.is_open
}

pub fn is_closed(model: Model) -> Bool {
  !model.is_open
}

/// Keymap for modal.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.Escape -> Some(Escape)
    _ -> None
  }
}
