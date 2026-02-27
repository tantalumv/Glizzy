import gleam/bool
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, none, text}
import lustre/element/html.{button, div, h2, input, p}
import lustre/event
import lib/tailwind
import lustre_utils/combobox as combobox_utils
import lustre_utils/grid_list as grid_list_utils
import lustre_utils/keyboard
import lustre_utils/select as select_utils
import lustre_utils/table as table_utils
import lustre_utils/virtualizer_utils
import types.{
  type Model, type Msg, ComboboxMsg, CustomSelectMsg, GridListMsg, NoOp, TableMsg,
}
import ui/button
import ui/checkbox
import ui/drop_zone
import ui/grid_list
import ui/group
import ui/list_box
import ui/table
import ui/tag_group
import ui/virtualizer

pub fn view_collections() -> Element(Msg) {
  tailwind.vstack_lg([
    tailwind.section_heading("Collections & Data"),

    tailwind.field([
      tailwind.section_description_text("List Box - Keyboard navigation, aria-activedescendant"),
      list_box.list_box(
        [
          list_box.aria_label("Select an item"),
          list_box.selection_mode(list_box.Single),
          attribute("data-testid", "listbox-demo"),
        ],
        [
          list_box.list_box_option(
            [attribute("id", "lb-option-1")],
            "Option One",
            "opt1",
          ),
          list_box.list_box_option(
            [attribute("id", "lb-option-2")],
            "Option Two",
            "opt2",
          ),
          list_box.list_box_option(
            [attribute("id", "lb-option-3")],
            "Option Three",
            "opt3",
          ),
        ],
      ),
    ]),

    tailwind.field([
      tailwind.section_description_text("Grid List - Multi-select with aria-multiselectable"),
      grid_list.grid_list(
        [
          grid_list.aria_label("Select items"),
          grid_list.selection_mode(grid_list.Multiple),
          attribute("data-testid", "gridlist-demo"),
        ],
        [
          grid_list.grid_list_item(
            [attribute("data-testid", "gridlist-item-1")],
            [text("Item A")],
          ),
          grid_list.grid_list_item(
            [attribute("data-testid", "gridlist-item-2")],
            [text("Item B")],
          ),
          grid_list.grid_list_item(
            [attribute("data-testid", "gridlist-item-3")],
            [text("Item C")],
          ),
        ],
      ),
    ]),

    tailwind.field([
      tailwind.section_description_text("Table - role=grid with sortable columns"),
      table.table(
        [
          table.aria_label("Data table"),
          attribute("data-testid", "table-demo"),
        ],
        [
          table.table_header([], [
            table.table_header_row([], [
              table.table_column_header([], [text("Name")]),
              table.table_column_header([], [text("Status")]),
              table.table_column_header([], [text("Actions")]),
            ]),
          ]),
          table.table_body([], [
            table.table_row([attribute("data-testid", "table-row-1")], [
              table.table_cell([], [text("Item Alpha")]),
              table.table_cell([], [text("Active")]),
              table.table_cell([], [text("Edit")]),
            ]),
            table.table_row([attribute("data-testid", "table-row-2")], [
              table.table_cell([], [text("Item Beta")]),
              table.table_cell([], [text("Pending")]),
              table.table_cell([], [text("Edit")]),
            ]),
          ]),
        ],
      ),
    ]),

    tailwind.field([
      tailwind.section_description_text("Tag Group - Removable tags with aria-selected"),
      tag_group.tag_group(
        [
          attribute("data-testid", "tag-group-demo"),
        ],
        "Selected filters",
        [
          tag_group.tag(
            [
              tag_group.variant(tag_group.Default),
              tag_group.size(tag_group.Medium),
              attribute("data-testid", "tag-1"),
            ],
            [text("React")],
          ),
          tag_group.tag(
            [
              tag_group.variant(tag_group.Secondary),
              tag_group.size(tag_group.Medium),
              attribute("data-testid", "tag-2"),
            ],
            [text("Gleam")],
          ),
          tag_group.tag_with_remove(
            [
              tag_group.variant(tag_group.Outline),
              tag_group.size(tag_group.Medium),
              attribute("data-testid", "tag-3"),
            ],
            [text("Lustre")],
          ),
        ],
      ),
    ]),

    tailwind.field([
      tailwind.section_description_text("Group - role=group for related controls"),
      group.group(
        [
          group.aria_label("Filter options"),
          attribute("data-testid", "group-demo"),
        ],
        [
          checkbox.checkbox([attribute("id", "group-cb-1")], [text("Active")]),
          checkbox.checkbox([attribute("id", "group-cb-2")], [text("Archived")]),
        ],
      ),
    ]),

    tailwind.field([
      tailwind.section_description_text("Virtualizer - Virtual scrolling container"),
      virtualizer.virtualizer(
        [
          virtualizer.aria_label("Virtual list"),
          attribute("data-testid", "virtualizer-demo"),
          class("h-64"),
        ],
        virtualizer_utils.generate_virtualizer_items(100),
      ),
    ]),

    tailwind.helper_text_text("Use arrow keys to navigate list/tree items. Space/Enter selects. Escape closes trees."),
  ])
}

