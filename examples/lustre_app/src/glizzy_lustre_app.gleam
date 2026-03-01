import gleam/time/calendar
import gleam/time/timestamp
import gleam/float
import gleam/list
import lustre
import lustre/effect.{type Effect, none}
import lustre/attribute.{attribute, class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h1, section}
import lustre/event
import lustre_utils/color_picker as cp_utils
import lustre_utils/date_picker as dp_utils
import lustre_utils/date_range_picker as drp_utils
import lustre_utils/dialog as dialog_utils
import lustre_utils/menu as menu_utils
import lustre_utils/modal as modal_utils
import lustre_utils/popover as popover_utils
import lustre_utils/tree as tree_utils
import lustre_utils/slider as slider_utils
import lustre_utils/radio_group as radio_group_utils
import lustre_utils/checkbox_group as checkbox_group_utils
import lustre_utils/toggle_button_group as toggle_button_group_utils
import lustre_utils/disclosure_group as disclosure_group_utils
import lustre_utils/toolbar as toolbar_utils
import lustre_utils/select as select_utils
import lustre_utils/combobox as combobox_utils
import lustre_utils/grid_list as grid_list_utils
import lustre_utils/table as table_utils
import lustre_utils/interactions.{MoveStart, Move, MoveEnd}
import lustre_utils/interactions/focus
import lustre_utils/interactions/move
import lustre_utils/click_outside
import data/tree_data
import gleam/option.{Some, None}
import types.{type Model, type Msg, Model, AreaError, AreaMove, AreaSubscribed, CheckboxToggled, CheckboxGroupMsg, ColorPickerMsg, ComboboxMsg, CustomSelectMsg, DatePickerMsg, DateRangePickerMsg, DialogMsg, DisclosureGroupMsg, DisclosureToggled, DropZoneActivated, DarkModeToggled, GridListMsg, InputChanged, MenuItemSelected, MenuMsg, ModalMsg, NoOp, PopoverMsg, RadioGroupMsg, SliderError, SliderMsg, SliderMove, SliderSubscribed, SwitchToggled, TabSelected, TableMsg, ToggleButtonGroupMsg, ToggleTooltip, ToolbarMsg, TreeMsg, MenuClickOutside, PopoverClickOutside, MenuClickOutsideSubscribed, PopoverClickOutsideSubscribed, CustomSelectClickOutside, ComboboxClickOutside, CustomSelectClickOutsideSubscribed, ComboboxClickOutsideSubscribed, DatePickerClickOutside, DateRangePickerClickOutside, DatePickerClickOutsideSubscribed, DateRangePickerClickOutsideSubscribed, CleanupSubscriptions}
import views/buttons
import views/collections
import views/feedback
import views/form_colors
import views/form_date_time
import views/form_inputs
import views/form_tree
import views/layout
import views/navigation
import views/overlays
import ui/button

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

