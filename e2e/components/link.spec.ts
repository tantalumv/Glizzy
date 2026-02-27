/**
 * Link Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const LINKS = {
  default: { testId: "link-default" },
  muted: { testId: "link-muted" },
  underline: { testId: "link-underline" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Link Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Link Variants", () => {
    for (const [key, { testId }] of Object.entries(LINKS)) {
      test(`should render ${key} link`, async ({ page }) => {
        const link = page.getByTestId(testId);
        await expect(link).toBeVisible();
        await expect(link).toHaveAttribute("href");
      });
    }

    test("should have text content", async ({ page }) => {
      for (const { testId } of Object.values(LINKS)) {
        const link = page.getByTestId(testId);
        const text = await link.textContent();
        expect(text?.trim()).toBeTruthy();
      }
    });
  });

  test.describe("Link Styling", () => {
    test("default should have color styling", async ({ page }) => {
      const link = page.getByTestId("link-default");
      await expect(link).toHaveClass(/text-/);
    });

    test("underline should have underline decoration", async ({ page }) => {
      const link = page.getByTestId("link-underline");
      await expect(link).toHaveClass(/underline/);
    });

    test("should have hover state", async ({ page }) => {
      const link = page.getByTestId("link-default");
      await expect(link).toHaveClass(/hover:/);
    });
  });

  test.describe("Link Layout", () => {
    test("should be visible", async ({ page }) => {
      const link = page.getByTestId("link-default");
      await expect(link).toBeVisible();
    });

    test("should have proper dimensions", async ({ page }) => {
      const link = page.getByTestId("link-default");
      const box = await link.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(0);
      expect(box!.height).toBeGreaterThan(0);
    });
  });

  test.describe("Link Interactions", () => {
    test("should handle hover", async ({ page }) => {
      const link = page.getByTestId("link-default");
      await link.hover();
      await expect(link).toBeVisible();
    });

    test("should handle click", async ({ page }) => {
      const link = page.getByTestId("link-default");
      await link.click({ noWaitAfter: true });
      await expect(link).toBeVisible();
    });

    test("should handle keyboard focus", async ({ page }) => {
      const link = page.getByTestId("link-default");
      await link.focus();
      await expect(link).toBeFocused();
    });
  });

  test.describe("Link Accessibility", () => {
    test("should have anchor element", async ({ page }) => {
      const link = page.getByTestId("link-default");
      const tagName = await link.evaluate((el) => el.tagName.toLowerCase());
      expect(tagName).toBe("a");
    });

    test("should have href attribute", async ({ page }) => {
      const link = page.getByTestId("link-default");
      await expect(link).toHaveAttribute("href");
    });

    test("should have accessible name", async ({ page }) => {
      const link = page.getByTestId("link-default");
      const text = await link.textContent();
      expect(text?.trim()).toBeTruthy();
    });
  });

  test.describe("Accessibility", () => {
    test("link should not have WCAG violations", async ({ page }, testInfo) => {
      const link = page.getByTestId("link-default");
      await expect(link).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='link-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("link-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