pub fn view_custom_select(model: Model) -> Element(Msg) {
  let options = select_utils.options(model.custom_select)
  let indices = list.range(0, list.length(options) - 1)
  let display_text = select_utils.display_text(model.custom_select)
  let highlighted_option_id = case model.custom_select.is_open && model.custom_select.highlighted_index >= 0 {
    True -> select_utils.option_element_id(model.custom_select.highlighted_index)
    False -> ""
  }
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Custom Select"),
    div(
      [
        class("relative"),
        attribute("data-testid", "custom-select-keyboard-demo"),
        attribute("tabindex", "0"),
        event.advanced("keydown", {
          use key <- decode.field("key", decode.string)
          use shift <- decode.field("shiftKey", decode.bool)
          use ctrl <- decode.field("ctrlKey", decode.bool)
          use meta <- decode.field("metaKey", decode.bool)
          use alt <- decode.field("altKey", decode.bool)

          // Only prevent default for navigation keys to avoid page scroll
          let should_prevent = case key {
            "Home" | "End" | "ArrowUp" | "ArrowDown" | "PageUp" | "PageDown" | " " -> True
            _ -> False
          }

          let key_event = keyboard.KeyEvent(key:, shift:, ctrl:, meta:, alt:)
          case select_utils.keymap(key_event, model.custom_select.is_open) {
            Some(msg) -> decode.success(event.handler(CustomSelectMsg(msg), prevent_default: should_prevent, stop_propagation: False))
            None -> decode.success(event.handler(NoOp, prevent_default: False, stop_propagation: False))
          }
        }),
      ],
      [
        // Select trigger - button has the combobox role
        html.button(
          [
            attribute("type", "button"),
            attribute("tabindex", "0"),
            attribute("role", "combobox"),
            attribute("aria-expanded", case model.custom_select.is_open {
              True -> "true"
              False -> "false"
            }),
            attribute("aria-haspopup", "listbox"),
            attribute("aria-label", "Keyboard-enabled custom select"),
            class("w-full justify-between p-2 border rounded-md cursor-pointer hover:bg-accent focus:outline-none focus:ring-2 focus:ring-primary"),
            event.on_click(CustomSelectMsg(select_utils.Toggle)),
            event.on_focus(CustomSelectMsg(select_utils.Focus)),
            // Handle keyboard events: Enter/Space toggle when closed, select when open
            event.advanced("keydown", {
              use key <- decode.field("key", decode.string)
              case key {
                "Enter" | " " -> {
                  // When dropdown is open, Select the highlighted option
                  // When closed, Toggle to open
                  let msg = case model.custom_select.is_open {
                    True -> select_utils.Select("")
                    False -> select_utils.Toggle
                  }
                  decode.success(event.handler(
                    CustomSelectMsg(msg),
                    prevent_default: True,
                    stop_propagation: True
                  ))
                }
                "ArrowDown" -> {
                  // Open and move to first item if closed, otherwise navigate
                  decode.success(event.handler(
                    CustomSelectMsg(select_utils.MoveNext),
                    prevent_default: True,
                    stop_propagation: True
                  ))
                }
                "ArrowUp" -> {
                  decode.success(event.handler(
                    CustomSelectMsg(select_utils.MovePrev),
                    prevent_default: True,
                    stop_propagation: True
                  ))
                }
                "Escape" -> {
                  decode.success(event.handler(
                    CustomSelectMsg(select_utils.Close),
                    prevent_default: True,
                    stop_propagation: True
                  ))
                }
                _ -> decode.success(event.handler(NoOp, prevent_default: False, stop_propagation: False))
              }
            }),
            // F7: Use aria-activedescendant to indicate active option
            attribute("aria-activedescendant", highlighted_option_id),
          ],
          [text(display_text)],
        ),
        // Dropdown content
        bool.guard(
          model.custom_select.is_open,
          div(
            [
              class(
                "absolute z-50 w-full mt-1 border rounded-md bg-background shadow-lg",
              ),
              attribute("id", select_utils.listbox_element_id()),
              attribute("role", "listbox"),
              attribute("tabindex", "-1"),
              attribute("aria-labelledby", "custom-select"),
            ],
            list.flatten(
              list.map(indices, fn(index) {
                case select_utils.option_at(model.custom_select, index) {
                  Some(opt) -> {
                    let is_highlighted =
                      select_utils.is_highlighted(model.custom_select, index)
                    let is_selected =
                      select_utils.is_selected(model.custom_select, opt.value)
                    [
                      div(
                        [
                          class(
                            "p-2 cursor-pointer hover:bg-accent"
                            <> case is_highlighted {
                              True -> " bg-accent"
                              False -> ""
                            },
                          ),
                          attribute("id", select_utils.option_element_id(index)),
                          attribute("role", "option"),
                          attribute("aria-selected", case is_selected {
                            True -> "true"
                            False -> "false"
                          }),
                          event.on_click(
                            CustomSelectMsg(select_utils.Select(opt.value)),
                          ),
                        ],
                        [
                          text(opt.label),
                        ],
                      ),
                    ]
                  }
                  None -> [none()]
                }
              }),
            ),
          ),
          fn() { none() },
        ),
        tailwind.helper_text_text("Focus with Tab, then use Arrow keys to navigate. Type to search. Enter/Space selects. Escape closes."),
      ],
    ),
  ])
}

