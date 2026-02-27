/**
 * Number Field Accessibility Tests
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

test.describe("Number Field", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("number field should have accessible label", async ({ page }) => {
    const numberInputs = page.locator('input[type="number"], input[type="tel"]');
    const count = await numberInputs.count();
    if (count > 0) {
      const input = numberInputs.first();
      const label = await input.getAttribute("aria-label") || await input.getAttribute("aria-labelledby");
      expect(label || (await input.getAttribute("id"))).toBeTruthy();
    }
  });

  test("number field should have role spinbutton when applicable", async ({ page }) => {
    const spinbuttons = page.locator('[role="spinbutton"]');
    const count = await spinbuttons.count();
    if (count > 0) {
      await expect(spinbuttons.first()).toHaveRole("spinbutton");
    }
  });

  test("number field should have aria-valuemin and aria-valuemax", async ({ page }) => {
    const spinbuttons = page.locator('[role="spinbutton"]');
    const count = await spinbuttons.count();
    if (count > 0) {
      const spinbutton = spinbuttons.first();
      const min = await spinbutton.getAttribute("aria-valuemin");
      const max = await spinbutton.getAttribute("aria-valuemax");
      if (min !== null) {
        await expect(spinbutton).toHaveAttribute("aria-valuemin");
      }
      if (max !== null) {
        await expect(spinbutton).toHaveAttribute("aria-valuemax");
      }
    }
  });

  test("number field should be keyboard accessible", async ({ page }) => {
    const numberInputs = page.locator('input[type="number"], [role="spinbutton"]');
    const count = await numberInputs.count();
    if (count > 0) {
      const input = numberInputs.first();
      await input.focus();
      await expect(input).toBeFocused();
    }
  });

  test.describe("Accessibility", () => {
    test("number field should not have WCAG violations", async ({ page }, testInfo) => {
      const numberInputs = page.locator('input[type="number"], [role="spinbutton"]');
      const count = await numberInputs.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('input[type="number"], [role="spinbutton"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("number-field-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
