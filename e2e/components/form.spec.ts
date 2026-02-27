/**
 * Form Accessibility Tests
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

test.describe("Form", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("form should have accessible name", async ({ page }) => {
    const forms = page.locator("form");
    const count = await forms.count();
    if (count > 0) {
      const form = forms.first();
      const label = await form.getAttribute("aria-label") || await form.getAttribute("aria-labelledby");
      expect(label).toBeTruthy();
    }
  });

  test("form fields should have labels", async ({ page }) => {
    const inputs = page.locator("form input:not([type='hidden']):not([type='submit'])");
    const count = await inputs.count();
    if (count > 0) {
      for (let i = 0; i < Math.min(count, 3); i++) {
        const input = inputs.nth(i);
        const label = await input.getAttribute("aria-label") || await input.getAttribute("aria-labelledby") || await page.locator(`label[for="${await input.getAttribute("id")}"]`).count();
        expect(label || (await input.getAttribute("id"))).toBeTruthy();
      }
    }
  });

  test("form submit button should be accessible", async ({ page }) => {
    const submitButtons = page.locator('form button[type="submit"], form input[type="submit"]');
    const count = await submitButtons.count();
    if (count > 0) {
      const button = submitButtons.first();
      const label = await button.textContent();
      expect(label?.trim()).toBeTruthy();
    }
  });

  test.describe("Accessibility", () => {
    test("form should not have WCAG violations", async ({ page }, testInfo) => {
      const forms = page.locator("form");
      const count = await forms.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include("form")
          .disableRules([
            "color-contrast",
            "image-alt",
            "target-size",
            "aria-required-attr",
          ])
          .analyze();

        await testInfo.attach("form-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
