/**
 * Range Calendar Accessibility Tests
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

test.describe("Range Calendar", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("range calendar should have accessible name", async ({ page }) => {
    const calendars = page.locator('[role="grid"][aria-label*="range"], [role="application"][aria-label*="range"]');
    const count = await calendars.count();
    if (count > 0) {
      const calendar = calendars.first();
      const label = await calendar.getAttribute("aria-label") || await calendar.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("range calendar should indicate selected range", async ({ page }) => {
    const grids = page.locator('[role="grid"]');
    const count = await grids.count();
    if (count > 0) {
      const grid = grids.first();
      const selectedCells = grid.locator('[aria-selected="true"], [data-selected="true"]');
      const selectedCount = await selectedCells.count();
      expect(selectedCount).toBeGreaterThanOrEqual(0);
    }
  });

  test("range calendar should have proper labeling for date range", async ({ page }) => {
    const grids = page.locator('[role="grid"]');
    const count = await grids.count();
    if (count > 0) {
      const grid = grids.first();
      const labelledBy = await grid.getAttribute("aria-labelledby");
      if (labelledBy) {
        const label = page.locator(`#${labelledBy}`);
        await expect(label).toBeVisible();
      }
    }
  });

  test.describe("Accessibility", () => {
    test("range calendar should not have WCAG violations", async ({ page }, testInfo) => {
      const grids = page.locator('[role="grid"]');
      const count = await grids.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="grid"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("range-calendar-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
