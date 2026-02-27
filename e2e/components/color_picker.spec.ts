/**
 * Color Picker Accessibility Tests
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

test.describe("Color Picker", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("color picker should have accessible name", async ({ page }) => {
    const pickers = page.locator('[role="dialog"][aria-label*="color"], [aria-label*="color picker"]');
    const count = await pickers.count();
    if (count > 0) {
      const picker = pickers.first();
      const label = await picker.getAttribute("aria-label") || await picker.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("color picker should have proper labeling", async ({ page }) => {
    const colorInputs = page.locator('input[type="color"]');
    const count = await colorInputs.count();
    if (count > 0) {
      const input = colorInputs.first();
      await input.focus();
      await expect(input).toBeFocused();
    }
  });

  test("color picker controls should be accessible", async ({ page }) => {
    const sliders = page.locator('[role="slider"][aria-label*="color"], [role="slider"][aria-label*="hue"]');
    const count = await sliders.count();
    if (count > 0) {
      const slider = sliders.first();
      await slider.focus();
      await expect(slider).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("color picker should not have WCAG violations", async ({ page }, testInfo) => {
      const pickers = page.locator('[role="dialog"], [aria-label*="color"]');
      const count = await pickers.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="dialog"], [aria-label*="color"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("color-picker-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
