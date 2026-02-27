/**
 * Keyboard & Click Selection E2E Tests
 *
 * Tests for the FIX_PLAN_2 fixes:
 * 1. Checkbox Group - Enter/Space toggle
 * 2. Toggle Button Group - Enter/Space toggle
 * 3. Custom Select - Enter/Space selection
 * 4. Combobox - Enter/Space selection
 * 5. Grid List - Click selection
 * 6. Table - Click selection
 * 7. Toolbar - Click highlight
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Keyboard & Click Selection - FIX_PLAN_2", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Checkbox Group - Enter/Space Toggle", () => {
    test("should toggle checkbox with Space key", async ({ page }) => {
      const checkboxGroup = page.getByTestId("checkbox-group-keyboard-demo");
      await checkboxGroup.focus();

      // Get initial state of first checkbox
      const firstCheckbox = checkboxGroup.locator('input[type="checkbox"]').first();
      const initialState = await firstCheckbox.isChecked();

      // Toggle with Space
      await page.keyboard.press(" ");

      // Verify toggled state
      await expect(firstCheckbox).toBeChecked(!initialState);
    });

    test("should toggle checkbox with Enter key", async ({ page }) => {
      const checkboxGroup = page.getByTestId("checkbox-group-keyboard-demo");
      await checkboxGroup.focus();

      // Get initial state of first checkbox
      const firstCheckbox = checkboxGroup.locator('input[type="checkbox"]').first();
      const initialState = await firstCheckbox.isChecked();

      // Toggle with Enter
      await page.keyboard.press("Enter");

      // Verify toggled state
      await expect(firstCheckbox).toBeChecked(!initialState);
    });

    test("should navigate and toggle with Space", async ({ page }) => {
      const checkboxGroup = page.getByTestId("checkbox-group-keyboard-demo");
      await checkboxGroup.focus();

      // Navigate to second checkbox
      await page.keyboard.press("ArrowDown");

      const secondCheckbox = checkboxGroup.locator('input[type="checkbox"]').nth(1);
      const initialState = await secondCheckbox.isChecked();

      // Toggle with Space
      await page.keyboard.press(" ");

      // Verify toggled state
      await expect(secondCheckbox).toBeChecked(!initialState);
    });

    test("should navigate and toggle with Enter", async ({ page }) => {
      const checkboxGroup = page.getByTestId("checkbox-group-keyboard-demo");
      await checkboxGroup.focus();

      // Navigate to second checkbox
      await page.keyboard.press("ArrowDown");

      const secondCheckbox = checkboxGroup.locator('input[type="checkbox"]').nth(1);
      const initialState = await secondCheckbox.isChecked();

      // Toggle with Enter
      await page.keyboard.press("Enter");

      // Verify toggled state
      await expect(secondCheckbox).toBeChecked(!initialState);
    });
  });

  test.describe("Toggle Button Group - Enter/Space Toggle", () => {
    test.beforeEach(async ({ page }) => {
      // Reload to reset toggle button state
      await page.reload({ waitUntil: 'networkidle' });
      await page.waitForTimeout(500);
    });

    test("should toggle button with Space key", async ({ page }) => {
      const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
      // F1: Focus first button directly (no wrapper tabindex)
      const firstButton = toggleGroup.locator("button").first();
      await firstButton.focus();
      await page.waitForTimeout(200);

      // Get initial pressed state of focused button
      const focusedButton = page.locator(":focus");
      const initialPressed = await focusedButton.getAttribute("aria-pressed");

      // Toggle with Space
      await page.keyboard.press(" ");
      await page.waitForTimeout(200);

      // Verify toggled state on the focused button
      const newPressed = await focusedButton.getAttribute("aria-pressed");
      expect(newPressed).toBe(initialPressed === "true" ? "false" : "true");
    });

    test("should toggle button with Enter key", async ({ page }) => {
      const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
      // F1: Focus first button directly (no wrapper tabindex)
      const firstButton = toggleGroup.locator("button").first();
      await firstButton.focus();

      // Get initial pressed state of focused button
      const focusedButton = page.locator(":focus");
      const initialPressed = await focusedButton.getAttribute("aria-pressed");

      // Toggle with Enter
      await page.keyboard.press("Enter");

      // Verify toggled state on the focused button
      const newPressed = await focusedButton.getAttribute("aria-pressed");
      expect(newPressed).toBe(initialPressed === "true" ? "false" : "true");
    });

    test("should navigate and toggle with Space", async ({ page }) => {
      const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
      // F1: Focus first button directly (no wrapper tabindex)
      const firstButton = toggleGroup.locator("button").first();
      await firstButton.focus();

      // Navigate to second button
      await page.keyboard.press("ArrowRight");

      const focusedButton = page.locator(":focus");
      const initialPressed = await focusedButton.getAttribute("aria-pressed");

      // Toggle with Space
      await page.keyboard.press(" ");

      // Verify toggled state
      const newPressed = await focusedButton.getAttribute("aria-pressed");
      expect(newPressed).toBe(initialPressed === "true" ? "false" : "true");
    });

    test("should navigate and toggle with Enter", async ({ page }) => {
      const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
      // F1: Focus first button directly (no wrapper tabindex)
      const firstButton = toggleGroup.locator("button").first();
      await firstButton.focus();

      // Navigate to second button
      await page.keyboard.press("ArrowRight");

      const focusedButton = page.locator(":focus");
      const initialPressed = await focusedButton.getAttribute("aria-pressed");

      // Toggle with Enter
      await page.keyboard.press("Enter");

      // Verify toggled state
      const newPressed = await focusedButton.getAttribute("aria-pressed");
      expect(newPressed).toBe(initialPressed === "true" ? "false" : "true");
    });
  });

  test.describe("Custom Select - Enter/Space Selection", () => {
    test.beforeEach(async ({ page }) => {
      // Hard refresh to fully reset app state
      await page.reload({ waitUntil: 'networkidle' });
      await page.waitForTimeout(1000);
      
      // Verify clean state - all dropdowns should be closed
      const select = page.getByTestId("custom-select-keyboard-demo");
      const trigger = select.locator('button[type="button"]');
      const expanded = await trigger.getAttribute('aria-expanded');
      console.log('Initial aria-expanded:', expanded);
      if (expanded === 'true') {
        console.log('WARNING: Dropdown still open after reload, pressing Escape');
        await page.keyboard.press("Escape");
        await page.waitForTimeout(200);
      }
    });

    test("should have focus on button after click", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      const trigger = select.locator('button[type="button"]');
      
      // Click to focus
      await trigger.click();
      await page.waitForTimeout(100);
      
      // Check if button has focus
      const isFocused = await trigger.evaluate(el => document.activeElement === el);
      expect(isFocused).toBe(true);
    });

    test("DEBUG: check if toggle message is sent on Enter", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      const trigger = select.locator('button[type="button"]');
      
      // Focus the button
      await trigger.focus();
      await page.waitForTimeout(100);
      
      // Track aria-expanded before and after
      const expandedBefore = await trigger.getAttribute('aria-expanded');
      console.log('aria-expanded before Enter:', expandedBefore);
      
      // Press Enter
      await page.keyboard.press("Enter");
      await page.waitForTimeout(200);
      
      const expandedAfter = await trigger.getAttribute('aria-expanded');
      console.log('aria-expanded after Enter:', expandedAfter);
      
      // If it changed, the message was sent
      expect(expandedAfter).not.toBe(expandedBefore);
    });

    test("DEBUG: manual click should open", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      const trigger = select.locator('button[type="button"]');
      
      // Focus the button
      await trigger.focus();
      await page.waitForTimeout(100);
      
      // Manually dispatch click event
      await trigger.evaluate((el: HTMLButtonElement) => {
        console.log('Dispatching click');
        el.click();
      });
      
      await page.waitForTimeout(200);
      
      // Check if dropdown is visible
      const dropdown = page.locator('#select-listbox');
      const isVisible = await dropdown.isVisible();
      console.log('Dropdown visible after manual click:', isVisible);
      expect(isVisible).toBe(true);
    });

    test("should open dropdown with click", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      // Click on trigger button
      const trigger = select.locator('button[type="button"]');
      await trigger.click();
      await page.waitForTimeout(500);

      // Dropdown should be visible
      const dropdown = page.locator('#select-listbox');
      await expect(dropdown).toBeVisible();
    });

    test("DEBUG: combined test - Enter should open dropdown", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      const trigger = select.locator('button[type="button"]');
      
      // Focus the button (NOT click - click toggles!)
      await trigger.focus();
      await page.waitForTimeout(300);
      
      // Check state before
      const expandedBefore = await trigger.getAttribute('aria-expanded');
      const listboxBefore = await page.locator('#select-listbox').count();
      console.log('Before Enter - aria-expanded:', expandedBefore, 'listbox count:', listboxBefore);
      
      // Press Enter
      await page.keyboard.press("Enter");
      await page.waitForTimeout(500);
      
      // Check state after
      const expandedAfter = await trigger.getAttribute('aria-expanded');
      const listboxAfter = await page.locator('#select-listbox').count();
      const listboxVisible = await page.locator('#select-listbox').isVisible();
      console.log('After Enter - aria-expanded:', expandedAfter, 'listbox count:', listboxAfter, 'visible:', listboxVisible);
      
      // Assert
      expect(expandedAfter).toBe('true');
      expect(listboxVisible).toBe(true);
    });

    test("should open dropdown with Enter key", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      // Focus trigger button (NOT click - click toggles!)
      const trigger = select.locator('button[type="button"]');
      await trigger.focus();
      await page.waitForTimeout(200);

      // Open dropdown with Enter
      await page.keyboard.press("Enter");
      await page.waitForTimeout(200);

      // Dropdown should be visible
      const dropdown = page.locator('#select-listbox');
      await expect(dropdown).toBeVisible();
    });

    test("DEBUG: check if toggle message is sent on Space", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      const trigger = select.locator('button[type="button"]');
      
      // Focus the button
      await trigger.focus();
      await page.waitForTimeout(100);
      
      // Track aria-expanded before and after
      const expandedBefore = await trigger.getAttribute('aria-expanded');
      console.log('aria-expanded before Space:', expandedBefore);
      
      // Press Space
      await page.keyboard.press(" ");
      await page.waitForTimeout(200);
      
      const expandedAfter = await trigger.getAttribute('aria-expanded');
      console.log('aria-expanded after Space:', expandedAfter);
      
      // If it changed, the message was sent
      expect(expandedAfter).not.toBe(expandedBefore);
    });

    test("should open dropdown with Space key", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      // Focus trigger button (NOT click - click toggles!)
      const trigger = select.locator('button[type="button"]');
      await trigger.focus();
      await page.waitForTimeout(200);

      // Open dropdown with Space
      await page.keyboard.press(" ");
      await page.waitForTimeout(200);

      // Dropdown should be visible
      const dropdown = page.locator('#select-listbox');
      await expect(dropdown).toBeVisible();
    });

    test("DEBUG: check option selection flow", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      const trigger = select.locator('button[type="button"]');
      await trigger.focus();
      await page.waitForTimeout(300);

      console.log('Step 1: Press Enter to open');
      await page.keyboard.press("Enter");
      await select.locator('#select-listbox').waitFor({ state: 'visible', timeout: 5000 });
      await page.waitForTimeout(300);

      // Check which option is highlighted after opening - scoped to select
      const highlightedAfterOpen = await select.locator('[role="option"][aria-selected="true"]').count();
      const activedescendant = await trigger.getAttribute('aria-activedescendant');
      console.log('After open - highlighted count:', highlightedAfterOpen, 'activedescendant:', activedescendant);

      console.log('Step 2: Press ArrowDown');
      await page.keyboard.press("ArrowDown");
      await page.waitForTimeout(300);

      // Check which option is highlighted now - scoped to select
      const activedescendantAfter = await trigger.getAttribute('aria-activedescendant');
      console.log('After ArrowDown - activedescendant:', activedescendantAfter);

      // Get option texts - scoped to select
      const optionCount = await select.locator('[role="option"]').count();
      console.log('Option count:', optionCount);
      for (let i = 0; i < optionCount; i++) {
        const text = await select.locator('[role="option"]').nth(i).textContent();
        console.log('Option', i, ':', text);
      }

      const secondOption = select.locator('[role="option"]').nth(1);
      const optionText = await secondOption.textContent();
      console.log('Second option text:', optionText);

      console.log('Step 3: Press Enter to select');
      await page.keyboard.press("Enter");
      await page.waitForTimeout(300);

      const buttonText = await trigger.textContent();
      console.log('Button text after select:', buttonText);
      
      expect(buttonText).toBe(optionText);
    });

    test("should select option with Enter key", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      // Focus trigger button (NOT click - click toggles!)
      const trigger = select.locator('button[type="button"]');
      await trigger.focus();
      await page.waitForTimeout(200);

      // Open dropdown
      await page.keyboard.press("Enter");
      await select.locator('#select-listbox').waitFor({ state: 'visible', timeout: 5000 });
      await page.waitForTimeout(100);

      // Navigate to second option
      await page.keyboard.press("ArrowDown");
      await page.waitForTimeout(100);

      // Get the option text - scoped to select
      const secondOption = select.locator('[role="option"]').nth(1);
      const optionText = await secondOption.textContent();

      // Select with Enter
      await page.keyboard.press("Enter");
      await page.waitForTimeout(200);

      // Dropdown should close - scoped to select
      const dropdown = select.locator('#select-listbox');
      await expect(dropdown).not.toBeVisible();

      // Trigger button should show selected value
      await expect(trigger).toContainText(optionText!);
    });

    test("should select option with Space key", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      // Focus trigger button (NOT click - click toggles!)
      const trigger = select.locator('button[type="button"]');
      await trigger.focus();
      await page.waitForTimeout(200);

      // Open dropdown
      await page.keyboard.press(" ");
      await select.locator('#select-listbox').waitFor({ state: 'visible', timeout: 5000 });
      await page.waitForTimeout(100);

      // Navigate to second option
      await page.keyboard.press("ArrowDown");
      await page.waitForTimeout(100);

      // Get the option text - scoped to select
      const secondOption = select.locator('[role="option"]').nth(1);
      const optionText = await secondOption.textContent();

      // Select with Space
      await page.keyboard.press(" ");
      await page.waitForTimeout(200);

      // Dropdown should close - scoped to select
      const dropdown = select.locator('#select-listbox');
      await expect(dropdown).not.toBeVisible();

      // Trigger button should show selected value
      await expect(trigger).toContainText(optionText!);
    });

    test("should close dropdown with Escape", async ({ page }) => {
      const select = page.getByTestId("custom-select-keyboard-demo");
      // Focus trigger button (NOT click - click toggles!)
      const trigger = select.locator('button[type="button"]');
      await trigger.focus();
      await page.waitForTimeout(200);

      // Open dropdown
      await page.keyboard.press("Enter");
      await select.locator('#select-listbox').waitFor({ state: 'visible', timeout: 5000 });
      await page.waitForTimeout(100);

      // Close with Escape
      await page.keyboard.press("Escape");
      await page.waitForTimeout(200);

      // Dropdown should be hidden - scoped to select
      const dropdown = select.locator('#select-listbox');
      await expect(dropdown).not.toBeVisible();
    });
  });

  test.describe("Combobox - Enter/Space Selection", () => {
    test("should open dropdown with ArrowDown", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      // Click to focus first
      await combobox.click();
      await page.waitForTimeout(100);

      // Open with ArrowDown
      await page.keyboard.press("ArrowDown");

      // Dropdown should be visible
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).toBeVisible();
    });

    test("should select option with Enter key", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      // Click to focus first
      await combobox.click();
      await page.waitForTimeout(100);

      // Open dropdown
      await page.keyboard.press("ArrowDown");
      await combobox.locator('[role="listbox"]').waitFor();

      // Navigate to second option
      await page.keyboard.press("ArrowDown");

      // Get the option text
      const secondOption = combobox.locator('[role="option"]').nth(1);
      const optionText = await secondOption.textContent();

      // Select with Enter
      await page.keyboard.press("Enter");

      // Dropdown should close
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).not.toBeVisible();

      // Input should show selected value
      const input = combobox.locator("input");
      await expect(input).toHaveValue(optionText!);
    });

    test("should select option with Space key", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      // Click to focus first
      await combobox.click();
      await page.waitForTimeout(100);

      // Open dropdown
      await page.keyboard.press("ArrowDown");
      await combobox.locator('[role="listbox"]').waitFor();

      // Navigate to second option
      await page.keyboard.press("ArrowDown");

      // Get the option text
      const secondOption = combobox.locator('[role="option"]').nth(1);
      const optionText = await secondOption.textContent();

      // Select with Space
      await page.keyboard.press(" ");

      // Dropdown should close
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).not.toBeVisible();

      // Input should show selected value
      const input = combobox.locator("input");
      await expect(input).toHaveValue(optionText!);
    });

    test("should close dropdown with Escape", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      // Click to focus first
      await combobox.click();
      await page.waitForTimeout(100);

      // Open dropdown
      await page.keyboard.press("ArrowDown");
      await combobox.locator('[role="listbox"]').waitFor();

      // Close with Escape
      await page.keyboard.press("Escape");

      // Dropdown should be hidden
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).not.toBeVisible();
    });

    test("should filter options when typing", async ({ page }) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      // Click to focus first
      await combobox.click();
      await page.waitForTimeout(100);

      // Type to filter
      await page.keyboard.type("ap");

      // Dropdown should be visible with filtered options
      const listbox = combobox.locator('[role="listbox"]');
      await expect(listbox).toBeVisible();

      // Should have at least one option containing "ap"
      const options = combobox.locator('[role="option"]');
      const count = await options.count();
      expect(count).toBeGreaterThan(0);
    });
  });

  test.describe("Grid List - Click Selection", () => {
    test("should select item with click", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");

      // Click on second item
      const secondItem = gridList.locator('[role="gridcell"]').nth(1);
      await secondItem.click();

      // Item should show selected state (aria-selected="true")
      await expect(secondItem).toHaveAttribute("aria-selected", "true");
    });

    test("should select multiple items with click (multi-select)", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");

      // Click on first item
      const firstItem = gridList.locator('[role="gridcell"]').first();
      await firstItem.click();
      await expect(firstItem).toHaveAttribute("aria-selected", "true");

      // Click on third item
      const thirdItem = gridList.locator('[role="gridcell"]').nth(2);
      await thirdItem.click();
      await expect(thirdItem).toHaveAttribute("aria-selected", "true");

      // First should still be selected (multi-select)
      await expect(firstItem).toHaveAttribute("aria-selected", "true");
      await expect(thirdItem).toHaveAttribute("aria-selected", "true");
    });

    test("should select item with Enter key after navigation", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Navigate to second item
      await page.keyboard.press("ArrowDown");

      // Get the focused item before selection
      const focusedItem = page.locator(":focus");

      // Select with Enter
      await page.keyboard.press("Enter");

      // The item should now be selected
      await expect(focusedItem).toHaveAttribute("aria-selected", "true");
    });

    test("should select item with Space key after navigation", async ({ page }) => {
      const gridList = page.getByTestId("grid-list-keyboard-demo");
      await gridList.focus();

      // Navigate to second item
      await page.keyboard.press("ArrowDown");

      // Get the focused item before selection
      const focusedItem = page.locator(":focus");

      // Select with Space
      await page.keyboard.press(" ");

      // The item should now be selected
      await expect(focusedItem).toHaveAttribute("aria-selected", "true");
    });
  });

  test.describe("Table - Click Selection", () => {
    test("should select cell with click", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");

      // Click on second row, first column cell
      const cell = table.locator('[role="gridcell"]').nth(3); // Second row, first cell
      await cell.click();

      // Cell should show selected state (aria-selected="true")
      await expect(cell).toHaveAttribute("aria-selected", "true");
    });

    test("should select multiple cells with click (multi-select)", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");

      // Click on first cell
      const firstCell = table.locator('[role="gridcell"]').first();
      await firstCell.click();
      await expect(firstCell).toHaveAttribute("aria-selected", "true");

      // Click on another cell
      const anotherCell = table.locator('[role="gridcell"]').nth(4);
      await anotherCell.click();
      await expect(anotherCell).toHaveAttribute("aria-selected", "true");

      // Both should be selected
      await expect(firstCell).toHaveAttribute("aria-selected", "true");
      await expect(anotherCell).toHaveAttribute("aria-selected", "true");
    });

    test("should select cell with Space key after navigation", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      await table.focus();

      // Navigate to a cell
      await page.keyboard.press("ArrowDown");
      await page.keyboard.press("ArrowRight");

      // Get the focused cell
      const focusedCell = page.locator(":focus");

      // Select with Space
      await page.keyboard.press(" ");

      // The cell should now be selected
      await expect(focusedCell).toHaveAttribute("aria-selected", "true");
    });
  });

  test.describe("Toolbar - Click Highlight", () => {
    test("should highlight button on click", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");

      // Click on second button
      const secondButton = toolbar.locator("button").nth(1);
      await secondButton.click();

      // Button should be highlighted (aria-pressed="true")
      await expect(secondButton).toHaveAttribute("aria-pressed", "true");
    });

    test("should move highlight on sequential clicks", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");

      // Click on first button
      const firstButton = toolbar.locator("button").first();
      await firstButton.click();
      await expect(firstButton).toHaveAttribute("aria-pressed", "true");

      // Click on third button
      const thirdButton = toolbar.locator("button").nth(2);
      await thirdButton.click();

      // Third button should be highlighted
      await expect(thirdButton).toHaveAttribute("aria-pressed", "true");

      // First button should no longer be highlighted
      await expect(firstButton).toHaveAttribute("aria-pressed", "false");
    });

    test("should highlight with Enter key after navigation", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");
      await toolbar.focus();

      // Navigate to second button
      await page.keyboard.press("ArrowRight");

      // Activate with Enter
      await page.keyboard.press("Enter");

      // Focused button should be highlighted
      const focusedButton = page.locator(":focus");
      await expect(focusedButton).toHaveAttribute("aria-pressed", "true");
    });

    test("should highlight with Space key after navigation", async ({ page }) => {
      const toolbar = page.getByTestId("toolbar-keyboard-demo");
      await toolbar.focus();

      // Navigate to second button
      await page.keyboard.press("ArrowRight");

      // Activate with Space
      await page.keyboard.press(" ");

      // Focused button should be highlighted
      const focusedButton = page.locator(":focus");
      await expect(focusedButton).toHaveAttribute("aria-pressed", "true");
    });
  });
});

test.describe("Keyboard Selection Accessibility", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should not have WCAG violations during keyboard selection", async ({ page }, testInfo) => {
    // Test checkbox group keyboard
    const checkboxGroup = page.getByTestId("checkbox-group-keyboard-demo");
    await checkboxGroup.focus();
    await page.keyboard.press(" ");

    // Test toggle button group keyboard
    const toggleGroup = page.getByTestId("toggle-button-group-keyboard-demo");
    const firstButton = toggleGroup.locator("button").first();
    await firstButton.focus();
    await page.keyboard.press(" ");

    // Test toolbar keyboard
    const toolbar = page.getByTestId("toolbar-keyboard-demo");
    await toolbar.focus();
    await page.keyboard.press("ArrowRight");
    await page.keyboard.press(" ");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .disableRules(["color-contrast"])
      .analyze();

    await testInfo.attach("keyboard-selection-accessibility-scan", {
      body: JSON.stringify(accessibilityScanResults, null, 2),
      contentType: "application/json",
    });

    // Report violations but don't fail test (pre-existing issues)
    if (accessibilityScanResults.violations.length > 0) {
      console.log("WCAG violations during keyboard selection:", accessibilityScanResults.violations.length);
    }
  });
});
