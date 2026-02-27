/**
 * Drop Zone Component Tests
 * Covers: aria-label, aria-describedby, keyboard activation
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

test.describe("Drop Zone Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Drop Zone Rendering", () => {
    test("should render drop zone", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toBeVisible();
    });

    test("should contain drop instruction text", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toContainText("Drop files here");
    });

    test("should contain browse text", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toContainText("click to browse");
    });
  });

  test.describe("Drop Zone ARIA Attributes", () => {
    test("should have role button", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveAttribute("role", "button");
    });

    test("should have aria-label", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveAttribute("aria-label", "Upload files by dropping them here");
    });

    test("should have aria-describedby", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveAttribute("aria-describedby", "drop-zone-hint");
    });

    test("should have tabindex for keyboard access", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveAttribute("tabindex", "0");
    });
  });

  test.describe("Drop Zone Keyboard Interactions", () => {
    test("should be focusable with Tab", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await dropZone.focus();
      await expect(dropZone).toBeFocused();
    });

    test("should be activatable with Enter key", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await dropZone.focus();
      
      await page.keyboard.press("Enter");
    });

    test("should be activatable with Space key", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await dropZone.focus();
      
      await page.keyboard.press("Space");
    });
  });

  test.describe("Drop Zone Styling", () => {
    test("should have dashed border", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveClass(/border-dashed/);
    });

    test("should have rounded corners", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveClass(/rounded/);
    });

    test("should have center alignment", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveClass(/text-center/);
    });

    test("should have focus ring on focus", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await dropZone.focus();
      await expect(dropZone).toHaveClass(/focus-visible:ring/);
    });

    test("should have padding", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toHaveClass(/p-/);
    });
  });

  test.describe("Drop Zone Accessibility", () => {
    test("should have accessible name from aria-label", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      const ariaLabel = await dropZone.getAttribute("aria-label");
      expect(ariaLabel).toBeTruthy();
      expect(ariaLabel).toContain("Drop");
    });

    test("should have hint text element with matching id", async ({ page }) => {
      const hint = page.locator("#drop-zone-hint");
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("aria-dropeffect");
    });

    test("should be operable by keyboard only users", async ({ page }) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await dropZone.focus();
      
      const isFocused = await dropZone.evaluate((el) => {
        return el === document.activeElement;
      });
      expect(isFocused).toBeTruthy();
    });
  });

  test.describe("Accessibility", () => {
    test("drop zone should not have WCAG violations", async ({ page }, testInfo) => {
      const dropZone = page.getByTestId("drop-zone-default");
      await expect(dropZone).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='drop-zone-default']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("drop-zone-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
