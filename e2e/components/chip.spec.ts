/**
 * Chip Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const CHIPS = {
  default: { testId: "chip-default" },
  secondary: { testId: "chip-secondary" },
  outline: { testId: "chip-outline" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Chip Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Chip Variants", () => {
    for (const [key, { testId }] of Object.entries(CHIPS)) {
      test(`should render ${key} chip`, async ({ page }) => {
        const chip = page.getByTestId(testId);
        await expect(chip).toBeVisible();
      });
    }

    test("should have text content", async ({ page }) => {
      for (const { testId } of Object.values(CHIPS)) {
        const chip = page.getByTestId(testId);
        const text = await chip.textContent();
        expect(text?.trim()).toBeTruthy();
      }
    });
  });

  test.describe("Chip Styling", () => {
    test("should have rounded corners", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      await expect(chip).toHaveClass(/rounded/);
    });

    test("should have padding", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      await expect(chip).toHaveClass(/p-/);
    });

    test("should have inline-flex display", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      await expect(chip).toHaveClass(/inline-flex/);
    });
  });

  test.describe("Chip Layout", () => {
    test("should be visible", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      await expect(chip).toBeVisible();
    });

    test("should have proper dimensions", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      const box = await chip.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(0);
      expect(box!.height).toBeGreaterThan(0);
    });
  });

  test.describe("Chip Interactions", () => {
    test("should handle hover", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      await chip.hover();
      await expect(chip).toBeVisible();
    });

    test("should handle click", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      await chip.click();
      await expect(chip).toBeVisible();
    });
  });

  test.describe("Chip Accessibility", () => {
    test("should be visible", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      await expect(chip).toBeVisible();
    });

    test("should have content", async ({ page }) => {
      const chip = page.getByTestId("chip-default");
      const text = await chip.textContent();
      expect(text?.trim()).toBeTruthy();
    });
  });

  test.describe("Axe Accessibility", () => {
    test("chip should not have WCAG violations", async ({ page }, testInfo) => {
      const chip = page.getByTestId("chip-default");
      await expect(chip).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='chip-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("chip-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
