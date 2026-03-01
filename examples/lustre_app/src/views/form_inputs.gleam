//// Form Inputs View
////
//// Renders basic form input components: inputs, checkboxes, switches, radios, selects, and sliders.

// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import lib/tailwind
import lustre/attribute.{attribute, class, type_}
import lustre/element.{type Element, none, text}
import lustre/element/html
import lustre/event
import lustre_utils/checkbox_group as checkbox_group_utils
import lustre_utils/keyboard
import lustre_utils/radio_group as radio_group_utils
import lustre_utils/slider as slider_utils
import lustre_utils/toggle_button_group as toggle_button_group_utils
import types.{
  type Model, type Msg, CheckboxGroupMsg, CheckboxToggled, InputChanged, NoOp,
  RadioGroupMsg, SliderMsg, SwitchToggled, ToggleButtonGroupMsg,
}
import ui/button
import ui/checkbox
import ui/input
import ui/select
import ui/slider
import ui/switch

pub fn view_inputs(model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Inputs"),
    tailwind.vstack_md([
      tailwind.field([
        tailwind.label_text("input-default", "Default input"),
        input.input([
          class("w-full max-w-sm"),
          attribute("data-testid", "input-default"),
          attribute("id", "input-default"),
          attribute("aria-describedby", "input-default-hint"),
          attribute("aria-label", "Default input"),
          attribute("value", model.input_value),
          event.on_input(InputChanged),
        ]),
        tailwind.helper_text_id(
          "input-default-hint",
          "Use Tab to focus. Type to see state update live.",
        ),
      ]),
      tailwind.field([
        tailwind.label_text("input-required", "Required input"),
        input.input([
          class("w-full max-w-sm"),
          attribute("data-testid", "input-required"),
          attribute("id", "input-required"),
          attribute("aria-label", "Required input"),
          attribute("aria-describedby", "input-required-hint"),
          attribute("aria-required", "true"),
          attribute("aria-invalid", case model.input_value == "" {
            True -> "true"
            False -> "false"
          }),
          attribute("placeholder", "This field is required"),
          event.on_input(InputChanged),
        ]),
        tailwind.helper_text_id(
          "input-required-hint",
          "This field must be filled.",
        ),
      ]),
      tailwind.field([
        tailwind.label_text("input-placeholder", "Input with placeholder"),
        input.input([
          class("w-full max-w-sm"),
          attribute("data-testid", "input-placeholder"),
          attribute("id", "input-placeholder"),
          attribute("aria-label", "Input with placeholder"),
          attribute("aria-describedby", "input-placeholder-hint"),
          attribute("placeholder", "Enter text here"),
        ]),
        tailwind.helper_text_id(
          "input-placeholder-hint",
          "Placeholder text shows expected format.",
        ),
      ]),
      tailwind.field([
        tailwind.label_text("input-muted", "Muted input"),
        input.input([
          input.variant(input.Muted),
          class("w-full max-w-sm"),
          attribute("data-testid", "input-muted"),
          attribute("id", "input-muted"),
          attribute("aria-describedby", "input-muted-hint"),
          attribute("aria-label", "Muted input"),
          attribute("placeholder", "muted@example.com"),
        ]),
        tailwind.helper_text_id(
          "input-muted-hint",
          "Muted inputs have subtle focus rings.",
        ),
      ]),
    ]),
  ])
}

pub fn view_switches(model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Switches"),
    tailwind.field([
      html.div(
        [
          attribute("data-testid", "switch-notifications-wrapper"),
          class("flex items-center gap-2"),
        ],
        [
          switch.switch(
            [
              attribute("id", "switch-notifications"),
              attribute("aria-labelledby", "switch-notifications-label"),
              attribute("aria-describedby", "switch-notifications-hint"),
              attribute("aria-checked", case model.switch_enabled {
                True -> "true"
                False -> "false"
              }),
              // Use on_change - fires when checkbox state changes
              event.on_change(fn(_) { SwitchToggled(!model.switch_enabled) }),
            ],
            [
              html.span(
                [
                  attribute("id", "switch-notifications-label"),
                  class("text-sm font-medium"),
                ],
                [text("Enable notifications")],
              ),
            ],
          ),
          html.span(
            [
              attribute("id", "switch-notifications-hint"),
              class("text-sm text-muted-foreground"),
            ],
            [
              text(
                "Toggle with Spacebar when focused; the switch announces state changes.",
              ),
            ],
          ),
        ],
      ),
    ]),
  ])
}

