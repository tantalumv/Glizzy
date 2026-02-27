import types.{type Model, type Msg}
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h2, p}
import lib/tailwind
import ui/badge
import ui/size
import ui/divider
import ui/kbd
import ui/layout/aside
import ui/layout/box as ui_box
import ui/layout/centre
import ui/layout/cluster
import ui/layout/sequence
import ui/layout/stack
import ui/layout/types as layout_types

pub fn view_layouts() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Layout Components"),

    div([attribute("data-testid", "layout-stack-section")], [
      tailwind.section_description_text("Stack - Vertical spacing"),
      div([attribute("data-testid", "stack-default")], [
        stack.stack([], layout_types.Relaxed, [
          div([class("p-2 bg-muted rounded")], [text("Item 1")]),
          div([class("p-2 bg-muted rounded")], [text("Item 2")]),
          div([class("p-2 bg-muted rounded")], [text("Item 3")]),
        ]),
      ]),
    ]),

    div([attribute("data-testid", "layout-stack-spacing")], [
      tailwind.section_description_text("Stack spacing variants"),
      tailwind.hwrap_md([
        div([attribute("data-testid", "stack-packed")], [
          tailwind.text_xs("Packed"),
          stack.stack([], layout_types.Packed, [
            div([class("p-1 bg-muted rounded text-xs")], [text("A")]),
            div([class("p-1 bg-muted rounded text-xs")], [text("B")]),
          ]),
        ]),
        div([attribute("data-testid", "stack-tight")], [
          tailwind.text_xs("Tight"),
          stack.stack([], layout_types.Tight, [
            div([class("p-1 bg-muted rounded text-xs")], [text("A")]),
            div([class("p-1 bg-muted rounded text-xs")], [text("B")]),
          ]),
        ]),
        div([attribute("data-testid", "stack-relaxed")], [
          tailwind.text_xs("Relaxed"),
          stack.stack([], layout_types.Relaxed, [
            div([class("p-1 bg-muted rounded text-xs")], [text("A")]),
            div([class("p-1 bg-muted rounded text-xs")], [text("B")]),
          ]),
        ]),
        div([attribute("data-testid", "stack-loose")], [
          tailwind.text_xs("Loose"),
          stack.stack([], layout_types.Loose, [
            div([class("p-1 bg-muted rounded text-xs")], [text("A")]),
            div([class("p-1 bg-muted rounded text-xs")], [text("B")]),
          ]),
        ]),
      ]),
    ]),

    div([attribute("data-testid", "layout-cluster-section")], [
      tailwind.section_description_text("Cluster - Horizontal wrapping"),
      div([attribute("data-testid", "cluster-default")], [
        cluster.cluster([cluster.align_centre()], layout_types.Relaxed, [
          badge.badge([], [text("Tag 1")]),
          badge.badge([], [text("Tag 2")]),
          badge.badge([], [text("Tag 3")]),
          badge.badge([], [text("Tag 4")]),
          badge.badge([], [text("Tag 5")]),
        ]),
      ]),
    ]),

    div([attribute("data-testid", "layout-cluster-align")], [
      tailwind.section_description_text("Cluster alignment"),
      tailwind.vstack_sm([
        div([attribute("data-testid", "cluster-align-start")], [
          tailwind.text_xs("Align Start"),
          cluster.cluster([cluster.align_start()], layout_types.Tight, [
            div([class("p-2 bg-muted rounded h-8")], [text("Short")]),
            div([class("p-2 bg-muted rounded h-12")], [text("Tall")]),
            div([class("p-2 bg-muted rounded h-6")], [text("Tiny")]),
          ]),
        ]),
        div([attribute("data-testid", "cluster-align-center")], [
          tailwind.text_xs("Align Center"),
          cluster.cluster([cluster.align_centre()], layout_types.Tight, [
            div([class("p-2 bg-muted rounded h-8")], [text("Short")]),
            div([class("p-2 bg-muted rounded h-12")], [text("Tall")]),
            div([class("p-2 bg-muted rounded h-6")], [text("Tiny")]),
          ]),
        ]),
        div([attribute("data-testid", "cluster-align-end")], [
          tailwind.text_xs("Align End"),
          cluster.cluster([cluster.align_end()], layout_types.Tight, [
            div([class("p-2 bg-muted rounded h-8")], [text("Short")]),
            div([class("p-2 bg-muted rounded h-12")], [text("Tall")]),
            div([class("p-2 bg-muted rounded h-6")], [text("Tiny")]),
          ]),
        ]),
      ]),
    ]),

    div([attribute("data-testid", "layout-centre-section")], [
      tailwind.section_description_text("Centre - Center content"),
      div(
        [
          attribute("data-testid", "centre-default"),
          class("border border-border rounded p-4 h-32"),
        ],
        [
          centre.centre([], [text("Centered content")]),
        ],
      ),
    ]),

    div([attribute("data-testid", "layout-box-section")], [
      tailwind.section_description_text("Box - Padding container"),
      tailwind.hwrap_md([
        div([attribute("data-testid", "box-default")], [
          ui_box.box([ui_box.border()], [text("Box with border")]),
        ]),
        div([attribute("data-testid", "box-shadow")], [
          ui_box.box([ui_box.border(), ui_box.shadow()], [text("Box with shadow")]),
        ]),
      ]),
    ]),

    div([attribute("data-testid", "layout-aside-section")], [
      tailwind.section_description_text("Aside - Sidebar layout"),
      div(
        [
          attribute("data-testid", "aside-default"),
          class("border border-border rounded overflow-hidden"),
        ],
        [
          aside.aside(
            [],
            layout_types.Relaxed,
            div([class("p-4 bg-muted")], [text("Sidebar")]),
            div([class("p-4 bg-background")], [
              text("Main content area that takes remaining space"),
            ]),
          ),
        ],
      ),
    ]),

    div(
      [
        attribute("data-testid", "aside-sidebar-end"),
        class("border border-border rounded overflow-hidden"),
      ],
      [
        aside.aside(
          [aside.sidebar_end()],
          layout_types.Relaxed,
          div([class("p-4 bg-muted")], [text("Sidebar (end)")]),
          div([class("p-4 bg-background")], [
            text("Main content with sidebar on right"),
          ]),
        ),
      ],
    ),

    div([attribute("data-testid", "layout-sequence-section")], [
      tailwind.section_description_text("Sequence - Responsive wrapping"),
      div([attribute("data-testid", "sequence-default")], [
        sequence.sequence([], layout_types.Relaxed, [
          div([class("p-4 bg-muted rounded min-w-24")], [text("Item 1")]),
          div([class("p-4 bg-muted rounded min-w-24")], [text("Item 2")]),
          div([class("p-4 bg-muted rounded min-w-24")], [text("Item 3")]),
          div([class("p-4 bg-muted rounded min-w-24")], [text("Item 4")]),
        ]),
      ]),
    ]),
  ])
}

