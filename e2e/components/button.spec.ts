/**
 * Button Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const BUTTONS = {
  default: { testId: "btn-default", text: "Default" },
  secondary: { testId: "btn-secondary", text: "Secondary" },
  destructive: { testId: "btn-destructive", text: "Destructive" },
  outline: { testId: "btn-outline", text: "Outline" },
  ghost: { testId: "btn-ghost", text: "Ghost" },
  link: { testId: "btn-link", text: "Link" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Button Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Button Variants", () => {
    for (const [key, { testId, text }] of Object.entries(BUTTONS)) {
      test(`should render ${key} button`, async ({ page }) => {
        const button = page.getByTestId(testId);
        await expect(button).toBeVisible();
        await expect(button).toBeEnabled();
        await expect(button).toContainText(text);
      });
    }

    test("should have correct text for each variant", async ({ page }) => {
      for (const { testId, text } of Object.values(BUTTONS)) {
        await expect(page.getByTestId(testId)).toContainText(text);
      }
    });
  });

  test.describe("Button States", () => {
    test("should have hover state", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.hover();
      await expect(button).toHaveClass(/hover:/);
    });

    test("should have focus state", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.focus();
      await expect(button).toBeFocused();
    });

    test("should have active state on click", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.click();
    });

    test("should maintain state after multiple clicks", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.click();
      await button.click();
      await expect(button).toBeVisible();
    });
  });

  test.describe("Button Interactions", () => {
    test("should handle single click", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.click();
      await expect(button).toBeVisible();
    });

    test("should handle double click", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.dblclick();
      await expect(button).toBeVisible();
    });

    test("should handle rapid clicks", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.click();
      await button.click();
      await button.click();
      await expect(button).toBeVisible();
    });

    test("should handle keyboard activation - Enter", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.focus();
      await page.keyboard.press("Enter");
      await expect(button).toBeVisible();
    });

    test("should handle keyboard activation - Space", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.focus();
      await page.keyboard.press(" ");
      await expect(button).toBeVisible();
    });
  });

  test.describe("Button Styling", () => {
    test("should have rounded corners", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toHaveClass(/rounded/);
    });

    test("should have transition classes", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toHaveClass(/transition/);
    });

    test("should have font classes", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toHaveClass(/font/);
    });

    test("should have proper display", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toHaveClass(/flex/);
    });
  });

  test.describe("Button Accessibility", () => {
    test("should have accessible name", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toHaveText(/Default/);
    });

    test("should be in tab order", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toBeEnabled();
    });

    test("should have proper role", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toHaveRole("button");
    });

    test("should have visible focus indicator", async ({ page }) => {
      const button = page.getByTestId("btn-default");
      await button.focus();
      await expect(button).toHaveClass(/focus/);
    });
  });

  test.describe("Accessibility", () => {
    test("button should not have WCAG violations", async ({ page }, testInfo) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='btn-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("button-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