pub fn view_selects() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Selects"),
    tailwind.field([
      select.select(
        [
          attribute("data-testid", "select-default"),
          attribute("aria-describedby", "select-default-hint"),
          attribute("aria-label", "Default select"),
        ],
        [
          select.option([], "Option 1", "option1"),
          select.option([], "Option 2", "option2"),
          select.option([], "Option 3", "option3"),
        ],
      ),
      tailwind.helper_text_id(
        "select-default-hint",
        "Press Enter to open. Use arrow keys to navigate.",
      ),
    ]),
    tailwind.field([
      select.select(
        [
          attribute("data-testid", "select-muted"),
          attribute("aria-describedby", "select-muted-hint"),
          attribute("aria-label", "Muted select"),
          select.variant(select.Muted),
        ],
        [
          select.option([], "Muted Option 1", "muted1"),
          select.option([], "Muted Option 2", "muted2"),
        ],
      ),
      tailwind.helper_text_id(
        "select-muted-hint",
        "Muted styling keeps focus ring visible.",
      ),
    ]),
  ])
}

pub fn view_checkboxes() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Checkboxes"),
    tailwind.field([
      html.div(
        [
          attribute("data-testid", "checkbox-terms-wrapper"),
        ],
        [
          checkbox.checkbox(
            [
              attribute("id", "checkbox-terms"),
              attribute("aria-labelledby", "checkbox-terms-label"),
              attribute("aria-describedby", "checkbox-terms-hint"),
              attribute("aria-checked", "false"),
            ],
            [
              html.span(
                [
                  attribute("id", "checkbox-terms-label"),
                  class("text-sm font-medium"),
                ],
                [text("I agree to terms")],
              ),
            ],
          ),
        ],
      ),
      html.span(
        [
          attribute("id", "checkbox-terms-hint"),
          class("text-xs text-muted-foreground"),
        ],
        [text("Spacebar toggles. Use Shift+Tab to return to previous control.")],
      ),
    ]),
    tailwind.field([
      html.div(
        [
          attribute("data-testid", "checkbox-newsletter-wrapper"),
        ],
        [
          checkbox.checkbox(
            [
              attribute("id", "checkbox-newsletter"),
              attribute("aria-labelledby", "checkbox-newsletter-label"),
              attribute("aria-describedby", "checkbox-newsletter-hint"),
              attribute("aria-checked", "false"),
              checkbox.variant(checkbox.Muted),
            ],
            [
              html.span(
                [
                  attribute("id", "checkbox-newsletter-label"),
                  class("text-sm font-medium"),
                ],
                [text("Subscribe to newsletter")],
              ),
            ],
          ),
        ],
      ),
      html.span(
        [
          attribute("id", "checkbox-newsletter-hint"),
          class("text-xs text-muted-foreground"),
        ],
        [
          text(
            "Optional newsletter. Press Space to toggle, Shift+Tab to return.",
          ),
        ],
      ),
    ]),
  ])
}

