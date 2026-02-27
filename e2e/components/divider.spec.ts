/**
 * Divider Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const DIVIDERS = {
  horizontal: { testId: "divider-horizontal" },
  vertical: { testId: "divider-vertical" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Divider Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Divider Variants", () => {
    for (const [key, { testId }] of Object.entries(DIVIDERS)) {
      test(`should render ${key} divider`, async ({ page }) => {
        const divider = page.getByTestId(testId);
        await expect(divider).toBeVisible();
      });
    }
  });

  test.describe("Divider Styling", () => {
    test("horizontal should have border styling", async ({ page }) => {
      const divider = page.getByTestId("divider-horizontal");
      await expect(divider).toHaveClass(/border/);
    });

    test("vertical should have border styling", async ({ page }) => {
      const divider = page.getByTestId("divider-vertical");
      await expect(divider).toHaveClass(/border/);
    });
  });

  test.describe("Divider Layout", () => {
    test("horizontal divider should be wider than tall", async ({ page }) => {
      const divider = page.getByTestId("divider-horizontal");
      const box = await divider.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(box!.height);
    });

    test("vertical divider should be taller than wide", async ({ page }) => {
      const divider = page.getByTestId("divider-vertical");
      const box = await divider.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.height).toBeGreaterThan(box!.width);
    });

    test("should be visible in layout section", async ({ page }) => {
      const divider = page.getByTestId("divider-horizontal");
      await expect(divider).toBeVisible();
    });
  });

  test.describe("Divider Accessibility", () => {
    test("should have separator role", async ({ page }) => {
      const divider = page.getByTestId("divider-horizontal");
      await expect(divider).toHaveAttribute("role", "separator");
    });

    test("vertical should have separator role", async ({ page }) => {
      const divider = page.getByTestId("divider-vertical");
      await expect(divider).toHaveAttribute("role", "separator");
    });

    test("horizontal should have aria-orientation horizontal", async ({ page }) => {
      const divider = page.getByTestId("divider-horizontal");
      await expect(divider).toHaveAttribute("aria-orientation", "horizontal");
    });

    test("vertical should have aria-orientation vertical", async ({ page }) => {
      const divider = page.getByTestId("divider-vertical");
      await expect(divider).toHaveAttribute("aria-orientation", "vertical");
    });
  });

  test.describe("Accessibility", () => {
    test("divider should not have WCAG violations", async ({ page }, testInfo) => {
      const divider = page.getByTestId("divider-horizontal");
      await expect(divider).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='divider-horizontal']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("divider-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
