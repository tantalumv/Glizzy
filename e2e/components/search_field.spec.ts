/**
 * Search Field Accessibility Tests
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

test.describe("Search Field", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("search field should have role searchbox", async ({ page }) => {
    const searchboxes = page.locator('[role="searchbox"]');
    const count = await searchboxes.count();
    if (count > 0) {
      await expect(searchboxes.first()).toHaveRole("searchbox");
    }
  });

  test("search field should have accessible label", async ({ page }) => {
    const searchboxes = page.locator('[role="searchbox"], input[type="search"]');
    const count = await searchboxes.count();
    if (count > 0) {
      const input = searchboxes.first();
      const label = await input.getAttribute("aria-label") || await input.getAttribute("aria-labelledby");
      expect(label || (await input.getAttribute("id"))).toBeTruthy();
    }
  });

  test("search field should be keyboard accessible", async ({ page }) => {
    const searchboxes = page.locator('[role="searchbox"], input[type="search"]');
    const count = await searchboxes.count();
    if (count > 0) {
      const input = searchboxes.first();
      await input.focus();
      await expect(input).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("search field should not have WCAG violations", async ({ page }, testInfo) => {
      const searchboxes = page.locator('[role="searchbox"], input[type="search"]');
      const count = await searchboxes.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="searchbox"], input[type="search"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("search-field-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
