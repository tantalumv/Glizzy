/**
 * Text Field Accessibility Tests
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

test.describe("Text Field", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("text field should have accessible label", async ({ page }) => {
    const inputs = page.locator('input[type="text"]');
    const count = await inputs.count();
    if (count > 0) {
      for (let i = 0; i < Math.min(count, 3); i++) {
        const input = inputs.nth(i);
        const label = await input.getAttribute("aria-label") || await input.getAttribute("aria-labelledby");
        expect(label || (await input.getAttribute("id"))).toBeTruthy();
      }
    }
  });

  test("text field should be focusable", async ({ page }) => {
    const inputs = page.locator('input[type="text"]');
    const count = await inputs.count();
    if (count > 0) {
      const input = inputs.first();
      await input.focus();
      await expect(input).toBeFocused();
    }
  });

  test("text field should support placeholder", async ({ page }) => {
    const inputs = page.locator('input[type="text"][placeholder]');
    const count = await inputs.count();
    if (count > 0) {
      const input = inputs.first();
      const placeholder = await input.getAttribute("placeholder");
      expect(placeholder).toBeTruthy();
    }
  });

  test.describe("Accessibility", () => {
    test("text field should not have WCAG violations", async ({ page }, testInfo) => {
      const inputs = page.locator('input[type="text"]');
      const count = await inputs.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('input[type="text"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("text-field-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
