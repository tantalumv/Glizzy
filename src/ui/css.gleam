// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

/// Focus ring styles for keyboard navigation
pub fn focus_ring() -> String {
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
}

/// Disabled state styles
pub fn disabled() -> String {
  "disabled:cursor-not-allowed disabled:opacity-50"
}
