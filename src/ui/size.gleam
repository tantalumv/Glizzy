// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

pub type Size {
  Small
  Medium
  Large
}

/// Text-only sizing: text-xs / text-sm / text-base
pub fn text_class(s: Size) -> String {
  case s {
    Small -> "text-xs"
    Medium -> "text-sm"
    Large -> "text-base"
  }
}

/// Input-like sizing: height + horizontal padding + text
pub fn input_class(s: Size) -> String {
  case s {
    Small -> "h-8 px-2 text-xs"
    Medium -> "h-10 px-3 text-sm"
    Large -> "h-11 px-4 text-base"
  }
}

/// Button-like sizing: height + horizontal padding + text
pub fn button_class(s: Size) -> String {
  case s {
    Small -> "h-8 px-3 text-xs"
    Medium -> "h-10 px-4 text-sm"
    Large -> "h-11 px-8"
  }
}

/// Toggle button sizing: height + horizontal padding + text
pub fn toggle_button_class(s: Size) -> String {
  case s {
    Small -> "h-8 px-3 text-xs"
    Medium -> "h-10 px-4 text-sm"
    Large -> "h-11 px-6 text-base"
  }
}

/// Container/overlay sizing: max-width constraints
pub fn container_class(s: Size) -> String {
  case s {
    Small -> "max-w-sm"
    Medium -> "max-w-lg"
    Large -> "max-w-2xl"
  }
}

/// Track/bar sizing: height only
pub fn track_class(s: Size) -> String {
  case s {
    Small -> "h-1"
    Medium -> "h-2"
    Large -> "h-3"
  }
}

/// Small indicator sizing: checkbox/radio dimensions
pub fn indicator_class(s: Size) -> String {
  case s {
    Small -> "h-3 w-3"
    Medium -> "h-4 w-4"
    Large -> "h-5 w-5"
  }
}

/// Icon/swatch sizing: small square elements
pub fn icon_class(s: Size) -> String {
  case s {
    Small -> "h-4 w-4"
    Medium -> "h-6 w-6"
    Large -> "h-8 w-8"
  }
}

/// Tag/badge sizing: padding + text
pub fn tag_class(s: Size) -> String {
  case s {
    Small -> "px-2 py-0.5 text-xs"
    Medium -> "px-3 py-1 text-sm"
    Large -> "px-4 py-1 text-base"
  }
}
