import types.{type Model, type Msg}
import lustre/attribute.{attribute, class, src}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h2, label, p}
import lib/tailwind
import ui/alert
import ui/avatar
import ui/badge
import ui/chip
import ui/meter
import ui/progress_bar
import ui/skeleton
import ui/spinner

pub fn view_alerts() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Alerts"),
    tailwind.section_description([
      text(
        "Alerts use role=status with aria-live=polite for screen reader announcements. Critical alerts use role=alert for immediate attention.",
      ),
    ]),
    div(
      [
        attribute("data-testid", "alerts-section"),
        class("space-y-4"),
      ],
      [
        tailwind.vstack_md([
          alert.alert(
            [
              alert.variant(alert.Default),
              attribute("data-testid", "alert-default"),
              alert.aria_label("Information alert"),
              ..alert.live_region()
            ],
            [
              alert.title([], [text("Default Alert")]),
              alert.description([], [text("This is a default alert.")]),
            ],
          ),
          alert.alert(
            [
              alert.variant(alert.Success),
              attribute("data-testid", "alert-success"),
              alert.aria_label("Success notification"),
              ..alert.live_region()
            ],
            [
              alert.title([], [text("Success!")]),
              alert.description([], [text("Your action was successful.")]),
            ],
          ),
          alert.alert(
            [
              alert.variant(alert.Warning),
              attribute("data-testid", "alert-warning"),
              alert.aria_label("Warning notification"),
              ..alert.live_region()
            ],
            [
              alert.title([], [text("Warning!")]),
              alert.description([], [text("Please review carefully.")]),
            ],
          ),
          alert.alert(
            [
              alert.variant(alert.Error),
              attribute("data-testid", "alert-error"),
              alert.aria_label("Error notification"),
              ..alert.critical_region()
            ],
            [
              alert.title([], [text("Error!")]),
              alert.description([], [text("Something went wrong.")]),
            ],
          ),
        ]),
      ]
    ),
    p(
      [
        attribute("data-testid", "alerts-keyboard-hint"),
        class("text-xs text-muted-foreground"),
      ],
      [text("Alerts use role=status with aria-live for screen reader announcements.")],
    ),
  ])
}

pub fn view_badges() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Badges"),
    tailwind.section_description([
      text(
        "Badges can use role=status with aria-live=polite for dynamic status indicators. Static badges do not need live regions.",
      ),
    ]),
    div(
      [
        attribute("data-testid", "badges-section"),
        class("space-y-4"),
      ],
      [
        tailwind.hwrap_md([
          badge.badge(
            [
              badge.variant(badge.Default),
              attribute("data-testid", "badge-default"),
            ],
            [text("Default")],
          ),
          badge.badge(
            [
              badge.variant(badge.Secondary),
              attribute("data-testid", "badge-secondary"),
            ],
            [text("Secondary")],
          ),
          badge.badge(
            [
              badge.variant(badge.Destructive),
              attribute("data-testid", "badge-destructive"),
              badge.role_status(),
              badge.aria_label("Critical status"),
            ],
            [text("Destructive")],
          ),
          badge.badge(
            [
              badge.variant(badge.Outline),
              attribute("data-testid", "badge-outline"),
            ],
            [text("Outline")],
          ),
        ]),
      ]
    ),
    p(
      [
        attribute("data-testid", "badges-keyboard-hint"),
        class("text-xs text-muted-foreground"),
      ],
      [text("Badges: static badges have no role, dynamic badges use role=status with aria-live.")],
    ),
  ])
}

pub fn view_chips() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Chips"),
    tailwind.hwrap_md([
      chip.chip(
        [chip.variant(chip.Default), attribute("data-testid", "chip-default")],
        [text("Default")],
      ),
      chip.chip(
        [
          chip.variant(chip.Secondary),
          attribute("data-testid", "chip-secondary"),
        ],
        [text("Secondary")],
      ),
      chip.chip(
        [chip.variant(chip.Outline), attribute("data-testid", "chip-outline")],
        [text("Outline")],
      ),
    ]),
  ])
}

