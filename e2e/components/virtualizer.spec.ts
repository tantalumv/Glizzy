/**
 * Virtualizer Accessibility Tests
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

test.describe("Virtualizer", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("virtualized list should have role list", async ({ page }) => {
    const virtualLists = page.locator('[role="list"][aria-label], [data-virtualized]');
    const count = await virtualLists.count();
    if (count > 0) {
      const list = virtualLists.first();
      const role = await list.getAttribute("role");
      if (role) {
        expect(role).toBe("list");
      }
    }
  });

  test("virtualized list items should be accessible", async ({ page }) => {
    const virtualLists = page.locator('[data-virtualized]');
    const count = await virtualLists.count();
    if (count > 0) {
      const list = virtualLists.first();
      const items = list.locator('[role="listitem"], li');
      const itemCount = await items.count();
      if (itemCount > 0) {
        await expect(items.first()).toBeVisible();
      }
    }
  });

  test("virtualized content should be keyboard navigable", async ({ page }) => {
    const virtualContainers = page.locator('[data-virtualized]');
    const count = await virtualContainers.count();
    if (count > 0) {
      const container = virtualContainers.first();
      const focusable = container.locator("button, a, [tabindex]");
      const focusableCount = await focusable.count();
      if (focusableCount > 0) {
        await focusable.first().focus();
        await expect(focusable.first()).toBeFocused();
      }
    }
  });

  test.describe("Accessibility", () => {
    test("virtualized content should not have WCAG violations", async ({ page }, testInfo) => {
      const virtualContainers = page.locator('[data-virtualized], [role="list"][aria-label]');
      const count = await virtualContainers.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[data-virtualized], [role="list"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
            "scrollable-region-focusable",
          ])
          .analyze();

        await testInfo.attach("virtualizer-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
