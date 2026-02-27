/**
 * Separator Accessibility Tests
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

test.describe("Separator", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("separator should have role separator", async ({ page }) => {
    const separators = page.locator('[role="separator"], hr');
    const count = await separators.count();
    if (count > 0) {
      await expect(separators.first()).toHaveRole("separator");
    }
  });

  test("separator should be accessible", async ({ page }) => {
    const separators = page.locator('[role="separator"], hr');
    const count = await separators.count();
    if (count > 0) {
      const separator = separators.first();
      await expect(separator).toBeVisible();
    }
  });

  test.describe("Accessibility", () => {
    test("separator should not have WCAG violations", async ({ page }, testInfo) => {
      const separators = page.locator('[role="separator"], hr');
      const count = await separators.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="separator"], hr')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("separator-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
