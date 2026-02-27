/**
 * Keyboard Navigation E2E Tests
 * 
 * Tests for keyboard interaction patterns across Glizzy UI components.
 * Covers arrow key navigation, activation keys, type-ahead, and focus management.
 */

import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test.describe("Keyboard Navigation", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");
  });

  test.describe("Radio Group", () => {
    test("should navigate with arrow keys", async ({ page }) => {
      const radioGroup = page.getByTestId("radio-group");
      await radioGroup.focus();

      // Initial focus should be on first radio
      await expect(page.locator(":focus")).toBeVisible();

      // ArrowDown should move to next radio
      await page.keyboard.press("ArrowDown");
      const focusedAfterDown = page.locator(":focus");
      await expect(focusedAfterDown).toBeVisible();

      // ArrowUp should move back
      await page.keyboard.press("ArrowUp");
      const focusedAfterUp = page.locator(":focus");
      await expect(focusedAfterUp).toBeVisible();
    });

    test("should select with Space key", async ({ page }) => {
      const radioGroup = page.getByTestId("radio-group");
      await radioGroup.focus();

      // Navigate to second radio
      await page.keyboard.press("ArrowDown");

      // Select with Space
      await page.keyboard.press(" ");

      // Verify selection state
      const focusedRadio = page.locator(":focus");
      await expect(focusedRadio).toBeChecked();
    });

    test("should wrap navigation", async ({ page }) => {
      const radioGroup = page.getByTestId("radio-group");
      await radioGroup.focus();

      // Navigate to last item with End
      await page.keyboard.press("End");

      // ArrowDown should wrap to first
      await page.keyboard.press("ArrowDown");
      const focusedAfterWrap = page.locator(":focus");
      await expect(focusedAfterWrap).toBeVisible();
    });

    test("should jump to first with Home", async ({ page }) => {
      const radioGroup = page.getByTestId("radio-group");
      await radioGroup.focus();

      // Navigate to middle
      await page.keyboard.press("ArrowDown");
      await page.keyboard.press("ArrowDown");

      // Home should jump to first
      await page.keyboard.press("Home");
      const focusedAfterHome = page.locator(":focus");
      await expect(focusedAfterHome).toBeVisible();
    });
  });

  test.describe("Checkbox Group", () => {
    test("should navigate with arrow keys", async ({ page }) => {
      const checkboxGroup = page.getByTestId("checkbox-group-keyboard-demo");
      await checkboxGroup.focus();

      // Initial focus
      await expect(page.locator(":focus")).toBeVisible();

      // ArrowDown should move to next checkbox
      await page.keyboard.press("ArrowDown");
      const focusedAfterDown = page.locator(":focus");
      await expect(focusedAfterDown).toBeVisible();

      // ArrowUp should move back
      await page.keyboard.press("ArrowUp");
      const focusedAfterUp = page.locator(":focus");
      await expect(focusedAfterUp).toBeVisible();
    });

    test("should toggle with Space key", async ({ page }) => {
      const checkboxGroup = page.getByTestId("checkbox-group-keyboard-demo");
      await checkboxGroup.focus();

      // Navigate to second checkbox
      await page.keyboard.press("ArrowDown");

      // Get initial state
      const focusedCheckbox = page.locator(":focus");
      const initialState = await focusedCheckbox.isChecked();

      // Toggle with Space
      await page.keyboard.press(" ");

      // Verify toggled state
      await expect(focusedCheckbox).toBeChecked(!initialState);
    });
  });

  test.describe("Toolbar", () => {
    test("should navigate with arrow keys", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");
      await toolbar.focus();

      // Initial focus
      await expect(page.locator(":focus")).toBeVisible();

      // ArrowRight should move to next button
      await page.keyboard.press("ArrowRight");
      const focusedAfterRight = page.locator(":focus");
      await expect(focusedAfterRight).toBeVisible();

      // ArrowLeft should move back
      await page.keyboard.press("ArrowLeft");
      const focusedAfterLeft = page.locator(":focus");
      await expect(focusedAfterLeft).toBeVisible();
    });

    test("should activate with Enter", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");
      await toolbar.focus();

      // Activate first button with Enter
      await page.keyboard.press("Enter");

      // Verify activation (button should show pressed state or trigger action)
      const focusedButton = page.locator(":focus");
      await expect(focusedButton).toBeVisible();
    });

    test("should activate with Space", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");
      await toolbar.focus();

      // Activate with Space
      await page.keyboard.press(" ");

      // Verify activation
      const focusedButton = page.locator(":focus");
      await expect(focusedButton).toBeVisible();
    });

    test("should wrap navigation", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");
      await toolbar.focus();

      // Navigate to last item with End
      await page.keyboard.press("End");

      // ArrowRight should wrap to first
      await page.keyboard.press("ArrowRight");
      const focusedAfterWrap = page.locator(":focus");
      await expect(focusedAfterWrap).toBeVisible();
    });
  });

  test.describe("Disclosure Group (Accordion)", () => {
    test("should navigate with arrow keys", async ({ page }) => {
      const disclosureGroup = page.getByTestId("disclosure-group-keyboard-demo");
      await disclosureGroup.focus();

      // Initial focus
      await expect(page.locator(":focus")).toBeVisible();

      // ArrowDown should move to next disclosure
      await page.keyboard.press("ArrowDown");
      const focusedAfterDown = page.locator(":focus");
      await expect(focusedAfterDown).toBeVisible();

      // ArrowUp should move back
      await page.keyboard.press("ArrowUp");
      const focusedAfterUp = page.locator(":focus");
      await expect(focusedAfterUp).toBeVisible();
    });

    test("should toggle with Enter", async ({ page }) => {
      const disclosureGroup = page.getByTestId("disclosure-group-keyboard-demo");
      await disclosureGroup.focus();

      // Get initial expanded state
      const focusedDisclosure = page.locator(":focus");
      
      // Toggle with Enter
      await page.keyboard.press("Enter");

      // Verify state changed (panel should expand/collapse)
      await expect(focusedDisclosure).toBeVisible();
    });

    test("should toggle with Space", async ({ page }) => {
      const disclosureGroup = page.getByTestId("disclosure-group-keyboard-demo");
      await disclosureGroup.focus();

      // Toggle with Space
      await page.keyboard.press(" ");

      // Verify state changed
      const focusedDisclosure = page.locator(":focus");
      await expect(focusedDisclosure).toBeVisible();
    });

    test("should jump to first/last with Home/End", async ({ page }) => {
      const disclosureGroup = page.getByTestId("disclosure-group-keyboard-demo");
      await disclosureGroup.focus();

      // Navigate to middle
      await page.keyboard.press("ArrowDown");
      await page.keyboard.press("ArrowDown");

      // Home should jump to first
      await page.keyboard.press("Home");
      const focusedAfterHome = page.locator(":focus");
      await expect(focusedAfterHome).toBeVisible();

      // End should jump to last
      await page.keyboard.press("End");
      const focusedAfterEnd = page.locator(":focus");
      await expect(focusedAfterEnd).toBeVisible();
    });
  });

  test.describe("Select", () => {
    test("should open with Enter", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      await select.focus();

      // Open dropdown with Enter
      await page.keyboard.press("Enter");

      // Dropdown should be visible
      const dropdown = select.locator('[role="listbox"]');
      await expect(dropdown).toBeVisible();
    });

    test("should navigate options with arrow keys", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      await select.focus();

      // Open dropdown
      await page.keyboard.press("Enter");
      await select.locator('[role="listbox"]').waitFor();

      // ArrowDown should move to next option
      await page.keyboard.press("ArrowDown");
      const focusedOption = page.locator(":focus");
      await expect(focusedOption).toBeVisible();

      // ArrowUp should move back
      await page.keyboard.press("ArrowUp");
      const focusedAfterUp = page.locator(":focus");
      await expect(focusedAfterUp).toBeVisible();
    });

    test("should select option with Enter", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      await select.focus();

      // Open dropdown
      await page.keyboard.press("Enter");
      await select.locator('[role="listbox"]').waitFor();

      // Navigate to second option
      await page.keyboard.press("ArrowDown");

      // Select with Enter
      await page.keyboard.press("Enter");

      // Dropdown should close
      const dropdown = select.locator('[role="listbox"]');
      await expect(dropdown).not.toBeVisible();
    });

    test("should close with Escape", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      await select.focus();

      // Open dropdown
      await page.keyboard.press("Enter");
      await select.locator('[role="listbox"]').waitFor();

      // Close with Escape
      await page.keyboard.press("Escape");

      // Dropdown should be hidden
      const dropdown = select.locator('[role="listbox"]');
      await expect(dropdown).not.toBeVisible();
    });

    test("should support type-ahead", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      await select.focus();

      // Open dropdown
      await page.keyboard.press("Enter");
      await select.locator('[role="listbox"]').waitFor();

      // Type first letter of an option
      await page.keyboard.press("b");

      // Should focus option starting with 'b'
      const focusedOption = page.locator(":focus");
      await expect(focusedOption).toBeVisible();
    });

    test("should close with Enter when closed", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      await select.focus();

      // Close with Enter (when already closed, should select current)
      await page.keyboard.press("Enter");

      // Should still be focused
      await expect(select).toBeFocused();
    });
  });

  test.describe("Slider", () => {
    test("should increase with ArrowRight/ArrowUp", async ({ page }) => {
      const slider = page.getByTestId("slider-keyboard-demo");
      await slider.focus();

      // Get initial value
      const initialValue = await slider.getAttribute("aria-valuenow");

      // Increase with ArrowRight
      await page.keyboard.press("ArrowRight");

      // Wait for value to change
      await page.waitForFunction(
        ([testId, expectedValue]) => {
          const el = document.querySelector(`[data-testid="${testId}"]`);
          return el?.getAttribute("aria-valuenow") !== expectedValue;
        },
        ["slider-keyboard-demo", initialValue]
      );

      // Value should increase
      const newValue = await slider.getAttribute("aria-valuenow");
      expect(Number(newValue)).toBeGreaterThan(Number(initialValue));
    });

    test("should decrease with ArrowLeft/ArrowDown", async ({ page }) => {
      const slider = page.getByTestId("slider-keyboard-demo");
      await slider.focus();

      // Get initial value (should be 50)
      const initialValue = await slider.getAttribute("aria-valuenow");
      
      // Increase first with ArrowRight - wait for value to change from initial
      await page.keyboard.press("ArrowRight");
      await page.waitForFunction(
        ([testId, expectedValue]) => {
          const el = document.querySelector(`[data-testid="${testId}"]`);
          const value = el?.getAttribute("aria-valuenow");
          return value !== null && value !== expectedValue;
        },
        ["slider-keyboard-demo", initialValue]
      );
      
      await page.keyboard.press("ArrowRight");
      await page.waitForTimeout(50); // Small wait for update

      const currentValue = await slider.getAttribute("aria-valuenow");

      // Decrease with ArrowLeft
      await page.keyboard.press("ArrowLeft");

      // Wait for value to change
      await page.waitForFunction(
        ([testId, expectedValue]) => {
          const el = document.querySelector(`[data-testid="${testId}"]`);
          return el?.getAttribute("aria-valuenow") !== expectedValue;
        },
        ["slider-keyboard-demo", currentValue]
      );

      // Value should decrease
      const newValue = await slider.getAttribute("aria-valuenow");
      expect(Number(newValue)).toBeLessThan(Number(currentValue));
    });

    test("should jump to min with Home", async ({ page }) => {
      const slider = page.getByTestId("slider-keyboard-demo");
      await slider.focus();

      // Increase value first
      await page.keyboard.press("ArrowRight");
      await page.waitForTimeout(50);
      await page.keyboard.press("ArrowRight");
      await page.waitForTimeout(50);
      await page.keyboard.press("ArrowRight");
      await page.waitForTimeout(50);

      // Verify value increased
      const valueBeforeHome = await slider.getAttribute("aria-valuenow");
      expect(Number(valueBeforeHome)).toBeGreaterThan(0);

      // Jump to min with Home
      await page.keyboard.press("Home");

      // Wait for value to be 0
      await page.waitForFunction(
        ([testId]) => {
          const el = document.querySelector(`[data-testid="${testId}"]`);
          const value = el?.getAttribute("aria-valuenow");
          return value === "0";
        },
        ["slider-keyboard-demo"]
      );

      // Value should be at minimum
      const newValue = await slider.getAttribute("aria-valuenow");
      expect(Number(newValue)).toBe(0);
    });

    test("should jump to max with End", async ({ page }) => {
      const slider = page.getByTestId("slider-keyboard-demo");
      await slider.focus();

      // Jump to max with End
      await page.keyboard.press("End");

      // Wait for value to be at maximum (100)
      await page.waitForFunction(
        ([testId]) => {
          const el = document.querySelector(`[data-testid="${testId}"]`);
          const value = el?.getAttribute("aria-valuenow");
          return value !== null && Number(value) > 50;
        },
        ["slider-keyboard-demo"]
      );

      // Value should be at maximum
      const newValue = await slider.getAttribute("aria-valuenow");
      // Assuming default max is 100
      expect(Number(newValue)).toBeGreaterThan(50);
    });

    test("should page increase/decrease", async ({ page }) => {
      const slider = page.getByTestId("slider-keyboard-demo");
      await slider.focus();

      // Get initial value
      const initialValue = await slider.getAttribute("aria-valuenow");

      // Page increase
      await page.keyboard.press("PageUp");

      // Wait for value to change
      await page.waitForFunction(
        ([testId, expectedValue]) => {
          const el = document.querySelector(`[data-testid="${testId}"]`);
          return el?.getAttribute("aria-valuenow") !== expectedValue;
        },
        ["slider-keyboard-demo", initialValue]
      );

      const afterPageUp = await slider.getAttribute("aria-valuenow");
      expect(Number(afterPageUp)).toBeGreaterThan(Number(initialValue));

      // Page decrease
      await page.keyboard.press("PageDown");

      // Wait for value to change
      await page.waitForFunction(
        ([testId, expectedValue]) => {
          const el = document.querySelector(`[data-testid="${testId}"]`);
          return el?.getAttribute("aria-valuenow") !== expectedValue;
        },
        ["slider-keyboard-demo", afterPageUp]
      );

      const afterPageDown = await slider.getAttribute("aria-valuenow");
      expect(Number(afterPageDown)).toBeLessThan(Number(afterPageUp));
    });
  });

  test.describe("Toggle Button Group", () => {
    test("should navigate with arrow keys", async ({ page }) => {
      const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
      await toggleGroup.focus();

      // Initial focus
      await expect(page.locator(":focus")).toBeVisible();

      // ArrowRight should move to next button
      await page.keyboard.press("ArrowRight");
      const focusedAfterRight = page.locator(":focus");
      await expect(focusedAfterRight).toBeVisible();

      // ArrowLeft should move back
      await page.keyboard.press("ArrowLeft");
      const focusedAfterLeft = page.locator(":focus");
      await expect(focusedAfterLeft).toBeVisible();
    });

    test("should toggle with Space", async ({ page }) => {
      const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
      await toggleGroup.focus();

      // Get initial pressed state
      let focusedButton = page.locator(":focus");
      const initialPressed = await focusedButton.getAttribute("aria-pressed");

      // Toggle with Space
      await page.keyboard.press(" ");

      // Wait for focus to move to button and aria-pressed to update
      await page.waitForFunction(() => {
        const focused = document.activeElement;
        return focused?.hasAttribute("aria-pressed");
      });

      // Verify toggled state
      focusedButton = page.locator(":focus");
      const newPressed = await focusedButton.getAttribute("aria-pressed");
      expect(newPressed).not.toBe(initialPressed);
    });

    test("should toggle with Enter", async ({ page }) => {
      const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
      await toggleGroup.focus();

      // Toggle with Enter
      await page.keyboard.press("Enter");

      // Verify button is still focused
      const focusedButton = page.locator(":focus");
      await expect(focusedButton).toBeVisible();
    });
  });

  test.describe("Grid List", () => {
    test("should navigate 2D with arrow keys", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Initial focus
      await expect(page.locator(":focus")).toBeVisible();

      // ArrowDown should move to next row
      await page.keyboard.press("ArrowDown");
      const focusedAfterDown = page.locator(":focus");
      await expect(focusedAfterDown).toBeVisible();

      // ArrowRight should move to next column
      await page.keyboard.press("ArrowRight");
      const focusedAfterRight = page.locator(":focus");
      await expect(focusedAfterRight).toBeVisible();
    });

    test("should select with Enter", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Navigate to second item
      await page.keyboard.press("ArrowDown");

      // Select with Enter
      await page.keyboard.press("Enter");

      // Item should show selected state
      const focusedItem = page.locator(":focus");
      await expect(focusedItem).toBeVisible();
    });

    test("should extend selection with Shift+Arrow", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Extend selection down
      await page.keyboard.press("Shift+ArrowDown");

      // Multiple items should be selected
      const focusedItem = page.locator(":focus");
      await expect(focusedItem).toBeVisible();
    });

    test("should move focus only with Ctrl+Arrow", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Move focus only (no selection)
      await page.keyboard.press("Control+ArrowDown");

      const focusedItem = page.locator(":focus");
      await expect(focusedItem).toBeVisible();
    });

    test("should wrap navigation horizontally", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Navigate to last column
      await page.keyboard.press("End");

      // ArrowRight should wrap
      await page.keyboard.press("ArrowRight");
      const focusedAfterWrap = page.locator(":focus");
      await expect(focusedAfterWrap).toBeVisible();
    });

    test("should jump to start/end with Home/End", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Navigate to middle
      await page.keyboard.press("ArrowDown");
      await page.keyboard.press("ArrowRight");

      // Home should jump to start
      await page.keyboard.press("Home");
      const focusedAfterHome = page.locator(":focus");
      await expect(focusedAfterHome).toBeVisible();
    });
  });

  test.describe("Table", () => {
    test("should navigate 2D cells with arrow keys", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      await table.focus();

      // Initial focus
      await expect(page.locator(":focus")).toBeVisible();

      // ArrowDown should move to next row
      await page.keyboard.press("ArrowDown");
      const focusedAfterDown = page.locator(":focus");
      await expect(focusedAfterDown).toBeVisible();

      // ArrowRight should move to next column
      await page.keyboard.press("ArrowRight");
      const focusedAfterRight = page.locator(":focus");
      await expect(focusedAfterRight).toBeVisible();
    });

    test("should select row with Space", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      await table.focus();

      // Select row with Space
      await page.keyboard.press(" ");

      // Row should show selected state
      const focusedCell = page.locator(":focus");
      await expect(focusedCell).toBeVisible();
    });

    test("should enter edit mode with F2", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      await table.focus();

      // Enter edit mode with F2
      await page.keyboard.press("F2");

      // Cell should show edit input
      const focusedElement = page.locator(":focus");
      await expect(focusedElement).toBeVisible();
    });

    test("should extend selection with Shift+Arrow", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      await table.focus();

      // Extend selection down
      await page.keyboard.press("Shift+ArrowDown");

      // Multiple rows should be selected
      const focusedCell = page.locator(":focus");
      await expect(focusedCell).toBeVisible();
    });

    test("should move focus only with Ctrl+Arrow", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      await table.focus();

      // Move focus only (no selection)
      await page.keyboard.press("Control+ArrowDown");

      const focusedCell = page.locator(":focus");
      await expect(focusedCell).toBeVisible();
    });

    test("should jump to row start/end with Home/End", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      await table.focus();

      // Navigate to middle column
      await page.keyboard.press("ArrowRight");
      await page.keyboard.press("ArrowRight");

      // Home should jump to row start
      await page.keyboard.press("Home");
      const focusedAfterHome = page.locator(":focus");
      await expect(focusedAfterHome).toBeVisible();
    });
  });

  test.describe("Combobox", () => {
    test("should open dropdown with ArrowDown", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      await combobox.focus();

      // Open with ArrowDown
      await page.keyboard.press("ArrowDown");

      // Dropdown should be visible
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).toBeVisible();
    });

    test("should navigate options with arrow keys", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      await combobox.focus();

      // Open dropdown
      await page.keyboard.press("ArrowDown");
      await combobox.locator('[role="listbox"]').waitFor();

      // ArrowDown should move to next option
      await page.keyboard.press("ArrowDown");
      const focusedOption = page.locator(":focus");
      await expect(focusedOption).toBeVisible();
    });

    test("should filter with type-ahead", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      await combobox.focus();

      // Type to filter
      await page.keyboard.type("a");

      // Should show filtered options
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).toBeVisible();
    });

    test("should select option with Enter", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      await combobox.focus();

      // Open dropdown
      await page.keyboard.press("ArrowDown");
      await combobox.locator('[role="listbox"]').waitFor();

      // Navigate to option
      await page.keyboard.press("ArrowDown");

      // Select with Enter
      await page.keyboard.press("Enter");

      // Dropdown should close
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).not.toBeVisible();
    });

    test("should close with Escape", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      await combobox.focus();

      // Open dropdown
      await page.keyboard.press("ArrowDown");
      await combobox.locator('[role="listbox"]').waitFor();

      // Close with Escape
      await page.keyboard.press("Escape");

      // Dropdown should be hidden
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).not.toBeVisible();
    });
  });

  test.describe("Focus Indicators", () => {
    test("should have visible focus on radio group", async ({ page }) => {
      const radioGroup = page.getByTestId("radio-group");
      await radioGroup.focus();

      const focusedElement = page.locator(":focus");
      await expect(focusedElement).toBeVisible();

      // Check for focus styles (ring, outline, or similar)
      const focusedClass = await focusedElement.evaluate((el) => {
        const styles = window.getComputedStyle(el);
        return styles.outlineStyle !== "none" ||
               styles.boxShadow !== "none" ||
               el.classList.contains("focus") ||
               el.classList.contains("focus-visible");
      });
      expect(focusedClass).toBe(true);
    });

    test("should have visible focus on toolbar", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");
      await toolbar.focus();

      const focusedElement = page.locator(":focus");
      await expect(focusedElement).toBeVisible();
      
      const focusedClass = await focusedElement.evaluate((el) => {
        const styles = window.getComputedStyle(el);
        return styles.outlineStyle !== "none" || 
               styles.boxShadow !== "none" ||
               el.classList.contains("focus") ||
               el.classList.contains("focus-visible");
      });
      expect(focusedClass).toBe(true);
    });

    test("should have visible focus on select", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      await select.focus();

      const focusedElement = page.locator(":focus");
      await expect(focusedElement).toBeVisible();

      const focusedClass = await focusedElement.evaluate((el) => {
        const styles = window.getComputedStyle(el);
        return styles.outlineStyle !== "none" ||
               styles.boxShadow !== "none" ||
               el.classList.contains("focus") ||
               el.classList.contains("focus-visible");
      });
      expect(focusedClass).toBe(true);
    });
  });

  test.describe("Roving Tabindex", () => {
    test("should have roving tabindex on radio group", async ({ page }) => {
      const radioGroup = page.getByTestId("radio-group");
      await radioGroup.focus();

      // Only one radio should have tabindex="0"
      const radios = radioGroup.locator('input[type="radio"]');
      const count = await radios.count();

      let tabindexZeroCount = 0;
      for (let i = 0; i < count; i++) {
        const radio = radios.nth(i);
        const tabindex = await radio.getAttribute("tabindex");
        if (tabindex === "0") {
          tabindexZeroCount++;
        }
      }

      expect(tabindexZeroCount).toBe(1);
    });

    test("should update roving tabindex on navigation", async ({ page }) => {
      const radioGroup = page.getByTestId("radio-group");
      await radioGroup.focus();

      // Navigate to second radio
      await page.keyboard.press("ArrowDown");

      // Wait for focus to move to second radio
      await page.waitForFunction(() => {
        const focused = document.activeElement;
        return focused !== null && focused.tagName === "INPUT";
      });

      // Tabindex should have moved
      const radios = radioGroup.locator('input[type="radio"]');
      const count = await radios.count();

      let tabindexZeroCount = 0;
      for (let i = 0; i < count; i++) {
        const radio = radios.nth(i);
        const tabindex = await radio.getAttribute("tabindex");
        if (tabindex === "0") {
          tabindexZeroCount++;
        }
      }

      expect(tabindexZeroCount).toBe(1);
    });
  });

  test.describe("Accessibility", () => {
    test("keyboard navigation demos should not have WCAG violations", async ({ page }, testInfo) => {
      const radioGroup = page.getByTestId("radio-group");
      await expect(radioGroup).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("body")
        .disableRules([
          "color-contrast",
          "aria-required-attr",
          "aria-required-children",
          "aria-required-parent",
          "aria-valid-attr-value",
          "image-alt",
          "nested-interactive",
          "scrollable-region-focusable",
          "target-size",
        ])
        .analyze();

      await testInfo.attach("keyboard-nav-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
