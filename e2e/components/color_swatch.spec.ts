/**
 * Color Swatch Accessibility Tests
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

test.describe("Color Swatch", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("color swatch should be focusable", async ({ page }) => {
    const swatches = page.locator('[role="img"][aria-label]');
    const count = await swatches.count();
    if (count > 0) {
      const swatch = swatches.first();
      await swatch.focus();
      await expect(swatch).toBeFocused();
    }
  });

  test("color swatch should have accessible name", async ({ page }) => {
    const swatches = page.locator('[role="img"][aria-label]');
    const count = await swatches.count();
    if (count > 0) {
      const swatch = swatches.first();
      const label = await swatch.getAttribute("aria-label");
      expect(label).toBeTruthy();
    }
  });

  test.describe("Accessibility", () => {
    test("color swatch should not have WCAG violations", async ({ page }, testInfo) => {
      const swatches = page.locator('[role="img"][aria-label]');
      const count = await swatches.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="img"][aria-label]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("color-swatch-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
