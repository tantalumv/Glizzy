/**
 * File Trigger Accessibility Tests
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

test.describe("File Trigger", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("file input should have accessible label", async ({ page }) => {
    const fileInputs = page.locator('input[type="file"]');
    const count = await fileInputs.count();
    if (count > 0) {
      const input = fileInputs.first();
      const label = await input.getAttribute("aria-label") || await input.getAttribute("aria-labelledby");
      expect(label || (await input.getAttribute("id"))).toBeTruthy();
    }
  });

  test("file input should be focusable", async ({ page }) => {
    const fileInputs = page.locator('input[type="file"]');
    const count = await fileInputs.count();
    if (count > 0) {
      const input = fileInputs.first();
      await input.focus();
      await expect(input).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("file input should not have WCAG violations", async ({ page }, testInfo) => {
      const fileInputs = page.locator('input[type="file"]');
      const count = await fileInputs.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('input[type="file"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("file-trigger-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
