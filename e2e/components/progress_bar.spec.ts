/**
 * Progress Bar Component Tests
 * Covers: role=progressbar, aria-valuenow/min/max, aria-live, aria-label
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const PROGRESS_BARS = {
  default: { testId: "progress-bar-default", ariaLabel: "Default progress indicator", value: 50 },
  large: { testId: "progress-bar-large", ariaLabel: "Large progress indicator", value: 75 },
  muted: { testId: "progress-bar-muted", ariaLabel: "Muted progress indicator", value: 25 },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

async function scrollToProgressBars(page: Page): Promise<void> {
  const section = page.getByTestId("progress-bars-section");
  await section.scrollIntoViewIfNeeded();
}

test.describe("Progress Bar Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Progress Bar Variants", () => {
    for (const [key, { testId }] of Object.entries(PROGRESS_BARS)) {
      test(`should render ${key} progress bar`, async ({ page }) => {
        await scrollToProgressBars(page);
        const progressBar = page.getByTestId(testId);
        await expect(progressBar).toBeAttached();
        await expect(progressBar).toHaveAttribute("role", "progressbar");
      });
    }
  });

  test.describe("Progress Bar ARIA Roles", () => {
    test("default progress bar should have role=progressbar", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveAttribute("role", "progressbar");
    });

    test("large progress bar should have role=progressbar", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-large");
      await expect(progressBar).toHaveAttribute("role", "progressbar");
    });

    test("muted progress bar should have role=progressbar", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-muted");
      await expect(progressBar).toHaveAttribute("role", "progressbar");
    });
  });

  test.describe("Progress Bar aria-valuenow", () => {
    test("default progress bar should have aria-valuenow=50", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveAttribute("aria-valuenow", "50");
    });

    test("large progress bar should have aria-valuenow=75", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-large");
      await expect(progressBar).toHaveAttribute("aria-valuenow", "75");
    });

    test("muted progress bar should have aria-valuenow=25", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-muted");
      await expect(progressBar).toHaveAttribute("aria-valuenow", "25");
    });
  });

  test.describe("Progress Bar aria-valuemin/max", () => {
    test("default progress bar should have aria-valuemin=0", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveAttribute("aria-valuemin", "0");
    });

    test("default progress bar should have aria-valuemax=100", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveAttribute("aria-valuemax", "100");
    });

    test("large progress bar should have aria-valuemin=0", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-large");
      await expect(progressBar).toHaveAttribute("aria-valuemin", "0");
    });

    test("large progress bar should have aria-valuemax=100", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-large");
      await expect(progressBar).toHaveAttribute("aria-valuemax", "100");
    });
  });

  test.describe("Progress Bar aria-live", () => {
    test("default progress bar should have aria-live=polite", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveAttribute("aria-live", "polite");
    });

    test("large progress bar should have aria-live=polite", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-large");
      await expect(progressBar).toHaveAttribute("aria-live", "polite");
    });

    test("muted progress bar should have aria-live=polite", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-muted");
      await expect(progressBar).toHaveAttribute("aria-live", "polite");
    });
  });

  test.describe("Progress Bar aria-label", () => {
    for (const [key, { testId, ariaLabel }] of Object.entries(PROGRESS_BARS)) {
      test(`${key} progress bar should have aria-label`, async ({ page }) => {
        const progressBar = page.getByTestId(testId);
        await expect(progressBar).toHaveAttribute("aria-label", ariaLabel);
      });
    }
  });

  test.describe("Progress Bar Styling", () => {
    test("should have rounded-full class", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveClass(/rounded-full/);
    });

    test("should have overflow-hidden", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveClass(/overflow-hidden/);
    });

    test("should have bg-muted background", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveClass(/bg-muted/);
    });

    test("indicator should have bg-primary", async ({ page }) => {
      const indicator = page.getByTestId("progress-bar-default-indicator");
      await expect(indicator).toHaveClass(/bg-primary/);
    });
  });

  test.describe("Progress Bar Layout", () => {
    test("should be in progress-bars section", async ({ page }) => {
      const section = page.getByTestId("progress-bars-section");
      await expect(section).toBeVisible();
    });

    test("should have keyboard hint visible", async ({ page }) => {
      const hint = page.getByTestId("progress-bars-keyboard-hint");
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("role=progressbar");
    });

    test("should have w-full width", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toHaveClass(/w-full/);
    });

    test("indicator should have transition-all", async ({ page }) => {
      const indicator = page.getByTestId("progress-bar-default-indicator");
      await expect(indicator).toHaveClass(/transition-all/);
    });
  });

  test.describe("Progress Bar Accessibility", () => {
    test("should not be focusable", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      const tabIndex = await progressBar.getAttribute("tabindex");
      expect(tabIndex).toBeNull();
    });

    test("should announce progress state via role=progressbar", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      const role = await progressBar.getAttribute("role");
      const ariaValueNow = await progressBar.getAttribute("aria-valuenow");
      expect(role).toBe("progressbar");
      expect(ariaValueNow).toBe("50");
    });

    test("should have accessible name via aria-label", async ({ page }) => {
      const progressBar = page.getByTestId("progress-bar-default");
      const ariaLabel = await progressBar.getAttribute("aria-label");
      expect(ariaLabel).toBeTruthy();
    });

    test("should have indicator element", async ({ page }) => {
      const indicator = page.getByTestId("progress-bar-default-indicator");
      await expect(indicator).toBeAttached();
    });
  });

  test.describe("Accessibility", () => {
    test("progress bar should not have WCAG violations", async ({ page }, testInfo) => {
      const progressBar = page.getByTestId("progress-bar-default");
      await expect(progressBar).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='progress-bar-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("progress-bar-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
