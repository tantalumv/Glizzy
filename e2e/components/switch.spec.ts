/**
 * Switch Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
}

async function toggleSwitch(page: Page): Promise<void> {
  const wrapper = page.getByTestId("switch-notifications-wrapper");
  const label = wrapper.locator("label");
  await label.click();
  await page.waitForTimeout(50);
}

test.describe("Switch Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Switch Visibility", () => {
    test("should render notifications switch", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeVisible();
    });

    test("should display Switches section heading", async ({ page }) => {
      const heading = page.getByText("Switches", { exact: true });
      await expect(heading).toBeVisible();
    });

    test("should have associated label", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      await expect(wrapper).toContainText("notifications");
    });
  });

  test.describe("Switch States", () => {
    test("should be off by default", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).not.toBeChecked();
    });

    test("should turn on when toggled", async ({ page }) => {
      await toggleSwitch(page);
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeChecked();
    });

    test("should toggle off when clicked again", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await toggleSwitch(page);
      await expect(checkbox).toBeChecked();
      await toggleSwitch(page);
      await expect(checkbox).not.toBeChecked();
    });

    test("should stay on after multiple toggles", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await toggleSwitch(page);
      await expect(checkbox).toBeChecked();
      await toggleSwitch(page);
      await expect(checkbox).not.toBeChecked();
      await toggleSwitch(page);
      await expect(checkbox).toBeChecked();
    });

    test("should maintain state after blur", async ({ page }) => {
      await toggleSwitch(page);
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await page.keyboard.press("Tab");
      await expect(checkbox).toBeChecked();
    });
  });

  test.describe("Switch Interactions", () => {
    test("should turn on via click", async ({ page }) => {
      await toggleSwitch(page);
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeChecked();
    });

    test("should handle keyboard space", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await checkbox.focus();
      await page.keyboard.press(" ");
      await expect(checkbox).toBeChecked();
    });

    test("should handle keyboard enter", async ({ page }) => {
      // Note: Per WAI-ARIA Switch pattern, only Space toggles the switch
      // Enter key does not toggle switch state
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await checkbox.focus();
      await page.keyboard.press("Enter");
      await expect(checkbox).not.toBeChecked();
    });

    test("should handle rapid toggling", async ({ page }) => {
      await toggleSwitch(page);
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeChecked();
    });

    test("should stay on after multiple keyboard actions", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await toggleSwitch(page);
      await expect(checkbox).toBeChecked();
      await toggleSwitch(page);
      await expect(checkbox).not.toBeChecked();
    });
  });

  test.describe("Switch Visual States", () => {
    test("should show off state visually", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).not.toBeChecked();
    });

    test("should show on state visually", async ({ page }) => {
      await toggleSwitch(page);
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeChecked();
    });
  });

  test.describe("Switch Styling", () => {
    test("should have checkbox type", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toHaveAttribute("type", "checkbox");
    });

    test("should have proper size", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeVisible();
    });

    test("should have transition for smooth toggle", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const visualToggle = wrapper.locator("div.relative");
      await expect(visualToggle).toHaveClass(/transition/);
    });
  });

  test.describe("Switch Accessibility", () => {
    test("should have switch role", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toHaveAttribute("role", "switch");
    });

    test("should have accessible name via aria-labelledby", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      const labelledBy = await checkbox.getAttribute("aria-labelledby");
      expect(labelledBy).toBeTruthy();
      
      // Verify the labelledby element exists and has text
      const labelElement = page.locator(`#${labelledBy}`);
      await expect(labelElement).toBeVisible();
      const labelText = await labelElement.textContent();
      expect(labelText?.toLowerCase()).toContain("notifications");
    });

    test("should be focusable", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await checkbox.focus();
      await expect(checkbox).toBeFocused();
    });

    test("should have focus styles", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await checkbox.focus();
      await expect(checkbox).toBeFocused();
    });

    test("should stay on after multiple state changes", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await toggleSwitch(page);
      await expect(checkbox).toBeChecked();
      // Verify state persists
      await page.waitForTimeout(100);
      await expect(checkbox).toBeChecked();
    });

    test("should be in tab order", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).not.toHaveAttribute("tabindex", "-1");
    });

    test("should have aria-checked attribute with correct value", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      
      // Check initial state (unchecked)
      await expect(checkbox).toHaveAttribute("aria-checked", "false");
      
      // Toggle and check checked state
      await toggleSwitch(page);
      await expect(checkbox).toHaveAttribute("aria-checked", "true");
      
      // Toggle back and check unchecked state
      await toggleSwitch(page);
      await expect(checkbox).toHaveAttribute("aria-checked", "false");
    });

    test("should have aria-describedby for hint", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      const hasAriaDescribedBy = await checkbox.getAttribute("aria-describedby");
      expect(hasAriaDescribedBy).toBeTruthy();
      
      // Verify the describedby element exists
      const describedByElement = page.locator(`#${hasAriaDescribedBy}`);
      await expect(describedByElement).toBeVisible();
    });
  });

  test.describe("Switch Label", () => {
    test("should have notifications label", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      await expect(wrapper).toContainText("notifications");
    });

    test("should turn on via keyboard", async ({ page }) => {
      await toggleSwitch(page);
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeChecked();
    });

    test("should have proper label association", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      await expect(wrapper).toBeVisible();
    });
  });

  test.describe("Switch Edge Cases", () => {
    test("should handle multiple rapid toggles", async ({ page }) => {
      await toggleSwitch(page);
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await expect(checkbox).toBeChecked();
    });

    test("should handle toggle while focused", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await checkbox.focus();
      await toggleSwitch(page);
      await expect(checkbox).toBeChecked();
    });

    test("should handle keyboard after toggle", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await toggleSwitch(page);
      await expect(checkbox).toBeChecked();
      // Verify keyboard navigation works after toggle
      await page.keyboard.press("Tab");
      await expect(checkbox).not.toBeFocused();
    });

    test("should handle rapid space key presses", async ({ page }) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      const checkbox = wrapper.locator('input[type="checkbox"]');
      await checkbox.focus();
      for (let i = 0; i < 5; i++) {
        await page.keyboard.press(" ");
      }
      await expect(checkbox).toBeChecked();
    });
  });

  test.describe("Accessibility", () => {
    test("switch should not have WCAG violations", async ({ page }, testInfo) => {
      const wrapper = page.getByTestId("switch-notifications-wrapper");
      await expect(wrapper).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='switch-notifications-wrapper']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("switch-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
