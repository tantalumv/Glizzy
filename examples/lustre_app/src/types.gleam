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
import lustre_utils/interactions.{type MoveEvent}
import lustre_utils/click_outside.{type ClickOutsideEvent}

pub type Model {
  Model(
    dark_mode: Bool,
    checkbox_checked: Bool,
    switch_enabled: Bool,
    input_value: String,
    // Use lustre_utils models
    dialog: dialog_utils.Model,
    tooltip_visible: Bool,
    modal: modal_utils.Model,
    disclosure_expanded: Bool,
    drop_zone_active: Bool,
    // Date picker state using lustre_utils
    date_picker: dp_utils.Model,
    date_range_picker: drp_utils.Model,
    popover: popover_utils.Model,
    // Navigation state
    tabs_selected: String,
    menu: menu_utils.Model,
    menu_selected: String,
    // Color picker state using lustre_utils
    color_picker: cp_utils.Model,
    // Tree state using lustre_utils
    tree: tree_utils.Model,
    // New keyboard navigation components
    slider: slider_utils.Model,
    radio_group: radio_group_utils.Model,
    checkbox_group: checkbox_group_utils.Model,
    toggle_button_group: toggle_button_group_utils.Model,
    disclosure_group: disclosure_group_utils.Model,
    toolbar: toolbar_utils.Model,
    custom_select: select_utils.Model,
    combobox: combobox_utils.Model,
    grid_list: grid_list_utils.Model,
    table: table_utils.Model,
    // Move subscription IDs for FFI pointer capture
    slider_subscription_id: String,
    area_subscription_id: String,
    // Color control dimensions for coordinate-to-color conversion
    slider_width: Float,
    area_width: Float,
    area_height: Float,
    // Click-outside subscription IDs for cleanup
    menu_click_outside_subscription: String,
    popover_click_outside_subscription: String,
    custom_select_click_outside_subscription: String,
    combobox_click_outside_subscription: String,
    date_picker_click_outside_subscription: String,
    date_range_picker_click_outside_subscription: String,
  )
}

pub type Msg {
  NoOp
  DarkModeToggled
  CheckboxToggled(Bool)
  SwitchToggled(Bool)
  InputChanged(String)
  DialogMsg(dialog_utils.Msg)
  ToggleTooltip
  ModalMsg(modal_utils.Msg)
  DisclosureToggled
  DropZoneActivated
  // Date picker messages using lustre_utils
  DatePickerMsg(dp_utils.Msg)
  DateRangePickerMsg(drp_utils.Msg)
  // Navigation messages
  TabSelected(String)
  MenuMsg(menu_utils.Msg)
  MenuItemSelected(String)
  // Color picker messages using lustre_utils
  ColorPickerMsg(cp_utils.Msg)
  // Popover messages using lustre_utils
  PopoverMsg(popover_utils.Msg)
  // Tree messages using lustre_utils
  TreeMsg(tree_utils.Msg)
  // New keyboard navigation component messages
  SliderMsg(slider_utils.Msg)
  RadioGroupMsg(radio_group_utils.Msg)
  CheckboxGroupMsg(checkbox_group_utils.Msg)
  ToggleButtonGroupMsg(toggle_button_group_utils.Msg)
  DisclosureGroupMsg(disclosure_group_utils.Msg)
  ToolbarMsg(toolbar_utils.Msg)
  CustomSelectMsg(select_utils.Msg)
  ComboboxMsg(combobox_utils.Msg)
  GridListMsg(grid_list_utils.Msg)
  TableMsg(table_utils.Msg)
  // Move interaction messages (FFI pointer capture)
  SliderMove(MoveEvent)
  AreaMove(MoveEvent)
  SliderSubscribed(String)
  AreaSubscribed(String)
  SliderError(String)
  AreaError(String)
  // Click-outside messages
  MenuClickOutside(ClickOutsideEvent)
  PopoverClickOutside(ClickOutsideEvent)
  CustomSelectClickOutside(ClickOutsideEvent)
  ComboboxClickOutside(ClickOutsideEvent)
  DatePickerClickOutside(ClickOutsideEvent)
  DateRangePickerClickOutside(ClickOutsideEvent)
  MenuClickOutsideSubscribed(String)
  PopoverClickOutsideSubscribed(String)
  CustomSelectClickOutsideSubscribed(String)
  ComboboxClickOutsideSubscribed(String)
  DatePickerClickOutsideSubscribed(String)
  DateRangePickerClickOutsideSubscribed(String)
  // Lifecycle cleanup messages
  CleanupSubscriptions
}
