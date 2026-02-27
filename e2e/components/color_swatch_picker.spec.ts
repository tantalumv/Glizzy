/**
 * Color Swatch Picker Accessibility Tests
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

test.describe("Color Swatch Picker", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("color swatch picker should have accessible name", async ({ page }) => {
    const pickers = page.locator('[role="listbox"][aria-label*="color"], [role="grid"][aria-label*="color"]');
    const count = await pickers.count();
    if (count > 0) {
      const picker = pickers.first();
      const label = await picker.getAttribute("aria-label") || await picker.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("color swatches in picker should be focusable", async ({ page }) => {
    const swatches = page.locator('[role="option"][aria-label*="color"], [role="gridcell"][aria-label*="color"]');
    const count = await swatches.count();
    if (count > 0) {
      const swatch = swatches.first();
      await swatch.focus();
      await expect(swatch).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("color swatch picker should not have WCAG violations", async ({ page }, testInfo) => {
      const pickers = page.locator('[role="listbox"], [role="grid"]');
      const count = await pickers.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="listbox"], [role="grid"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("color-swatch-picker-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
