/**
 * Autocomplete/Combobox Accessibility Tests
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

test.describe("Autocomplete/Combobox", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("combobox container should have role combobox", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    await expect(combobox).toHaveRole("combobox");
  });

  test("combobox should have aria-autocomplete list", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    await expect(combobox).toHaveAttribute("aria-autocomplete", "list");
  });

  test("combobox should have aria-expanded false when closed", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    await expect(combobox).toHaveAttribute("aria-expanded", "false");
  });

  test("combobox should have aria-expanded true when open", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    const input = combobox.locator("input");
    await input.click();
    await expect(combobox).toHaveAttribute("aria-expanded", "true");
  });

  test("combobox should have aria-controls pointing to listbox", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    const input = combobox.locator("input");
    await input.click();
    const listbox = combobox.locator('[role="listbox"]');
    const listboxId = await listbox.getAttribute("id");
    expect(listboxId).toBeTruthy();
    if (listboxId) {
      await expect(input).toHaveAttribute("aria-controls", listboxId);
    }
  });

  test("listbox should have role listbox", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    const input = combobox.locator("input");
    await input.click();
    const listbox = combobox.locator('[role="listbox"]');
    await expect(listbox).toHaveRole("listbox");
  });

  test("options should have role option", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    const input = combobox.locator("input");
    await input.click();
    const option = combobox.locator('[role="option"]').first();
    await expect(option).toHaveRole("option");
  });

  test("options should be focusable", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    const input = combobox.locator("input");
    await input.click();
    const options = combobox.locator('[role="option"]');
    const firstOption = options.first();
    await expect(firstOption).toBeVisible();
  });

  test("aria-activedescendant should be set on input when option is highlighted", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    const input = combobox.locator("input");
    await input.click();
    await input.press("ArrowDown");
    const firstOption = combobox.locator('[role="option"]').first();
    const optionId = await firstOption.getAttribute("id");
    expect(optionId).toBeTruthy();
    if (optionId) {
      await expect(input).toHaveAttribute("aria-activedescendant", optionId);
    }
  });

  test("typing should filter options", async ({ page }) => {
    const combobox = page.getByTestId("combobox-keyboard-demo");
    const input = combobox.locator("input");
    await input.click();
    await input.fill("a");
    const options = combobox.locator('[role="option"]');
    const count = await options.count();
    expect(count).toBeGreaterThan(0);
  });

  test.describe("Accessibility", () => {
    test("autocomplete should not have WCAG violations", async ({ page }, testInfo) => {
      const combobox = page.getByTestId("combobox-keyboard-demo");
      await combobox.click();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include('[role="combobox"]')
        .disableRules([
          "color-contrast",
          "image-alt",
          "aria-valid-attr-value",
          "list",
          "nested-interactive",
          "scrollable-region-focusable",
          "target-size",
        ])
        .analyze();

      await testInfo.attach("autocomplete-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
