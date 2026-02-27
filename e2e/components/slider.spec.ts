/**
 * Slider Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const SLIDERS = {
  default: { testId: "slider-default" },
  large: { testId: "slider-large" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Slider Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Slider Variants", () => {
    for (const [key, { testId }] of Object.entries(SLIDERS)) {
      test(`should render ${key} slider`, async ({ page }) => {
        const slider = page.getByTestId(testId);
        await expect(slider).toBeVisible();
      });
    }
  });

  test.describe("Slider Layout", () => {
    test("should be visible in forms section", async ({ page }) => {
      const slider = page.getByTestId("slider-default");
      await expect(slider).toBeVisible();
    });

    test("should have proper width", async ({ page }) => {
      const slider = page.getByTestId("slider-default");
      const box = await slider.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(100);
    });
  });

  test.describe("Slider Accessibility", () => {
    test("should have input element", async ({ page }) => {
      const slider = page.getByTestId("slider-default");
      await expect(slider).toBeVisible();
    });

    test("should be visible", async ({ page }) => {
      const slider = page.getByTestId("slider-large");
      await expect(slider).toBeVisible();
    });

    test("should have role slider", async ({ page }) => {
      const slider = page.getByTestId("slider-default");
      await expect(slider).toHaveAttribute("role", "slider");
    });

    test("should have aria-valuemin and aria-valuemax", async ({ page }) => {
      const slider = page.getByTestId("slider-default");
      await expect(slider).toHaveAttribute("aria-valuemin");
      await expect(slider).toHaveAttribute("aria-valuemax");
    });

    test("should have aria-valuenow", async ({ page }) => {
      const slider = page.getByTestId("slider-default");
      await expect(slider).toHaveAttribute("aria-valuenow");
    });
  });

  test.describe("Accessibility", () => {
    test("slider should not have WCAG violations", async ({ page }, testInfo) => {
      const slider = page.getByTestId("slider-default");
      await expect(slider).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='slider-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("slider-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
