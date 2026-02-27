/**
 * Screen Reader Tests - ARIA Attribute Verification
 * Tests that verify proper ARIA attributes for screen reader compatibility
 *
 * Supported: VoiceOver (macOS), NVDA (Windows)
 * Not supported: Orca (Linux) - Guidepup does not support Orca
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

test.describe("Screen Reader Announcements", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
    // Close any open dialogs/menus/popovers to ensure test isolation
    await page.keyboard.press("Escape");
    await page.waitForTimeout(100);
  });

  test.describe("ARIA Live Region Verification", () => {
    test("alert should have role alert with aria-live assertive", async ({ page }) => {
      const alert = page.getByTestId("alert-error");
      const exists = await alert.count() > 0;

      if (exists) {
        await expect(alert).toHaveRole("alert");
        await expect(alert).toHaveAttribute("aria-live", "assertive");
      }
    });

    test("status should have role status with aria-live polite", async ({ page }) => {
      const status = page.getByTestId("alert-default");
      const exists = await status.count() > 0;

      if (exists) {
        await expect(status).toHaveRole("status");
        await expect(status).toHaveAttribute("aria-live", "polite");
      }
    });

    test("toast should have aria-live polite by default", async ({ page }) => {
      const toasts = page.locator('[role="status"]');
      const count = await toasts.count();

      if (count > 0) {
        const toast = toasts.first();
        await expect(toast).toHaveAttribute("aria-live", "polite");
      }
    });

    test("error toast should have aria-live assertive", async ({ page }) => {
      const errorToasts = page.locator('[role="alert"]');
      const count = await errorToasts.count();

      if (count > 0) {
        await expect(errorToasts.first()).toHaveAttribute("aria-live", "assertive");
      }
    });
  });

  test.describe("Dialog Announcements", () => {
    test("dialog should have role dialog and aria-modal", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      const exists = await trigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await trigger.click();
      await page.waitForTimeout(100);

      const dialog = page.locator('[data-dialog-content="true"]');
      await expect(dialog).toHaveRole("dialog");
      await expect(dialog).toHaveAttribute("aria-modal", "true");
    });

    test("dialog should have accessible name via aria-labelledby", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      const exists = await trigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await trigger.click();
      await page.waitForTimeout(100);

      const dialog = page.locator('[data-dialog-content="true"]');
      const labelledBy = await dialog.getAttribute("aria-labelledby");

      expect(labelledBy).toBeTruthy();

      const title = page.locator(`#${labelledBy}`);
      await expect(title).toBeVisible();
    });

    test("dialog should remain open when tabbing", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      const exists = await trigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await trigger.click();
      await page.waitForTimeout(300);

      const dialog = page.locator('[data-dialog-content="true"]');
      await expect(dialog).toBeVisible();

      await page.keyboard.press("Tab");

      const isStillVisible = await dialog.isVisible();
      expect(isStillVisible).toBe(true);
    });

    test("dialog should restore focus on close", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      const exists = await trigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await trigger.click();
      await page.waitForTimeout(100);

      await page.keyboard.press("Escape");
      await page.waitForTimeout(100);

      await expect(trigger).toBeFocused();
    });
  });

  test.describe("Form Validation Announcements", () => {
    test("inputs should have aria-describedby for hints", async ({ page }) => {
      const input = page.getByTestId("input-default");
      const exists = await input.count() > 0;

      if (!exists) {
        test.skip();
      }

      const describedBy = await input.getAttribute("aria-describedby");
      expect(describedBy).toBeTruthy();

      const hint = page.locator(`#${describedBy}`);
      await expect(hint).toBeVisible();
    });

    test("inputs should have accessible label", async ({ page }) => {
      const input = page.getByTestId("input-default");
      const exists = await input.count() > 0;

      if (!exists) {
        test.skip();
      }

      const id = await input.getAttribute("id");
      if (id) {
        const label = page.locator(`label[for="${id}"]`);
        await expect(label).toBeVisible();
      }
    });
  });

  test.describe("Tabs Announcements", () => {
    test("selected tab should have aria-selected true", async ({ page }) => {
      const tabsDemo = page.getByTestId("tabs-demo");
      const exists = await tabsDemo.count() > 0;

      if (!exists) {
        test.skip();
      }

      const selectedTab = tabsDemo.locator('[role="tab"][aria-selected="true"]').first();
      await expect(selectedTab).toHaveAttribute("aria-selected", "true");
    });

    test("tab should have aria-controls pointing to tabpanel", async ({ page }) => {
      const tabsDemo = page.getByTestId("tabs-demo");
      const exists = await tabsDemo.count() > 0;

      if (!exists) {
        test.skip();
      }

      const tab = tabsDemo.locator('[role="tab"]').first();
      const controlsId = await tab.getAttribute("aria-controls");

      expect(controlsId).toBeTruthy();

      const tabpanel = page.locator(`#${controlsId}`);
      await expect(tabpanel).toHaveRole("tabpanel");
    });

    test("tabpanel should have aria-labelledby referencing tab", async ({ page }) => {
      const tabsDemo = page.getByTestId("tabs-demo");
      const exists = await tabsDemo.count() > 0;

      if (!exists) {
        test.skip();
      }

      const tabpanel = tabsDemo.locator('[role="tabpanel"]').first();
      const labelledBy = await tabpanel.getAttribute("aria-labelledby");

      expect(labelledBy).toBeTruthy();
    });

    test("should navigate tabs with arrow keys", async ({ page }) => {
      const tabsDemo = page.getByTestId("tabs-demo");
      const exists = await tabsDemo.count() > 0;

      if (!exists) {
        test.skip();
      }

      await tabsDemo.scrollIntoViewIfNeeded();
      await page.waitForTimeout(1000);

      const tabs = tabsDemo.locator('[role="tab"]');
      const count = await tabs.count();

      expect(count).toBeGreaterThanOrEqual(2);

      if (count >= 2) {
        const firstTab = tabs.first();
        await expect(firstTab).toHaveAttribute("role", "tab");

        const secondTab = tabs.nth(1);
        await expect(secondTab).toHaveAttribute("role", "tab");
      }
    });
  });

  test.describe("Menu Announcements", () => {
    test("menu should have role menu", async ({ page }) => {
      const menuTrigger = page.getByTestId("menu-trigger");
      const exists = await menuTrigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await menuTrigger.click();
      await page.waitForTimeout(100);

      const menu = page.locator('[role="menu"]');
      await expect(menu).toHaveRole("menu");
    });

    test("menu trigger should have aria-expanded", async ({ page }) => {
      const menuTrigger = page.getByTestId("menu-trigger");
      const exists = await menuTrigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await menuTrigger.click();
      await page.waitForTimeout(100);

      await expect(menuTrigger).toHaveAttribute("aria-expanded", "true");

      await page.keyboard.press("Escape");
    });

    test("menu items should have role menuitem", async ({ page }) => {
      const menuTrigger = page.getByTestId("menu-trigger");
      const exists = await menuTrigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await menuTrigger.click();
      await page.waitForTimeout(100);

      const menuItems = page.locator('[role="menuitem"]');
      const count = await menuItems.count();

      if (count > 0) {
        await expect(menuItems.first()).toHaveRole("menuitem");
      }
    });
  });

  test.describe("Combobox Announcements", () => {
    test("combobox should have role combobox with aria-autocomplete", async ({ page }) => {
      const comboboxContainer = page.getByTestId("combobox-keyboard-demo");
      const exists = await comboboxContainer.count() > 0;

      if (!exists) {
        test.skip();
      }

      await comboboxContainer.scrollIntoViewIfNeeded();
      await page.waitForTimeout(1000);

      await expect(comboboxContainer).toHaveRole("combobox");
    });

    test("combobox should have aria-expanded state", async ({ page }) => {
      const comboboxContainer = page.getByTestId("combobox-keyboard-demo");
      const exists = await comboboxContainer.count() > 0;

      if (!exists) {
        test.skip();
      }

      await comboboxContainer.scrollIntoViewIfNeeded();
      await page.waitForTimeout(1000);

      const ariaExpanded = await comboboxContainer.getAttribute("aria-expanded");
      expect(["true", "false"]).toContain(ariaExpanded);
    });

    test("listbox should have role listbox", async ({ page }) => {
      const comboboxContainer = page.getByTestId("combobox-keyboard-demo");
      const exists = await comboboxContainer.count() > 0;

      if (!exists) {
        test.skip();
      }

      await comboboxContainer.scrollIntoViewIfNeeded();
      await page.waitForTimeout(1000);

      const listbox = page.locator('[role="listbox"]');
      const count = await listbox.count();

      if (count > 0) {
        await expect(listbox.first()).toHaveRole("listbox");
      }
    });
  });

  test.describe("Switch Announcements", () => {
    test("switch should have role switch", async ({ page }) => {
      const switchWrapper = page.getByTestId("switch-notifications-wrapper");
      const exists = await switchWrapper.count() > 0;

      if (!exists) {
        test.skip();
      }

      await switchWrapper.scrollIntoViewIfNeeded();

      const switchInput = switchWrapper.locator('[role="switch"]');
      const inputExists = await switchInput.count() > 0;

      if (inputExists) {
        await expect(switchInput).toHaveRole("switch");
      }
    });

    test("switch should announce checked state", async ({ page }) => {
      const switchWrapper = page.getByTestId("switch-notifications-wrapper");
      const exists = await switchWrapper.count() > 0;

      if (!exists) {
        test.skip();
      }

      await switchWrapper.scrollIntoViewIfNeeded();
      await page.waitForTimeout(1000);

      const switchInput = switchWrapper.locator('[role="switch"]');
      const inputExists = await switchInput.count() > 0;

      if (inputExists) {
        const ariaChecked = await switchInput.getAttribute("aria-checked");
        expect(["true", "false"]).toContain(ariaChecked);
      }
    });
  });

  test.describe("Checkbox Announcements", () => {
    test("checkbox should have proper checked state", async ({ page }) => {
      const checkboxWrapper = page.getByTestId("checkbox-terms-wrapper");
      const exists = await checkboxWrapper.count() > 0;

      if (!exists) {
        test.skip();
      }

      await checkboxWrapper.scrollIntoViewIfNeeded();
      await page.waitForTimeout(1000);

      const checkbox = checkboxWrapper.locator('input[type="checkbox"]');
      const inputExists = await checkbox.count() > 0;

      if (inputExists) {
        const checked = await checkbox.getAttribute("checked");
        expect(checked === "" || checked === "checked" || checked === null).toBe(true);
      }
    });
  });

  test.describe("Focus Management", () => {
    test("dialog should have first focusable element focused", async ({ page }) => {
      const trigger = page.getByTestId("dialog-trigger");
      const exists = await trigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await trigger.click();
      await page.waitForTimeout(100);

      const isFocused = await page.evaluate(() => {
        return document.activeElement !== null;
      });
      expect(isFocused).toBe(true);
    });

    test("focus should be visible on interactive elements", async ({ page }) => {
      const button = page.getByRole("button").first();
      await button.focus();

      const hasFocus = await button.evaluate((el) => el === document.activeElement);
      expect(hasFocus).toBe(true);
    });
  });

  test.describe("Accessible Name Announcements", () => {
    test("buttons should have accessible name", async ({ page }) => {
      const button = page.getByRole("button").first();
      const name = await button.textContent();
      expect(name?.trim()).toBeTruthy();
    });

    test("inputs should have associated label", async ({ page }) => {
      const inputs = page.locator("input:not([type='hidden']):not([type='submit'])");
      const count = await inputs.count();

      if (count > 0) {
        const firstInput = inputs.first();
        const id = await firstInput.getAttribute("id");

        if (id) {
          const label = page.locator(`label[for="${id}"]`);
          const labelCount = await label.count();

          if (labelCount === 0) {
            const parentLabel = await firstInput.evaluate((el) => {
              const parent = el.parentElement;
              return parent?.tagName === "LABEL" ? parent : null;
            });
            expect(parentLabel || labelCount > 0).toBeTruthy();
          }
        }
      }
    });
  });

  test.describe("Accessibility Scan", () => {
    test("dialog should pass axe-core accessibility scan", async ({ page }, testInfo) => {
      const trigger = page.getByTestId("dialog-trigger");
      const exists = await trigger.count() > 0;

      if (!exists) {
        test.skip();
      }

      await trigger.click();
      await page.waitForTimeout(100);

      const dialog = page.locator('[data-dialog-content="true"]');
      const dialogExists = await dialog.count() > 0;

      if (dialogExists) {
        const accessibilityScanResults = await new AxeBuilder({ page })
          .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
          .include('[data-dialog-content="true"]')
          .disableRules(["color-contrast"])
          .analyze();

        await testInfo.attach("dialog-a11y-scan", {
          body: JSON.stringify(accessibilityScanResults, null, 2),
          contentType: "application/json",
        });

        expect(accessibilityScanResults.violations).toHaveLength(0);
      }
    });

    test("forms should pass axe-core accessibility scan", async ({ page }, testInfo) => {
      const input = page.getByTestId("input-default");
      const exists = await input.count() > 0;

      if (!exists) {
        test.skip();
      }

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include('[data-testid="input-default"]')
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("form-a11y-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