pub fn view_combobox(model: Model) -> Element(Msg) {
  let options = combobox_utils.options(model.combobox)
  let indices = list.range(0, list.length(options) - 1)
  let highlighted_option_id = case model.combobox.is_open && model.combobox.highlighted_index >= 0 {
    True -> combobox_utils.option_element_id(model.combobox.highlighted_index)
    False -> ""
  }
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Combobox"),
    div(
      [
        class("relative"),
        attribute("data-testid", "combobox-keyboard-demo"),
        attribute("id", "combobox-wrapper"),
        attribute("tabindex", "0"),
        event.advanced("keydown", {
          use key <- decode.field("key", decode.string)
          use shift <- decode.field("shiftKey", decode.bool)
          use ctrl <- decode.field("ctrlKey", decode.bool)
          use meta <- decode.field("metaKey", decode.bool)
          use alt <- decode.field("altKey", decode.bool)

          // Only prevent default for navigation keys to avoid page scroll
          let should_prevent = case key {
            "Home" | "End" | "ArrowUp" | "ArrowDown" | "PageUp" | "PageDown" -> True
            _ -> False
          }

          let key_event = keyboard.KeyEvent(key:, shift:, ctrl:, meta:, alt:)
          case combobox_utils.keymap(key_event, model.combobox.is_open) {
            Some(msg) -> decode.success(event.handler(ComboboxMsg(msg), prevent_default: should_prevent, stop_propagation: False))
            None -> decode.success(event.handler(NoOp, prevent_default: False, stop_propagation: False))
          }
        }),
      ],
      [
        // Input field - handles all input and keyboard events
        input([
          class("w-full border rounded-md p-2"),
          attribute("value", model.combobox.input_value),
          attribute("placeholder", combobox_utils.placeholder(model.combobox)),
          attribute("role", "combobox"),
          attribute("aria-autocomplete", "list"),
          attribute("aria-controls", combobox_utils.listbox_element_id()),
          // F8: Use aria-activedescendant to indicate active option
          attribute("aria-activedescendant", highlighted_option_id),
          event.on_input(fn(v) { ComboboxMsg(combobox_utils.InputChange(v)) }),
          // F3: Use prevent_default to stop input's default Space behavior
          event.advanced("keydown", {
            use key <- decode.field("key", decode.string)
            use shift <- decode.field("shiftKey", decode.bool)
            use ctrl <- decode.field("ctrlKey", decode.bool)
            use meta <- decode.field("metaKey", decode.bool)
            use alt <- decode.field("altKey", decode.bool)

            // Only prevent default for navigation keys
            let should_prevent = case key {
              "Home" | "End" | "ArrowUp" | "ArrowDown" | "PageUp" | "PageDown" | " " -> True
              _ -> False
            }

            let key_event = keyboard.KeyEvent(key:, shift:, ctrl:, meta:, alt:)
            case combobox_utils.keymap(key_event, model.combobox.is_open) {
              Some(msg) -> decode.success(event.handler(ComboboxMsg(msg), prevent_default: should_prevent, stop_propagation: False))
              None -> decode.success(event.handler(NoOp, prevent_default: False, stop_propagation: False))
            }
          }),
        ]),
        // Dropdown content
        bool.guard(
          model.combobox.is_open,
          div(
            [
              class(
                "absolute z-50 w-full mt-1 border rounded-md bg-background shadow-lg max-h-60 overflow-y-auto",
              ),
              attribute("id", combobox_utils.listbox_element_id()),
              attribute("role", "listbox"),
              attribute("tabindex", "-1"),
              attribute("aria-labelledby", "combobox"),
            ],
            list.flatten(
              list.map(indices, fn(index) {
                case combobox_utils.option_at(model.combobox, index) {
                  Some(opt) -> {
                    let is_highlighted =
                      combobox_utils.is_highlighted(model.combobox, index)
                    let is_selected =
                      combobox_utils.is_selected(model.combobox, opt.value)
                    [
                      div(
                        [
                          class(
                            "p-2 cursor-pointer hover:bg-accent"
                            <> case is_highlighted {
                              True -> " bg-accent"
                              False -> ""
                            },
                          ),
                          attribute(
                            "id",
                            combobox_utils.option_element_id(index),
                          ),
                          attribute("role", "option"),
                          attribute("aria-selected", case is_selected {
                            True -> "true"
                            False -> "false"
                          }),
                          event.on_click(
                            ComboboxMsg(combobox_utils.Select(opt.value)),
                          ),
                        ],
                        [
                          text(opt.label),
                        ],
                      ),
                    ]
                  }
                  None -> [none()]
                }
              }),
            ),
          ),
          fn() { none() },
        ),
        tailwind.helper_text_text("Type to filter. Arrow keys navigate filtered results. Enter/Space selects. Escape closes."),
      ],
    ),
  ])
}

