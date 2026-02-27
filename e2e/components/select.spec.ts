/**
 * Select Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const SELECTS = {
  default: { testId: "select-default" },
  muted: { testId: "select-muted" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Select Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Select Variants", () => {
    for (const [key, { testId }] of Object.entries(SELECTS)) {
      test(`should render ${key} select`, async ({ page }) => {
        const select = page.getByTestId(testId);
        await expect(select).toBeVisible();
      });
    }
  });

  test.describe("Select Styling", () => {
    test("should have rounded corners", async ({ page }) => {
      const select = page.getByTestId("select-default");
      await expect(select).toHaveClass(/rounded/);
    });

    test("should have border", async ({ page }) => {
      const select = page.getByTestId("select-default");
      await expect(select).toHaveClass(/border/);
    });
  });

  test.describe("Select Layout", () => {
    test("should be visible in forms section", async ({ page }) => {
      const select = page.getByTestId("select-default");
      await expect(select).toBeVisible();
    });

    test("should have proper width", async ({ page }) => {
      const select = page.getByTestId("select-default");
      const box = await select.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(100);
    });
  });

  test.describe("Select Interactions", () => {
    test("should handle keyboard focus", async ({ page }) => {
      const select = page.getByTestId("select-default");
      await select.focus();
      await expect(select).toBeFocused();
    });
  });

  test.describe("Select Accessibility", () => {
    test("should have select element", async ({ page }) => {
      const select = page.getByTestId("select-default");
      const tagName = await select.evaluate((el) => el.tagName.toLowerCase());
      expect(tagName).toBe("select");
    });

    test("should be in tab order", async ({ page }) => {
      const select = page.getByTestId("select-default");
      const tabIndex = await select.getAttribute("tabindex");
      expect(tabIndex).toBeNull();
    });

    test("should have aria-describedby for hint", async ({ page }) => {
      const select = page.getByTestId("select-default");
      const hasAriaDescribedBy = await select.getAttribute("aria-describedby");
      expect(hasAriaDescribedBy).toBeTruthy();
    });
  });

  test.describe("Accessibility", () => {
    test("select should not have WCAG violations", async ({ page }, testInfo) => {
      const select = page.getByTestId("select-default");
      await expect(select).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='select-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("select-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
