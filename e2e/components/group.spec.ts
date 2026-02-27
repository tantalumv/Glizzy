/**
 * Group Accessibility Tests
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

test.describe("Group", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("group should have accessible name", async ({ page }) => {
    const groups = page.locator('[role="group"]');
    const count = await groups.count();
    if (count > 0) {
      const group = groups.first();
      const label = await group.getAttribute("aria-label") || await group.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("group should have proper role", async ({ page }) => {
    const groups = page.locator('[role="group"]');
    const count = await groups.count();
    if (count > 0) {
      await expect(groups.first()).toHaveRole("group");
    }
  });

  test("group contents should be accessible", async ({ page }) => {
    const groups = page.locator('[role="group"]');
    const count = await groups.count();
    if (count > 0) {
      const group = groups.first();
      const elements = group.locator("button, input, a");
      const elementCount = await elements.count();
      expect(elementCount).toBeGreaterThan(0);
    }
  });

  test.describe("Accessibility", () => {
    test("group should not have WCAG violations", async ({ page }, testInfo) => {
      const groups = page.locator('[role="group"]');
      const count = await groups.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="group"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("group-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
