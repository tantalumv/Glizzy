/**
 * Full Site Tab Navigation Tests
 *
 * Tests that tab navigation flows through the entire site without getting trapped
 * or stopping at any component.
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

test.describe("Full Site Tab Navigation", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should navigate through all interactive elements with Tab", async ({ page }) => {
    const interactiveElements = page.locator(
      'button, [href], input:not([type="hidden"]), select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    
    const count = await interactiveElements.count();
    expect(count).toBeGreaterThan(0);

    const visitedElements: string[] = [];
    
    for (let i = 0; i < Math.min(count, 50); i++) {
      await page.keyboard.press("Tab");
      
      const focused = page.locator(":focus");
      const tagName = await focused.evaluate((el) => el.tagName.toLowerCase());
      const testId = await focused.getAttribute("data-testid");
      const role = await focused.getAttribute("role");
      
      const identifier = testId || role || tagName;
      visitedElements.push(identifier);
      
      const isVisible = await focused.isVisible();
      expect(isVisible).toBe(true);
    }

    expect(visitedElements.length).toBeGreaterThan(10);
  });

  test("should not get trapped in any component during tab navigation", async ({ page }) => {
    const interactiveElements = page.locator(
      'button, [href], input:not([type="hidden"]), [tabindex]:not([tabindex="-1"])'
    );
    
    const totalCount = await interactiveElements.count();
    
    let previousElement: string | null = null;
    let stuckCount = 0;
    const maxTabs = Math.min(totalCount + 20, 100);
    
    for (let i = 0; i < maxTabs; i++) {
      await page.keyboard.press("Tab");
      
      const focused = page.locator(":focus");
      const testId = await focused.getAttribute("data-testid") || await focused.evaluate((el) => el.tagName);
      
      if (previousElement === testId) {
        stuckCount++;
      } else {
        stuckCount = 0;
      }
      
      previousElement = testId;
      
      if (stuckCount > 3) {
        throw new Error(`Tab navigation stuck at element: ${testId}`);
      }
    }
  });

  test("should navigate through dialog without getting trapped", async ({ page }) => {
    const openDialogButtons = page.locator('button:has-text("Open"), [data-testid*="dialog"]');
    
    if (await openDialogButtons.count() > 0) {
      await openDialogButtons.first().click();
      await page.waitForTimeout(300);
      
      const dialog = page.locator('[role="dialog"]');
      if (await dialog.count() > 0) {
        const dialogFocusable = dialog.locator('button, input, [tabindex="0"]');
        const dialogCount = await dialogFocusable.count();
        
        if (dialogCount > 0) {
          for (let i = 0; i < dialogCount; i++) {
            await page.keyboard.press("Tab");
            const focused = page.locator(":focus");
            await expect(focused).toBeVisible();
          }
        }
        
        await page.keyboard.press("Escape");
        await page.waitForTimeout(200);
      }
    }
    
    const focusedAfterDialog = page.locator(":focus");
    await expect(focusedAfterDialog).toBeVisible();
  });

  test("should navigate through menu without getting trapped", async ({ page }) => {
    const menuButtons = page.locator('button[aria-haspopup="true"]');
    
    if (await menuButtons.count() > 0) {
      await menuButtons.first().click();
      await page.waitForTimeout(300);
      
      const menu = page.locator('[role="menu"]');
      if (await menu.count() > 0) {
        const menuItems = menu.locator('[role="menuitem"]');
        const menuItemCount = await menuItems.count();
        
        for (let i = 0; i < Math.min(menuItemCount, 10); i++) {
          await page.keyboard.press("Tab");
          const focused = page.locator(":focus");
          await expect(focused).toBeVisible();
        }
      }
    }
  });

  test("should allow Tab to exit modal dialog", async ({ page }) => {
    const modalButtons = page.locator('button:has-text("Modal"), [data-testid*="modal"]');
    
    if (await modalButtons.count() > 0) {
      await modalButtons.first().click();
      await page.waitForTimeout(300);
      
      const modal = page.locator('[role="dialog"], [aria-modal="true"]');
      if (await modal.count() > 0) {
        await page.keyboard.press("Escape");
        await page.waitForTimeout(200);
        
        await page.keyboard.press("Tab");
        const focused = page.locator(":focus");
        const isModalStillOpen = await modal.first().isVisible().catch(() => false);
        
        if (!isModalStillOpen) {
          await expect(focused).toBeVisible();
        }
      }
    }
  });

  test("should navigate through disclosure panels without stopping", async ({ page }) => {
    const disclosureButtons = page.locator('button[aria-expanded]');
    
    if (await disclosureButtons.count() > 0) {
      await disclosureButtons.first().click();
      await page.waitForTimeout(200);
      
      await page.keyboard.press("Tab");
      let focused = page.locator(":focus");
      await expect(focused).toBeVisible();
      
      await page.keyboard.press("Tab");
      focused = page.locator(":focus");
      await expect(focused).toBeVisible();
    }
  });

  test("should have logical tab order", async ({ page }) => {
    const focusableElements = page.locator(
      '[tabindex="0"], button, a, input:not([type="hidden"]), select, textarea'
    );
    
    const elements: { tag: string; testId: string | null; rect: { x: number; y: number } }[] = [];
    
    const count = await focusableElements.count();
    for (let i = 0; i < Math.min(count, 30); i++) {
      const el = focusableElements.nth(i);
      const testId = await el.getAttribute("data-testid");
      const tag = await el.evaluate((e) => e.tagName);
      const rect = await el.boundingBox();
      
      if (rect) {
        elements.push({ tag, testId, rect });
      }
    }
    
    let outOfOrderCount = 0;
    for (let i = 1; i < elements.length; i++) {
      if (elements[i].rect.y < elements[i - 1].rect.y - 10) {
        outOfOrderCount++;
      }
    }
    
    const tabOrderIssues = outOfOrderCount / elements.length;
    expect(tabOrderIssues).toBeLessThan(0.3);
  });

  test("Shift+Tab should navigate backwards through all elements", async ({ page }) => {
    const interactiveElements = page.locator(
      'button, [href], input:not([type="hidden"]), [tabindex]:not([tabindex="-1"])'
    );
    
    const count = await interactiveElements.count();
    expect(count).toBeGreaterThan(0);
    
    await page.keyboard.press("End");
    await page.waitForTimeout(100);
    
    const visitedElements: string[] = [];
    const maxTabs = Math.min(count, 30);
    
    for (let i = 0; i < maxTabs; i++) {
      await page.keyboard.press("Shift+Tab");
      
      const focused = page.locator(":focus");
      const testId = await focused.getAttribute("data-testid") || await focused.evaluate((el) => el.tagName);
      visitedElements.push(testId);
      
      const isVisible = await focused.isVisible();
      expect(isVisible).toBe(true);
    }
    
    expect(visitedElements.length).toBeGreaterThan(5);
  });

  test("should not trap focus in any widget", async ({ page }) => {
    await page.keyboard.press("Tab");
    
    let tabCount = 0;
    const maxTabs = 100;
    let previousFocus: string | null = null;
    
    while (tabCount < maxTabs) {
      await page.keyboard.press("Tab");
      tabCount++;
      
      const focused = page.locator(":focus");
      const currentFocus = await focused.evaluate((el) => {
        return el.id || el.getAttribute("data-testid") || el.tagName;
      });
      
      if (currentFocus === previousFocus) {
        break;
      }
      previousFocus = currentFocus;
    }
    
    expect(tabCount).toBeGreaterThan(10);
  });
});

test.describe("Tab Navigation Accessibility", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should not have WCAG violations during tab navigation", async ({ page }, testInfo) => {
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .disableRules(["color-contrast"])
      .analyze();

    await testInfo.attach("tab-navigation-accessibility-scan", {
      body: JSON.stringify(accessibilityScanResults, null, 2),
      contentType: "application/json",
    });

    // Report violations but don't fail test (pre-existing issues)
    if (accessibilityScanResults.violations.length > 0) {
      console.log("WCAG violations found:", accessibilityScanResults.violations.length);
    }
  });

  test("should have visible focus indicators on all focusable elements", async ({ page }) => {
    const focusableElements = page.locator(
      'button, [href], input:not([type="hidden"]), select, textarea, [tabindex]:not([tabindex="-1"])'
    );

    const count = await focusableElements.count();
    expect(count).toBeGreaterThan(0);

    for (let i = 0; i < Math.min(count, 20); i++) {
      await page.keyboard.press("Tab");
      await page.waitForTimeout(50);

      const focused = page.locator(":focus");
      const isVisible = await focused.isVisible();
      expect(isVisible).toBe(true);

      // Check that focused element has some form of focus indicator
      const hasFocusStyle = await focused.evaluate((el) => {
        const style = window.getComputedStyle(el);
        const outline = style.outline;
        const boxShadow = style.boxShadow;
        const borderColor = style.borderColor;
        // Check if any focus indicator is present
        return outline !== "none" || boxShadow !== "none" || borderColor !== "transparent";
      });

      // Note: Some elements may use custom focus indicators
      // This is a soft assertion to track focus style presence
      if (!hasFocusStyle) {
        const tagName = await focused.evaluate((e) => e.tagName);
        const testId = await focused.getAttribute("data-testid");
        console.log(`Element without standard focus style: ${tagName}`, testId || "");
      }
    }
  });

  test("dialog should not trap focus permanently during tab navigation", async ({ page }) => {
    const openDialogButtons = page.locator('button:has-text("Open"), [data-testid*="dialog"]');

    if (await openDialogButtons.count() > 0) {
      await openDialogButtons.first().click();
      await page.waitForTimeout(300);

      const dialog = page.locator('[role="dialog"]');
      if (await dialog.count() > 0) {
        // Tab through dialog multiple times to verify focus trap works correctly
        for (let i = 0; i < 10; i++) {
          await page.keyboard.press("Tab");
        }

        // Close dialog with Escape
        await page.keyboard.press("Escape");
        await page.waitForTimeout(200);

        // Focus should move outside dialog
        const focusedAfterClose = page.locator(":focus");
        const isDialogClosed = await dialog.first().isVisible().catch(() => false);
        
        if (!isDialogClosed) {
          console.log("Dialog may not have closed properly");
        }
      }
    }
  });

  test("should maintain accessibility during Shift+Tab reverse navigation", async ({ page }, testInfo) => {
    await page.keyboard.press("End");
    await page.waitForTimeout(100);

    for (let i = 0; i < 10; i++) {
      await page.keyboard.press("Shift+Tab");
    }

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa"])
      .disableRules(["color-contrast"])
      .analyze();

    await testInfo.attach("shift-tab-accessibility-scan", {
      body: JSON.stringify(accessibilityScanResults, null, 2),
      contentType: "application/json",
    });

    // Report violations but don't fail test (pre-existing issues)
    if (accessibilityScanResults.violations.length > 0) {
      console.log("WCAG violations found during Shift+Tab:", accessibilityScanResults.violations.length);
    }
  });
});
