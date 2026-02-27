# Glizzy UI Test Suite

End-to-end component tests for Glizzy UI using Playwright.

## Test Directory Structure

This project has two test directories:

| Directory | Framework               | Purpose                   |
| --------- | ----------------------- | ------------------------- |
| `test/`   | Gleeunit (Gleam)        | Unit tests for Gleam code |
| `e2e/`    | Playwright (TypeScript) | End-to-end browser tests  |

## Quick Commands

```bash
# Run all E2E tests
bunx playwright test

# Run specific test file
bunx playwright test e2e/components/button.spec.ts

# Run on specific browser
bunx playwright test --project chromium

# Run with UI mode (debug)
bunx playwright test --ui

# View HTML report
bunx playwright show-report

# View trace
bunx playwright show-trace test-results/trace.zip
```

## Test Files

### Component Tests (`components/`)

| File                  | Components Tested           | Tests |
| --------------------- | --------------------------- | ----- |
| `button.spec.ts`      | Button (6 variants)         | 24    |
| `badge.spec.ts`       | Badge (4 variants)          | 14    |
| `input.spec.ts`       | Input (various states)      | 28    |
| `form-controls.spec.ts` | Form controls accessibility | 12    |
| `checkbox.spec.ts`    | Checkbox                    | 26    |
| `switch.spec.ts`      | Switch                      | 28    |
| `alert.spec.ts`       | Alert (4 variants)          | 16    |
| `avatar.spec.ts`      | Avatar (4 sizes + fallback) | 17    |
| `breadcrumbs.spec.ts` | Breadcrumbs                 | 14    |
| `chip.spec.ts`        | Chip (3 variants)           | 14    |
| `divider.spec.ts`     | Divider (2 orientations)    | 12    |
| `kbd.spec.ts`         | Keyboard shortcuts          | 14    |
| `link.spec.ts`        | Link (3 variants)           | 16    |
| `radio.spec.ts`       | Radio group                 | 18    |
| `select.spec.ts`      | Select dropdown             | 14    |
| `pickers.spec.ts`     | Pickers & color controls    | 3     |
| `skeleton.spec.ts`    | Skeleton loaders            | 14    |
| `slider.spec.ts`      | Slider                      | 16    |
| `spinner.spec.ts`     | Spinner (4 sizes)           | 14    |
| `tabs.spec.ts`        | Tabs                        | 17    |
| `menu.spec.ts`        | Menu                        | 9     |
| `popover.spec.ts`     | Popover                     | 9     |
| `tooltip.spec.ts`     | Tooltip (2 positions)       | 16    |
| `autocomplete.spec.ts` | Autocomplete/Combobox       | 11    |
| `toast.spec.ts`       | Toast notifications         | 8     |
| `accordion.spec.ts`   | Accordion                   | 7     |
| `calendar.spec.ts`   | Calendar                    | 5     |
| `color_picker.spec.ts` | Color Picker                | 4     |
| `color_swatch.spec.ts` | Color Swatch                | 3     |
| `color_swatch_picker.spec.ts` | Color Swatch Picker | 3     |
| `color_field.spec.ts` | Color Field                 | 4     |
| `form.spec.ts`        | Form                        | 4     |
| `group.spec.ts`       | Group                       | 4     |
| `number_field.spec.ts`| Number Field                | 5     |
| `search_field.spec.ts`| Search Field                | 4     |
| `separator.spec.ts`   | Separator                   | 3     |
| `split_panel.spec.ts`| Split Panel                 | 4     |
| `text_field.spec.ts` | Text Field                  | 4     |
| `toggle_button.spec.ts` | Toggle Button              | 4     |
| `toggle_button_group.spec.ts` | Toggle Button Group | 4     |
| `file_trigger.spec.ts`| File Trigger               | 3     |
| `focus.spec.ts`      | Focus utilities             | 4     |
| `range_calendar.spec.ts` | Range Calendar            | 4     |
| `virtualizer.spec.ts`| Virtualizer                 | 4     |
| `tab-navigation.spec.ts` | Full site tab navigation | 10    |

### Integration Tests

| File                       | Description                   | Tests |
| -------------------------- | ----------------------------- | ----- |
| `components.spec.ts`       | General component integration | 16    |
| `accessibility.spec.ts`    | ARIA, keyboard, color contrast | 33   |
| `keyboard-navigation.spec.ts` | Keyboard interactions        | 80+   |
| `responsive.spec.ts`       | Mobile, tablet, desktop       | 24    |
| `pages/home.spec.ts`       | Home page tests               | 16    |
| `keyboard-selection.spec.ts` | Keyboard selection          | 12    |
| `click-outside.spec.ts`    | Click outside behavior        | 12    |