pub fn view_radio_group(model: Model) -> Element(Msg) {
  let options = radio_group_utils.options(model.radio_group)
  let indexed_options =
    list.index_map(options, fn(option, index) { #(option, index) })
  let radio_items =
    list.flatten(
      list.map(indexed_options, fn(item) {
        let #(option, index) = item
        let is_checked =
          radio_group_utils.is_selected(model.radio_group, option)
        let is_highlighted = radio_group_utils.is_highlighted(model.radio_group, index)
        let radio_id = radio_group_utils.radio_element_id(index)
        let label_id = "radio-label-" <> int.to_string(index)
        let checked_attrs = case is_checked {
          True -> [attribute("checked", ""), attribute("aria-checked", "true")]
          False -> [attribute("aria-checked", "false")]
        }
        // Roving tabindex: only the highlighted radio has tabindex="0", others have tabindex="-1"
        let tabindex_attrs = case is_highlighted {
          True -> [attribute("tabindex", "0")]
          False -> [attribute("tabindex", "-1")]
        }
        [
          html.label(
            [
              class("flex items-center gap-2 cursor-pointer"),
              attribute("id", label_id),
            ],
            [
              html.input(list.append(
                [
                  type_("radio"),
                  attribute("id", radio_id),
                  attribute("name", "keyboard-radio-options"),
                  attribute("value", option),
                  attribute("aria-labelledby", label_id),
                  // Roving tabindex for keyboard navigation
                  attribute("tabindex", case is_highlighted {
                    True -> "0"
                    False -> "-1"
                  }),
                  event.on_change(fn(_e) {
                    RadioGroupMsg(radio_group_utils.Select(option))
                  }),
                ],
                checked_attrs,
              )),
              html.span([class("text-sm")], [text(option)]),
            ],
          ),
        ]
      }),
    )
  let all_children =
    list.append(
      [
        html.legend(
          [
            class("text-sm font-semibold"),
            attribute("id", "radio-group-label"),
          ],
          [
            text("Choose an option with keyboard"),
          ],
        ),
      ],
      radio_items,
    )
    |> list.append([
      html.span(
        [
          attribute("id", "radio-group-hint"),
          class("text-xs text-muted-foreground"),
        ],
        [
          text(
            "Arrow keys move between options. Space selects the focused option.",
          ),
        ],
      ),
    ])
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Radio Group"),
    tailwind.field([
      html.div(
        [
          class("space-y-2"),
          attribute("data-testid", "radio-group"),
          attribute("id", radio_group_utils.group_element_id()),
          attribute("role", "radiogroup"),
          attribute("aria-label", "Choose an option"),
          attribute("aria-labelledby", "radio-group-label"),
          attribute("aria-describedby", "radio-group-hint"),
          // Remove tabindex="0" from radiogroup - native radio buttons handle focus naturally
          keyboard.on_keydown(fn(event) {
            case radio_group_utils.keymap(event) {
              Some(msg) -> RadioGroupMsg(msg)
              None -> RadioGroupMsg(radio_group_utils.Focus)
            }
          }),
        ],
        all_children,
      ),
    ]),
  ])
}

pub fn view_checkbox_group(model: Model) -> Element(Msg) {
  let options = checkbox_group_utils.options(model.checkbox_group)
  let indexed_options =
    list.index_map(options, fn(option, index) { #(option, index) })
  let checkbox_items =
    list.flatten(
      list.map(indexed_options, fn(item) {
        let #(option, index) = item
        let is_checked =
          checkbox_group_utils.is_checked(model.checkbox_group, option)
        let tabindex =
          checkbox_group_utils.tabindex_for(model.checkbox_group, index)
        let checked_attrs = case is_checked {
          True -> [attribute("checked", "")]
          False -> []
        }
        [
          html.label(
            [
              class("flex items-center gap-2 cursor-pointer"),
            ],
            [
              html.input(list.append(
                [
                  type_("checkbox"),
                  attribute(
                    "id",
                    checkbox_group_utils.checkbox_element_id(index),
                  ),
                  attribute("value", option),
                  attribute("tabindex", int.to_string(tabindex)),
                  event.on_change(fn(_e) {
                    CheckboxGroupMsg(checkbox_group_utils.Toggle(option))
                  }),
                ],
                checked_attrs,
              )),
              html.span([class("text-sm")], [text(option)]),
            ],
          ),
        ]
      }),
    )
  let all_children =
    list.append(
      [
        html.legend([class("text-sm font-semibold")], [
          text("Select multiple options with keyboard"),
        ]),
      ],
      checkbox_items,
    )
    |> list.append([
      tailwind.helper_text_text(
        "Focus with Tab, then use Arrow keys to navigate. Space toggles the focused checkbox. Home/End jump to first/last.",
      ),
    ])
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Checkbox Group"),
    tailwind.field([
      html.div(
        [
          class("space-y-2"),
          attribute("data-testid", "checkbox-group-keyboard-demo"),
          attribute("id", checkbox_group_utils.group_element_id()),
          attribute("role", "group"),
          attribute("aria-label", "Keyboard-enabled checkbox group"),
          attribute("tabindex", "0"),
          keyboard.on_keydown(fn(event) {
            case checkbox_group_utils.keymap(event) {
              Some(msg) -> CheckboxGroupMsg(msg)
              None -> CheckboxGroupMsg(checkbox_group_utils.Focus)
            }
          }),
        ],
        all_children,
      ),
    ]),
  ])
}