pub fn init(_flags: Nil) -> #(Model, Effect(Msg)) {
  // Get the actual current date instead of hardcoding
  let now = timestamp.system_time()
  let #(today, _) = timestamp.to_calendar(now, calendar.utc_offset)

  // Default dimensions for color controls (can be updated dynamically if needed)
  let default_slider_width = 256.0
  let default_area_width = 256.0
  let default_area_height = 256.0

  // Initialize keyboard navigation components
  let slider_model = slider_utils.init_with_range(0, 100, 50)
  let radio_options = ["option1", "option2", "option3"]
  let radio_model = radio_group_utils.init_first(radio_options)
  let checkbox_options = ["email", "sms", "push", "newsletter"]
  let checkbox_model = checkbox_group_utils.init_empty(checkbox_options)
  let toggle_buttons = ["Bold", "Italic", "Underline", "Strikethrough"]
  let toggle_model = toggle_button_group_utils.init(toggle_buttons |> list.length, False)
  let disclosure_model = disclosure_group_utils.init(3, [0])
  let toolbar_items = [
    toolbar_utils.button_item("cut", "Cut"),
    toolbar_utils.button_item("copy", "Copy"),
    toolbar_utils.button_item("paste", "Paste"),
  ]
  let toolbar_model = toolbar_utils.init(toolbar_items)
  let select_options = [
    select_utils.option("react", "React"),
    select_utils.option("vue", "Vue"),
    select_utils.option("svelte", "Svelte"),
    select_utils.option("solid", "Solid"),
  ]
  let select_model = select_utils.init_empty(select_options)
  let combobox_options = [
    combobox_utils.option("apple", "Apple"),
    combobox_utils.option("banana", "Banana"),
    combobox_utils.option("cherry", "Cherry"),
    combobox_utils.option("date", "Date"),
    combobox_utils.option("elderberry", "Elderberry"),
  ]
  let combobox_model = combobox_utils.init_empty(combobox_options)
  let grid_items = ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9"]
  let grid_model = grid_list_utils.init(grid_items, 3, 3, True)
  let table_columns = ["Name", "Email", "Role"]
  let table_data = [
    ["Alice", "alice@example.com", "Admin"],
    ["Bob", "bob@example.com", "User"],
    ["Charlie", "charlie@example.com", "User"],
  ]
  let table_model = table_utils.init(table_columns, table_data, True)

  // Initialize dialog, modal and popover with effects
  let #(dialog_model, dialog_init_effect) = dialog_utils.init()
  let #(modal_model, modal_init_effect) = modal_utils.init()
  let #(popover_model, popover_init_effect) = popover_utils.init()

  let model = Model(
    dark_mode: False,
    checkbox_checked: False,
    switch_enabled: False,
    input_value: "",
    dialog: dialog_model,
    tooltip_visible: False,
    modal: modal_model,
    disclosure_expanded: False,
    drop_zone_active: False,
    // Date picker state using lustre_utils
    date_picker: dp_utils.init(today),
    date_range_picker: drp_utils.init(today),
    popover: popover_model,
    // Navigation state
    tabs_selected: "overview",
    menu: menu_utils.init(2),
    menu_selected: "",
    // Color picker state using lustre_utils
    color_picker: cp_utils.init_from_hex("#a855f7"),
    // Tree state using lustre_utils with sample data from data module
    tree: tree_utils.init(tree_data.sample_tree()),
    // New keyboard navigation components
    slider: slider_model,
    radio_group: radio_model,
    checkbox_group: checkbox_model,
    toggle_button_group: toggle_model,
    disclosure_group: disclosure_model,
    toolbar: toolbar_model,
    custom_select: select_model,
    combobox: combobox_model,
    grid_list: grid_model,
    table: table_model,
    // Move subscription IDs (will be set by effects)
    slider_subscription_id: "",
    area_subscription_id: "",
    // Color control dimensions
    slider_width: default_slider_width,
    area_width: default_area_width,
    area_height: default_area_height,
    // Click-outside subscription IDs (will be set by effects)
    menu_click_outside_subscription: "",
    popover_click_outside_subscription: "",
    custom_select_click_outside_subscription: "",
    combobox_click_outside_subscription: "",
    date_picker_click_outside_subscription: "",
    date_range_picker_click_outside_subscription: "",
  )

  // Subscribe to move events for color slider and area
  let effect = effect.batch([
    effect.map(dialog_init_effect, DialogMsg),
    effect.map(modal_init_effect, ModalMsg),
    effect.map(popover_init_effect, PopoverMsg),
    move.subscribe_color_slider(
      "color-slider-track",
      SliderMove,
      SliderSubscribed,
      SliderError,
    ),
    move.subscribe_color_area(
      "color-area-surface",
      AreaMove,
      AreaSubscribed,
      AreaError,
    ),
  ])

  #(model, effect)
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    NoOp -> #(model, none())
    DarkModeToggled -> #(Model(..model, dark_mode: !model.dark_mode), none())
    CheckboxToggled(checked) -> #(Model(..model, checkbox_checked: checked), none())
    SwitchToggled(enabled) -> #(Model(..model, switch_enabled: enabled), none())
    InputChanged(value) -> #(Model(..model, input_value: value), none())
    DialogMsg(d_msg) -> {
      let #(new_dialog, dialog_effect) = dialog_utils.update(model.dialog, d_msg)
      #(Model(..model, dialog: new_dialog), effect.map(dialog_effect, DialogMsg))
    }
    ToggleTooltip -> #(Model(..model, tooltip_visible: !model.tooltip_visible), none())
    ModalMsg(m_msg) -> {
      let #(new_modal, modal_effect) = modal_utils.update(model.modal, m_msg)
      #(Model(..model, modal: new_modal), effect.map(modal_effect, ModalMsg))
    }
    DisclosureToggled ->
      #(Model(..model, disclosure_expanded: !model.disclosure_expanded), none())
    DropZoneActivated -> #(Model(..model, drop_zone_active: True), none())
    // Date picker updates using lustre_utils with current time for type-ahead
    DatePickerMsg(dp_msg) -> {
      let now = timestamp.system_time()
      let current_time = { timestamp.to_unix_seconds(now) *. 1000.0 } |> float.truncate
      let new_picker = dp_utils.update(model.date_picker, dp_msg, current_time)

      let click_outside_effect = case dp_msg, new_picker.is_open {
        dp_utils.ToggleOpen, True ->
          click_outside.subscribe("date-picker-block", DatePickerClickOutside, DatePickerClickOutsideSubscribed)
        dp_utils.Open, True ->
          click_outside.subscribe("date-picker-block", DatePickerClickOutside, DatePickerClickOutsideSubscribed)
        dp_utils.ToggleOpen, False | dp_utils.Close, False ->
          click_outside.unsubscribe(model.date_picker_click_outside_subscription)
        _, _ -> none()
      }

      #(Model(..model, date_picker: new_picker), click_outside_effect)
    }
    DateRangePickerMsg(drp_msg) -> {
      let now = timestamp.system_time()
      let current_time = { timestamp.to_unix_seconds(now) *. 1000.0 } |> float.truncate
      let new_picker = drp_utils.update(model.date_range_picker, drp_msg, current_time)

      let click_outside_effect = case drp_msg, new_picker.is_open {
        drp_utils.ToggleOpen, True ->
          click_outside.subscribe("date-range-picker-block", DateRangePickerClickOutside, DateRangePickerClickOutsideSubscribed)
        drp_utils.Open, True ->
          click_outside.subscribe("date-range-picker-block", DateRangePickerClickOutside, DateRangePickerClickOutsideSubscribed)
        drp_utils.ToggleOpen, False | drp_utils.Close, False ->
          click_outside.unsubscribe(model.date_range_picker_click_outside_subscription)
        _, _ -> none()
      }

      #(
        Model(..model, date_range_picker: new_picker),
        click_outside_effect,
      )
    }
    // Navigation updates - focus the newly selected tab
    TabSelected(tab) -> #(
      Model(..model, tabs_selected: tab),
      focus.focus_by_id("demo-tab-" <> tab),
    )
    MenuMsg(m_msg) -> {
      let new_menu = menu_utils.update(model.menu, m_msg)
      case m_msg {
        menu_utils.Open | menu_utils.Toggle if new_menu.is_open ->
          #(Model(..model, menu: new_menu), click_outside.subscribe("demo-menu", MenuClickOutside, MenuClickOutsideSubscribed))
        menu_utils.Close | menu_utils.Toggle if !new_menu.is_open ->
          #(
            Model(..model, menu: new_menu),
            click_outside.unsubscribe(model.menu_click_outside_subscription),
          )
        menu_utils.MoveUp | menu_utils.MoveDown | menu_utils.MoveFirst | menu_utils.MoveLast ->
          #(Model(..model, menu: new_menu), focus.focus_by_id(menu_utils.item_element_id(new_menu.highlighted_index)))
        _ ->
          #(Model(..model, menu: new_menu), none())
      }
    }
    MenuItemSelected(item) ->
      #(
        Model(
          ..model,
          menu_selected: item,
          menu: menu_utils.update(model.menu, menu_utils.Select),
        ),
        none(),
      )
    // Color picker update using lustre_utils
    ColorPickerMsg(cp_msg) ->
      #(Model(..model, color_picker: cp_utils.update(model.color_picker, cp_msg)), none())
    // Toggle popover using lustre_utils
    PopoverMsg(p_msg) -> {
      let #(new_popover, popover_effect) = popover_utils.update(model.popover, p_msg)
      let click_outside_effect = case p_msg {
        popover_utils.Open | popover_utils.Toggle if new_popover.is_open ->
          click_outside.subscribe("demo-popover", PopoverClickOutside, PopoverClickOutsideSubscribed)
        popover_utils.Close | popover_utils.Toggle if !new_popover.is_open ->
          click_outside.unsubscribe(model.popover_click_outside_subscription)
        _ -> none()
      }
      #(Model(..model, popover: new_popover), effect.batch([effect.map(popover_effect, PopoverMsg), click_outside_effect]))
    }
    // Tree update using lustre_utils with current time for type-ahead
    TreeMsg(t_msg) -> {
      let now = timestamp.system_time()
      let current_time = { timestamp.to_unix_seconds(now) *. 1000.0 } |> float.truncate
      let new_tree = tree_utils.update(model.tree, t_msg, current_time)
      case t_msg {
        tree_utils.MoveUp | tree_utils.MoveDown | tree_utils.MoveFirst | tree_utils.MoveLast -> {
          case new_tree.focused_id {
            Some(id) -> #(Model(..model, tree: new_tree), focus.focus_by_id(tree_utils.item_element_id(id)))
            None -> #(Model(..model, tree: new_tree), none())
          }
        }
        _ -> #(Model(..model, tree: new_tree), none())
      }
    }
    // New keyboard navigation component updates
    SliderMsg(s_msg) -> {
      let new_slider = slider_utils.update(model.slider, s_msg)
      #(Model(..model, slider: new_slider), none())
    }
    RadioGroupMsg(r_msg) -> {
      let new_radio = radio_group_utils.update(model.radio_group, r_msg)
      case r_msg {
        radio_group_utils.MoveNext | radio_group_utils.MovePrev | radio_group_utils.MoveFirst | radio_group_utils.MoveLast ->
          #(Model(..model, radio_group: new_radio), focus.focus_by_id(radio_group_utils.radio_element_id(new_radio.highlighted_index)))
        _ -> #(Model(..model, radio_group: new_radio), none())
      }
    }
    CheckboxGroupMsg(c_msg) -> {
      let new_checkbox = checkbox_group_utils.update(model.checkbox_group, c_msg)
      case c_msg {
        checkbox_group_utils.MoveNext | checkbox_group_utils.MovePrev | checkbox_group_utils.MoveFirst | checkbox_group_utils.MoveLast ->
          #(Model(..model, checkbox_group: new_checkbox), focus.focus_by_id(checkbox_group_utils.checkbox_element_id(new_checkbox.highlighted_index)))
        _ -> #(Model(..model, checkbox_group: new_checkbox), none())
      }
    }
    ToggleButtonGroupMsg(t_msg) -> {
      let #(new_toggle, effect) = toggle_button_group_utils.update(model.toggle_button_group, t_msg)
      let mapped_effect = effect.map(effect, ToggleButtonGroupMsg)
      #(Model(..model, toggle_button_group: new_toggle), mapped_effect)
    }
    DisclosureGroupMsg(d_msg) -> {
      let new_disclosure = disclosure_group_utils.update(model.disclosure_group, d_msg)
      case d_msg {
        disclosure_group_utils.MoveNext | disclosure_group_utils.MovePrev | disclosure_group_utils.MoveFirst | disclosure_group_utils.MoveLast ->
          #(Model(..model, disclosure_group: new_disclosure), focus.focus_by_id(disclosure_group_utils.disclosure_trigger_element_id(new_disclosure.highlighted_index)))
        _ -> #(Model(..model, disclosure_group: new_disclosure), none())
      }
    }
    ToolbarMsg(t_msg) -> {
      let new_toolbar = toolbar_utils.update(model.toolbar, t_msg)
      case t_msg {
        toolbar_utils.MoveNext | toolbar_utils.MovePrev | toolbar_utils.MoveFirst | toolbar_utils.MoveLast ->
          #(Model(..model, toolbar: new_toolbar), focus.focus_by_id(toolbar_utils.toolbar_item_element_id(new_toolbar.highlighted_index)))
        _ -> #(Model(..model, toolbar: new_toolbar), none())
      }
    }
    CustomSelectMsg(s_msg) -> {
      let now = timestamp.system_time()
      let current_time = { timestamp.to_unix_seconds(now) *. 1000.0 } |> float.truncate
      let new_select = select_utils.update(model.custom_select, s_msg, current_time)

      let click_outside_effect = case s_msg {
        select_utils.Open if new_select.is_open ->
          click_outside.subscribe("custom-select", CustomSelectClickOutside, CustomSelectClickOutsideSubscribed)
        select_utils.Close if !new_select.is_open ->
          click_outside.unsubscribe(model.custom_select_click_outside_subscription)
        _ -> none()
      }

      // F7: Remove focus effect - focus stays on trigger, use aria-activedescendant instead
      let focus_effect = none()

      #(Model(..model, custom_select: new_select), effect.batch([click_outside_effect, focus_effect]))
    }
    ComboboxMsg(c_msg) -> {
      let now = timestamp.system_time()
      let current_time = { timestamp.to_unix_seconds(now) *. 1000.0 } |> float.truncate
      let new_combobox = combobox_utils.update(model.combobox, c_msg, current_time)

      let click_outside_effect = case new_combobox.is_open, model.combobox.is_open {
        // Combobox just opened - subscribe to click outside
        True, False ->
          click_outside.subscribe("combobox", ComboboxClickOutside, ComboboxClickOutsideSubscribed)
        // Combobox just closed - unsubscribe from click outside
        False, True ->
          click_outside.unsubscribe(model.combobox_click_outside_subscription)
        // No change in open state
        _, _ -> none()
      }

      // F8: Remove focus effect - focus stays on input, use aria-activedescendant instead
      let focus_effect = none()

      #(Model(..model, combobox: new_combobox), effect.batch([click_outside_effect, focus_effect]))
    }
    GridListMsg(g_msg) -> {
      let new_grid = grid_list_utils.update(model.grid_list, g_msg)
      case g_msg {
        grid_list_utils.MoveDown | grid_list_utils.MoveUp | grid_list_utils.MoveRight | grid_list_utils.MoveLeft | grid_list_utils.MoveRowStart | grid_list_utils.MoveRowEnd | grid_list_utils.MoveGridFirst | grid_list_utils.MoveGridLast | grid_list_utils.SelectFocused ->
          #(Model(..model, grid_list: new_grid), focus.focus_by_id(grid_list_utils.grid_item_element_id(new_grid.focused_row, new_grid.focused_col)))
        grid_list_utils.Select(_, _) ->
          #(Model(..model, grid_list: new_grid), focus.focus_by_id(grid_list_utils.grid_item_element_id(new_grid.focused_row, new_grid.focused_col)))
        _ -> #(Model(..model, grid_list: new_grid), none())
      }
    }
    TableMsg(t_msg) -> {
      let new_table = table_utils.update(model.table, t_msg)
      case t_msg {
        table_utils.MoveDown | table_utils.MoveUp | table_utils.MoveRight | table_utils.MoveLeft | table_utils.MoveRowStart | table_utils.MoveRowEnd | table_utils.MoveTableFirst | table_utils.MoveTableLast | table_utils.SelectFocusedCell ->
          #(Model(..model, table: new_table), focus.focus_by_id(table_utils.table_cell_element_id(new_table.focused_row, new_table.focused_col)))
        table_utils.SelectCell(_, _) ->
          #(Model(..model, table: new_table), focus.focus_by_id(table_utils.table_cell_element_id(new_table.focused_row, new_table.focused_col)))
        _ -> #(Model(..model, table: new_table), none())
      }
    }
    // Move interaction messages (FFI pointer capture)
    SliderMove(move_event) -> {
      case move_event {
        MoveStart(x, _y) | Move(x: x, ..) -> {
          // x is normalized 0.0-1.0 ratio from FFI
          let hue = x *. 360.0
          #(Model(..model, color_picker: cp_utils.update(model.color_picker, cp_utils.HueChanged(hue))), none())
        }
        MoveEnd(..) -> #(model, none())
      }
    }
    AreaMove(move_event) -> {
      case move_event {
        MoveStart(x, y) | Move(x: x, y: y, ..) -> {
          // x,y are normalized 0.0-1.0 ratios from FFI
          let saturation = x *. 100.0
          let lightness = { 1.0 -. y } *. 100.0
          #(Model(..model, color_picker: cp_utils.update(model.color_picker, cp_utils.AreaChanged(saturation, lightness))), none())
        }
        MoveEnd(..) -> #(model, none())
      }
    }
    SliderSubscribed(subscription_id) ->
      #(Model(..model, slider_subscription_id: subscription_id), none())
    AreaSubscribed(subscription_id) ->
      #(Model(..model, area_subscription_id: subscription_id), none())
    SliderError(_error_msg) ->
      // Log error but don't change state (could add error tracking to Model)
      #(model, none())
    AreaError(_error_msg) ->
      // Log error but don't change state (could add error tracking to Model)
      #(model, none())
    // Click-outside messages - close menu/popover when clicking outside
    MenuClickOutside(_event) ->
      #(
        Model(..model, menu: menu_utils.update(model.menu, menu_utils.Close)),
        click_outside.unsubscribe(model.menu_click_outside_subscription),
      )
    PopoverClickOutside(_event) -> {
      let #(new_popover, popover_effect) = popover_utils.update(model.popover, popover_utils.Close)
      #(
        Model(..model, popover: new_popover),
        effect.batch([
          effect.map(popover_effect, PopoverMsg),
          click_outside.unsubscribe(model.popover_click_outside_subscription),
        ]),
      )
    }
    CustomSelectClickOutside(_event) -> {
      let now = timestamp.system_time()
      let current_time = { timestamp.to_unix_seconds(now) *. 1000.0 } |> float.truncate
      #(
        Model(..model, custom_select: select_utils.update(model.custom_select, select_utils.Close, current_time)),
        click_outside.unsubscribe(model.custom_select_click_outside_subscription),
      )
    }
    ComboboxClickOutside(_event) -> {
      let now = timestamp.system_time()
      let current_time = { timestamp.to_unix_seconds(now) *. 1000.0 } |> float.truncate
      #(
        Model(..model, combobox: combobox_utils.update(model.combobox, combobox_utils.Close, current_time)),
        click_outside.unsubscribe(model.combobox_click_outside_subscription),
      )
    }
    DatePickerClickOutside(_event) -> {
      #(
        Model(..model, date_picker: dp_utils.update(model.date_picker, dp_utils.Close, 0)),
        click_outside.unsubscribe(model.date_picker_click_outside_subscription),
      )
    }
    DateRangePickerClickOutside(_event) -> {
      #(
        Model(..model, date_range_picker: drp_utils.update(model.date_range_picker, drp_utils.Close, 0)),
        click_outside.unsubscribe(model.date_range_picker_click_outside_subscription),
      )
    }
    MenuClickOutsideSubscribed(subscription_id) ->
      #(Model(..model, menu_click_outside_subscription: subscription_id), none())
    PopoverClickOutsideSubscribed(subscription_id) ->
      #(Model(..model, popover_click_outside_subscription: subscription_id), none())
    CustomSelectClickOutsideSubscribed(subscription_id) ->
      #(Model(..model, custom_select_click_outside_subscription: subscription_id), none())
    ComboboxClickOutsideSubscribed(subscription_id) ->
      #(Model(..model, combobox_click_outside_subscription: subscription_id), none())
    DatePickerClickOutsideSubscribed(subscription_id) ->
      #(Model(..model, date_picker_click_outside_subscription: subscription_id), none())
    DateRangePickerClickOutsideSubscribed(subscription_id) ->
      #(Model(..model, date_range_picker_click_outside_subscription: subscription_id), none())
    // Lifecycle cleanup - called when component unmounts
    CleanupSubscriptions -> #(
      model,
      effect.batch([
        move.unsubscribe_color_slider(model.slider_subscription_id),
        move.unsubscribe_color_area(model.area_subscription_id),
        click_outside.unsubscribe(model.menu_click_outside_subscription),
        click_outside.unsubscribe(model.popover_click_outside_subscription),
        click_outside.unsubscribe(model.custom_select_click_outside_subscription),
        click_outside.unsubscribe(model.combobox_click_outside_subscription),
        click_outside.unsubscribe(model.date_picker_click_outside_subscription),
        click_outside.unsubscribe(model.date_range_picker_click_outside_subscription),
      ]),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  let dark_class = case model.dark_mode {
    True -> "dark"
    False -> ""
  }

  div([class(dark_class <> " min-h-screen bg-background text-foreground")], [
    section([class("container mx-auto p-8 max-w-4xl")], [
      div([class("flex items-center justify-between mb-8")], [
        h1([class("text-3xl font-bold text-foreground")], [
          text("Glizzy UI Demo"),
        ]),
        view_dark_mode_toggle(model),
      ]),

      div([class("space-y-8")], [
        layout.view(model),
        buttons.view(model),
        form_inputs.view(model),
        form_date_time.view(model),
        form_colors.view(model),
        form_tree.view(model),
        collections.view(model),
        feedback.view(model),
        overlays.view(model),
        navigation.view(model),
      ]),
    ]),
  ])
}

fn view_dark_mode_toggle(model: Model) -> Element(Msg) {
  let label_text = case model.dark_mode {
    True -> "🌙 Dark"
    False -> "☀️ Light"
  }

  button.button(
    [
      button.variant(button.Outline),
      button.size(button.Small),
      event.on_click(DarkModeToggled),
      attribute("data-testid", "dark-mode-toggle"),
    ],
    [text(label_text)],
  )
}