pub fn view_progress_bars() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Progress Bars"),
    tailwind.section_description([
      text(
        "Progress bars use role=progressbar with aria-valuenow/min/max. aria-label provides context for screen reader users.",
      ),
    ]),
    div(
      [
        attribute("data-testid", "progress-bars-section"),
        class("space-y-4"),
      ],
      [
        tailwind.vstack_md([
          tailwind.field([
            tailwind.label_text("progress-bar-default", "Default progress"),
            progress_bar.progress_bar(
              [
                attribute("data-testid", "progress-bar-default"),
                progress_bar.aria_label("Default progress indicator"),
                progress_bar.aria_valuenow(50),
              ],
              [
                progress_bar.indicator([
                  class("w-1/2"),
                  attribute("data-testid", "progress-bar-default-indicator"),
                ]),
              ],
            ),
          ]),
          tailwind.field([
            tailwind.label_text("progress-bar-large", "Large progress"),
            progress_bar.progress_bar(
              [
                attribute("data-testid", "progress-bar-large"),
                progress_bar.size(progress_bar.Large),
                progress_bar.aria_label("Large progress indicator"),
                progress_bar.aria_valuenow(75),
              ],
              [
                progress_bar.indicator([
                  class("w-3/4"),
                  attribute("data-testid", "progress-bar-large-indicator"),
                ]),
              ],
            ),
          ]),
          tailwind.field([
            tailwind.label_text("progress-bar-muted", "Muted progress"),
            progress_bar.progress_bar(
              [
                attribute("data-testid", "progress-bar-muted"),
                progress_bar.variant(progress_bar.Muted),
                progress_bar.aria_label("Muted progress indicator"),
                progress_bar.aria_valuenow(25),
              ],
              [
                progress_bar.indicator([
                  class("w-1/4"),
                  attribute("data-testid", "progress-bar-muted-indicator"),
                ]),
              ],
            ),
          ]),
        ]),
      ]
    ),
    p(
      [
        attribute("data-testid", "progress-bars-keyboard-hint"),
        class("text-xs text-muted-foreground"),
      ],
      [text("Progress bars use role=progressbar with aria-valuenow/min/max.")],
    ),
  ])
}

pub fn view_meters() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Meters"),
    tailwind.section_description([
      text(
        "Meters use role=metric with aria-valuenow/min/max. aria-label provides context for screen reader users.",
      ),
    ]),
    div(
      [
        attribute("data-testid", "meters-section"),
        class("space-y-4"),
      ],
      [
        tailwind.vstack_md([
          tailwind.field([
            tailwind.label_text("meter-default", "Battery level"),
            meter.meter(
              [
                attribute("data-testid", "meter-default"),
                meter.aria_label("Battery level indicator"),
                meter.aria_valuenow(80),
              ],
              [
                meter.fill([
                  class("w-4/5 bg-green-500"),
                  attribute("data-testid", "meter-default-fill"),
                ]),
              ],
            ),
          ]),
          tailwind.field([
            tailwind.label_text("meter-large", "Storage usage"),
            meter.meter(
              [
                attribute("data-testid", "meter-large"),
                meter.size(meter.Large),
                meter.aria_label("Storage usage indicator"),
                meter.aria_valuenow(60),
              ],
              [
                meter.fill([
                  class("w-3/5"),
                  attribute("data-testid", "meter-large-fill"),
                ]),
              ],
            ),
          ]),
          tailwind.field([
            tailwind.label_text("meter-muted", "CPU usage"),
            meter.meter(
              [
                attribute("data-testid", "meter-muted"),
                meter.variant(meter.Muted),
                meter.aria_label("CPU usage indicator"),
                meter.aria_valuenow(40),
              ],
              [
                meter.fill([
                  class("w-2/5"),
                  attribute("data-testid", "meter-muted-fill"),
                ]),
              ],
            ),
          ]),
        ]),
      ]
    ),
    p(
      [
        attribute("data-testid", "meters-keyboard-hint"),
        class("text-xs text-muted-foreground"),
      ],
      [text("Meters use role=metric with aria-valuenow/min/max.")],
    ),
  ])
}

