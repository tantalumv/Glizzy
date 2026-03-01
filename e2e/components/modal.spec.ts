/**
 * Modal Component Tests
 * Covers: focus trap, aria-modal, aria-describedby, aria-labelledby
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Modal Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Modal Rendering", () => {
    test("should render modal trigger button", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await expect(trigger).toBeVisible();
      await expect(trigger).toContainText("Open Modal");
    });

    test("should not show modal content by default", async ({ page }) => {
      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).not.toBeVisible();
    });

    test("should show modal when trigger is clicked", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toBeVisible();
    });

    test("should have underlay element when modal opens", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toBeVisible();

      const underlay = page.getByTestId("modal-underlay");
      const underlayCount = await underlay.count();
      expect(underlayCount).toBeGreaterThan(0);
    });
  });

  test.describe("Modal ARIA Attributes", () => {
    test("should have role dialog", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toHaveAttribute("role", "dialog");
    });

    test("should have aria-modal true", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toHaveAttribute("aria-modal", "true");
    });

    test("should have aria-labelledby pointing to title", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toHaveAttribute("aria-labelledby", "modal-title");
    });

    test("should have aria-describedby pointing to description", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toHaveAttribute("aria-describedby", "modal-description");
    });

    test("should have title element with matching id", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const title = page.locator("#modal-title");
      await expect(title).toBeVisible();
      await expect(title).toContainText("Modal Title");
    });

    test("should have description element with matching id", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const description = page.locator("#modal-description");
      await expect(description).toBeVisible();
    });
  });

  test.describe("Modal Interactions", () => {
    test("should close modal when close button is clicked", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toBeVisible();

      const closeButton = page.getByTestId("modal-close");
      await closeButton.click();

      await expect(modalWrapper).not.toBeVisible();
    });

    test("should close modal when underlay is clicked", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toBeVisible();

      const underlay = page.getByTestId("modal-underlay");
      await underlay.dispatchEvent("click");

      await expect(modalWrapper).not.toBeVisible();
    });

    test("should close modal when Escape key is pressed", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toBeVisible();
      
      // Focus the close button to ensure focus is in modal
      const closeButton = page.getByTestId("modal-close");
      await closeButton.focus();

      await page.keyboard.press("Escape");
      await page.waitForTimeout(100);
      await expect(modalWrapper).not.toBeVisible();
    });
  });

  test.describe("Modal Focus Management", () => {
    test("should have close button as focusable", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).not.toHaveClass(/hidden/);

      const closeButton = page.getByTestId("modal-close");
      await closeButton.focus();
      await expect(closeButton).toBeFocused();
    });

    test("should close modal and allow re-opening", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toBeVisible();

      const closeButton = page.getByTestId("modal-close");
      await closeButton.click();

      await expect(modalWrapper).not.toBeVisible();

      await trigger.click();
      await expect(modalWrapper).toBeVisible();
    });
  });

  test.describe("Modal Styling", () => {
    test("should have fixed positioning", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toHaveClass(/fixed/);
    });

    test("should have high z-index", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalWrapper = page.getByTestId("modal-wrapper");
      await expect(modalWrapper).toHaveClass(/z-50/);
    });

    test("should have rounded corners on content", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalContent = page.getByTestId("modal-content");
      await expect(modalContent).toHaveClass(/rounded/);
    });

    test("should have shadow on content", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalContent = page.getByTestId("modal-content");
      await expect(modalContent).toHaveClass(/shadow/);
    });

    test("should have data-state attribute when open", async ({ page }) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalContent = page.getByTestId("modal-content");
      await expect(modalContent).toHaveAttribute("data-state", "open");
    });
  });

  test.describe("Accessibility", () => {
    test("modal should not have WCAG violations when open", async ({ page }, testInfo) => {
      const trigger = page.getByTestId("modal-trigger");
      await trigger.click();

      const modalContent = page.getByTestId("modal-content");
      await expect(modalContent).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='modal-content']")
        .analyze();

      await testInfo.attach("modal-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