**Total: 600+ tests**

## Accessibility Testing

### WAI-ARIA Compliance: 90%

The test suite includes comprehensive WAI-ARIA 1.2/1.3 testing:

- **ARIA Attributes**: 400+ assertions across 59 test files
- **Keyboard Navigation**: 100+ tests for all interactive components
- **Focus Management**: Tab navigation, focus traps, focus restoration
- **Color Contrast**: Automated WCAG AA/AAA checks via axe-core
- **Screen Reader**: Guidepup integration for VoiceOver/NVDA testing

### axe-core Testing

40+ files include automated axe-core accessibility scans:

```bash
# Run tests with axe-core violations reported
bunx playwright test --reporter=list
```

### Screen Reader Testing (Guidepup)

Install and configure screen reader testing:

```bash
# Install guidepup-playwright
bun add -D @guidepup/playwright
```

See [Screen Reader Testing](#screen-reader-testing) below.

## Test Organization

```
e2e/
├── components/           # Per-component tests
│   ├── button.spec.ts
│   ├── badge.spec.ts
│   └── ...
├── pages/                # Page-level tests
│   └── home.spec.ts
├── fixtures/             # Test fixtures
├── accessibility.spec.ts # Accessibility tests
├── responsive.spec.ts    # Responsive tests
├── tab-navigation.spec.ts # Full site tab navigation
├── components.spec.ts    # Integration tests
├── global-setup.ts       # Setup hook
└── global-teardown.ts    # Teardown hook
```

## Writing Tests

### Basic Test Structure

```typescript
import { test, expect } from "@playwright/test";

test.describe("Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
  });

  test("should render", async ({ page }) => {
    const component = page.getByTestId("component-default");
    await expect(component).toBeVisible();
  });
});
```

### Using Test IDs

All components use `data-testid` attributes:

```typescript
// Get component by test ID
const button = page.getByTestId("btn-default");

// Assert visibility
await expect(button).toBeVisible();

// Assert content
await expect(button).toContainText("Click me");

// Assert classes
await expect(button).toHaveClass(/rounded-md/);
```

### Testing Interactions

```typescript
// Click
await button.click();

// Hover
await button.hover();

// Keyboard
await page.keyboard.press("Enter");
await page.keyboard.press("Tab");

// Focus
await button.focus();
await expect(button).toBeFocused();
```

### Testing ARIA Attributes

```typescript
// Test role
await expect(button).toHaveRole("button");

// Test ARIA attributes
await expect(input).toHaveAttribute("aria-label", "Submit form");
await expect(panel).toHaveAttribute("aria-expanded", "true");
await expect(combobox).toHaveAttribute("aria-autocomplete", "list");

// Test aria-describedby
await expect(input).toHaveAttribute("aria-describedby", "hint-id");
const hint = page.locator("#hint-id");
await expect(hint).toBeVisible();
```

### Screen Reader Testing

```typescript
import { screenReader } from "@guidepup/playwright";

test("should announce dynamic content changes", async ({ page }) => {
  await page.goto("/");
  
  // Start screen reader
  await screenRecorder.startDevice();
  
  // Perform action
  await page.getByTestId("submit-btn").click();
  
  // Get announcements
  const announcements = await screenRecorder.stopAndGetAnnouncements();
  
  // Assert screen reader announcements
  expect(announcements).toContain("Form submitted successfully");
});
```

## Debugging

### Screenshots on Failure

Automatically captured and saved to `test-results/`.

### Trace Viewer

```bash
# Run with trace
bunx playwright test --trace on

# View trace
bunx playwright show-trace test-results/trace.zip
```

### UI Mode

```bash
bunx playwright test --ui
```

Interactive UI for running and debugging tests.

## Configuration

See `playwright.config.ts` for:

- Browser configurations
- Test timeouts
- Reporter settings
- Web server configuration

## Resources

- [Testing Guide](../docs/TESTING_GUIDE.md) - Comprehensive testing documentation
- [Playwright Docs](https://playwright.dev)
- [Test Assertions](https://playwright.dev/docs/test-assertions)
- [WAI-ARIA Test Coverage](./WAI_ARIA_TEST_COVERAGE.md)
- [WAI-ARIA Test Expansion Plan](./WAI_ARIA_TEST_EXPANSION.md)
- [Guidepup Docs](https://guidepup.github.io/guidepup-playwright/)
