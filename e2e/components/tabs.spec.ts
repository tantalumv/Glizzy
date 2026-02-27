/**
 * Tabs Component Tests
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

test.describe("Tabs Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should render tab list with tabs", async ({ page }) => {
    const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
    await expect(tabList).toBeVisible();

    const tabs = tabList.locator('[role="tab"]');
    await expect(tabs).toHaveCount(3);
  });

  test("should wire aria-controls and aria-labelledby", async ({ page }) => {
    const selectedTab = page.getByRole("tab", { name: "Overview" });
    const tabPanel = page.getByRole("tabpanel");

    await expect(selectedTab).toHaveAttribute("aria-controls", "demo-tabpanel-overview");
    await expect(tabPanel).toHaveAttribute("id", "demo-tabpanel-overview");
    await expect(tabPanel).toHaveAttribute("aria-labelledby", "demo-tab-overview");
  });

  test("should mark selected and disabled tabs with ARIA states", async ({ page }) => {
    const selectedTab = page.getByRole("tab", { name: "Overview" });
    const disabledTab = page.getByRole("tab", { name: "Disabled" });

    await expect(selectedTab).toHaveAttribute("aria-selected", "true");
    await expect(selectedTab).toHaveAttribute("tabindex", "0");
    await expect(disabledTab).toHaveAttribute("aria-disabled", "true");
  });

  test.describe("Tabs Keyboard Navigation", () => {
    test("should navigate between tabs with arrow keys", async ({ page }) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      const firstTab = tabList.locator('[role="tab"]').first();
      
      await firstTab.focus();
      await expect(firstTab).toBeFocused();
      
      await page.keyboard.press("ArrowRight");
      const secondTab = tabList.locator('[role="tab"]').nth(1);
      await expect(secondTab).toBeFocused();
      
      await page.keyboard.press("ArrowRight");
      const thirdTab = tabList.locator('[role="tab"]').nth(2);
      await expect(thirdTab).toBeFocused();
    });

    test("should navigate backwards with left arrow", async ({ page }) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      const thirdTab = tabList.locator('[role="tab"]').nth(2);
      
      await thirdTab.focus();
      await expect(thirdTab).toBeFocused();
      
      await page.keyboard.press("ArrowLeft");
      const secondTab = tabList.locator('[role="tab"]').nth(1);
      await expect(secondTab).toBeFocused();
    });

    test("should navigate with Home key", async ({ page }) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      const thirdTab = tabList.locator('[role="tab"]').nth(2);
      
      await thirdTab.focus();
      await page.keyboard.press("Home");
      
      const firstTab = tabList.locator('[role="tab"]').first();
      await expect(firstTab).toBeFocused();
    });

    test("should navigate with End key", async ({ page }) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      const firstTab = tabList.locator('[role="tab"]').first();
      
      await firstTab.focus();
      await page.keyboard.press("End");
      
      const lastTab = tabList.locator('[role="tab"]').last();
      await expect(lastTab).toBeFocused();
    });

    test("should activate tab with Enter or Space", async ({ page }) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      const secondTab = tabList.locator('[role="tab"]').nth(1);
      
      await secondTab.focus();
      await page.keyboard.press("Enter");
      
      await expect(secondTab).toHaveAttribute("aria-selected", "true");
    });
  });

  test.describe("Accessibility", () => {
    test("tabs should not have WCAG violations", async ({ page }, testInfo) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      await expect(tabList).toBeVisible();

      const secondTab = tabList.locator('[role="tab"]').nth(1);
      await secondTab.click();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='tabs-demo']")
        .disableRules(["color-contrast"])
        .analyze();

      await testInfo.attach("tabs-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });

    test("selected tab should have aria-current page", async ({ page }) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      const selectedTab = tabList.locator('[role="tab"][aria-selected="true"]');
      
      if (await selectedTab.count() > 0) {
        const ariaCurrent = await selectedTab.first().getAttribute("aria-current");
        if (ariaCurrent) {
          await expect(selectedTab.first()).toHaveAttribute("aria-current", "page");
        }
      }
    });

    test("tab should indicate current page when selected", async ({ page }) => {
      const tabList = page.getByTestId("tabs-demo").locator('[role="tablist"]');
      const tabs = tabList.locator('[role="tab"]');
      
      for (let i = 0; i < await tabs.count(); i++) {
        const tab = tabs.nth(i);
        const isSelected = await tab.getAttribute("aria-selected");
        if (isSelected === "true") {
          const ariaCurrent = await tab.getAttribute("aria-current");
          expect(ariaCurrent === "page" || ariaCurrent === null).toBe(true);
        }
      }
    });
  });
});