pub fn view_dividers() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Dividers"),
    tailwind.vstack_md([
      div([], [
        tailwind.section_description_text("Horizontal"),
        divider.divider([
          divider.variant(divider.Default),
          divider.aria_orientation(divider.Horizontal),
          attribute("data-testid", "divider-horizontal"),
          class("w-full h-[1px]"),
        ]),
      ]),
      div([class("h-24 flex items-center")], [
        div([class("w-24")], [
          tailwind.section_description_text("Vertical"),
        ]),
        divider.divider([
          divider.variant(divider.Default),
          divider.aria_orientation(divider.Vertical),
          attribute("data-testid", "divider-vertical"),
          class("h-20 w-[1px]"),
        ]),
      ]),
    ]),
  ])
}

pub fn view_kbds() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard Shortcuts"),
    div([class("flex flex-wrap gap-3")], [
      kbd.kbd([attribute("data-testid", "kbd-default")], [text("⌘K")]),
      kbd.kbd([kbd.variant(kbd.Muted), attribute("data-testid", "kbd-muted")], [
        text("⌘B"),
      ]),
      tailwind.gap_1([
        kbd.command(),
        kbd.kbd([], [text("K")]),
      ]),
    ]),
  ])
}

pub fn view(_model: Model) -> Element(Msg) {
  tailwind.vstack_xl([
    view_layouts(),
    view_dividers(),
    view_kbds(),
  ])
}
