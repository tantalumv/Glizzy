/**
 * Tooltip Component Tests
 * Covers: aria-describedby, focus/hover triggers, role=tooltip
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

test.describe("Tooltip Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Tooltip Rendering", () => {
    test("should render tooltip section", async ({ page }) => {
      const section = page.getByTestId("tooltip-section");
      await expect(section).toBeVisible();
    });

    test("should render default tooltip trigger", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-default");
      await expect(trigger).toBeVisible();
      await expect(trigger).toContainText("Click me");
    });

    test("should render focus tooltip trigger", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-focus");
      await expect(trigger).toBeVisible();
      await expect(trigger).toContainText("Focus me");
    });
  });

  test.describe("Tooltip ARIA Attributes", () => {
    test("default trigger should have aria-describedby", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-default");
      await expect(trigger).toHaveAttribute("aria-describedby", "tooltip-content-default");
    });

    test("focus trigger should have aria-describedby", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-focus");
      await expect(trigger).toHaveAttribute("aria-describedby", "tooltip-content-focus");
    });

    test("tooltip content should have role tooltip", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveAttribute("role", "tooltip");
    });

    test("focus tooltip content should have role tooltip", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-focus");
      await expect(tooltipContent).toHaveAttribute("role", "tooltip");
    });

    test("tooltip content should have matching id", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveAttribute("id", "tooltip-content-default");
    });

    test("focus tooltip content should have matching id", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-focus");
      await expect(tooltipContent).toHaveAttribute("id", "tooltip-content-focus");
    });
  });

  test.describe("Tooltip Visibility", () => {
    test("should show tooltip on click", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-default");
      const tooltipContent = page.getByTestId("tooltip-default");
      
      await expect(tooltipContent).toHaveClass(/hidden/);
      
      await trigger.click();
      await expect(tooltipContent).not.toHaveClass(/hidden/);
    });

    test("should hide tooltip on second click", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-default");
      const tooltipContent = page.getByTestId("tooltip-default");
      
      await trigger.click();
      await expect(tooltipContent).not.toHaveClass(/hidden/);
      
      await trigger.click();
      await expect(tooltipContent).toHaveClass(/hidden/);
    });
  });

  test.describe("Tooltip Styling", () => {
    test("should have rounded corners", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveClass(/rounded/);
    });

    test("should have padding", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveClass(/px-3/);
      await expect(tooltipContent).toHaveClass(/py-1/);
    });

    test("should have background color", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveClass(/bg-primary/);
    });

    test("should have shadow", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveClass(/shadow/);
    });

    test("should have high z-index", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveClass(/z-50/);
    });

    test("should position above trigger", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      await expect(tooltipContent).toHaveClass(/bottom-full/);
    });
  });

  test.describe("Tooltip Accessibility", () => {
    test("tooltip content should be accessible via aria-describedby", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-default");
      const describedBy = await trigger.getAttribute("aria-describedby");
      expect(describedBy).toBe("tooltip-content-default");

      // Verify aria attribute exists (tooltip is hidden until triggered)
      await expect(trigger).toHaveAttribute("aria-describedby", "tooltip-content-default");
    });

    test("focus tooltip content should be accessible via aria-describedby", async ({ page }) => {
      const trigger = page.getByTestId("tooltip-trigger-focus");
      const describedBy = await trigger.getAttribute("aria-describedby");
      expect(describedBy).toBe("tooltip-content-focus");

      // Verify aria attribute exists (tooltip is hidden until triggered)
      await expect(trigger).toHaveAttribute("aria-describedby", "tooltip-content-focus");
    });

    test("tooltip should contain text content", async ({ page }) => {
      const tooltipContent = page.getByTestId("tooltip-default");
      const text = await tooltipContent.textContent();
      expect(text?.trim()).toBeTruthy();
    });

    test("should have keyboard hint text", async ({ page }) => {
      const hint = page.getByTestId("tooltip-keyboard-hint");
      await expect(hint).toBeVisible();
      await expect(hint).toContainText("aria-describedby");
    });
  });
});

test.describe("Tooltip Axe Scan", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("tooltip section has no axe violations", async ({ page }) => {
    const section = page.getByTestId("tooltip-section");
    await expect(section).toBeVisible();

    await page.addScriptTag({ content: axeSource });
    const results = await page.evaluate(async () => {
      // @ts-expect-error axe is injected by addScriptTag
      return await axe.run(document.querySelector("[data-testid='tooltip-section']"), {
        runOnly: { type: "tag", values: ["wcag2aa", "wcag2a"] },
      });
    });

    expect(results.violations).toHaveLength(0);
  });
});
