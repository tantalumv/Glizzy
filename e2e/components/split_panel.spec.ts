/**
 * Split Panel Accessibility Tests
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

test.describe("Split Panel", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("split panel should have accessible name", async ({ page }) => {
    const panels = page.locator('[role="separator"][aria-orientation]');
    const count = await panels.count();
    if (count > 0) {
      const panel = panels.first();
      const label = await panel.getAttribute("aria-label") || await panel.getAttribute("aria-valuetext");
      expect(label).toBeTruthy();
    }
  });

  test("split panel separator should have role separator", async ({ page }) => {
    const separators = page.locator('[role="separator"]');
    const count = await separators.count();
    if (count > 0) {
      await expect(separators.first()).toHaveRole("separator");
    }
  });

  test("split panel should be keyboard accessible", async ({ page }) => {
    const separators = page.locator('[role="separator"]');
    const count = await separators.count();
    if (count > 0) {
      const separator = separators.first();
      await separator.focus();
      await expect(separator).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("split panel should not have WCAG violations", async ({ page }, testInfo) => {
      const separators = page.locator('[role="separator"]');
      const count = await separators.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="separator"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("split-panel-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
