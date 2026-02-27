import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{Some, None}
import types.{type Model, type Msg, DisclosureGroupMsg, MenuMsg, MenuItemSelected, NoOp, PopoverMsg, TabSelected, ToolbarMsg}
import lustre/attribute.{attribute, class, href}
import lustre/element.{type Element, none, text}
import lustre/element/html.{button, div, h2, p}
import lustre/event
import lib/tailwind
import lustre_utils/disclosure_group as disclosure_group_utils
import lustre_utils/keyboard as keyboard
import lustre_utils/menu as menu_utils
import lustre_utils/popover as popover_utils
import lustre_utils/toolbar as toolbar_utils
import ui/button
import ui/breadcrumbs
import ui/link
import ui/menu
import ui/popover
import ui/tabs

pub fn view_navigation(model: Model) -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Navigation"),
    tailwind.vstack_lg([
      tailwind.field([
        tailwind.section_description_text("Tabs"),
        tabs.tabs([attribute("data-testid", "tabs-demo")], [
          tabs.tab_list(
            [
              tabs.orientation(tabs.Horizontal),
              event.on_keydown(fn(key) {
                case key {
                  "ArrowRight" -> {
                    case model.tabs_selected {
                      "overview" -> TabSelected("details")
                      "details" -> TabSelected("disabled")
                      _ -> TabSelected("overview")
                    }
                  }
                  "ArrowLeft" -> {
                    case model.tabs_selected {
                      "overview" -> TabSelected("disabled")
                      "details" -> TabSelected("overview")
                      _ -> TabSelected("details")
                    }
                  }
                  "Home" -> TabSelected("overview")
                  "End" -> TabSelected("disabled")
                  "Enter" | " " -> TabSelected(model.tabs_selected)
                  _ -> TabSelected(model.tabs_selected)
                }
              }),
            ],
            [
            tabs.tab(
              [
                tabs.tab_selected(model.tabs_selected == "overview"),
                attribute("id", "demo-tab-overview"),
                attribute("aria-controls", "demo-tabpanel-overview"),
                attribute("tabindex", case model.tabs_selected == "overview" {
                  True -> "0"
                  False -> "-1"
                }),
                event.on_click(TabSelected("overview")),
              ],
              [text("Overview")],
            ),
            tabs.tab(
              [
                tabs.tab_selected(model.tabs_selected == "details"),
                attribute("id", "demo-tab-details"),
                attribute("aria-controls", "demo-tabpanel-details"),
                attribute("tabindex", case model.tabs_selected == "details" {
                  True -> "0"
                  False -> "-1"
                }),
                event.on_click(TabSelected("details")),
              ],
              [text("Details")],
            ),
            tabs.tab(
              [
                tabs.tab_disabled(True),
                attribute("id", "demo-tab-disabled"),
                attribute("aria-controls", "demo-tabpanel-disabled"),
              ],
              [text("Disabled")],
            ),
          ]),
          tabs.tab_panel(
            [
              attribute("id", "demo-tabpanel-overview"),
              attribute("aria-labelledby", "demo-tab-overview"),
              class(case model.tabs_selected == "overview" {
                True -> ""
                False -> " hidden"
              }),
            ],
            [text("Tabs component with useTabList ARIA semantics.")],
          ),
          tabs.tab_panel(
            [
              attribute("id", "demo-tabpanel-details"),
              attribute("aria-labelledby", "demo-tab-details"),
              class(case model.tabs_selected == "details" {
                True -> ""
                False -> " hidden"
              }),
            ],
            [text("Details panel content. Switch tabs to see more.")],
          ),
        ]),
      ]),
      tailwind.field([
        tailwind.section_description_text("Menu"),
        div([class("relative inline-block"), attribute("data-testid", "menu-demo")], [
          menu.trigger(
            [
              menu.controls("demo-menu"),
              menu.expanded(menu_utils.is_open(model.menu)),
              event.on_click(MenuMsg(menu_utils.Toggle)),
              attribute("data-testid", "menu-trigger"),
              attribute("aria-expanded", case menu_utils.is_open(model.menu) {
                True -> "true"
                False -> "false"
              }),
            ],
            [text("Open menu")],
          ),
          // Menu content with keyboard handler
          bool.guard(
            menu_utils.is_open(model.menu),
            html.div(
              [
                class("absolute z-50"),
                attribute("style", "top: 100%; left: 0; margin-top: 0.25rem;"),
                attribute("tabindex", "-1"),
                event.on_keydown(fn(key) {
                  case key {
                    "Escape" -> MenuMsg(menu_utils.Close)
                    "ArrowDown" -> MenuMsg(menu_utils.MoveDown)
                    "ArrowUp" -> MenuMsg(menu_utils.MoveUp)
                    "Home" -> MenuMsg(menu_utils.MoveFirst)
                    "End" -> MenuMsg(menu_utils.MoveLast)
                    _ -> MenuMsg(menu_utils.Close)
                  }
                }),
              ],
              [
                menu.menu(
                  [
                    menu.size(menu.Medium),
                    attribute("id", "demo-menu"),
                    attribute("aria-label", "Actions"),
                    attribute("data-testid", "menu"),
                    attribute("tabindex", "0"),
                  ],
                  [
                    menu.menu_item(
                      [
                        event.on_click(MenuItemSelected("new_file")),
                        attribute("tabindex", case menu_utils.is_highlighted(model.menu, 0) {
                          True -> "0"
                          False -> "-1"
                        }),
                        attribute("id", "menu-item-0"),
                        attribute("data-highlighted", case menu_utils.is_highlighted(model.menu, 0) {
                          True -> "true"
                          False -> "false"
                        }),
                        event.on_focus(MenuMsg(menu_utils.SetHighlightedIndex(0))),
                      ],
                      [text("New file")],
                    ),
                    menu.menu_item(
                      [
                        event.on_click(MenuItemSelected("rename")),
                        attribute("tabindex", case menu_utils.is_highlighted(model.menu, 1) {
                          True -> "0"
                          False -> "-1"
                        }),
                        attribute("id", "menu-item-1"),
                        attribute("data-highlighted", case menu_utils.is_highlighted(model.menu, 1) {
                          True -> "true"
                          False -> "false"
                        }),
                        event.on_focus(MenuMsg(menu_utils.SetHighlightedIndex(1))),
                      ],
                      [text("Rename")],
                    ),
                    menu.separator([]),
                    menu.menu_section([], "Preferences", [
                      menu.menu_item_checkbox(
                        [
                          event.on_click(MenuItemSelected("autosave")),
                          attribute("tabindex", case menu_utils.is_highlighted(model.menu, 2) {
                            True -> "0"
                            False -> "-1"
                          }),
                          attribute("id", "menu-item-2"),
                          attribute("data-highlighted", case menu_utils.is_highlighted(model.menu, 2) {
                            True -> "true"
                            False -> "false"
                          }),
                          event.on_focus(MenuMsg(menu_utils.SetHighlightedIndex(2))),
                        ],
                        True,
                        [text("Autosave")],
                      ),
                      menu.menu_item_radio(
                        [
                          event.on_click(MenuItemSelected("compact")),
                          attribute("tabindex", case menu_utils.is_highlighted(model.menu, 3) {
                            True -> "0"
                            False -> "-1"
                          }),
                          attribute("id", "menu-item-3"),
                          attribute("data-highlighted", case menu_utils.is_highlighted(model.menu, 3) {
                            True -> "true"
                            False -> "false"
                          }),
                          event.on_focus(MenuMsg(menu_utils.SetHighlightedIndex(3))),
                        ],
                        True,
                        [text("Compact mode")],
                      ),
                    ]),
                  ],
                ),
              ],
            ),
            fn() { none() },
          ),
        ]),
      ]),
      tailwind.field([
        tailwind.section_description_text("Popover"),
        div([class("relative inline-block"), attribute("data-testid", "popover-section")], [
          popover.trigger(
            [
              popover.controls("demo-popover"),
              popover.expanded(popover_utils.is_open(model.popover)),
              event.on_click(PopoverMsg(popover_utils.Toggle)),
              attribute("data-testid", "popover-trigger"),
              attribute("aria-expanded", case popover_utils.is_open(model.popover) {
                True -> "true"
                False -> "false"
              }),
            ],
            [text("Show popover")],
          ),
          // Popover content with keyboard handler for Escape
          bool.guard(
            popover_utils.is_open(model.popover),
            html.div(
              [
                class("absolute z-50"),
                attribute("style", "top: 100%; left: 0; margin-top: 0.25rem;"),
                attribute("tabindex", "-1"),
                event.on_keydown(fn(key) {
                  case key {
                    "Escape" -> PopoverMsg(popover_utils.Close)
                    _ -> PopoverMsg(popover_utils.Close)
                  }
                }),
              ],
              [
                popover.content(
                  [
                    popover.placement(popover.Bottom),
                    popover.size(popover.Medium),
                    attribute("id", "demo-popover"),
                    attribute("role", "dialog"),
                    attribute("aria-label", "Popover details"),
                    attribute("data-testid", "popover-content"),
                  ],
                  [
                    popover.arrow([]),
                    p([], [text("Popover content with usePopover semantics.")]),
                  ],
                ),
              ],
            ),
            fn() { none() },
          ),
        ]),
      ]),
    ]),
  ])
}

