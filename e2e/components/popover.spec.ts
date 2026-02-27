/**
 * Popover Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const axeSource = readFileSync(resolve("node_modules/axe-core/axe.min.js"), "utf8");

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Popover Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should render popover content with dialog semantics", async ({ page }) => {
    // Popover starts closed, click trigger to open
    const trigger = page.getByTestId("popover-trigger");
    await trigger.click();
    
    const content = page.getByTestId("popover-content");
    await expect(content).toBeVisible();
    await expect(content).toHaveAttribute("role", "dialog");
    await expect(content).toHaveAttribute("aria-label", "Popover details");
    await expect(content).toHaveAttribute("data-popover-content", "true");
    await expect(content).toHaveAttribute("tabindex", "-1");
    await expect(content).toHaveAttribute("data-placement", "bottom");
  });

  test("should wire trigger ARIA attributes", async ({ page }) => {
    // Initially closed
    const trigger = page.getByTestId("popover-trigger");
    await expect(trigger).toHaveAttribute("aria-haspopup", "dialog");
    await expect(trigger).toHaveAttribute("aria-expanded", "false");
    await expect(trigger).toHaveAttribute("aria-controls", "demo-popover");
    
    // After opening
    await trigger.click();
    await expect(trigger).toHaveAttribute("aria-expanded", "true");
  });

  test("should render popover arrow", async ({ page }) => {
    // Open popover first
    await page.getByTestId("popover-trigger").click();
    
    const arrow = page.locator("[data-popover-arrow='true']");
    await expect(arrow).toBeVisible();
  });
});

test.describe("Popover Axe Scan", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("popover section has no axe violations", async ({ page }) => {
    const section = page.getByTestId("popover-section");
    await expect(section).toBeVisible();

    await page.addScriptTag({ content: axeSource });
    const results = await page.evaluate(async () => {
      // @ts-expect-error axe is injected by addScriptTag
      return await axe.run(document.querySelector("[data-testid='popover-section']"), {
        runOnly: { type: "tag", values: ["wcag2aa", "wcag2a"] },
      });
    });

    expect(results.violations).toHaveLength(0);
  });
});
