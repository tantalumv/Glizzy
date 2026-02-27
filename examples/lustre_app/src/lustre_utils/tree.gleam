import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre_utils/keyboard as keyboard

pub type TreeItem {
  TreeItem(
    id: String,
    label: String,
    children: List(TreeItem),
    expanded: Bool,
    selected: Bool,
  )
}

pub type Model {
  Model(
    items: List(TreeItem),
    expanded_ids: Dict(String, Bool),
    selected_id: Option(String),
    // Focus management for roving tabindex
    focused_id: Option(String),
    // Multi-char type-ahead state
    typeahead_buffer: String,
    typeahead_timeout: Int,
  )
}

pub type Msg {
  ToggleExpand(String)
  SelectItem(String)
  ExpandAll
  CollapseAll
  ExpandPath(List(String))
  MoveUp
  MoveDown
  MoveFirst
  MoveLast
  ExpandNode
  CollapseNode
  TypeAhead(String)
  SetFocusedId(String)
}

pub fn init(items: List(TreeItem)) -> Model {
  let expanded_ids = collect_expanded_ids(items)
  let first_id = get_first_item_id(items)
  Model(
    items: items,
    expanded_ids: expanded_ids,
    selected_id: None,
    focused_id: first_id,
    typeahead_buffer: "",
    typeahead_timeout: 0,
  )
}

