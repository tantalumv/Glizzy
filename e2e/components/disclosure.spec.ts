/**
 * Disclosure Component Tests
 * Covers: aria-expanded, aria-controls, keyboard interactions
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

test.describe("Disclosure Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Disclosure Rendering", () => {
    test("should render disclosure wrapper", async ({ page }) => {
      const wrapper = page.getByTestId("disclosure-wrapper");
      await expect(wrapper).toBeVisible();
    });

    test("should render disclosure trigger button", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await expect(trigger).toBeVisible();
      await expect(trigger).toContainText("Toggle Details");
    });

    test("should have panel element with correct id", async ({ page }) => {
      const panel = page.getByTestId("disclosure-panel");
      await expect(panel).toHaveAttribute("id", "disclosure-panel");
    });
  });

  test.describe("Disclosure ARIA Attributes", () => {
    test("should have aria-controls pointing to panel", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await expect(trigger).toHaveAttribute("aria-controls", "disclosure-panel");
    });

    test("should have aria-expanded false by default", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await expect(trigger).toHaveAttribute("aria-expanded", "false");
    });

    test("should toggle aria-expanded to true when clicked", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await trigger.click();

      await expect(trigger).toHaveAttribute("aria-expanded", "true");
    });

    test("should toggle aria-expanded back to false on second click", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      
      await trigger.click();
      await expect(trigger).toHaveAttribute("aria-expanded", "true");
      
      await trigger.click();
      await expect(trigger).toHaveAttribute("aria-expanded", "false");
    });
  });

  test.describe("Disclosure Panel Visibility", () => {
    test("should hide panel content by default", async ({ page }) => {
      const panel = page.getByTestId("disclosure-panel");
      await expect(panel).toHaveClass(/hidden/);
    });

    test("should show panel when trigger is clicked", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await trigger.click();

      const panel = page.getByTestId("disclosure-panel");
      await expect(panel).not.toHaveClass(/hidden/);
      await expect(panel).toBeVisible();
    });

    test("should hide panel when trigger is clicked again", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      
      await trigger.click();
      const panel = page.getByTestId("disclosure-panel");
      await expect(panel).not.toHaveClass(/hidden/);
      
      await trigger.click();
      await expect(panel).toHaveClass(/hidden/);
    });
  });

  test.describe("Disclosure Keyboard Interactions", () => {
    test("should be focusable", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await trigger.focus();
      await expect(trigger).toBeFocused();
    });

    test("should have type button", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await expect(trigger).toHaveAttribute("type", "button");
    });

    test("should toggle with Space key", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await trigger.focus();
      
      await page.keyboard.press("Space");
      await expect(trigger).toHaveAttribute("aria-expanded", "true");
      
      await page.keyboard.press("Space");
      await expect(trigger).toHaveAttribute("aria-expanded", "false");
    });

    test("should toggle with Enter key", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await trigger.focus();
      
      await page.keyboard.press("Enter");
      await expect(trigger).toHaveAttribute("aria-expanded", "true");
    });
  });

  test.describe("Disclosure Styling", () => {
    test("trigger should have focus ring on focus", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await trigger.focus();
      await expect(trigger).toHaveClass(/focus-visible:ring/);
    });

    test("wrapper should have border styling", async ({ page }) => {
      const wrapper = page.getByTestId("disclosure-wrapper");
      await expect(wrapper).toHaveClass(/border/);
    });

    test("panel should have padding", async ({ page }) => {
      const trigger = page.getByTestId("disclosure-trigger");
      await trigger.click();
      
      const panel = page.getByTestId("disclosure-panel");
      await expect(panel).toHaveClass(/px-/);
    });
  });
});

test.describe("Disclosure Axe Scan", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("disclosure section has no axe violations", async ({ page }) => {
    const section = page.getByTestId("disclosure-section");
    await expect(section).toBeVisible();

    await page.addScriptTag({ content: axeSource });
    const results = await page.evaluate(async () => {
      // @ts-expect-error axe is injected by addScriptTag
      return await axe.run(document.querySelector("[data-testid='disclosure-section']"), {
        runOnly: { type: "tag", values: ["wcag2aa", "wcag2a"] },
      });
    });

    expect(results.violations).toHaveLength(0);
  });
});
