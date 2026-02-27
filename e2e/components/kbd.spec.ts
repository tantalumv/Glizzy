/**
 * Kbd Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const KBDS = {
  default: { testId: "kbd-default" },
  muted: { testId: "kbd-muted" },
  shortcut: { testId: "kbd-shortcut" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Kbd Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Kbd Variants", () => {
    for (const [key, { testId }] of Object.entries(KBDS)) {
      test(`should render ${key} kbd`, async ({ page }) => {
        const kbd = page.getByTestId(testId);
        await expect(kbd).toBeVisible();
      });
    }

    test("should display keyboard key text", async ({ page }) => {
      for (const { testId } of Object.values(KBDS)) {
        const kbd = page.getByTestId(testId);
        const text = await kbd.textContent();
        expect(text?.trim()).toBeTruthy();
      }
    });
  });

  test.describe("Kbd Styling", () => {
    test("should have rounded corners", async ({ page }) => {
      const kbd = page.getByTestId("kbd-default");
      await expect(kbd).toHaveClass(/rounded/);
    });

    test("should have border", async ({ page }) => {
      const kbd = page.getByTestId("kbd-default");
      await expect(kbd).toHaveClass(/border/);
    });
  });

  test.describe("Kbd Layout", () => {
    test("should be visible", async ({ page }) => {
      const kbd = page.getByTestId("kbd-default");
      await expect(kbd).toBeVisible();
    });

    test("should have proper dimensions", async ({ page }) => {
      const kbd = page.getByTestId("kbd-default");
      const box = await kbd.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(0);
      expect(box!.height).toBeGreaterThan(0);
    });
  });

  test.describe("Kbd Accessibility", () => {
    test("should have kbd element or role", async ({ page }) => {
      const kbd = page.getByTestId("kbd-default");
      const tagName = await kbd.evaluate((el) => el.tagName.toLowerCase());
      expect(tagName === "kbd").toBeTruthy();
    });

    test("should be visible", async ({ page }) => {
      const kbd = page.getByTestId("kbd-muted");
      await expect(kbd).toBeVisible();
    });
  });

  test.describe("Accessibility", () => {
    test("kbd should not have WCAG violations", async ({ page }, testInfo) => {
      const kbd = page.getByTestId("kbd-default");
      await expect(kbd).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='kbd-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("kbd-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
