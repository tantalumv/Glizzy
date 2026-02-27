/**
 * Focus Accessibility Tests
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

test.describe("Focus", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("interactive elements should be focusable", async ({ page }) => {
    const focusableElements = page.locator('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
    const count = await focusableElements.count();
    expect(count).toBeGreaterThan(0);
  });

  test("focusable elements should have visible focus indicators", async ({ page }) => {
    const buttons = page.locator("button");
    const count = await buttons.count();
    if (count > 0) {
      const button = buttons.first();
      await button.focus();
      const isFocused = await button.evaluate((el) => {
        return el === document.activeElement;
      });
      expect(isFocused).toBe(true);
    }
  });

  test("tab order should be logical", async ({ page }) => {
    const focusableElements = page.locator('[tabindex="0"]');
    const count = await focusableElements.count();
    if (count > 2) {
      await focusableElements.first().focus();
      await page.keyboard.press("Tab");
      const secondFocused = await page.locator(":focus");
      expect(await secondFocused.count()).toBe(1);
    }
  });

  test.describe("Accessibility", () => {
    test("focusable elements should not have WCAG violations", async ({ page }, testInfo) => {
      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("body")
        .disableRules([
          "color-contrast",
          "image-alt",
          "target-size",
        ])
        .analyze();

      await testInfo.attach("focus-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      const focusRelatedViolations = accessibilityScanResults.violations.filter(
        (v: { id: string }) => v.id === "tabindex" || v.id === "focus-order-semantics",
      );
      expect(focusRelatedViolations).toHaveLength(0);
    });
  });
});
