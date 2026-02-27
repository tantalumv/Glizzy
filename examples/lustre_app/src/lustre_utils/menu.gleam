import gleam/int
import gleam/option.{type Option, None, Some}
import lustre_utils/keyboard as keyboard

pub type Model {
  Model(highlighted_index: Int, is_open: Bool, item_count: Int)
}

pub type Msg {
  Toggle
  Open
  Close
  Escape
  ClickOutside
  Select
  MoveUp
  MoveDown
  MoveFirst
  MoveLast
  SetHighlightedIndex(Int)
}

pub fn init(item_count: Int) -> Model {
  Model(highlighted_index: -1, is_open: False, item_count: item_count)
}

pub fn init_open(item_count: Int) -> Model {
  Model(highlighted_index: 0, is_open: True, item_count: item_count)
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Toggle -> Model(..model, is_open: !model.is_open)
    Open -> Model(..model, is_open: True)
    Close -> Model(..model, is_open: False, highlighted_index: -1)
    Escape -> Model(..model, is_open: False, highlighted_index: -1)
    ClickOutside -> Model(..model, is_open: False, highlighted_index: -1)
    Select -> Model(..model, is_open: False, highlighted_index: -1)
    MoveUp -> {
      let new_index = keyboard.prev_index(model.highlighted_index, model.item_count, True)
      Model(..model, highlighted_index: new_index)
    }
    MoveDown -> {
      let new_index = keyboard.next_index(model.highlighted_index, model.item_count, True)
      Model(..model, highlighted_index: new_index)
    }
    MoveFirst -> Model(..model, highlighted_index: keyboard.first_index(model.item_count))
    MoveLast -> Model(..model, highlighted_index: keyboard.last_index(model.item_count))
    SetHighlightedIndex(index) -> Model(..model, highlighted_index: index)
  }
}

pub fn is_open(model: Model) -> Bool {
  model.is_open
}

pub fn is_closed(model: Model) -> Bool {
  !model.is_open
}

pub fn highlighted_index(model: Model) -> Int {
  model.highlighted_index
}

pub fn is_highlighted(model: Model, index: Int) -> Bool {
  model.highlighted_index == index
}

/// Get the element ID for a menu item at the given index.
pub fn item_element_id(index: Int) -> String {
  "menu-item-" <> int.to_string(index)
}

/// Keymap for menu keyboard navigation.
/// Follows WAI-ARIA menu pattern.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.ArrowDown -> Some(MoveDown)
    keyboard.ArrowUp -> Some(MoveUp)
    keyboard.Home -> Some(MoveFirst)
    keyboard.End -> Some(MoveLast)
    keyboard.Enter | keyboard.Space -> Some(Select)
    keyboard.Escape -> Some(Escape)
    _ -> None
  }
}
