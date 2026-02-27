import types.{type Model, type Msg}
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h2}
import lib/tailwind
import ui/button

pub fn view_buttons() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Buttons"),
    tailwind.hwrap_md([
      button.button(
        [
          button.variant(button.Default),
          button.size(button.Medium),
          attribute("data-testid", "btn-default"),
        ],
        [text("Default")],
      ),
      button.button(
        [
          button.variant(button.Secondary),
          button.size(button.Medium),
          attribute("data-testid", "btn-secondary"),
        ],
        [text("Secondary")],
      ),
      button.button(
        [
          button.variant(button.Destructive),
          button.size(button.Medium),
          attribute("data-testid", "btn-destructive"),
        ],
        [text("Destructive")],
      ),
      button.button(
        [
          button.variant(button.Outline),
          button.size(button.Medium),
          attribute("data-testid", "btn-outline"),
        ],
        [text("Outline")],
      ),
      button.button(
        [
          button.variant(button.Ghost),
          button.size(button.Medium),
          attribute("data-testid", "btn-ghost"),
        ],
        [text("Ghost")],
      ),
      button.button(
        [
          button.variant(button.Link),
          button.size(button.Medium),
          attribute("data-testid", "btn-link"),
        ],
        [text("Link")],
      ),
    ]),
  ])
}

pub fn view(_model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    view_buttons(),
  ])
}
