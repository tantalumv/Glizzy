// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details.

import lustre/attribute.{type Attribute, styles}

import ui/layout/types.{
  type Align, type Spacing, Centre, Custom, End, Loose, Packed, Relaxed, Start,
  Stretch, Tight,
}

pub fn spacing_to_gap(spacing: Spacing) -> String {
  case spacing {
    Packed -> "0"
    Tight -> "0.5rem"
    Relaxed -> "1rem"
    Loose -> "1.5rem"
    Custom(s) -> s
  }
}

pub fn spacing_to_tw(spacing: Spacing) -> String {
  case spacing {
    Packed -> "gap-0"
    Tight -> "gap-2"
    Relaxed -> "gap-4"
    Loose -> "gap-6"
    Custom(s) -> "gap-[" <> s <> "]"
  }
}

pub fn align_to_flex(align: Align) -> String {
  case align {
    Start -> "flex-start"
    Centre -> "center"
    End -> "flex-end"
    Stretch -> "stretch"
  }
}

pub fn align_to_tw(align: Align) -> String {
  case align {
    Start -> "items-start"
    Centre -> "items-center"
    End -> "items-end"
    Stretch -> "items-stretch"
  }
}

pub fn css_style(props: List(#(String, String))) -> Attribute(a) {
  styles(props)
}
