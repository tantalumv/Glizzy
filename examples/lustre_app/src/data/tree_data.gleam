// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Tree Sample Data
////
//// Provides sample tree data for the tree view component demonstration.

import lustre_utils/tree.{type TreeItem, TreeItem}

/// Sample tree data representing a file browser structure.
/// This is used for demonstration purposes in the UI demo app.
pub fn sample_tree() -> List(TreeItem) {
  [
    TreeItem(
      id: "tree-node-1",
      label: "src/",
      children: [
        TreeItem(
          id: "tree-node-1-1",
          label: "main.gleam",
          children: [],
          expanded: False,
          selected: False,
        ),
        TreeItem(
          id: "tree-node-1-2",
          label: "app.gleam",
          children: [],
          expanded: False,
          selected: False,
        ),
      ],
      expanded: True,
      selected: False,
    ),
    TreeItem(
      id: "tree-node-2",
      label: "test/",
      children: [],
      expanded: False,
      selected: False,
    ),
  ]
}
