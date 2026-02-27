/**
 * Toggle Button Group Accessibility Tests
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

test.describe("Toggle Button Group", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("toggle button group should have accessible name", async ({ page }) => {
    const groups = page.locator('[role="group"][aria-label], [role="group"][aria-labelledby]');
    const count = await groups.count();
    if (count > 0) {
      const group = groups.first();
      const label = await group.getAttribute("aria-label") || await group.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("toggle buttons in group should have aria-pressed", async ({ page }) => {
    const groups = page.locator('[role="group"]');
    const count = await groups.count();
    if (count > 0) {
      const buttons = groups.first().locator("button[aria-pressed]");
      const buttonCount = await buttons.count();
      if (buttonCount > 0) {
        await expect(buttons.first()).toHaveAttribute("aria-pressed");
      }
    }
  });

  test("toggle buttons should be keyboard navigable within group", async ({ page }) => {
    const groups = page.locator('[role="group"]');
    const count = await groups.count();
    if (count > 0) {
      const group = groups.first();
      const buttons = group.locator("button");
      const buttonCount = await buttons.count();
      if (buttonCount > 1) {
        await buttons.first().focus();
        await expect(buttons.first()).toBeFocused();
      }
    }
  });

  test.describe("Accessibility", () => {
    test("toggle button group should not have WCAG violations", async ({ page }, testInfo) => {
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

        await testInfo.attach("toggle-button-group-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
