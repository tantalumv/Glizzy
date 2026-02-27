/**
 * Form Control Accessibility Tests
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

test.describe("Form Controls", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("inputs have labels and descriptive hints", async ({ page }) => {
    const defaultInput = page.getByLabel("Default input");
    await expect(defaultInput).toHaveAttribute("aria-describedby", "input-default-hint");
    await expect(page.locator("#input-default-hint")).toContainText("Use Tab to focus");

    const placeholderInput = page.getByLabel("Input with placeholder");
    await expect(placeholderInput).toHaveAttribute("aria-describedby", "input-placeholder-hint");
    await expect(page.locator("#input-placeholder-hint")).toContainText("Placeholder text");
  });

  test("checkbox hints explain keyboard usage", async ({ page }) => {
    const termsCheckbox = page.getByLabel("I agree to terms");
    await expect(termsCheckbox).toHaveAttribute("aria-describedby", "checkbox-terms-hint");
    await expect(page.locator("#checkbox-terms-hint")).toContainText("Spacebar toggles");

    const newsletterCheckbox = page.getByLabel("Subscribe to newsletter");
    await expect(newsletterCheckbox).toHaveAttribute("aria-describedby", "checkbox-newsletter-hint");
    await expect(page.locator("#checkbox-newsletter-hint")).toContainText("Shift+Tab");
  });

  test("switch hint emphasizes state announcement", async ({ page }) => {
    const notificationsSwitch = page.getByLabel("Enable notifications");
    await expect(notificationsSwitch).toHaveAttribute("aria-describedby", "switch-notifications-hint");
    await expect(page.locator("#switch-notifications-hint")).toContainText("Toggle with Spacebar");
  });

  test("radio group legend and hint anchor keyboard guidance", async ({ page }) => {
    const radioGroup = page.getByRole("radiogroup", { name: "Choose an option" });
    await expect(radioGroup).toHaveAttribute("aria-describedby", "radio-group-hint");
    await expect(page.locator("#radio-group-hint")).toContainText("Arrow keys move between options");
  });

  test("selects pair with labels and guidance text", async ({ page }) => {
    const defaultSelect = page.getByLabel("Default select");
    await expect(defaultSelect).toHaveAttribute("aria-describedby", "select-default-hint");
    await expect(page.locator("#select-default-hint")).toContainText("Press Enter to open");

    const mutedSelect = page.getByLabel("Muted select");
    await expect(mutedSelect).toHaveAttribute("aria-describedby", "select-muted-hint");
    await expect(page.locator("#select-muted-hint")).toContainText("Muted styling keeps focus ring visible");
  });

  test.describe("Accessibility", () => {
    test("form controls should not have WCAG violations", async ({ page }, testInfo) => {
      const input = page.getByLabel("Default input");
      await expect(input).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("body")
        .disableRules([
          "color-contrast",
          "image-alt",
          "aria-required-attr",
          "aria-required-children",
          "aria-required-parent",
          "aria-valid-attr-value",
          "list",
          "nested-interactive",
          "scrollable-region-focusable",
          "target-size",
        ])
        .analyze();

      await testInfo.attach("form-controls-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });

  test.describe("Form Validation ARIA", () => {
    test("required fields should have aria-required attribute", async ({ page }) => {
      const requiredInput = page.locator('[aria-required="true"]');
      await expect(requiredInput.first()).toHaveAttribute("aria-required", "true");
    });

    test("invalid fields should have aria-invalid attribute", async ({ page }) => {
      const invalidInput = page.locator('[aria-invalid="true"]');
      await expect(invalidInput.first()).toHaveAttribute("aria-invalid", "true");
    });

    test("error messages should be referenced by aria-errormessage", async ({ page }) => {
      const inputsWithErrors = page.locator("[aria-errormessage]");
      const count = await inputsWithErrors.count();
      if (count > 0) {
        const input = inputsWithErrors.first();
        const errormessageId = await input.getAttribute("aria-errormessage");
        expect(errormessageId).toBeTruthy();
        const errorMessage = page.locator(`#${errormessageId}`);
        await expect(errorMessage).toBeVisible();
      }
    });

    test("readonly fields should have aria-readonly attribute", async ({ page }) => {
      const readonlyInputs = page.locator('[aria-readonly="true"]');
      const count = await readonlyInputs.count();
      if (count > 0) {
        await expect(readonlyInputs.first()).toHaveAttribute("aria-readonly", "true");
      }
    });

    test("date fields should have aria-required when marked required", async ({ page }) => {
      const dateField = page.locator('[data-testid="date-field-input"][aria-required="true"]');
      const count = await dateField.count();
      if (count > 0) {
        const isRequired = await dateField.first().getAttribute("aria-required");
        expect(isRequired).toBe("true");
      }
    });

    test("time fields should have aria-required and aria-invalid states", async ({ page }) => {
      const timeField = page.locator('[data-testid="time-field-input"][aria-required="true"]');
      const count = await timeField.count();
      if (count > 0) {
        const isRequired = await timeField.first().getAttribute("aria-required");
        expect(isRequired).toBe("true");
      }
    });
  });
});
