import gleam/bool
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, none, text}
import lustre/element/html.{button, div, h2, p}
import lustre/event
import lib/tailwind
import lustre_utils/dialog as dialog_utils
import lustre_utils/modal as modal_utils
import types.{
  type Model, type Msg, DialogMsg, DisclosureToggled, ModalMsg, NoOp, ToggleTooltip,
}
import ui/button
import ui/dialog
import ui/disclosure
import ui/modal

pub fn view_dialogs(model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Dialog"),
    tailwind.hwrap_md([
      button.button(
        [
          button.variant(button.Default),
          button.size(button.Medium),
          attribute("id", "dialog-trigger"),
          attribute("data-testid", "dialog-trigger"),
          event.on_click(DialogMsg(dialog_utils.Toggle)),
        ],
        [text("Open Dialog")],
      ),
      bool.guard(
        dialog_utils.is_open(model.dialog),
        div(
          [
            class("fixed inset-0 z-50"),
            event.on_click(DialogMsg(dialog_utils.Close)),
            event.on_keydown(fn(key) {
              case key {
                "Escape" -> DialogMsg(dialog_utils.Escape)
                _ -> NoOp
              }
            }),
          ],
          [
            dialog.dialog(
              [
                attribute("data-testid", "dialog-wrapper"),
                attribute("data-state", "open"),
              ],
              [
                dialog.content(
                  [
                    attribute("id", model.dialog.focus_scope_id),
                    attribute("data-state", "open"),
                    attribute("aria-labelledby", "dialog-title"),
                  ],
                  [
                    dialog.title([attribute("id", "dialog-title")], [
                      text("Edit Profile"),
                    ]),
                    dialog.description([], [
                      text(
                        "Make changes to your profile here. Click save when you're done.",
                      ),
                    ]),
                    dialog.close([
                      attribute("data-testid", "dialog-close"),
                      event.on_click(DialogMsg(dialog_utils.Close)),
                    ]),
                    tailwind.button_group_right([
                      button.button(
                        [
                          button.variant(button.Secondary),
                          button.size(button.Medium),
                          event.on_click(DialogMsg(dialog_utils.Close)),
                          attribute("data-testid", "dialog-cancel"),
                        ],
                        [text("Cancel")],
                      ),
                      button.button(
                        [
                          button.variant(button.Default),
                          button.size(button.Medium),
                          event.on_click(DialogMsg(dialog_utils.Close)),
                          attribute("data-testid", "dialog-save"),
                        ],
                        [text("Save")],
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ],
        ),
        fn() { none() },
      ),
    ]),
  ])
}

pub fn view_modals(model: Model) -> Element(Msg) {
  let is_open = modal_utils.is_open(model.modal)
  tailwind.vstack_md([
    tailwind.section_heading("Modal"),
    tailwind.section_description_text("Modal with focus trap, aria-modal, and aria-describedby."),
    tailwind.hwrap_md([
      button.button(
        [
          button.variant(button.Default),
          button.size(button.Medium),
          attribute("id", "modal-trigger"),
          attribute("data-testid", "modal-trigger"),
          event.on_click(ModalMsg(modal_utils.Toggle)),
        ],
        [text("Open Modal")],
      ),
    ]),
    bool.guard(
      is_open,
      modal.modal(
        [
          attribute("data-testid", "modal-wrapper"),
          attribute("tabindex", "-1"),
          modal.aria_labelledby("modal-title"),
          modal.aria_describedby("modal-description"),
          event.on_keydown(fn(key) {
            case key {
              "Escape" -> ModalMsg(modal_utils.Escape)
              _ -> NoOp
            }
          }),
        ],
        [
          modal.underlay([
            attribute("data-testid", "modal-underlay"),
            event.on_click(ModalMsg(modal_utils.Close)),
          ]),
          modal.content(
            [
              attribute("id", model.modal.focus_scope_id),
              modal.size(modal.Medium),
              attribute("data-testid", "modal-content"),
              attribute("data-state", "open"),
              event.on_keydown(fn(key) {
                case key {
                  "Escape" -> ModalMsg(modal_utils.Escape)
                  _ -> NoOp
                }
              }),
            ],
            [
              h2(
                [
                  attribute("id", "modal-title"),
                  class("text-lg font-semibold"),
                ],
                [text("Modal Title")],
              ),
              p(
                [
                  attribute("id", "modal-description"),
                  class("text-sm text-muted-foreground mt-2"),
                ],
                [text("This modal has aria-modal=true and aria-describedby pointing to this description. Focus should be trapped within the modal while open.")],
              ),
              tailwind.button_group_right([
                button.button(
                  [
                    button.variant(button.Secondary),
                    button.size(button.Medium),
                    event.on_click(ModalMsg(modal_utils.Close)),
                    attribute("data-testid", "modal-close"),
                  ],
                  [text("Close")],
                ),
              ]),
            ],
          ),
        ],
      ),
      fn() { none() },
    ),
    tailwind.helper_text_text("Escape closes modal. Tab cycles focus within modal content."),
  ])
}

pub fn view_disclosures(model: Model) -> Element(Msg) {
  let panel_visibility = case model.disclosure_expanded {
    True -> ""
    False -> " hidden"
  }

  tailwind.vstack_md([
    tailwind.section_heading("Disclosure"),
    tailwind.section_description_text("Disclosure with aria-expanded and aria-controls."),
    disclosure.disclosure([attribute("data-testid", "disclosure-wrapper")], [
      disclosure.trigger(
        [
          disclosure.aria_controls("disclosure-panel"),
          disclosure.aria_expanded(model.disclosure_expanded),
          event.on_click(DisclosureToggled),
          attribute("data-testid", "disclosure-trigger"),
        ],
        [
          text("Toggle Details"),
          div(
            [
              class(
                "ml-auto transition-transform"
                <> case model.disclosure_expanded {
                  True -> " rotate-180"
                  False -> ""
                },
              ),
            ],
            [text("▼")],
          ),
        ],
      ),
      disclosure.panel(
        [
          attribute("id", "disclosure-panel"),
          attribute("data-testid", "disclosure-panel"),
          class(panel_visibility),
        ],
        [
          text(
            "This content is revealed when the disclosure is expanded. The trigger button has aria-expanded toggling between true/false and aria-controls pointing to this panel's ID.",
          ),
        ],
      ),
    ]),
    tailwind.helper_text_text("Space or Enter toggles disclosure when trigger is focused."),
  ])
}

pub fn view_tooltips(model: Model) -> Element(Msg) {
  let tooltip_visibility_class = case model.tooltip_visible {
    True -> ""
    False -> " hidden"
  }

  tailwind.vstack_md([
    tailwind.section_heading("Tooltips"),
    tailwind.section_description_text("Tooltip with aria-describedby and focus/hover triggers."),
    tailwind.hwrap_lg([
      div([class("relative inline-flex group")], [
        button.button(
          [
            button.variant(button.Default),
            button.size(button.Medium),
            event.on_click(ToggleTooltip),
            attribute("data-testid", "tooltip-trigger-default"),
            attribute("aria-describedby", "tooltip-content-default"),
          ],
          [text("Click me")],
        ),
        div(
          [
            attribute("id", "tooltip-content-default"),
            attribute("role", "tooltip"),
            attribute("data-testid", "tooltip-default"),
            class(
              "absolute z-50 whitespace-nowrap rounded-md bg-primary px-3 py-1.5 text-primary-foreground text-sm shadow-md bottom-full left-1/2 -translate-x-1/2 mb-3"
              <> tooltip_visibility_class,
            ),
          ],
          [text("Tooltip content")],
        ),
      ]),
      div([class("relative inline-flex group")], [
        button.button(
          [
            button.variant(button.Outline),
            button.size(button.Medium),
            class("peer"),
            attribute("data-testid", "tooltip-trigger-focus"),
            attribute("aria-describedby", "tooltip-content-focus"),
          ],
          [text("Focus me")],
        ),
        div(
          [
            attribute("id", "tooltip-content-focus"),
            attribute("role", "tooltip"),
            attribute("data-testid", "tooltip-focus"),
            class(
              "absolute z-50 whitespace-nowrap rounded-md bg-muted px-3 py-1.5 text-muted-foreground text-sm shadow-md bottom-full left-1/2 -translate-x-1/2 mb-3 opacity-0 peer-hover:opacity-100 focus-within:opacity-100 peer-focus:opacity-100 transition-opacity",
            ),
          ],
          [text("Focus tooltip")],
        ),
      ]),
      div([class("relative inline-flex group")], [
        button.button(
          [
            button.variant(button.Secondary),
            button.size(button.Medium),
            class("peer"),
            attribute("data-testid", "tooltip-trigger-hover"),
            attribute("aria-describedby", "tooltip-content-hover"),
          ],
          [text("Hover me")],
        ),
        div(
          [
            attribute("id", "tooltip-content-hover"),
            attribute("role", "tooltip"),
            attribute("data-testid", "tooltip-hover"),
            class(
              "absolute z-50 whitespace-nowrap rounded-md bg-accent px-3 py-1.5 text-accent-foreground text-sm shadow-md bottom-full left-1/2 -translate-x-1/2 mb-3 opacity-0 peer-hover:opacity-100 transition-opacity",
            ),
          ],
          [text("Hover tooltip")],
        ),
      ]),
    ]),
    tailwind.helper_text_text("Tooltips should appear on hover or focus. Screen readers announce content via aria-describedby."),
  ])
}

pub fn view(model: Model) -> Element(Msg) {
  tailwind.vstack_xl([
    view_dialogs(model),
    view_modals(model),
    view_disclosures(model),
    view_tooltips(model),
  ])
}