pub fn view_toggle_button_group(model: Model) -> Element(Msg) {
  let button_count =
    toggle_button_group_utils.button_count(model.toggle_button_group)
  let indices = list.range(0, button_count - 1)
  let button_items =
    list.map(indices, fn(index) {
      let is_toggled =
        toggle_button_group_utils.is_toggled(model.toggle_button_group, index)
      let tabindex =
        toggle_button_group_utils.tabindex_for(model.toggle_button_group, index)
      let label = case index {
        0 -> "Bold"
        1 -> "Italic"
        2 -> "Underline"
        3 -> "Strikethrough"
        _ -> "Button"
      }
      button.button(
        [
          button.variant(case is_toggled {
            True -> button.Secondary
            False -> button.Ghost
          }),
          button.size(button.Small),
          attribute(
            "id",
            toggle_button_group_utils.toggle_button_element_id(index),
          ),
          attribute("tabindex", int.to_string(tabindex)),
          attribute("aria-pressed", case is_toggled {
            True -> "true"
            False -> "false"
          }),
          event.on_click(
            ToggleButtonGroupMsg(toggle_button_group_utils.Toggle(index)),
          ),
          // Per-button keyboard handler for Space/Enter toggle
          event.advanced("keydown", {
            use key <- decode.field("key", decode.string)
            case key {
              " " | "Enter" ->
                decode.success(event.handler(
                  ToggleButtonGroupMsg(toggle_button_group_utils.Toggle(index)),
                  prevent_default: True,
                  stop_propagation: True,
                ))
              _ ->
                decode.success(event.handler(
                  NoOp,
                  prevent_default: False,
                  stop_propagation: False,
                ))
            }
          }),
        ],
        [text(label)],
      )
    })
  let all_children =
    list.append(button_items, [
      tailwind.helper_text_text(
        "Focus with Tab, then use Arrow keys to navigate. Space/Enter toggles the focused button. Home/End jump to first/last.",
      ),
    ])
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Toggle Button Group"),
    tailwind.field([
      // Wrapper handles navigation (arrows, home, end) and Space/Enter toggle
      // Buttons also handle Space/Enter for direct toggle
      html.div(
        [
          class("flex gap-2"),
          attribute("data-testid", "toggle-button-group-keyboard-demo"),
          attribute("id", toggle_button_group_utils.group_element_id()),
          attribute("role", "group"),
          attribute("aria-label", "Keyboard-enabled toggle button group"),
          attribute("tabindex", "0"),
          keyboard.on_keydown(fn(event) {
            case toggle_button_group_utils.keymap(event) {
              // Handle navigation on wrapper
              Some(msg) as msg_option
                if msg_option == Some(toggle_button_group_utils.MoveNext)
                || msg_option == Some(toggle_button_group_utils.MovePrev)
                || msg_option == Some(toggle_button_group_utils.MoveFirst)
                || msg_option == Some(toggle_button_group_utils.MoveLast)
              -> ToggleButtonGroupMsg(msg)
              // Handle toggle on wrapper - toggle the highlighted button
              Some(toggle_button_group_utils.Toggle(_)) ->
                ToggleButtonGroupMsg(toggle_button_group_utils.Toggle(-1))
              _ -> NoOp
            }
          }),
        ],
        all_children,
      ),
    ]),
  ])
}