pub fn view_grid_list(model: Model) -> Element(Msg) {
  let items = grid_list_utils.items(model.grid_list)
  let indices = list.range(0, list.length(items) - 1)
  let grid_items =
    list.flatten(
      list.map(indices, fn(index) {
        case get_at_index(items, index) {
          Ok(item) -> {
            let row = index / model.grid_list.cols
            let col = index % model.grid_list.cols
            let is_focused =
              model.grid_list.focused_row == row
              && model.grid_list.focused_col == col
            // F6: Check selected_items for multi-select, or selected for single-select
            let is_selected = case model.grid_list.multi_select {
              True -> list.contains(model.grid_list.selected_items, item)
              False -> case model.grid_list.selected {
                Some(i) -> i == item
                None -> False
              }
            }
            // Roving tabindex: focused cell has tabindex="0", others have tabindex="-1"
            let tabindex = case is_focused {
              True -> "0"
              False -> "-1"
            }
            [
              div(
                [
                  class(
                    "p-4 border rounded-md text-center cursor-pointer"
                    <> case is_focused {
                      True -> " ring-2 ring-primary"
                      False -> ""
                    }
                    <> case is_selected {
                      True -> " bg-primary text-primary-foreground"
                      False -> ""
                    },
                  ),
                  attribute(
                    "id",
                    grid_list_utils.grid_item_element_id(row, col),
                  ),
                  attribute("tabindex", tabindex),
                  attribute("role", "gridcell"),
                  attribute("aria-selected", case is_selected {
                    True -> "true"
                    False -> "false"
                  }),
                  event.on_click(GridListMsg(grid_list_utils.Select(row, col))),
                ],
                [
                  text(item),
                ],
              ),
            ]
          }
          Error(_) -> [none()]
        }
      }),
    )
  let all_children =
    list.append(grid_items, [
      tailwind.helper_text_text("Focus with Tab, then use Arrow keys to navigate in 2D. Home/End for row ends. Ctrl+Home/End for grid corners. Enter/Space selects."),
    ])
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Grid List"),
    div(
      [
        class("grid grid-cols-3 gap-2 p-2 border rounded-md"),
        attribute("data-testid", "grid-list-keyboard-demo"),
        attribute("id", grid_list_utils.grid_element_id()),
        attribute("role", "grid"),
        attribute("aria-label", "Keyboard-enabled grid list"),
        attribute("tabindex", "0"),
        event.advanced("keydown", {
          use key <- decode.field("key", decode.string)
          use shift <- decode.field("shiftKey", decode.bool)
          use ctrl <- decode.field("ctrlKey", decode.bool)
          use meta <- decode.field("metaKey", decode.bool)
          use alt <- decode.field("altKey", decode.bool)

          // Only prevent default for navigation keys to avoid page scroll
          let should_prevent = case key {
            "Home" | "End" | "ArrowUp" | "ArrowDown" | "PageUp" | "PageDown" -> True
            _ -> False
          }

          let key_event = keyboard.KeyEvent(key:, shift:, ctrl:, meta:, alt:)
          case grid_list_utils.keymap(key_event, model.grid_list.multi_select) {
            Some(msg) -> decode.success(event.handler(GridListMsg(msg), prevent_default: should_prevent, stop_propagation: False))
            None -> decode.success(event.handler(NoOp, prevent_default: False, stop_propagation: False))
          }
        }),
      ],
      all_children,
    ),
  ])
}