pub fn view_spinners() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Spinners"),
    tailwind.section_description_text(
      "Spinners use role=status, aria-live=polite, and aria-busy=true. aria-label provides context for screen reader users.",
    ),
    div(
      [
        attribute("data-testid", "spinners-section"),
        class("space-y-4"),
      ],
      [
        tailwind.hwrap_lg([
          spinner.spinner_with_size(spinner.Small, [
            spinner.border(),
            attribute("data-testid", "spinner-small"),
            spinner.aria_label("Loading, small size"),
          ]),
          spinner.spinner_with_size(spinner.Medium, [
            spinner.border(),
            attribute("data-testid", "spinner-medium"),
            spinner.aria_label("Loading, medium size"),
          ]),
          spinner.spinner_with_size(spinner.Large, [
            spinner.border(),
            attribute("data-testid", "spinner-large"),
            spinner.aria_label("Loading, large size"),
          ]),
          spinner.spinner_with_size(spinner.Medium, [
            spinner.variant(spinner.Muted),
            spinner.border(),
            attribute("data-testid", "spinner-muted"),
            spinner.aria_label("Loading, muted style"),
          ]),
        ]),
      ]
    ),
    p(
      [
        attribute("data-testid", "spinners-keyboard-hint"),
        class("text-xs text-muted-foreground"),
      ],
      [text("Spinners use role=status with aria-live=polite and aria-busy=true.")],
    ),
  ])
}

pub fn view_skeletons() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Skeletons"),
    tailwind.section_description_text(
      "Skeletons use role=status, aria-live=polite, and aria-busy=true to indicate loading state to screen readers.",
    ),
    div(
      [
        attribute("data-testid", "skeletons-section"),
        class("space-y-4"),
      ],
      [
        tailwind.hwrap_lg([
          skeleton.skeleton([
            skeleton.circle(40),
            attribute("data-testid", "skeleton-circle"),
            skeleton.aria_label("Loading avatar"),
          ]),
          skeleton.skeleton([
            skeleton.rect("12", "12"),
            attribute("data-testid", "skeleton-rect"),
            skeleton.aria_label("Loading content block"),
          ]),
          skeleton.skeleton([
            skeleton.rect("48", "4"),
            attribute("data-testid", "skeleton-text"),
            skeleton.aria_label("Loading text line"),
          ]),
        ]),
      ]
    ),
    p(
      [
        attribute("data-testid", "skeletons-keyboard-hint"),
        class("text-xs text-muted-foreground"),
      ],
      [text("Skeletons use role=status with aria-live=polite and aria-busy=true.")],
    ),
  ])
}

pub fn view_avatars() -> Element(Msg) {
  tailwind.vstack_md([
    tailwind.section_heading("Avatars"),
    tailwind.hwrap_lg([
      avatar.avatar([
        src("https://github.com/github.png"),
        attribute("data-testid", "avatar-default"),
      ]),
      avatar.avatar([
        avatar.size(avatar.Small),
        src("https://github.com/github.png"),
        attribute("data-testid", "avatar-small"),
      ]),
      avatar.avatar([
        avatar.size(avatar.Medium),
        src("https://github.com/github.png"),
        attribute("data-testid", "avatar-medium"),
      ]),
      avatar.avatar([
        avatar.size(avatar.Large),
        src("https://github.com/github.png"),
        attribute("data-testid", "avatar-large"),
      ]),
      avatar.fallback([attribute("data-testid", "avatar-fallback")]),
    ]),
  ])
}

pub fn view(_model: Model) -> Element(Msg) {
  tailwind.vstack_xl([
    view_alerts(),
    view_badges(),
    view_chips(),
    view_progress_bars(),
    view_meters(),
    view_spinners(),
    view_skeletons(),
    view_avatars(),
  ])
}
