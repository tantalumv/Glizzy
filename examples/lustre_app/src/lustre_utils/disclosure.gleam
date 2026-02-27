import gleam/option.{type Option, None, Some}
import lustre_utils/keyboard as keyboard

pub type Model {
  Model(is_open: Bool)
}

pub type Msg {
  Toggle
  Open
  Close
}

pub fn init() -> Model {
  Model(is_open: False)
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Toggle -> Model(is_open: !model.is_open)
    Open -> Model(is_open: True)
    Close -> Model(is_open: False)
  }
}

pub fn is_open(model: Model) -> Bool {
  model.is_open
}

pub fn is_closed(model: Model) -> Bool {
  !model.is_open
}

/// Keymap for disclosure.
pub fn keymap(key_event: keyboard.KeyEvent) -> Option(Msg) {
  case keyboard.decode_key(key_event.key) {
    keyboard.Enter | keyboard.Space -> Some(Toggle)
    _ -> None
  }
}
