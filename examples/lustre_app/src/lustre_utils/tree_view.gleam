import gleam/list
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, i}
import lustre/event
import lustre_utils/tree.{type Model, type Msg, type TreeItem, is_expanded, is_selected, is_focused, ToggleExpand, SelectItem}
import ui/tree as ui_tree

pub fn render_tree_item(
  tree_model: Model,
  item: TreeItem,
  _selected: Bool,
  level: Int,
  to_msg: fn(Msg) -> msg,
) -> List(Element(msg)) {
  let has_children = !list.is_empty(item.children)
  let expanded = is_expanded(tree_model, item.id)
  let selected = is_selected(tree_model, item.id)
  let focused = is_focused(tree_model, item.id)

  let icon_class = case expanded {
    True -> "ri-arrow-down-s-line"
    False -> "ri-arrow-right-s-line"
  }

  let expand_button = case has_children {
    True ->
      ui_tree.tree_expand_button(
        expanded,
        [
          event.stop_propagation(
            event.on_click(to_msg(ToggleExpand(item.id))),
          ),
        ],
        [
          i(
            [
              class(
                "ri-fw ri-xs transition-transform duration-200 "
                <> icon_class,
              ),
              attribute("aria-hidden", "true"),
            ],
            [],
          ),
        ],
      )
    False -> div([class("w-4")], [])
  }

  let children_elements = case expanded, has_children {
    True, True ->
      item.children
      |> list.flat_map(fn(child) {
        render_tree_item(tree_model, child, False, level + 1, to_msg)
      })
    _, _ -> []
  }

  let item_content = ui_tree.tree_item_content(
    [
      event.on_click(to_msg(SelectItem(item.id))),
    ],
    [
      ui_tree.tree_node([], [
        expand_button,
        ui_tree.tree_item_label([], [text(item.label)]),
      ]),
    ],
  )

  // Roving tabindex - only the focused item is focusable
  let tabindex = case focused {
    True -> "0"
    False -> "-1"
  }

  let item_element = ui_tree.tree_item(
    [
      attribute("id", "tree-item-" <> item.id),
      attribute("aria-expanded", case expanded, has_children {
        True, True -> "true"
        _, _ -> "false"
      }),
      attribute("aria-selected", case selected {
        True -> "true"
        False -> "false"
      }),
      attribute("tabindex", tabindex),
      event.on_keydown(fn(key) {
        case key {
          "Enter" | " " -> to_msg(ToggleExpand(item.id))
          _ -> to_msg(SelectItem(item.id))
        }
      }),
    ],
    [item_content]
      |> list.append(case expanded, has_children {
        True, True -> [ui_tree.tree_group([], children_elements)]
        _, _ -> []
      }),
  )

  [item_element]
}