pub fn view_slider(model: Model) -> Element(Msg) {
  html.div(
    [
      attribute("data-testid", "sliders-section"),
      class("space-y-6"),
    ],
    [
      tailwind.vstack_md([
        tailwind.section_heading("Slider"),
        tailwind.vstack_md([
          // Keyboard-enabled slider with stateful component - default
          html.div(
            [
              class("space-y-2"),
              attribute("data-testid", "slider-default"),
              keyboard.on_keydown(fn(event) {
                case slider_utils.keymap(event, slider.Horizontal) {
                  Some(msg) -> SliderMsg(msg)
                  None -> SliderMsg(slider_utils.Focus)
                }
              }),
              attribute("tabindex", "0"),
              attribute("id", slider_utils.element_id()),
              attribute("role", "slider"),
              attribute("aria-valuenow", int.to_string(model.slider.value)),
              attribute("aria-valuemin", int.to_string(model.slider.min)),
              attribute("aria-valuemax", int.to_string(model.slider.max)),
              attribute("aria-label", "Keyboard-enabled slider"),
            ],
            [
              slider.slider([
                attribute("min", int.to_string(model.slider.min)),
                attribute("max", int.to_string(model.slider.max)),
                attribute("value", int.to_string(model.slider.value)),
                slider.aria_valuemin(model.slider.min),
                slider.aria_valuemax(model.slider.max),
                slider.aria_valuenow(model.slider.value),
                slider.aria_label("Keyboard-enabled slider"),
                event.on_input(fn(v) {
                  SliderMsg(slider_utils.SetValue(
                    int.parse(v) |> result.unwrap(0),
                  ))
                }),
              ]),
              tailwind.helper_text_text(
                "Focus with Tab, then use Arrow keys to adjust. Home/End for min/max, PageUp/PageDown for larger steps.",
              ),
            ],
          ),
          // Large slider variant
          html.div(
            [
              class("space-y-2"),
              attribute("data-testid", "slider-large"),
              keyboard.on_keydown(fn(event) {
                case slider_utils.keymap(event, slider.Horizontal) {
                  Some(msg) -> SliderMsg(msg)
                  None -> SliderMsg(slider_utils.Focus)
                }
              }),
              attribute("tabindex", "0"),
              attribute("id", "slider-large-element"),
              attribute("role", "slider"),
              attribute("aria-valuenow", int.to_string(model.slider.value)),
              attribute("aria-valuemin", int.to_string(model.slider.min)),
              attribute("aria-valuemax", int.to_string(model.slider.max)),
              attribute("aria-label", "Large keyboard-enabled slider"),
            ],
            [
              slider.slider([
                attribute("min", int.to_string(model.slider.min)),
                attribute("max", int.to_string(model.slider.max)),
                attribute("value", int.to_string(model.slider.value)),
                slider.aria_valuemin(model.slider.min),
                slider.aria_valuemax(model.slider.max),
                slider.aria_valuenow(model.slider.value),
                slider.aria_label("Large keyboard-enabled slider"),
                event.on_input(fn(v) {
                  SliderMsg(slider_utils.SetValue(
                    int.parse(v) |> result.unwrap(0),
                  ))
                }),
              ]),
              tailwind.helper_text_text("Large slider variant."),
            ],
          ),
        ]),
      ]),
      html.p(
        [
          attribute("data-testid", "sliders-keyboard-hint"),
          class("text-xs text-muted-foreground"),
        ],
        [text("Sliders: arrow keys adjust value, Home/End for min/max.")],
      ),
    ],
  )
}

pub fn view(model: Model) -> Element(Msg) {
  tailwind.vstack_xl([
    view_inputs(model),
    view_selects(),
    view_checkboxes(),
    view_switches(model),
    view_radio_group(model),
    view_checkbox_group(model),
    view_toggle_button_group(model),
    view_slider(model),
  ])
}