pub fn view_toolbar(model: Model) -> Element(Msg) {
  let item_count = toolbar_utils.item_count(model.toolbar)
  let indices = list.range(0, item_count - 1)
  let button_items = list.map(indices, fn(index) {
    case toolbar_utils.item_at(model.toolbar, index) {
      Some(item) -> {
        let tabindex = toolbar_utils.tabindex_for(model.toolbar, index)
        let is_highlighted = toolbar_utils.is_highlighted(model.toolbar, index)
        let variant = case is_highlighted { True -> button.Secondary False -> button.Ghost }
        let aria_pressed = case is_highlighted { True -> "true" False -> "false" }
        button.button(
          [
            button.variant(variant),
            button.size(button.Small),
            attribute("id", toolbar_utils.toolbar_item_element_id(index)),
            // Roving tabindex: highlighted button is focusable, others are not
            // But all buttons remain clickable via mouse
            attribute("tabindex", int.to_string(tabindex)),
            attribute("aria-pressed", aria_pressed),
            event.on_click(ToolbarMsg(toolbar_utils.SetHighlightedIndex(index))),
          ],
          [text(item.label)],
        )
      }
      None -> none()
    }
  })
  let all_children = list.append(button_items, [
    tailwind.helper_text_text("Focus with Tab, then use Arrow keys to navigate. Enter/Space activates the focused button. Home/End jump to first/last."),
  ])
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Toolbar"),
    div([
      class("flex gap-1 p-2 border rounded-md"),
      attribute("data-testid", "toolbar-keyboard-demo"),
      attribute("id", toolbar_utils.toolbar_element_id()),
      attribute("role", "toolbar"),
      attribute("aria-label", "Keyboard-enabled toolbar"),
      attribute("tabindex", "0"),
      event.on_focus(ToolbarMsg(toolbar_utils.Focus)),
      event.on_blur(ToolbarMsg(toolbar_utils.Blur)),
      keyboard.on_keydown(fn(event) {
        case toolbar_utils.keymap(event) {
          Some(msg) -> ToolbarMsg(msg)
          None -> NoOp
        }
      }),
    ], all_children),
  ])
}

