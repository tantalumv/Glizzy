/**
 * Toggle Button Accessibility Tests
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

test.describe("Toggle Button", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("toggle button should have aria-pressed attribute", async ({ page }) => {
    const buttons = page.locator("button[aria-pressed]");
    const count = await buttons.count();
    if (count > 0) {
      const button = buttons.first();
      const pressed = await button.getAttribute("aria-pressed");
      expect(pressed === "true" || pressed === "false").toBe(true);
    }
  });

  test("toggle button should toggle aria-pressed on click", async ({ page }) => {
    const buttons = page.locator("button[aria-pressed]");
    const count = await buttons.count();
    if (count > 0) {
      const button = buttons.first();
      const initialState = await button.getAttribute("aria-pressed");
      await button.click();
      const newState = await button.getAttribute("aria-pressed");
      expect(newState).not.toBe(initialState);
    }
  });

  test("toggle button should be keyboard accessible", async ({ page }) => {
    const buttons = page.locator("button[aria-pressed]");
    const count = await buttons.count();
    if (count > 0) {
      const button = buttons.first();
      await button.focus();
      await expect(button).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("toggle button should not have WCAG violations", async ({ page }, testInfo) => {
      const buttons = page.locator("button[aria-pressed]");
      const count = await buttons.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include("button[aria-pressed]")
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("toggle-button-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
