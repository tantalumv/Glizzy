/**
 * Badge Component Tests
 * Covers: role=status for status badges, aria-label, aria-live
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const BADGES = {
  default: { testId: "badge-default", text: "Default", hasRole: false },
  secondary: { testId: "badge-secondary", text: "Secondary", hasRole: false },
  destructive: {
    testId: "badge-destructive",
    text: "Destructive",
    hasRole: true,
    ariaLabel: "Critical status",
  },
  outline: { testId: "badge-outline", text: "Outline", hasRole: false },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
}

test.describe("Badge Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Badge Variants", () => {
    for (const [key, { testId, text }] of Object.entries(BADGES)) {
      test(`should render ${key} badge`, async ({ page }) => {
        const badge = page.getByTestId(testId);
        await expect(badge).toBeVisible();
        await expect(badge).toContainText(text);
      });
    }

    test("should have correct text for each variant", async ({ page }) => {
      for (const { testId, text } of Object.values(BADGES)) {
        await expect(page.getByTestId(testId)).toContainText(text);
      }
    });
  });

  test.describe("Badge ARIA Roles", () => {
    test("default badge should not have role=status (static badge)", async ({ page }) => {
      const badge = page.getByTestId("badge-default");
      const role = await badge.getAttribute("role");
      expect(role).toBeNull();
    });

    test("secondary badge should not have role=status (static badge)", async ({ page }) => {
      const badge = page.getByTestId("badge-secondary");
      const role = await badge.getAttribute("role");
      expect(role).toBeNull();
    });

    test("destructive badge should have role=status (dynamic status)", async ({ page }) => {
      const badge = page.getByTestId("badge-destructive");
      await expect(badge).toHaveAttribute("role", "status");
    });

    test("outline badge should not have role=status (static badge)", async ({ page }) => {
      const badge = page.getByTestId("badge-outline");
      const role = await badge.getAttribute("role");
      expect(role).toBeNull();
    });
  });

  test.describe("Badge aria-label", () => {
    test("destructive badge should have aria-label", async ({ page }) => {
      const badge = page.getByTestId("badge-destructive");
      await expect(badge).toHaveAttribute("aria-label", "Critical status");
    });
  });

  test.describe("Badge Styling", () => {
    test("should have rounded-full class", async ({ page }) => {
      const badge = page.getByTestId("badge-default");
      await expect(badge).toHaveClass(/rounded-full/);
    });

    test("should have inline-flex display", async ({ page }) => {
      const badge = page.getByTestId("badge-default");
      await expect(badge).toHaveClass(/inline-flex/);
    });

    test("should have proper padding", async ({ page }) => {
      const badge = page.getByTestId("badge-default");
      await expect(badge).toHaveClass(/px-/);
      await expect(badge).toHaveClass(/py-/);
    });

    test("should have font-semibold", async ({ page }) => {
      const badge = page.getByTestId("badge-default");
      await expect(badge).toHaveClass(/font-semibold/);
    });
  });

  test.describe("Badge Layout", () => {
    test("should be visible in badges section", async ({ page }) => {
      const section = page.getByTestId("badges-section");
      await expect(section).toBeVisible();
    });

    test("should have all badges in flex container", async ({ page }) => {
      const container = page.getByTestId("badge-default").locator("..");
      await expect(container).toHaveClass(/flex/);
    });

    test("should have proper gap between badges", async ({ page }) => {
      const container = page.getByTestId("badge-default").locator("..");
      await expect(container).toHaveClass(/gap-/);
    });

    test("should have keyboard hint visible", async ({ page }) => {
      const hint = page.getByTestId("badges-keyboard-hint");
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("role=status");
    });
  });

  test.describe("Badge Accessibility", () => {
    test("should have text content", async ({ page }) => {
      const badge = page.getByTestId("badge-default");
      const text = await badge.textContent();
      expect(text?.trim()).toBeTruthy();
    });

    test("should not be interactive", async ({ page }) => {
      const badge = page.getByTestId("badge-default");
      await expect(badge).not.toHaveAttribute("tabindex");
    });

    test("destructive badge should be announced as status", async ({ page }) => {
      const badge = page.getByTestId("badge-destructive");
      const role = await badge.getAttribute("role");
      expect(role).toBe("status");
    });
  });

  test.describe("Accessibility", () => {
    test("badge should not have WCAG violations", async ({ page }, testInfo) => {
      const badge = page.getByTestId("badge-default");
      await expect(badge).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='badge-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("badge-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
