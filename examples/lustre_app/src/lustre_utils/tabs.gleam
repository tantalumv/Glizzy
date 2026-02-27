import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre_utils/keyboard as keyboard

pub type Model {
  Model(selected: String, tabs: List(String))
}

pub type Orientation {
  Horizontal
  Vertical
}

pub type Msg {
  Select(String)
  SelectNext
  SelectPrev
  SelectFirst
  SelectLast
  // Optional features from deferred keyboard functions
  OpenPopupMenu
  CloseCurrentTab
}

pub fn init(tabs: List(String), initial: String) -> Model {
  Model(selected: initial, tabs: tabs)
}

fn find_index(items: List(a), item: a) -> Int {
  case items {
    [] -> 0
    [x, ..rest] -> {
      case x == item {
        True -> 0
        False -> 1 + find_index(rest, item)
      }
    }
  }
}

fn get_at(items: List(a), index: Int) -> option.Option(a) {
  case items {
    [] -> None
    [x, ..rest] -> {
      case index == 0 {
        True -> Some(x)
        False -> get_at(rest, index - 1)
      }
    }
  }
}

fn next_tab(tabs: List(String), current: String) -> String {
  let index = find_index(tabs, current)
  let next = case index + 1 >= list.length(tabs) {
    True -> 0
    False -> index + 1
  }
  get_at(tabs, next) |> option.unwrap(current)
}

fn prev_tab(tabs: List(String), current: String) -> String {
  let index = find_index(tabs, current)
  let prev = case index == 0 {
    True -> list.length(tabs) - 1
    False -> index - 1
  }
  get_at(tabs, prev) |> option.unwrap(current)
}

fn first_tab(tabs: List(String)) -> String {
  case tabs {
    [] -> ""
    [first, ..] -> first
  }
}

fn last_tab(tabs: List(String)) -> String {
  tabs |> list.reverse |> first_tab
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Select(tab) -> Model(..model, selected: tab)
    SelectNext -> Model(..model, selected: next_tab(model.tabs, model.selected))
    SelectPrev -> Model(..model, selected: prev_tab(model.tabs, model.selected))
    SelectFirst -> Model(..model, selected: first_tab(model.tabs))
    SelectLast -> Model(..model, selected: last_tab(model.tabs))
    // Optional features - no-op if not implemented
    OpenPopupMenu -> model
    CloseCurrentTab -> model
  }
}

pub fn selected_tab(model: Model) -> String {
  model.selected
}

pub fn is_selected(model: Model, tab: String) -> Bool {
  model.selected == tab
}

/// Get the element ID for a tab button.
pub fn tab_element_id(tab: String) -> String {
  "tab-" <> string_to_safe_id(tab)
}

/// Convert a string to a safe ID by replacing spaces and special chars.
fn string_to_safe_id(s: String) -> String {
  s
  |> string.lowercase
  |> string.replace(each: " ", with: "-")
  |> string.replace(each: "_", with: "-")
  |> string.replace(each: ".", with: "-")
}

/// Keymap for tabs keyboard navigation.
/// Follows WAI-ARIA tabs pattern.
pub fn keymap(key_event: keyboard.KeyEvent, orientation: Orientation) -> Option(Msg) {
  let nav_keys = case orientation {
    Horizontal -> #(keyboard.ArrowRight, keyboard.ArrowLeft)
    Vertical -> #(keyboard.ArrowDown, keyboard.ArrowUp)
  }
  case keyboard.decode_key(key_event.key) {
    keyboard.Home -> Some(SelectFirst)
    keyboard.End -> Some(SelectLast)
    key if key == nav_keys.0 -> Some(SelectNext)
    key if key == nav_keys.1 -> Some(SelectPrev)
    // Optional: Shift+F10 for popup menu (if tabs have context menus)
    keyboard.F10 if key_event.shift -> Some(OpenPopupMenu)
    // Optional: Delete to close current tab (if tabs are closable)
    keyboard.Delete -> Some(CloseCurrentTab)
    _ -> None
  }
}