pub fn view_disclosure_group(model: Model) -> Element(Msg) {
  let item_count = disclosure_group_utils.item_count(model.disclosure_group)
  let indices = list.range(0, item_count - 1)
  let disclosure_items = list.map(indices, fn(index) {
    let is_expanded = disclosure_group_utils.is_expanded(model.disclosure_group, index)
    let tabindex = disclosure_group_utils.tabindex_for(model.disclosure_group, index)
    div([class("border rounded-md")], [
      button.button(
        [
          button.variant(button.Ghost),
          class("w-full justify-between"),
          attribute("id", disclosure_group_utils.disclosure_trigger_element_id(index)),
          attribute("tabindex", int.to_string(tabindex)),
          attribute("aria-expanded", case is_expanded { True -> "true" False -> "false" }),
          attribute("aria-controls", disclosure_group_utils.disclosure_content_element_id(index)),
          event.on_click(DisclosureGroupMsg(disclosure_group_utils.Toggle(index))),
        ],
        [text("Section " <> int.to_string(index + 1))],
      ),
      bool.guard(
        is_expanded,
        div([
          class("p-4 border-t"),
          attribute("id", disclosure_group_utils.disclosure_content_element_id(index)),
        ], [
          p([], [text("Content for section " <> int.to_string(index + 1))]),
        ]),
        fn() { none() },
      ),
    ])
  })
  let all_children = list.append(disclosure_items, [
    tailwind.helper_text_text("Focus with Tab, then use Arrow keys to navigate between headers. Enter/Space expands/collapses. Home/End jump to first/last."),
  ])
  tailwind.vstack_md([
    tailwind.section_heading("Keyboard-Enabled Disclosure Group"),
    div([
      class("space-y-2"),
      attribute("data-testid", "disclosure-group-keyboard-demo"),
      attribute("id", disclosure_group_utils.group_element_id()),
      attribute("tabindex", "0"),
      keyboard.on_keydown(fn(event) {
        case disclosure_group_utils.keymap(event) {
          Some(msg) -> DisclosureGroupMsg(msg)
          None -> DisclosureGroupMsg(disclosure_group_utils.Focus)
        }
      }),
    ], all_children),
  ])
}

pub fn view_breadcrumbs() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Breadcrumbs"),
    breadcrumbs.breadcrumbs(
      [attribute("data-testid", "breadcrumbs-default")],
      breadcrumbs.separator(),
      [
        breadcrumbs.link([href("#home")], [text("Home")]),
        breadcrumbs.link([href("#components")], [text("Components")]),
        breadcrumbs.link([breadcrumbs.current(), href("#breadcrumbs")], [
          text("Breadcrumbs"),
        ]),
      ],
    ),
  ])
}

pub fn view_links() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Links"),
    tailwind.hwrap_md([
      link.link([href("#default"), attribute("data-testid", "link-default")], [
        text("Default Link"),
      ]),
      link.link(
        [
          link.variant(link.Muted),
          href("#muted"),
          attribute("data-testid", "link-muted"),
        ],
        [text("Muted Link")],
      ),
      link.link(
        [
          link.underline(link.Always),
          href("#underline"),
          attribute("data-testid", "link-underline"),
        ],
        [text("Always Underlined")],
      ),
    ]),
  ])
}

pub fn view(model: Model) -> Element(Msg) {
  tailwind.vstack_xl([
    view_navigation(model),
    view_toolbar(model),
    view_disclosure_group(model),
    view_breadcrumbs(),
    view_links(),
  ])
}