fn collect_expanded_ids(items: List(TreeItem)) -> Dict(String, Bool) {
  collect_expanded_ids_list(items)
  |> list.map(fn(id) { #(id, True) })
  |> dict.from_list
}

fn collect_expanded_ids_list(items: List(TreeItem)) -> List(String) {
  items
  |> list.flat_map(fn(item) {
    case item.expanded {
      True -> [item.id, ..collect_expanded_ids_list(item.children)]
      False -> collect_expanded_ids_list(item.children)
    }
  })
}

/// Get the first item ID from the tree.
fn get_first_item_id(items: List(TreeItem)) -> Option(String) {
  case items {
    [] -> None
    [first, ..] -> Some(first.id)
  }
}

/// Get all visible item IDs (expanded items only).
fn get_visible_item_ids(items: List(TreeItem), expanded_ids: Dict(String, Bool)) -> List(String) {
  collect_visible_ids(items, expanded_ids, [])
}

fn collect_visible_ids(
  items: List(TreeItem),
  expanded_ids: Dict(String, Bool),
  acc: List(String),
) -> List(String) {
  case items {
    [] -> list.reverse(acc)
    [item, ..rest] -> {
      let new_acc = [item.id, ..acc]
      let is_expanded = case dict.get(expanded_ids, item.id) {
        Ok(exp) -> exp
        Error(_) -> False
      }
      case is_expanded {
        True -> collect_visible_ids(item.children, expanded_ids, new_acc) |> list.append(collect_visible_ids(rest, expanded_ids, []))
        False -> collect_visible_ids(rest, expanded_ids, new_acc)
      }
    }
  }
}

/// Find the index of a focused ID in the visible items list.
fn find_focused_index(visible_ids: List(String), focused_id: Option(String)) -> Int {
  case focused_id {
    None -> -1
    Some(id) -> find_index(visible_ids, id)
  }
}

fn find_index(items: List(a), target: a) -> Int {
  do_find_index(items, target, 0)
}

fn do_find_index(items: List(a), target: a, index: Int) -> Int {
  case items {
    [] -> -1
    [x, ..rest] -> {
      case x == target {
        True -> index
        False -> do_find_index(rest, target, index + 1)
      }
    }
  }
}

/// Get item at index in list.
fn get_at(items: List(a), index: Int) -> Option(a) {
  case items, index {
    [], _ -> None
    _, i if i < 0 -> None
    [x, .._rest], 0 -> Some(x)
    [_x, ..rest], i -> get_at(rest, i - 1)
  }
}

/// Get item by ID from the tree.
fn get_item_by_id(items: List(TreeItem), id: String) -> Option(TreeItem) {
  case items {
    [] -> None
    [item, ..rest] -> {
      case item.id == id {
        True -> Some(item)
        False -> {
          case get_item_by_id(rest, id) {
            Some(found) -> Some(found)
            None -> get_item_by_id(item.children, id)
          }
        }
      }
    }
  }
}

pub fn update(model: Model, msg: Msg, current_time: Int) -> Model {
  let visible_ids = get_visible_item_ids(model.items, model.expanded_ids)
  let focused_index = find_focused_index(visible_ids, model.focused_id)
  
  case msg {
    ToggleExpand(id) -> {
      let new_expanded_ids = dict.upsert(
        model.expanded_ids,
        id,
        fn(current) {
          case current {
            Some(expanded) -> !expanded
            None -> True
          }
        },
      )
      Model(..model, expanded_ids: new_expanded_ids)
    }
    SelectItem(id) -> {
      Model(..model, selected_id: Some(id), focused_id: Some(id))
    }
    ExpandAll -> {
      let all_ids = collect_all_ids(model.items)
      let new_expanded_ids = dict.from_list(list.map(all_ids, fn(id) { #(id, True) }))
      Model(..model, expanded_ids: new_expanded_ids)
    }
    CollapseAll -> {
      Model(..model, expanded_ids: dict.new(), focused_id: get_first_item_id(model.items))
    }
    ExpandPath(path) -> {
      let new_expanded_ids = dict.from_list(list.map(path, fn(id) { #(id, True) }))
      Model(..model, expanded_ids: new_expanded_ids)
    }
    MoveUp -> {
      let new_index = keyboard.prev_index(focused_index, list.length(visible_ids), True)
      let new_focused_id = get_at(visible_ids, new_index)
      Model(..model, focused_id: new_focused_id, typeahead_buffer: "")
    }
    MoveDown -> {
      let new_index = keyboard.next_index(focused_index, list.length(visible_ids), True)
      let new_focused_id = get_at(visible_ids, new_index)
      Model(..model, focused_id: new_focused_id, typeahead_buffer: "")
    }
    MoveFirst -> {
      let new_focused_id = case visible_ids {
        [] -> None
        [first, ..] -> Some(first)
      }
      Model(..model, focused_id: new_focused_id, typeahead_buffer: "")
    }
    MoveLast -> {
      let new_focused_id = case list.reverse(visible_ids) {
        [] -> None
        [last, ..] -> Some(last)
      }
      Model(..model, focused_id: new_focused_id, typeahead_buffer: "")
    }
    ExpandNode -> {
      case model.focused_id {
        Some(id) -> {
          case get_item_by_id(model.items, id) {
            Some(item) -> {
              let has_children = !list.is_empty(item.children)
              case has_children {
                True -> {
                  let is_expanded = is_expanded(model, id)
                  let new_expanded_ids = dict.insert(model.expanded_ids, id, !is_expanded)
                  Model(..model, expanded_ids: new_expanded_ids)
                }
                False -> model
              }
            }
            _ -> model
          }
        }
        None -> model
      }
    }
    CollapseNode -> {
      case model.focused_id {
        Some(id) -> {
          case is_expanded(model, id) {
            True -> {
              let new_expanded_ids = dict.insert(model.expanded_ids, id, False)
              Model(..model, expanded_ids: new_expanded_ids)
            }
            False -> model
          }
        }
        None -> model
      }
    }
    TypeAhead(char) -> {
      let #(new_buffer, _reset) = keyboard.update_typeahead_buffer(
        model.typeahead_buffer,
        model.typeahead_timeout,
        current_time,
        char,
        keyboard.default_typeahead_timeout_ms,
      )
      // Find item matching the buffer by label
      let matching_item = find_item_by_label_prefix(model.items, new_buffer)
      let new_focused_id = case matching_item {
        Some(item) -> Some(item.id)
        None -> model.focused_id
      }
      Model(
        ..model,
        focused_id: new_focused_id,
        typeahead_buffer: new_buffer,
        typeahead_timeout: current_time,
      )
    }
    SetFocusedId(id) -> {
      Model(..model, focused_id: Some(id))
    }
  }
}

/// Find an item whose label starts with the given buffer.
fn find_item_by_label_prefix(items: List(TreeItem), buffer: String) -> Option(TreeItem) {
  let normalized_buffer = string.lowercase(buffer)
  do_find_item_by_label_prefix(items, normalized_buffer)
}

fn do_find_item_by_label_prefix(items: List(TreeItem), normalized_buffer: String) -> Option(TreeItem) {
  case items {
    [] -> None
    [item, ..rest] -> {
      case string.starts_with(string.lowercase(item.label), normalized_buffer) {
        True -> Some(item)
        False -> {
          case do_find_item_by_label_prefix(rest, normalized_buffer) {
            Some(found) -> Some(found)
            None -> do_find_item_by_label_prefix(item.children, normalized_buffer)
          }
        }
      }
    }
  }
}

pub fn is_expanded(model: Model, id: String) -> Bool {
  case dict.get(model.expanded_ids, id) {
    Ok(expanded) -> expanded
    Error(_) -> False
  }
}

pub fn is_selected(model: Model, id: String) -> Bool {
  case model.selected_id {
    Some(selected_id) -> selected_id == id
    None -> False
  }
}

pub fn is_focused(model: Model, id: String) -> Bool {
  case model.focused_id {
    Some(focused_id) -> focused_id == id
    None -> False
  }
}

pub fn get_items(model: Model) -> List(TreeItem) {
  model.items
}

pub fn get_selected_id(model: Model) -> Option(String) {
  model.selected_id
}

pub fn get_focused_id(model: Model) -> Option(String) {
  model.focused_id
}

/// Get the element ID for a tree item.
pub fn item_element_id(id: String) -> String {
  "tree-item-" <> id
}

fn collect_all_ids(items: List(TreeItem)) -> List(String) {
  items
  |> list.flat_map(fn(item) {
    [item.id, ..collect_all_ids(item.children)]
  })
}

pub fn render_tree_item(
  model: Model,
  item: TreeItem,
  level: Int,
  render_fn: fn(TreeItem, Bool, Bool, Int) -> element,
) -> List(element) {
  let expanded = is_expanded(model, item.id)
  let selected = is_selected(model, item.id)
  let has_children = !list.is_empty(item.children)

  let item_element = render_fn(item, expanded, selected, level)

  let children_elements = case expanded, has_children {
    True, True -> {
      item.children
      |> list.flat_map(fn(child) {
        render_tree_item(model, child, level + 1, render_fn)
      })
    }
    _, _ -> []
  }

  [item_element, ..children_elements]
}

pub fn has_children(item: TreeItem) -> Bool {
  !list.is_empty(item.children)
}

pub fn indent_class(level: Int) -> String {
  "pl-" <> int.to_string(level * 4)
}

pub fn tree_item_label_class() -> String {
  string.join(
    [
      "flex items-center gap-1 py-1 px-2 rounded-sm text-sm cursor-pointer",
      "outline-none",
      "hover:bg-accent hover:text-accent-foreground",
      "focus:bg-accent focus:text-accent-foreground",
      "aria-selected:bg-accent aria-selected:text-accent-foreground",
    ],
    " ",
  )
}

pub fn tree_group_class() -> String {
  "pl-4"
}

pub fn expand_button_class() -> String {
  string.join(
    [
      "h-4 w-4 p-0 flex items-center justify-center rounded-sm hover:bg-accent",
      "transition-transform duration-200",
    ],
    " ",
  )
}

/// Keymap for tree view.
/// Follows WAI-ARIA tree pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowDown -> Some(MoveDown)
    keyboard.ArrowUp -> Some(MoveUp)
    keyboard.ArrowRight -> Some(ExpandNode)
    keyboard.ArrowLeft -> Some(CollapseNode)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Enter | keyboard.Space -> Some(ToggleExpand(""))
    keyboard.Character("*") -> Some(ExpandAll)
    keyboard.Character(c) -> Some(TypeAhead(c))
    _ -> None
  }
}