fn get_at_index(items: List(String), index: Int) -> Result(String, Nil) {
  case items {
    [] -> Error(Nil)
    [item, ..rest] -> {
      case index == 0 {
        True -> Ok(item)
        False -> get_at_index(rest, index - 1)
      }
    }
  }
}

pub fn view_table(model: Model) -> Element(Msg) {
  let columns = table_utils.columns(model.table)
  let data = table_utils.data(model.table)
  let row_indices = list.range(0, model.table.rows - 1)
  let col_indices = list.range(0, model.table.cols - 1)
  div([class("space-y-4")], [
    h2([class("text-xl font-semibold")], [text("Keyboard-Enabled Table")]),
    div(
      [
        class("border rounded-md overflow-hidden"),
        attribute("data-testid", "table-keyboard-demo"),
        attribute("id", table_utils.table_element_id()),
        attribute("role", "grid"),
        attribute("aria-label", "Keyboard-enabled table"),
        attribute("tabindex", "0"),
        event.advanced("keydown", {
          use key <- decode.field("key", decode.string)
          use shift <- decode.field("shiftKey", decode.bool)
          use ctrl <- decode.field("ctrlKey", decode.bool)
          use meta <- decode.field("metaKey", decode.bool)
          use alt <- decode.field("altKey", decode.bool)

          // Only prevent default for navigation keys to avoid page scroll
          let should_prevent = case key {
            "Home" | "End" | "ArrowUp" | "ArrowDown" | "PageUp" | "PageDown" -> True
            _ -> False
          }

          let key_event = keyboard.KeyEvent(key:, shift:, ctrl:, meta:, alt:)
          case
            table_utils.keymap(
              key_event,
              model.table.multi_select,
              model.table.editable,
            )
          {
            Some(msg) -> decode.success(event.handler(TableMsg(msg), prevent_default: should_prevent, stop_propagation: False))
            None -> decode.success(event.handler(NoOp, prevent_default: False, stop_propagation: False))
          }
        }),
      ],
      [
        // Header
        table.table([], [
          table.table_header([], [
            table.table_header_row(
              [],
              list.map2(columns, list.range(0, list.length(columns) - 1), fn(col, col_idx) {
                let sort_icon_class = case table_utils.is_column_sorted(model.table, col_idx) {
                  True -> {
                    case model.table.sort_direction {
                      table_utils.Ascending -> "ri-arrow-up-line"
                      table_utils.Descending -> "ri-arrow-down-line"
                    }
                  }
                  False -> "ri-arrow-up-down-line"
                }
                table.table_column_header(
                  [
                    attribute("aria-sort", table_utils.aria_sort(model.table, col_idx)),
                    attribute("tabindex", "0"),
                    attribute("role", "columnheader"),
                    class("cursor-pointer hover:bg-accent select-none"),
                    event.on_click(TableMsg(table_utils.ToggleSort(col_idx))),
                    event.on_keydown(fn(key) {
                      case key {
                        "Enter" | " " -> TableMsg(table_utils.ToggleSort(col_idx))
                        _ -> NoOp
                      }
                    }),
                  ],
                  [
                    text(col),
                    html.i([
                      class("ri ri-fw ri-xs ml-1 " <> sort_icon_class),
                      attribute("aria-hidden", "true"),
                    ], []),
                  ],
                )
              }),
            ),
          ]),
          // Body
          table.table_body(
            [],
            list.map(row_indices, fn(row_idx) {
              table.table_row(
                [
                  attribute("role", "row"),
                  class(case list.contains(model.table.selected_rows, row_idx) {
                    True -> " bg-accent"
                    False -> ""
                  }),
                ],
                list.map(col_indices, fn(col_idx) {
                  let is_focused =
                    model.table.focused_row == row_idx
                    && model.table.focused_col == col_idx
                  let tabindex = case is_focused {
                    True -> "0"
                    False -> "-1"
                  }
                  let cell_pos = table_utils.CellPos(row_idx, col_idx)
                  let is_cell_selected =
                    list.contains(model.table.selected_cells, cell_pos)
                  case get_nested_list_at(data, row_idx) {
                    Ok(row_data) -> {
                      case get_at_index(row_data, col_idx) {
                        Ok(cell_value) -> {
                          table.table_cell(
                            [
                              attribute("tabindex", tabindex),
                              attribute("role", "gridcell"),
                              class(
                                "p-2 border"
                                <> case is_focused {
                                  True -> " ring-2 ring-primary"
                                  False -> ""
                                }
                                <> case is_cell_selected {
                                  True -> " bg-primary text-primary-foreground"
                                  False -> ""
                                },
                              ),
                              attribute(
                                "id",
                                table_utils.table_cell_element_id(
                                  row_idx,
                                  col_idx,
                                ),
                              ),
                              attribute("aria-selected", case is_cell_selected {
                                True -> "true"
                                False -> "false"
                              }),
                              event.on_click(TableMsg(table_utils.SelectCell(row_idx, col_idx))),
                            ],
                            [text(cell_value)],
                          )
                        }
                        Error(_) -> table.table_cell([], [none()])
                      }
                    }
                    Error(_) -> table.table_cell([], [none()])
                  }
                }),
              )
            }),
          ),
        ]),
        tailwind.helper_text_text("Focus with Tab, then use Arrow keys to navigate cells. Space toggles row selection. F2 enters edit mode. Home/End for row ends."),
      ],
    ),
  ])
}

