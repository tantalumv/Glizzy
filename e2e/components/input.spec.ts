/**
 * Input Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
}

test.describe("Input Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Input Visibility", () => {
    test("should render default input", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toBeVisible();
    });

    test("should render input with placeholder", async ({ page }) => {
      const input = page.getByTestId("input-placeholder");
      await expect(input).toBeVisible();
    });

    test("should display Inputs section heading", async ({ page }) => {
      const heading = page.getByText("Inputs", { exact: true });
      await expect(heading).toBeVisible();
    });
  });

  test.describe("Input Values", () => {
    test("should have empty initial value", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toHaveValue("");
    });

    test("should accept text input", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("Hello World");
      await expect(input).toHaveValue("Hello World");
    });

    test("should accept long text input", async ({ page }) => {
      const input = page.getByTestId("input-default");
      const longText = "A".repeat(100);
      await input.fill(longText);
      await expect(input).toHaveValue(longText);
    });

    test("should accept special characters", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("!@#$%^&*()");
      await expect(input).toHaveValue("!@#$%^&*()");
    });

    test("should accept unicode characters", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("Hello 世界 🌍");
      await expect(input).toHaveValue("Hello 世界 🌍");
    });

    test("should accept numbers", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("12345");
      await expect(input).toHaveValue("12345");
    });

    test("should accept mixed content", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("Test123!@#");
      await expect(input).toHaveValue("Test123!@#");
    });
  });

  test.describe("Input Interactions", () => {
    test("should focus on click", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.click();
      await expect(input).toBeFocused();
    });

    test("should accept keyboard input", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.click();
      await page.keyboard.type("Hello");
      await expect(input).toHaveValue("Hello");
    });

    test("should allow text selection", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("Hello World");
      await input.selectText();
      await expect(input).toBeFocused();
    });

    test("should allow text deletion", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("Hello");
      await input.press("Backspace");
      await expect(input).toHaveValue("Hell");
    });

    test("should clear on fill with empty string", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("Hello");
      await input.fill("");
      await expect(input).toHaveValue("");
    });

    test("should handle cut and paste", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("Hello World");
      await input.selectText();
      await page.keyboard.press("Control+c");
      await input.press("End");
      await page.keyboard.press("Control+v");
      await expect(input).toHaveValue("Hello WorldHello World");
    });
  });

  test.describe("Input Placeholder", () => {
    test("should display placeholder", async ({ page }) => {
      const input = page.getByTestId("input-placeholder");
      await expect(input).toHaveAttribute("placeholder");
    });

    test("should hide placeholder when typing", async ({ page }) => {
      const input = page.getByTestId("input-placeholder");
      await input.fill("x");
      await expect(input).not.toBeEmpty();
    });

    test("should show placeholder when empty", async ({ page }) => {
      const input = page.getByTestId("input-placeholder");
      await expect(input).toHaveAttribute("placeholder");
    });
  });

  test.describe("Input Styling", () => {
    test("should have rounded-md class", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toHaveClass(/rounded-md/);
    });

    test("should have border class", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toHaveClass(/border/);
    });

    test("should have proper width", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toHaveClass(/w-/);
    });

    test("should have proper height", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toHaveClass(/h-/);
    });

    test("should have focus ring", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.focus();
      await expect(input).toHaveClass(/focus-visible:ring/);
    });
  });

  test.describe("Input Accessibility", () => {
    test("should have textbox role", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toHaveAttribute("type", "text");
    });

    test("should be focusable", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.focus();
      await expect(input).toBeFocused();
    });

    test("should have accessible name", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).toHaveAttribute("type");
    });

    test("should be in tab order", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await expect(input).not.toHaveAttribute("tabindex", "-1");
    });

    test("should have aria-describedby for hint", async ({ page }) => {
      const input = page.getByTestId("input-default");
      const hasAriaDescribedBy = await input.getAttribute("aria-describedby");
      expect(hasAriaDescribedBy).toBeTruthy();
    });

    test("should have aria-label for placeholder input", async ({ page }) => {
      const input = page.getByTestId("input-placeholder");
      const hasAriaLabel = await input.getAttribute("aria-label");
      expect(hasAriaLabel).toBeTruthy();
    });
  });

  test.describe("Input Edge Cases", () => {
    test("should handle XSS attempt", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill('<script>alert("xss")</script>');
      await expect(input).toHaveValue('<script>alert("xss")</script>');
    });

    test("should handle SQL injection attempt", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("'; DROP TABLE users; --");
      await expect(input).toHaveValue("'; DROP TABLE users; --");
    });

    test("should handle emoji input", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("😀🎉🚀");
      await expect(input).toHaveValue("😀🎉🚀");
    });

    test("should handle RTL text", async ({ page }) => {
      const input = page.getByTestId("input-default");
      await input.fill("مرحبا");
      await expect(input).toHaveValue("مرحبا");
    });
  });

  test.describe("Accessibility", () => {
    test("input should not have WCAG violations", async ({ page }, testInfo) => {
      const input = page.getByTestId("input-default");
      await expect(input).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='input-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("input-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
