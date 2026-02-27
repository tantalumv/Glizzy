/**
 * Breadcrumbs Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const BREADCRUMBS = {
  default: { testId: "breadcrumbs-default" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Breadcrumbs Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Breadcrumbs Variants", () => {
    test("should render default breadcrumbs", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      await expect(breadcrumbs).toBeVisible();
    });

    test("should contain links", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      const links = breadcrumbs.locator("a");
      await expect(links.first()).toBeVisible();
    });
  });

  test.describe("Breadcrumbs Styling", () => {
    test("should have flex layout", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      await expect(breadcrumbs).toHaveClass(/flex/);
    });

    test("should have gap between items", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      await expect(breadcrumbs).toHaveClass(/gap/);
    });
  });

  test.describe("Breadcrumbs Layout", () => {
    test("should be visible in navigation section", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      await expect(breadcrumbs).toBeVisible();
    });

    test("should have proper width", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      const box = await breadcrumbs.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(0);
    });

    test("should display breadcrumb path", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      const text = await breadcrumbs.textContent();
      expect(text?.trim()).toBeTruthy();
    });
  });

  test.describe("Breadcrumbs Accessibility", () => {
    test("should have role=navigation", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      await expect(breadcrumbs).toHaveAttribute("role", "navigation");
    });

    test("should have aria-label=Breadcrumb", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      await expect(breadcrumbs).toHaveAttribute("aria-label", "Breadcrumb");
    });

    test("links should be keyboard navigable", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      const firstLink = breadcrumbs.locator("a").first();
      await firstLink.focus();
      await expect(firstLink).toBeFocused();
    });

    test("last link should have aria-current=page", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      const links = breadcrumbs.locator("a");
      const lastLink = links.last();
      await expect(lastLink).toHaveAttribute("aria-current", "page");
    });

    test("should have accessible content", async ({ page }) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      const text = await breadcrumbs.textContent();
      expect(text?.trim()).toBeTruthy();
    });
  });

  test.describe("Accessibility", () => {
    test("breadcrumbs should not have WCAG violations", async ({ page }, testInfo) => {
      const breadcrumbs = page.getByTestId("breadcrumbs-default");
      await expect(breadcrumbs).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='breadcrumbs-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("breadcrumbs-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
