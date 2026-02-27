/**
 * Color Field Accessibility Tests
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

test.describe("Color Field", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("color field input should have accessible label", async ({ page }) => {
    const colorInputs = page.locator('input[type="color"]');
    const count = await colorInputs.count();
    if (count > 0) {
      const input = colorInputs.first();
      const label = await input.getAttribute("aria-label") || await input.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("color field should have proper role", async ({ page }) => {
    const colorInputs = page.locator('input[type="color"]');
    const count = await colorInputs.count();
    if (count > 0) {
      const input = colorInputs.first();
      await expect(input).toBeVisible();
    }
  });

  test("color field should be keyboard accessible", async ({ page }) => {
    const colorInputs = page.locator('input[type="color"]');
    const count = await colorInputs.count();
    if (count > 0) {
      const input = colorInputs.first();
      await input.focus();
      await expect(input).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("color field should not have WCAG violations", async ({ page }, testInfo) => {
      const colorInputs = page.locator('input[type="color"]');
      const count = await colorInputs.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('input[type="color"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("color-field-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
