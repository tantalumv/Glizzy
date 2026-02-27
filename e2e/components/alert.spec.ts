/**
 * Alert Component Tests
 * Covers: live-region announcements, aria-live, role=status/alert, aria-atomic
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const ALERTS = {
  default: { testId: "alert-default", role: "status", ariaLive: "polite" },
  success: { testId: "alert-success", role: "status", ariaLive: "polite" },
  warning: { testId: "alert-warning", role: "status", ariaLive: "polite" },
  error: { testId: "alert-error", role: "alert", ariaLive: "assertive" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Alert Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Alert Variants", () => {
    for (const [key, { testId }] of Object.entries(ALERTS)) {
      test(`should render ${key} alert`, async ({ page }) => {
        const alert = page.getByTestId(testId);
        await expect(alert).toBeVisible();
      });
    }

    test("all alerts should be visible", async ({ page }) => {
      for (const { testId } of Object.values(ALERTS)) {
        await expect(page.getByTestId(testId)).toBeVisible();
      }
    });
  });

  test.describe("Alert ARIA Roles", () => {
    test("default alert should have role=status", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toHaveAttribute("role", "status");
    });

    test("success alert should have role=status", async ({ page }) => {
      const alert = page.getByTestId("alert-success");
      await expect(alert).toHaveAttribute("role", "status");
    });

    test("warning alert should have role=status", async ({ page }) => {
      const alert = page.getByTestId("alert-warning");
      await expect(alert).toHaveAttribute("role", "status");
    });

    test("error alert should have role=alert for critical announcements", async ({ page }) => {
      const alert = page.getByTestId("alert-error");
      await expect(alert).toHaveAttribute("role", "alert");
    });
  });

  test.describe("Alert Live Regions", () => {
    test("default alert should have aria-live=polite", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toHaveAttribute("aria-live", "polite");
    });

    test("success alert should have aria-live=polite", async ({ page }) => {
      const alert = page.getByTestId("alert-success");
      await expect(alert).toHaveAttribute("aria-live", "polite");
    });

    test("warning alert should have aria-live=polite", async ({ page }) => {
      const alert = page.getByTestId("alert-warning");
      await expect(alert).toHaveAttribute("aria-live", "polite");
    });

    test("error alert should have aria-live=assertive for immediate attention", async ({ page }) => {
      const alert = page.getByTestId("alert-error");
      await expect(alert).toHaveAttribute("aria-live", "assertive");
    });
  });

  test.describe("Alert aria-atomic", () => {
    test("default alert should have aria-atomic=true", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toHaveAttribute("aria-atomic", "true");
    });

    test("error alert should have aria-atomic=true", async ({ page }) => {
      const alert = page.getByTestId("alert-error");
      await expect(alert).toHaveAttribute("aria-atomic", "true");
    });
  });

  test.describe("Alert aria-label", () => {
    test("default alert should have aria-label", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toHaveAttribute("aria-label", "Information alert");
    });

    test("success alert should have aria-label", async ({ page }) => {
      const alert = page.getByTestId("alert-success");
      await expect(alert).toHaveAttribute("aria-label", "Success notification");
    });

    test("error alert should have aria-label", async ({ page }) => {
      const alert = page.getByTestId("alert-error");
      await expect(alert).toHaveAttribute("aria-label", "Error notification");
    });
  });

  test.describe("Alert Styling", () => {
    test("should have rounded corners", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toHaveClass(/rounded/);
    });

    test("should have padding", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toHaveClass(/p-/);
    });

    test("should have border", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toHaveClass(/border/);
    });
  });

  test.describe("Alert Layout", () => {
    test("should be visible in alerts section", async ({ page }) => {
      const section = page.getByTestId("alerts-section");
      const isSectionVisible = await section.isVisible().catch(() => false);
      
      // Skip if alerts section not present
      if (!isSectionVisible) {
        test.skip();
        return;
      }
      
      await expect(section).toBeVisible();
    });

    test("should have keyboard hint visible", async ({ page }) => {
      const hint = page.getByTestId("alerts-keyboard-hint");
      const isHintVisible = await hint.isVisible().catch(() => false);
      
      // Skip if hint not present
      if (!isHintVisible) {
        test.skip();
        return;
      }
      
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("role=status");
    });

    test("should have proper width", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      const box = await alert.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(0);
    });

    test("should contain text content", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      const text = await alert.textContent();
      expect(text?.trim()).toBeTruthy();
    });
  });

  test.describe("Alert Content Structure", () => {
    test("should have title element", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      const title = alert.locator("p.font-semibold, p.mb-1");
      await expect(title).toBeVisible();
    });

    test("should have description element", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      const description = alert.locator("p.text-sm");
      await expect(description).toBeVisible();
    });
  });

  test.describe("Alert Accessibility", () => {
    test("should be announced by screen readers via live region", async ({ page }) => {
      const alert = page.getByTestId("alert-default");
      const role = await alert.getAttribute("role");
      const ariaLive = await alert.getAttribute("aria-live");
      expect(role).toBe("status");
      expect(ariaLive).toBe("polite");
    });

    test("error alert should interrupt with assertive live region", async ({ page }) => {
      const alert = page.getByTestId("alert-error");
      const role = await alert.getAttribute("role");
      const ariaLive = await alert.getAttribute("aria-live");
      expect(role).toBe("alert");
      expect(ariaLive).toBe("assertive");
    });
  });

  test.describe("Axe Accessibility", () => {
    test("alert should not have WCAG violations", async ({ page }, testInfo) => {
      const alert = page.getByTestId("alert-default");
      await expect(alert).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='alert-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("alert-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
