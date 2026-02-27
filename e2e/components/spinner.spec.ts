/**
 * Spinner Component Tests
 * Covers: aria-busy, aria-live, role=status, loading state announcements
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const SPINNERS = {
  small: { testId: "spinner-small", ariaLabel: "Loading, small size" },
  medium: { testId: "spinner-medium", ariaLabel: "Loading, medium size" },
  large: { testId: "spinner-large", ariaLabel: "Loading, large size" },
  muted: { testId: "spinner-muted", ariaLabel: "Loading, muted style" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

async function scrollToSpinners(page: Page): Promise<void> {
  const section = page.getByTestId("spinners-section");
  await section.scrollIntoViewIfNeeded();
}

test.describe("Spinner Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Spinner Variants", () => {
    for (const [key, { testId }] of Object.entries(SPINNERS)) {
      test(`should render ${key} spinner`, async ({ page }) => {
        await scrollToSpinners(page);
        const spinner = page.getByTestId(testId);
        await expect(spinner).toBeAttached();
        await expect(spinner).toHaveAttribute("role", "status");
      });
    }
  });

  test.describe("Spinner ARIA Roles", () => {
    test("small spinner should have role=status", async ({ page }) => {
      const spinner = page.getByTestId("spinner-small");
      await expect(spinner).toHaveAttribute("role", "status");
    });

    test("medium spinner should have role=status", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toHaveAttribute("role", "status");
    });

    test("large spinner should have role=status", async ({ page }) => {
      const spinner = page.getByTestId("spinner-large");
      await expect(spinner).toHaveAttribute("role", "status");
    });

    test("muted spinner should have role=status", async ({ page }) => {
      const spinner = page.getByTestId("spinner-muted");
      await expect(spinner).toHaveAttribute("role", "status");
    });
  });

  test.describe("Spinner aria-live", () => {
    test("medium spinner should have aria-live=polite", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toHaveAttribute("aria-live", "polite");
    });

    test("small spinner should have aria-live=polite", async ({ page }) => {
      const spinner = page.getByTestId("spinner-small");
      await expect(spinner).toHaveAttribute("aria-live", "polite");
    });
  });

  test.describe("Spinner aria-busy", () => {
    test("medium spinner should have aria-busy=true", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toHaveAttribute("aria-busy", "true");
    });

    test("small spinner should have aria-busy=true", async ({ page }) => {
      const spinner = page.getByTestId("spinner-small");
      await expect(spinner).toHaveAttribute("aria-busy", "true");
    });

    test("large spinner should have aria-busy=true", async ({ page }) => {
      const spinner = page.getByTestId("spinner-large");
      await expect(spinner).toHaveAttribute("aria-busy", "true");
    });
  });

  test.describe("Spinner aria-label", () => {
    for (const [key, { testId, ariaLabel }] of Object.entries(SPINNERS)) {
      test(`${key} spinner should have aria-label`, async ({ page }) => {
        const spinner = page.getByTestId(testId);
        await expect(spinner).toHaveAttribute("aria-label", ariaLabel);
      });
    }
  });

  test.describe("Spinner Styling", () => {
    test("should have animate-spin", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toHaveClass(/animate/);
    });

    test("should have border", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toHaveClass(/border/);
    });
  });

  test.describe("Spinner Layout", () => {
    test("should be in DOM", async ({ page }) => {
      await scrollToSpinners(page);
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toBeAttached();
    });

    test("should have equal width and height", async ({ page }) => {
      await scrollToSpinners(page);
      const spinner = page.getByTestId("spinner-medium");
      const box = await spinner.boundingBox();
      expect(box).not.toBeNull();
      const widthHeightDiff = Math.abs(box!.width - box!.height);
      expect(widthHeightDiff).toBeLessThan(5);
    });

    test("large should be bigger than small", async ({ page }) => {
      await scrollToSpinners(page);
      const small = await page.getByTestId("spinner-small").boundingBox();
      const large = await page.getByTestId("spinner-large").boundingBox();
      expect(small).not.toBeNull();
      expect(large).not.toBeNull();
      expect(large!.width).toBeGreaterThan(small!.width);
      expect(large!.height).toBeGreaterThan(small!.height);
    });

    test("should be in spinners section", async ({ page }) => {
      const section = page.getByTestId("spinners-section");
      await expect(section).toBeVisible();
    });

    test("should have keyboard hint visible", async ({ page }) => {
      const hint = page.getByTestId("spinners-keyboard-hint");
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("aria-busy=true");
    });
  });

  test.describe("Spinner Animation", () => {
    test("should have animation class", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toHaveClass(/animate/);
    });

    test("small should have animation", async ({ page }) => {
      const spinner = page.getByTestId("spinner-small");
      await expect(spinner).toHaveClass(/animate/);
    });

    test("large should have animation", async ({ page }) => {
      const spinner = page.getByTestId("spinner-large");
      await expect(spinner).toHaveClass(/animate/);
    });
  });

  test.describe("Spinner Accessibility", () => {
    test("should not be focusable", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      const tabIndex = await spinner.getAttribute("tabindex");
      expect(tabIndex).toBeNull();
    });

    test("should announce loading state via role=status", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      const role = await spinner.getAttribute("role");
      const ariaBusy = await spinner.getAttribute("aria-busy");
      expect(role).toBe("status");
      expect(ariaBusy).toBe("true");
    });

    test("should have accessible name via aria-label", async ({ page }) => {
      const spinner = page.getByTestId("spinner-medium");
      const ariaLabel = await spinner.getAttribute("aria-label");
      expect(ariaLabel).toBeTruthy();
    });
  });

  test.describe("Accessibility", () => {
    test("spinner should not have WCAG violations", async ({ page }, testInfo) => {
      const spinner = page.getByTestId("spinner-medium");
      await expect(spinner).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='spinner-medium']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("spinner-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
