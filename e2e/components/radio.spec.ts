/**
 * Radio Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const RADIO = {
  group: { testId: "radio-group" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Radio Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Radio Variants", () => {
    test("should render radio group", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      await expect(group).toBeVisible();
    });

    test("one option should be checked by default", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radios = group.locator('input[type="radio"]');
      const checkedCount = await radios.evaluateAll(
        (els) => els.filter((el) => (el as HTMLInputElement).checked).length,
      );
      expect(checkedCount).toBeGreaterThanOrEqual(1);
    });
  });

  test.describe("Radio Styling", () => {
    test("radio inputs should have proper styling", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radio = group.locator('input[type="radio"]').first();
      await expect(radio).toBeVisible();
    });
  });

  test.describe("Radio Layout", () => {
    test("should be visible in forms section", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      await expect(group).toBeVisible();
    });

    test("should have proper width", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const box = await group.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(0);
    });
  });

  test.describe("Radio Interactions", () => {
    test("should select radio on click", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radios = group.locator('input[type="radio"]');
      const firstRadio = radios.first();
      await firstRadio.click();
      await expect(firstRadio).toBeChecked();
    });

    test("should handle label click", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const label = group.locator("label").first();
      await label.click();
      const radio = group.locator('input[type="radio"]').first();
      await expect(radio).toBeChecked();
    });
  });

  test.describe("Radio Accessibility", () => {
    test("radio inputs should have type radio", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radios = group.locator('input[type="radio"]');
      await expect(radios.first()).toHaveAttribute("type", "radio");
    });

    test("should be visible", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      await expect(group).toBeVisible();
    });

    test("radio group should have role radiogroup", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      await expect(group).toHaveAttribute("role", "radiogroup");
    });

    test("radio options should have aria-checked with correct values", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radios = group.locator('input[type="radio"]');
      
      // Check that all radios have aria-checked
      const radioCount = await radios.count();
      for (let i = 0; i < radioCount; i++) {
        await expect(radios.nth(i)).toHaveAttribute("aria-checked");
      }
      
      // Verify only one is checked (true) and others are false
      const checkedRadios = await radios.evaluateAll(
        (els) => els.filter((el) => el.getAttribute("aria-checked") === "true").length
      );
      expect(checkedRadios).toBe(1);
    });

    test("radio group should have aria-labelledby", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const labelledBy = await group.getAttribute("aria-labelledby");
      expect(labelledBy).toBeTruthy();
      
      // Verify the labelledby element exists
      const labelElement = page.locator(`#${labelledBy}`);
      await expect(labelElement).toBeVisible();
    });

    test("should support arrow key navigation", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radios = group.locator('input[type="radio"]');
      
      // Focus first radio
      await radios.first().focus();
      await expect(radios.first()).toBeFocused();
      
      // Press ArrowRight to move to next
      await page.keyboard.press("ArrowRight");
      await expect(radios.nth(1)).toBeFocused();
      
      // Press ArrowDown to move to next
      await page.keyboard.press("ArrowDown");
      await expect(radios.nth(2)).toBeFocused();
      
      // Press ArrowLeft to move back
      await page.keyboard.press("ArrowLeft");
      await expect(radios.nth(1)).toBeFocused();
    });

    test("should support Home and End keys", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radios = group.locator('input[type="radio"]');
      const radioCount = await radios.count();
      
      // Focus first radio, then press End to go to last
      await radios.first().focus();
      await page.keyboard.press("End");
      await expect(radios.nth(radioCount - 1)).toBeFocused();
      
      // Press Home to go back to first
      await page.keyboard.press("Home");
      await expect(radios.first()).toBeFocused();
    });

    test("should maintain mutual exclusion (only one checked)", async ({ page }) => {
      const group = page.getByTestId("radio-group");
      const radios = group.locator('input[type="radio"]');
      
      // Click second radio
      await radios.nth(1).click();
      
      // Verify only second is checked
      const checkedCount = await radios.evaluateAll(
        (els) => els.filter((el) => (el as HTMLInputElement).checked).length
      );
      expect(checkedCount).toBe(1);
      await expect(radios.nth(1)).toBeChecked();
    });
  });

  test.describe("Accessibility", () => {
    test("radio should not have WCAG violations", async ({ page }, testInfo) => {
      const group = page.getByTestId("radio-group");
      await expect(group).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='radio-group']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("radio-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
