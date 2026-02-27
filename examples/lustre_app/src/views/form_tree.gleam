// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Tree View
////
//// Renders the tree view component for file browser demonstration.

import gleam/list
import types.{type Model, type Msg, TreeMsg}
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event
import lib/tailwind
import lustre_utils/tree as tree_utils
import lustre_utils/tree_view
import ui/tree

pub fn view_tree(model: Model) -> Element(Msg) {
  tailwind.field([
    tailwind.section_heading("Tree"),
    tailwind.section_description_text("Tree - Collapsible nodes with aria-expanded"),
    {
      let tree_items = tree_utils.get_items(model.tree)
      tree.tree(
        [
          tree.aria_label("File browser"),
          attribute("data-testid", "tree-demo"),
        ],
        list.flat_map(tree_items, fn(item) {
          tree_view.render_tree_item(model.tree, item, False, 0, TreeMsg)
        }),
      )
    },
  ])
}

pub fn view(model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    view_tree(model),
  ])
}
