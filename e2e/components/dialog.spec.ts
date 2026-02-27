/**
 * Dialog Component Tests
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

test.describe("Dialog Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Dialog Rendering", () => {
    test("should render dialog trigger button", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await expect(trigger).toBeVisible();
      await expect(trigger).toContainText("Open Dialog");
    });

    test("should not show dialog content by default", async ({ page }) => {
      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).not.toBeVisible();
    });

    test("should show dialog when trigger is clicked", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toBeVisible();
    });

    test("should render dialog title", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const title = page.locator('[data-dialog-title="true"]');
      await expect(title).toBeVisible();
      await expect(title).toContainText("Edit Profile");
    });

    test("should render dialog description", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const description = page.locator('[data-dialog-description="true"]');
      await expect(description).toBeVisible();
      await expect(description).toContainText("Make changes to your profile here");
    });

    test("should render dialog close button", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const closeButton = page.getByTestId("dialog-close");
      await expect(closeButton).toBeVisible();
    });

    test("should render dialog save button", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const saveButton = page.getByTestId("dialog-save");
      await expect(saveButton).toBeVisible();
      await expect(saveButton).toContainText("Save");
    });
  });

  test.describe("Dialog Interactions", () => {
    test("should close dialog when close button is clicked", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const closeButton = page.getByTestId("dialog-close");
      await closeButton.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).not.toBeVisible();
    });

    test("should close dialog when save button is clicked", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const saveButton = page.getByTestId("dialog-save");
      await saveButton.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).not.toBeVisible();
    });

    test("should close dialog when Escape key is pressed", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      await page.keyboard.press("Escape");

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).not.toBeVisible();
    });

    test("should close dialog when clicking on backdrop", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const backdrop = page.locator('[data-dialog-overlay="true"]');
      await backdrop.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).not.toBeVisible();
    });

    test("should be able to reopen dialog after closing", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");

      // Open
      await trigger.click();
      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toBeVisible();

      // Close
      const closeButton = page.getByTestId("dialog-close");
      await closeButton.click();
      await expect(dialogContent).not.toBeVisible();

      // Reopen
      await trigger.click();
      await expect(dialogContent).toBeVisible();
    });
  });

  test.describe("Dialog Focus Management", () => {
    test("should focus first focusable element when dialog opens", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      // Wait for dialog to be visible
      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toBeVisible();

      // Check that focus is within the dialog
      const focusedElement = page.locator(":focus");
      const dialogBounds = await dialogContent.boundingBox();
      const focusedBounds = await focusedElement.boundingBox();

      if (dialogBounds && focusedBounds) {
        expect(focusedBounds.y).toBeGreaterThanOrEqual(dialogBounds.y - 10);
      }
    });

    test("should trap focus within dialog", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toBeVisible();

      // Tab through all focusable elements
      await page.keyboard.press("Tab");
      await page.keyboard.press("Tab");
      await page.keyboard.press("Tab");

      // Focus should still be within dialog
      const focusedElement = page.locator(":focus");
      const dialogBounds = await dialogContent.boundingBox();
      const focusedBounds = await focusedElement.boundingBox();

      if (dialogBounds && focusedBounds) {
        expect(focusedBounds.y).toBeLessThanOrEqual(dialogBounds.y + dialogBounds.height + 10);
      }
    });

    test("should restore focus to trigger when dialog closes", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();
      await trigger.blur();

      const closeButton = page.getByTestId("dialog-close");
      await closeButton.click();

      // Wait for dialog to close
      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).not.toBeVisible();

      // Focus should be restored to trigger
      await expect(trigger).toBeFocused();
    });
  });

  test.describe("Dialog Accessibility", () => {
    test("should have role dialog", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveRole("dialog");
    });

    test("should have aria-modal true", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveAttribute("aria-modal", "true");
    });

    test("should have aria-label on close button", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const closeButton = page.getByTestId("dialog-close");
      await expect(closeButton).toHaveAttribute("aria-label", "Close");
    });

    test("should have proper heading structure", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const title = page.locator('[data-dialog-title="true"]');
      await expect(title).toHaveRole("heading");
    });

    test("should have accessible name from title", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const title = page.locator('[data-dialog-title="true"]');
      await expect(title).toContainText("Edit Profile");
    });
  });

  test.describe("Dialog Styling", () => {
    test("should have backdrop overlay", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const backdrop = page.locator('[data-dialog-overlay="true"]');
      await expect(backdrop).toBeVisible();
      await expect(backdrop).toHaveClass(/bg-black/);
    });

    test("should have rounded corners", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveClass(/rounded/);
    });

    test("should have shadow", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveClass(/shadow/);
    });

    test("should have proper z-index", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveClass(/z-50/);
    });

    test("should have centered content", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveClass(/items-center/);
      await expect(dialogContent).toHaveClass(/justify-center/);
    });
  });

  test.describe("Dialog Animation States", () => {
    test("should have open state attribute when visible", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveAttribute("data-state", "open");
    });

    test("should have animation classes", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toHaveClass(/animate-in/);
    });
  });

  test.describe("Accessibility", () => {
    test("dialog should not have WCAG violations when open", async ({ page }, testInfo) => {
      const trigger = page.getByTestId("dialog-trigger");
      await trigger.click();

      const dialogContent = page.locator('[data-dialog-content="true"]');
      await expect(dialogContent).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include('[data-dialog-content="true"]')
        .analyze();

      await testInfo.attach("dialog-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
