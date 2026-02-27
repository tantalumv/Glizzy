/**
 * General Components Integration Tests
 */

import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

test.describe("Home Page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");
  });

  test("should display page title", async ({ page }) => {
    await expect(page).toHaveTitle(/Glizzy/);
  });

  test("should display Buttons section", async ({ page }) => {
    await expect(page.getByText("Buttons", { exact: true })).toBeVisible();
  });

  test("should display all button variants", async ({ page }) => {
    await expect(page.getByTestId("btn-default")).toBeVisible();
    await expect(page.getByTestId("btn-secondary")).toBeVisible();
    await expect(page.getByTestId("btn-destructive")).toBeVisible();
    await expect(page.getByTestId("btn-outline")).toBeVisible();
  });

  test("should display Inputs section", async ({ page }) => {
    await expect(page.getByText("Inputs", { exact: true })).toBeVisible();
  });

  test("should have working text input", async ({ page }) => {
    const input = page.getByTestId("input-default");
    await input.fill("Test");
    await expect(input).toHaveValue("Test");
  });

  test("should display Checkboxes section", async ({ page }) => {
    await expect(page.getByText("Checkboxes", { exact: true })).toBeVisible();
  });

  test("should toggle checkbox", async ({ page }) => {
    const checkbox = page.locator('input[type="checkbox"]').first();
    await checkbox.click();
    await expect(checkbox).toBeChecked();
  });

  test("should display Switches section", async ({ page }) => {
    await expect(page.getByText("Switches", { exact: true })).toBeVisible();
  });

  test("should toggle switch", async ({ page }) => {
    const wrapper = page.getByTestId("switch-notifications-wrapper");
    const checkbox = wrapper.locator('input[type="checkbox"]');
    await checkbox.focus();
    await page.keyboard.press(" ");
    await expect(checkbox).toBeChecked();
  });

  test("should display Badges section", async ({ page }) => {
    await expect(page.getByText("Badges", { exact: true })).toBeVisible();
  });

  test("should display all badge variants", async ({ page }) => {
    await expect(page.getByTestId("badge-default")).toBeVisible();
    await expect(page.getByTestId("badge-secondary")).toBeVisible();
    await expect(page.getByTestId("badge-destructive")).toBeVisible();
    await expect(page.getByTestId("badge-outline")).toBeVisible();
  });
});

test.describe("Accessibility", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");
  });

  test("should have proper focus indicators", async ({ page }) => {
    const button = page.getByTestId("btn-default");
    await button.focus();
    await expect(button).toHaveClass(/focus/);
  });

  test("buttons should be accessible", async ({ page }) => {
    const button = page.getByTestId("btn-default");
    await expect(button).toBeEnabled();
    await expect(button).toBeVisible();
  });

  test("checkboxes should be accessible", async ({ page }) => {
    const checkbox = page.locator('input[type="checkbox"]').first();
    await expect(checkbox).toBeVisible();
    await checkbox.focus();
    await expect(checkbox).toBeFocused();
  });

  test("input should be accessible", async ({ page }) => {
    const input = page.getByTestId("input-default");
    await expect(input).toBeVisible();
    await input.fill("test");
    await expect(input).toHaveValue("test");
  });
});

test.describe("Responsive Design", () => {
  test("should render correctly on mobile", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto("/");
    await expect(page.getByText("Glizzy UI Demo")).toBeVisible();
  });

  test("should render correctly on tablet", async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto("/");
    await expect(page.getByText("Glizzy UI Demo")).toBeVisible();
  });

  test("should render correctly on desktop", async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto("/");
    await expect(page.getByText("Glizzy UI Demo")).toBeVisible();
  });
});

test.describe("Component Styling", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await page.waitForLoadState("networkidle");
  });

  test("buttons should have proper classes", async ({ page }) => {
    const button = page.getByTestId("btn-default");
    await expect(button).toHaveClass(/rounded/);
    await expect(button).toHaveClass(/transition/);
  });

  test("badges should have proper classes", async ({ page }) => {
    const badge = page.getByTestId("badge-default");
    await expect(badge).toHaveClass(/rounded-full/);
    await expect(badge).toHaveClass(/inline-flex/);
  });

  test("input should have proper classes", async ({ page }) => {
    const input = page.getByTestId("input-default");
    await expect(input).toHaveClass(/rounded-md/);
    await expect(input).toHaveClass(/border/);
  });

  test.describe("Accessibility", () => {
    test("home page components should not have WCAG violations", async ({ page }, testInfo) => {
      const button = page.getByTestId("btn-default");
      await expect(button).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='btn-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("home-page-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
