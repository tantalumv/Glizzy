/**
 * Collections & Data Accessibility Tests
 */

import { test, expect, type Page } from "@playwright/test";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const axeSource = readFileSync(resolve("node_modules/axe-core/axe.min.js"), "utf8");

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Collections", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("listbox has aria-label and activedescendant", async ({ page }) => {
    const listbox = page.getByRole("listbox", { name: "Select an item" });
    await expect(listbox).toBeVisible();
    await expect(listbox).toHaveAttribute("aria-activedescendant", "");
    await expect(listbox).toHaveAttribute("tabindex", "0");
  });

  test("listbox options have correct roles", async ({ page }) => {
    const listbox = page.getByTestId("listbox-demo");
    const options = listbox.getByRole("option");
    await expect(options).toHaveCount(3);
    
    const firstOption = options.first();
    await expect(firstOption).toHaveAttribute("aria-selected", "false");
    await expect(firstOption).toHaveAttribute("tabindex", "-1");
  });

  test("grid list has multiselectable attribute", async ({ page }) => {
    const grid = page.getByTestId("gridlist-demo");
    await expect(grid).toHaveAttribute("role", "grid");
    await expect(grid).toHaveAttribute("aria-multiselectable", "true");
    await expect(grid).toHaveAttribute("aria-label", "Select items");
  });

  test("grid list items have row roles", async ({ page }) => {
    const grid = page.getByTestId("gridlist-demo");
    const rows = grid.getByRole("row");
    await expect(rows).toHaveCount(3);
  });

  test("table has grid role and aria-label", async ({ page }) => {
    const table = page.getByTestId("table-demo");
    await expect(table).toHaveAttribute("role", "grid");
    await expect(table).toHaveAttribute("aria-label", "Data table");
  });

  test("table headers have columnheader role", async ({ page }) => {
    const table = page.getByTestId("table-demo");
    const headers = table.getByRole("columnheader");
    await expect(headers).toHaveCount(3);
  });

  test("table rows have correct roles", async ({ page }) => {
    const table = page.getByTestId("table-demo");
    const rows = table.getByRole("row");
    await expect(rows).toHaveCount(3);
  });

  test("tag group items are focusable", async ({ page }) => {
    const tagGroup = page.getByTestId("tag-group-demo");
    await expect(tagGroup).toBeVisible();
    
    const tags = tagGroup.locator("[tabindex='0']");
    await expect(tags).toHaveCount(3);
  });

  test("tree has aria-label and activedescendant", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    await expect(tree).toHaveAttribute("role", "tree");
    await expect(tree).toHaveAttribute("aria-label", "File browser");
    await expect(tree).toHaveAttribute("aria-activedescendant", "");
  });

  test("tree items have correct roles", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const treeItems = tree.getByRole("treeitem");
    await expect(treeItems.first()).toBeVisible();
    
    const rootNode = treeItems.first();
    await expect(rootNode).toHaveAttribute("aria-selected", "false");
  });

  test("toolbar has correct role and label", async ({ page }) => {
    const toolbar = page.getByTestId("toolbar-keyboard-demo");
    await expect(toolbar).toHaveAttribute("role", "toolbar");
    await expect(toolbar).toHaveAttribute("aria-label", "Keyboard-enabled toolbar");
  });

  test("group has correct role and label", async ({ page }) => {
    const group = page.getByTestId("group-demo");
    await expect(group).toHaveAttribute("role", "group");
    await expect(group).toHaveAttribute("aria-label", "Filter options");
  });

  test("virtualizer has listbox role", async ({ page }) => {
    const virtualizer = page.getByTestId("virtualizer-demo");
    await expect(virtualizer).toHaveAttribute("role", "listbox");
    await expect(virtualizer).toHaveAttribute("aria-label", "Virtual list");
  });

  test("virtualizer items have option role", async ({ page }) => {
    const virtualizer = page.getByTestId("virtualizer-demo");
    const options = virtualizer.getByRole("option");
    await expect(options).toHaveCount(3);
  });

  test("collections keyboard hint is visible", async ({ page }) => {
    const hint = page.getByTestId("collections-keyboard-hint");
    await expect(hint).toContainText("arrow keys");
    await expect(hint).toContainText("Space/Enter");
  });

  test("tree items are focusable with tab", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const treeItems = tree.getByRole("treeitem");
    const firstItem = treeItems.first();
    
    await firstItem.focus();
    await expect(firstItem).toBeFocused();
  });

  test("tree supports arrow key navigation", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const treeItems = tree.getByRole("treeitem");
    
    const firstItem = treeItems.nth(0);
    await firstItem.focus();
    
    await page.keyboard.press("ArrowDown");
    const secondItem = treeItems.nth(1);
    const isFocused = await secondItem.evaluate((el) => el === document.activeElement);
    expect(isFocused).toBeTruthy();
  });

  test("tree supports Home/End key navigation", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const treeItems = tree.getByRole("treeitem");

    const firstItem = treeItems.first();
    await firstItem.focus();

    await page.keyboard.press("End");
    const lastItem = treeItems.last();
    const isFocused = await lastItem.evaluate((el) => el === document.activeElement);
    expect(isFocused).toBeTruthy();
  });

  test("tree expand button has aria-expanded attribute", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const expandButtons = tree.locator("button[aria-expanded]");
    
    // At least one expand button should exist
    const count = await expandButtons.count();
    expect(count).toBeGreaterThan(0);
    
    // Check that aria-expanded is either "true" or "false"
    const firstButton = expandButtons.first();
    const ariaExpanded = await firstButton.getAttribute("aria-expanded");
    expect(ariaExpanded).toMatch(/^(true|false)$/);
  });

  test("tree expand button aria-label reflects state", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const expandButtons = tree.locator("button[aria-expanded]");
    
    const count = await expandButtons.count();
    for (let i = 0; i < count; i++) {
      const button = expandButtons.nth(i);
      const ariaExpanded = await button.getAttribute("aria-expanded");
      const ariaLabel = await button.getAttribute("aria-label");
      
      if (ariaExpanded === "true") {
        expect(ariaLabel).toBe("Collapse");
      } else {
        expect(ariaLabel).toBe("Expand");
      }
    }
  });

  test("tree items with children have aria-expanded", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const treeItems = tree.getByRole("treeitem");
    
    const count = await treeItems.count();
    for (let i = 0; i < count; i++) {
      const item = treeItems.nth(i);
      const ariaExpanded = await item.getAttribute("aria-expanded");
      // Items should have aria-expanded attribute
      expect(ariaExpanded).toMatch(/^(true|false)$/);
    }
  });

  test("clicking expand button toggles aria-expanded", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const expandButtons = tree.locator("button[aria-expanded]");
    
    const firstButton = expandButtons.first();
    const initialExpanded = await firstButton.getAttribute("aria-expanded");
    
    // Click the expand button
    await firstButton.click();
    
    // Wait for the attribute to change
    const expectedValue = initialExpanded === "true" ? "false" : "true";
    await expect(firstButton).toHaveAttribute("aria-expanded", expectedValue);
    
    const newExpanded = await firstButton.getAttribute("aria-expanded");
    expect(newExpanded).toBe(expectedValue);
  });

  test("tree group visibility toggles with expand/collapse", async ({ page }) => {
    const tree = page.getByTestId("tree-demo");
    const expandButtons = tree.locator("button[aria-expanded]");
    
    const firstButton = expandButtons.first();
    const initialExpanded = await firstButton.getAttribute("aria-expanded");
    
    // Find the parent treeitem for this button
    const parentTreeItem = firstButton.locator("xpath=ancestor-or-self::*[@role='treeitem']").first();
    
    if (initialExpanded === "true") {
      // Should have a visible group
      const group = parentTreeItem.locator("[role='group']").first();
      await expect(group).toBeVisible();
      
      // Collapse it
      await firstButton.click();
      await expect(firstButton).toHaveAttribute("aria-expanded", "false");
      
      // Group should be hidden or removed
      const groupAfter = parentTreeItem.locator("[role='group']").first();
      const isVisible = await groupAfter.isVisible({ timeout: 1000 }).catch(() => false);
      expect(isVisible).toBeFalsy();
    } else {
      // Should not have a visible group
      const group = parentTreeItem.locator("[role='group']").first();
      const isVisible = await group.isVisible({ timeout: 1000 }).catch(() => false);
      expect(isVisible).toBeFalsy();
      
      // Expand it
      await firstButton.click();
      await expect(firstButton).toHaveAttribute("aria-expanded", "true");
      
      // Group should be visible
      const groupAfter = parentTreeItem.locator("[role='group']").first();
      await expect(groupAfter).toBeVisible();
    }
  });
});

test.describe("Collections Axe Scan", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("collections section has no axe violations", async ({ page }) => {
    const section = page.getByTestId("collections-section");
    await expect(section).toBeVisible();

    await page.addScriptTag({ content: axeSource });
    const results = await page.evaluate(async () => {
      // @ts-expect-error axe is injected by addScriptTag
      return await axe.run(document.querySelector("[data-testid='collections-section']"), {
        runOnly: { type: "tag", values: ["wcag2aa", "wcag2a"] },
      });
    });

    expect(results.violations).toHaveLength(0);
  });
});
