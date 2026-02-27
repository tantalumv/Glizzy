/**
 * Pickers & Color Controls Accessibility
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

test.describe("Pickers & Calendar", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("date and time fields expose descriptive hints and defaults", async ({ page }) => {
    const dateField = page.getByTestId("date-field-input");
    await expect(dateField).toHaveAttribute("aria-describedby", "date-field-hint");

    const timeField = page.getByTestId("time-field-input");
    await expect(timeField).toHaveAttribute("aria-describedby", "time-field-hint");
    await expect(timeField).toHaveValue("14:30:00");
  });

  test("date picker and range picker describe their overlays", async ({ page }) => {
    const datePicker = page.getByTestId("date-picker-input");
    await expect(datePicker).toHaveAttribute("aria-describedby", "date-picker-hint");

    const rangeButton = page.getByLabel("Choose date range");
    await expect(rangeButton).toHaveAttribute("data-date-range-picker-trigger", "true");
  });

  test("color controls include roles, descriptions, and axe compliance", async ({ page }) => {
    const slider = page.getByTestId("color-slider");
    await expect(slider).toHaveAttribute("role", "slider");

    const colorArea = page.getByTestId("color-area");
    await expect(colorArea).toHaveAttribute("aria-label", "Color area");

    await page.addScriptTag({ content: axeSource });
    const results = await page.evaluate(async () => {
      return await axe.run(document.querySelector("[data-testid='color-controls-section']"), {
        runOnly: { type: "tag", values: ["wcag2aa", "wcag2a"] },
      });
    });

    expect(results.violations).toHaveLength(0);
  });
});
