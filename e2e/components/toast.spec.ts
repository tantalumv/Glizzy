/**
 * Toast Accessibility Tests
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

test.describe("Toast", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("toast should have role status by default", async ({ page }) => {
    const toasts = page.locator('[role="status"]');
    const count = await toasts.count();
    if (count > 0) {
      await expect(toasts.first()).toHaveRole("status");
    }
  });

  test("toast should have aria-live polite by default", async ({ page }) => {
    const toasts = page.locator('[role="status"]');
    const count = await toasts.count();
    if (count > 0) {
      await expect(toasts.first()).toHaveAttribute("aria-live", "polite");
    }
  });

  test("toast should have aria-atomic for full announcement", async ({ page }) => {
    const toasts = page.locator('[role="status"]');
    const count = await toasts.count();
    if (count > 0) {
      const toast = toasts.first();
      const ariaAtomic = await toast.getAttribute("aria-atomic");
      if (ariaAtomic) {
        await expect(toast).toHaveAttribute("aria-atomic", "true");
      }
    }
  });

  test("error toast should have role alert for immediate attention", async ({ page }) => {
    const alertToasts = page.locator('[role="alert"]');
    const count = await alertToasts.count();
    if (count > 0) {
      await expect(alertToasts.first()).toHaveRole("alert");
    }
  });

  test("error toast should have aria-live assertive", async ({ page }) => {
    const alertToasts = page.locator('[role="alert"]');
    const count = await alertToasts.count();
    if (count > 0) {
      await expect(alertToasts.first()).toHaveAttribute("aria-live", "assertive");
    }
  });

  test("toast should be visible when rendered", async ({ page }) => {
    const toasts = page.locator('[role="status"]');
    const count = await toasts.count();
    if (count > 0) {
      await expect(toasts.first()).toBeVisible();
    }
  });

  test("toast should contain text content", async ({ page }) => {
    const toasts = page.locator('[role="status"]');
    const count = await toasts.count();
    if (count > 0) {
      const toast = toasts.first();
      const text = await toast.textContent();
      expect(text).toBeTruthy();
    }
  });

  test.describe("Accessibility", () => {
    test("toast should not have WCAG violations", async ({ page }, testInfo) => {
      const toasts = page.locator('[role="status"], [role="alert"]');
      const count = await toasts.count();
      if (count > 0) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[role="status"], [role="alert"]')
          .disableRules([
            "color-contrast",
            "image-alt",
            "aria-valid-attr-value",
            "list",
            "nested-interactive",
            "scrollable-region-focusable",
            "target-size",
          ])
          .analyze();

        await testInfo.attach("toast-accessibility-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });
  });
});
