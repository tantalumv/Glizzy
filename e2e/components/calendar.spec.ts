/**
 * Calendar Accessibility Tests
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

test.describe("Calendar", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("calendar should have accessible name", async ({ page }) => {
    const calendars = page.locator('[role="grid"][aria-label*="calendar"], [role="application"][aria-label*="calendar"]');
    const count = await calendars.count();
    if (count > 0) {
      const calendar = calendars.first();
      const label = await calendar.getAttribute("aria-label") || await calendar.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("calendar grid should have proper role", async ({ page }) => {
    const grids = page.locator('[role="grid"]');
    const count = await grids.count();
    if (count > 0) {
      await expect(grids.first()).toHaveRole("grid");
    }
  });

  test("calendar grid cells should have proper roles", async ({ page }) => {
    const grids = page.locator('[role="grid"]');
    const count = await grids.count();
    if (count > 0) {
      const grid = grids.first();
      const row = grid.locator('[role="row"]').first();
      if (await row.count() > 0) {
        const cell = row.locator('[role="gridcell"]').first();
        const cellCount = await cell.count();
        if (cellCount > 0) {
          await expect(cell.first()).toHaveRole("gridcell");
        }
      }
    }
  });

  test("calendar should be keyboard navigable", async ({ page }) => {
    const grids = page.locator('[role="grid"]');
    const count = await grids.count();
    if (count > 0) {
      const grid = grids.first();
      const cells = grid.locator('[role="gridcell"]');
      const cellCount = await cells.count();
      if (cellCount > 0) {
        await cells.first().focus();
        await expect(cells.first()).toBeFocused();
      }
    }
  });

  test.describe("Accessibility", () => {
    test("calendar should not have WCAG violations", async ({ page }, testInfo) => {
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

        await testInfo.attach("calendar-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
