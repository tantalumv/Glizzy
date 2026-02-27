// View Transitions FFI bindings
// Wraps the JavaScript View Transitions API for Gleam

@external(javascript, "./view_transition.mjs", "startViewTransition")
pub fn start_view_transition(callback: fn() -> Nil) -> Nil

@external(javascript, "./view_transition.mjs", "isSupported")
pub fn is_supported() -> Bool
