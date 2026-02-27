/**
 * Meter Component Tests
 * Covers: role=metric (meter), aria-valuenow/min/max, aria-live, aria-label
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const METERS = {
  default: { testId: "meter-default", ariaLabel: "Battery level indicator", value: 80 },
  large: { testId: "meter-large", ariaLabel: "Storage usage indicator", value: 60 },
  muted: { testId: "meter-muted", ariaLabel: "CPU usage indicator", value: 40 },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

async function scrollToMeters(page: Page): Promise<void> {
  const section = page.getByTestId("meters-section");
  await section.scrollIntoViewIfNeeded();
}

test.describe("Meter Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Meter Variants", () => {
    for (const [key, { testId }] of Object.entries(METERS)) {
      test(`should render ${key} meter`, async ({ page }) => {
        await scrollToMeters(page);
        const meter = page.getByTestId(testId);
        await expect(meter).toBeAttached();
        await expect(meter).toHaveAttribute("role", "meter");
      });
    }
  });

  test.describe("Meter ARIA Roles", () => {
    test("default meter should have role=meter", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveAttribute("role", "meter");
    });

    test("large meter should have role=meter", async ({ page }) => {
      const meter = page.getByTestId("meter-large");
      await expect(meter).toHaveAttribute("role", "meter");
    });

    test("muted meter should have role=meter", async ({ page }) => {
      const meter = page.getByTestId("meter-muted");
      await expect(meter).toHaveAttribute("role", "meter");
    });
  });

  test.describe("Meter aria-valuenow", () => {
    test("default meter should have aria-valuenow=80", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveAttribute("aria-valuenow", "80");
    });

    test("large meter should have aria-valuenow=60", async ({ page }) => {
      const meter = page.getByTestId("meter-large");
      await expect(meter).toHaveAttribute("aria-valuenow", "60");
    });

    test("muted meter should have aria-valuenow=40", async ({ page }) => {
      const meter = page.getByTestId("meter-muted");
      await expect(meter).toHaveAttribute("aria-valuenow", "40");
    });
  });

  test.describe("Meter aria-valuemin/max", () => {
    test("default meter should have aria-valuemin=0", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveAttribute("aria-valuemin", "0");
    });

    test("default meter should have aria-valuemax=100", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveAttribute("aria-valuemax", "100");
    });

    test("large meter should have aria-valuemin=0", async ({ page }) => {
      const meter = page.getByTestId("meter-large");
      await expect(meter).toHaveAttribute("aria-valuemin", "0");
    });

    test("large meter should have aria-valuemax=100", async ({ page }) => {
      const meter = page.getByTestId("meter-large");
      await expect(meter).toHaveAttribute("aria-valuemax", "100");
    });
  });

  test.describe("Meter aria-live", () => {
    test("default meter should have aria-live=polite", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveAttribute("aria-live", "polite");
    });

    test("large meter should have aria-live=polite", async ({ page }) => {
      const meter = page.getByTestId("meter-large");
      await expect(meter).toHaveAttribute("aria-live", "polite");
    });

    test("muted meter should have aria-live=polite", async ({ page }) => {
      const meter = page.getByTestId("meter-muted");
      await expect(meter).toHaveAttribute("aria-live", "polite");
    });
  });

  test.describe("Meter aria-label", () => {
    for (const [key, { testId, ariaLabel }] of Object.entries(METERS)) {
      test(`${key} meter should have aria-label`, async ({ page }) => {
        const meter = page.getByTestId(testId);
        await expect(meter).toHaveAttribute("aria-label", ariaLabel);
      });
    }
  });

  test.describe("Meter Styling", () => {
    test("should have rounded-full class", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveClass(/rounded-full/);
    });

    test("should have overflow-hidden", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveClass(/overflow-hidden/);
    });

    test("should have bg-muted background", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveClass(/bg-muted/);
    });

    test("fill should have bg-primary", async ({ page }) => {
      const fill = page.getByTestId("meter-default-fill");
      await expect(fill).toHaveClass(/bg-primary/);
    });
  });

  test.describe("Meter Layout", () => {
    test("should be in meters section", async ({ page }) => {
      const section = page.getByTestId("meters-section");
      await expect(section).toBeVisible();
    });

    test("should have keyboard hint visible", async ({ page }) => {
      const hint = page.getByTestId("meters-keyboard-hint");
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("role=metric");
    });

    test("should have w-full width", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toHaveClass(/w-full/);
    });

    test("large meter should be taller than default", async ({ page }) => {
      await scrollToMeters(page);
      const defaultMeter = page.getByTestId("meter-default");
      const largeMeter = page.getByTestId("meter-large");
      const defaultBox = await defaultMeter.boundingBox();
      const largeBox = await largeMeter.boundingBox();
      expect(defaultBox).not.toBeNull();
      expect(largeBox).not.toBeNull();
      expect(largeBox!.height).toBeGreaterThan(defaultBox!.height);
    });
  });

  test.describe("Meter Accessibility", () => {
    test("should not be focusable", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      const tabIndex = await meter.getAttribute("tabindex");
      expect(tabIndex).toBeNull();
    });

    test("should announce meter state via role=meter", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      const role = await meter.getAttribute("role");
      const ariaValueNow = await meter.getAttribute("aria-valuenow");
      expect(role).toBe("meter");
      expect(ariaValueNow).toBe("80");
    });

    test("should have accessible name via aria-label", async ({ page }) => {
      const meter = page.getByTestId("meter-default");
      const ariaLabel = await meter.getAttribute("aria-label");
      expect(ariaLabel).toBeTruthy();
    });

    test("should have fill element", async ({ page }) => {
      const fill = page.getByTestId("meter-default-fill");
      await expect(fill).toBeAttached();
    });
  });

  test.describe("Accessibility", () => {
    test("meter should not have WCAG violations", async ({ page }, testInfo) => {
      const meter = page.getByTestId("meter-default");
      await expect(meter).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='meter-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("meter-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