fn get_nested_list_at(
  items: List(List(String)),
  index: Int,
) -> Result(List(String), Nil) {
  case items {
    [] -> Error(Nil)
    [item, ..rest] -> {
      case index == 0 {
        True -> Ok(item)
        False -> get_nested_list_at(rest, index - 1)
      }
    }
  }
}

pub fn view_drop_zones(model: Model) -> Element(Msg) {
  let drop_zone_class = case model.drop_zone_active {
    True -> " border-primary bg-primary/10"
    False -> ""
  }

  tailwind.vstack_md([
    tailwind.section_heading("Drop Zone"),
    tailwind.section_description_text("Drop zone with aria-dropeffect and aria-label."),
    drop_zone.drop_zone_with_input(
      [
        attribute("data-testid", "drop-zone-default"),
        attribute("aria-label", "Drop files here or click to browse"),
        class(drop_zone_class),
        attribute("accept", ".png,.jpg,.gif,.webp"),
        attribute("multiple", "true"),
      ],
      [
        tailwind.vstack_sm([
          tailwind.text_sm("Drop files here"),
          tailwind.helper_text_text("or click to browse"),
        ]),
      ],
    ),
    tailwind.helper_text_text("Drop zone accepts file drops. aria-dropeffect indicates the type of operation (copy). Keyboard users can activate with Enter or Space."),
  ])
}

pub fn view(model: Model) -> Element(Msg) {
  tailwind.vstack_xl([
    view_collections(),
    view_custom_select(model),
    view_combobox(model),
    view_grid_list(model),
    view_table(model),
    view_drop_zones(model),
  ])
}
