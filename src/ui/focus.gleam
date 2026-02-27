//// Focus management utilities for Glizzy components
////
//// Provides effect-based focus management and focus trapping for overlays.
//// Use this for dialogs, modals, popovers, and other overlay components.
////
//// ## Usage
////
//// ```gleam
//// import lustre/effect.{type Effect, batch}
//// import glizzy/ui/focus
////
//// type Model {
////   Model(
////     is_open: Bool,
////     focus_scope_id: String,
////   )
//// }
////
//// type Msg {
////   Open
////   Close
////   FocusScopeCreated(String)
//// }
////
//// fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
////   case msg {
////     Open -> #(
////       Model(..model, is_open: True),
////       batch([
////         focus.trap_focus(model.focus_scope_id, True),
////         focus.focus_first(model.focus_scope_id),
////       ])
////     )
////     Close -> #(
////       Model(..model, is_open: False),
////       focus.trap_focus(model.focus_scope_id, False)
////     )
////     FocusScopeCreated(scope_id) -> #(
////       Model(..model, focus_scope_id: scope_id),
////       effect.none()
////     )
////   }
//// }
//// ```

// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/option.{type Option}
import lustre/effect.{type Effect, after_paint, from}

// ============================================================================
// Types
// ============================================================================

/// A unique identifier for a focus scope.
pub type FocusScopeId =
  String

// ============================================================================
// Focus Scope Management
// ============================================================================

/// Create a focus scope for the given container element.
/// Returns an effect that creates the scope and dispatches the scope ID.
///
/// Use this in your component's `init` function to set up focus management.
///
/// ## Example
///
/// ```gleam
/// fn init() -> #(Model, Effect(Msg)) {
///   #(
///     Model(is_open: False, focus_scope_id: ""),
///     focus.create_scope("dialog-content", FocusScopeCreated),
///   )
/// }
/// ```
pub fn create_scope(
  container_id: String,
  on_created: fn(FocusScopeId) -> msg,
) -> Effect(msg) {
  from(fn(dispatch) {
    let scope_id = create_focus_scope_js(container_id)
    dispatch(on_created(scope_id))
  })
}

/// Destroy a focus scope and clean up resources.
/// Returns an effect that destroys the scope.
///
/// Use this when your component unmounts to prevent memory leaks.
pub fn destroy_scope(scope_id: FocusScopeId) -> Effect(msg) {
  from(fn(_) { destroy_focus_scope_js(scope_id) })
}

/// Focus the first focusable element within the scope.
/// Returns an effect that focuses the first element after paint.
///
/// Use this when opening an overlay to move focus inside.
pub fn focus_first(scope_id: FocusScopeId) -> Effect(msg) {
  after_paint(fn(_, _) { focus_scope_focus_first_js(scope_id) })
}

/// Focus the last focusable element within the scope.
/// Returns an effect that focuses the last element after paint.
///
/// Use this for reverse focus navigation or when closing from the first element.
pub fn focus_last(scope_id: FocusScopeId) -> Effect(msg) {
  after_paint(fn(_, _) { focus_scope_focus_last_js(scope_id) })
}

/// Enable or disable focus trapping within the scope.
/// When enabled, Tab key cycles through focusable elements within the scope.
///
/// Returns an effect that enables/disables the trap after paint.
///
/// ## Example
///
/// ```gleam
/// // Enable focus trap when opening dialog
/// focus.trap_focus(scope_id, True)
///
/// // Disable focus trap when closing dialog
/// focus.trap_focus(scope_id, False)
/// ```
pub fn trap_focus(scope_id: FocusScopeId, enabled: Bool) -> Effect(msg) {
  after_paint(fn(_, _) { focus_scope_trap_focus_js(scope_id, enabled) })
}

// ============================================================================
// Standalone Focus Trap
// ============================================================================

/// Enable focus trap on a container element by ID.
/// This is a simpler alternative to using focus scopes.
///
/// When enabled, Tab key cycles through focusable elements within the container.
/// Shift+Tab reverses the cycle.
///
/// Returns an effect that enables the trap after paint.
pub fn enable_trap(container_id: String) -> Effect(msg) {
  after_paint(fn(_, _) { enable_focus_trap_js(container_id) })
}

/// Disable focus trap on a container element by ID.
/// Returns an effect that disables the trap after paint.
pub fn disable_trap(container_id: String) -> Effect(msg) {
  after_paint(fn(_, _) { disable_focus_trap_js(container_id) })
}

// ============================================================================
// Focus Helpers
// ============================================================================

/// Focus an element by its ID.
/// Returns an effect that focuses the element after paint.
///
/// Use this to restore focus to a trigger element when closing an overlay.
pub fn focus_by_id(element_id: String) -> Effect(msg) {
  after_paint(fn(_, _) { focus_element_js(element_id) })
}

/// Get the currently focused element's ID.
/// Returns an effect that dispatches the focused element ID.
///
/// Use this to save the currently focused element before opening an overlay,
/// so you can restore focus when closing.
pub fn get_focused_id(on_got_id: fn(Option(String)) -> msg) -> Effect(msg) {
  from(fn(dispatch) {
    let id = get_focused_element_id_js()
    dispatch(on_got_id(id))
  })
}

// ============================================================================
// FFI Bindings
// ============================================================================

@external(javascript, "./focus.ffi.mjs", "createFocusScope")
fn create_focus_scope_js(container_id: String) -> FocusScopeId

@external(javascript, "./focus.ffi.mjs", "destroyFocusScope")
fn destroy_focus_scope_js(scope_id: FocusScopeId) -> Nil

@external(javascript, "./focus.ffi.mjs", "focusScopeFocusFirst")
fn focus_scope_focus_first_js(scope_id: FocusScopeId) -> Nil

@external(javascript, "./focus.ffi.mjs", "focusScopeFocusLast")
fn focus_scope_focus_last_js(scope_id: FocusScopeId) -> Nil

@external(javascript, "./focus.ffi.mjs", "focusScopeTrapFocus")
fn focus_scope_trap_focus_js(scope_id: FocusScopeId, enabled: Bool) -> Nil

@external(javascript, "./focus.ffi.mjs", "enableFocusTrap")
fn enable_focus_trap_js(container_id: String) -> Nil

@external(javascript, "./focus.ffi.mjs", "disableFocusTrap")
fn disable_focus_trap_js(container_id: String) -> Nil

@external(javascript, "./focus.ffi.mjs", "focusElementById")
fn focus_element_js(element_id: String) -> Nil

@external(javascript, "./focus.ffi.mjs", "getFocusedElementId")
fn get_focused_element_id_js() -> Option(String)
