// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

// FFI bindings for move interactions
@external(javascript, "./interactions.ffi.mjs", "subscribeMove")
pub fn subscribe_move(element_id: String, dispatch: fn(String) -> Nil) -> String

@external(javascript, "./interactions.ffi.mjs", "unsubscribeMove")
pub fn unsubscribe_move(subscription_id: String) -> Nil

// FFI bindings for focus interactions
@external(javascript, "./interactions.ffi.mjs", "subscribeFocus")
pub fn subscribe_focus(
  element_id: String,
  dispatch: fn(String) -> Nil,
  config: String,
) -> String

@external(javascript, "./interactions.ffi.mjs", "unsubscribeFocus")
pub fn unsubscribe_focus(subscription_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "initFocusVisible")
pub fn init_focus_visible() -> Nil

@external(javascript, "./interactions.ffi.mjs", "getFocusVisibleState")
pub fn get_focus_visible_state() -> Bool

@external(javascript, "./interactions.ffi.mjs", "subscribeFocusVisible")
pub fn subscribe_focus_visible(
  element_id: String,
  dispatch: fn(String) -> Nil,
  config: String,
) -> String

// FFI bindings for focus scope (roving tabindex, focus trap)
@external(javascript, "./interactions.ffi.mjs", "createFocusScope")
pub fn create_focus_scope(container_id: String) -> String

@external(javascript, "./interactions.ffi.mjs", "destroyFocusScope")
pub fn destroy_focus_scope(scope_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "focusScopeFocusFirst")
pub fn focus_scope_focus_first(scope_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "focusScopeFocusLast")
pub fn focus_scope_focus_last(scope_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "focusScopeTrapFocus")
pub fn focus_scope_trap_focus(scope_id: String, enabled: Bool) -> Nil

// FFI bindings for focus trap (standalone)
@external(javascript, "./interactions.ffi.mjs", "enableFocusTrap")
pub fn enable_focus_trap(container_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "disableFocusTrap")
pub fn disable_focus_trap(container_id: String) -> Nil

// FFI bindings for dialog
@external(javascript, "./interactions.ffi.mjs", "setupDialog")
pub fn setup_dialog(
  dialog_id: String,
  on_open_change: fn(Bool) -> Nil,
  on_close: fn() -> Nil,
) -> Nil

@external(javascript, "./interactions.ffi.mjs", "openDialog")
pub fn open_dialog(dialog_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "closeDialog")
pub fn close_dialog(dialog_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "isDialogOpen")
pub fn is_dialog_open(dialog_id: String) -> Bool

// FFI bindings for click outside detection
@external(javascript, "./interactions.ffi.mjs", "subscribeClickOutside")
pub fn subscribe_click_outside(
  element_id: String,
  dispatch: fn(String) -> Nil,
  config_json: String,
) -> String

@external(javascript, "./interactions.ffi.mjs", "unsubscribeClickOutside")
pub fn unsubscribe_click_outside(subscription_id: String) -> Nil

@external(javascript, "./interactions.ffi.mjs", "updateClickOutsideElement")
pub fn update_click_outside_element(
  subscription_id: String,
  new_element_id: String,
) -> Nil
