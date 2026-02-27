/**
 * Skeleton Component Tests
 * Covers: aria-busy, aria-live, role=status, loading state announcements
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const SKELETONS = {
  circle: { testId: "skeleton-circle", ariaLabel: "Loading avatar" },
  rect: { testId: "skeleton-rect", ariaLabel: "Loading content block" },
  text: { testId: "skeleton-text", ariaLabel: "Loading text line" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Skeleton Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Skeleton Variants", () => {
    test("should render circle skeleton", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-circle");
      await expect(skeleton).toHaveCount(1);
    });

    test("should render rect skeleton", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      await expect(skeleton).toHaveCount(1);
    });

    test("should render text skeleton", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-text");
      await expect(skeleton).toHaveCount(1);
    });
  });

  test.describe("Skeleton ARIA Roles", () => {
    test("circle skeleton should have role=status", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-circle");
      await expect(skeleton).toHaveAttribute("role", "status");
    });

    test("rect skeleton should have role=status", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      await expect(skeleton).toHaveAttribute("role", "status");
    });

    test("text skeleton should have role=status", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-text");
      await expect(skeleton).toHaveAttribute("role", "status");
    });
  });

  test.describe("Skeleton aria-live", () => {
    test("circle skeleton should have aria-live=polite", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-circle");
      await expect(skeleton).toHaveAttribute("aria-live", "polite");
    });

    test("rect skeleton should have aria-live=polite", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      await expect(skeleton).toHaveAttribute("aria-live", "polite");
    });
  });

  test.describe("Skeleton aria-busy", () => {
    test("circle skeleton should have aria-busy=true", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-circle");
      await expect(skeleton).toHaveAttribute("aria-busy", "true");
    });

    test("rect skeleton should have aria-busy=true", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      await expect(skeleton).toHaveAttribute("aria-busy", "true");
    });

    test("text skeleton should have aria-busy=true", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-text");
      await expect(skeleton).toHaveAttribute("aria-busy", "true");
    });
  });

  test.describe("Skeleton aria-label", () => {
    for (const [key, { testId, ariaLabel }] of Object.entries(SKELETONS)) {
      test(`${key} skeleton should have aria-label`, async ({ page }) => {
        const skeleton = page.getByTestId(testId);
        await expect(skeleton).toHaveAttribute("aria-label", ariaLabel);
      });
    }
  });

  test.describe("Skeleton Styling", () => {
    test("should have background color", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      await expect(skeleton).toHaveClass(/bg-/);
    });

    test("should have animate-pulse or similar", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      await expect(skeleton).toHaveClass(/animate/);
    });

    test("circle should be rounded-full", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-circle");
      await expect(skeleton).toHaveClass(/rounded/);
    });
  });

  test.describe("Skeleton Layout", () => {
    test("circle should have dimensions", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-circle");
      const box = await skeleton.boundingBox();
      expect(box).not.toBeNull();
    });

    test("should be in skeletons section", async ({ page }) => {
      const section = page.getByTestId("skeletons-section");
      await expect(section).toBeVisible();
    });

    test("should have keyboard hint visible", async ({ page }) => {
      const hint = page.getByTestId("skeletons-keyboard-hint");
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("aria-busy=true");
    });
  });

  test.describe("Skeleton Animation", () => {
    test("should have animation class", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      await expect(skeleton).toHaveClass(/animate/);
    });

    test("circle should have animation", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-circle");
      await expect(skeleton).toHaveClass(/animate/);
    });
  });

  test.describe("Skeleton Accessibility", () => {
    test("should not be focusable", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      const tabIndex = await skeleton.getAttribute("tabindex");
      expect(tabIndex).toBeNull();
    });

    test("should announce loading state via role=status", async ({ page }) => {
      const skeleton = page.getByTestId("skeleton-rect");
      const role = await skeleton.getAttribute("role");
      const ariaBusy = await skeleton.getAttribute("aria-busy");
      expect(role).toBe("status");
      expect(ariaBusy).toBe("true");
    });
  });

  test.describe("Accessibility", () => {
    test("skeleton should not have WCAG violations", async ({ page }, testInfo) => {
      const section = page.getByTestId("skeletons-section");
      await expect(section).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='skeletons-section']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("skeleton-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
