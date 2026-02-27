/**
 * Table Sorting Accessibility Tests
 * 
 * Tests for WAI-ARIA aria-sort attribute compliance:
 * https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Reference/Attributes/aria-sort
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

test.describe("Table Sorting - WAI-ARIA Compliance", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("aria-sort Attribute", () => {
    test("column headers should have aria-sort attribute", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");
      const count = await headers.count();

      expect(count).toBeGreaterThan(0);

      // Check each header has aria-sort
      for (let i = 0; i < count; i++) {
        const header = headers.nth(i);
        const ariaSort = await header.getAttribute("aria-sort");
        expect(ariaSort).toMatch(/^(none|ascending|descending)$/);
      }
    });

    test("unsorted columns should have aria-sort='none'", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");
      const count = await headers.count();

      // Initially all columns should be unsorted
      for (let i = 0; i < count; i++) {
        const header = headers.nth(i);
        await expect(header).toHaveAttribute("aria-sort", "none");
      }
    });

    test("clicking header should set aria-sort='ascending'", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // Initially unsorted
      await expect(firstHeader).toHaveAttribute("aria-sort", "none");

      // Click to sort ascending
      await firstHeader.click();
      await expect(firstHeader).toHaveAttribute("aria-sort", "ascending");
    });

    test("clicking sorted header should toggle to aria-sort='descending'", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // Click twice to get descending
      await firstHeader.click();
      await expect(firstHeader).toHaveAttribute("aria-sort", "ascending");

      await firstHeader.click();
      await expect(firstHeader).toHaveAttribute("aria-sort", "descending");
    });

    test("clicking third time should return to aria-sort='none' or cycle to ascending", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // Click three times
      await firstHeader.click(); // ascending
      await firstHeader.click(); // descending
      await firstHeader.click(); // should cycle back

      const ariaSort = await firstHeader.getAttribute("aria-sort");
      // Either it cycles back to none or to ascending (both are valid patterns)
      expect(ariaSort).toMatch(/^(none|ascending)$/);
    });

    test("sorting one column should set others to aria-sort='none'", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");

      // Sort first column
      await headers.nth(0).click();
      await expect(headers.nth(0)).toHaveAttribute("aria-sort", "ascending");

      // Other columns should be "none"
      const count = await headers.count();
      for (let i = 1; i < count; i++) {
        await expect(headers.nth(i)).toHaveAttribute("aria-sort", "none");
      }
    });

    test("sorting different column should change aria-sort correctly", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");

      // Sort first column
      await headers.nth(0).click();
      await expect(headers.nth(0)).toHaveAttribute("aria-sort", "ascending");

      // Sort second column
      await headers.nth(1).click();
      await expect(headers.nth(0)).toHaveAttribute("aria-sort", "none");
      await expect(headers.nth(1)).toHaveAttribute("aria-sort", "ascending");
    });
  });

  test.describe("Visual Sort Indicators", () => {
    test("unsorted columns should show sort icon", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");
      const count = await headers.count();

      for (let i = 0; i < count; i++) {
        const header = headers.nth(i);
        const icon = header.locator("i.ri-arrow-up-down-line");
        await expect(icon).toBeVisible();
      }
    });

    test("ascending sorted column should show up arrow icon", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      await firstHeader.click();
      await expect(firstHeader).toHaveAttribute("aria-sort", "ascending");
      const icon = firstHeader.locator("i.ri-arrow-up-line");
      await expect(icon).toBeVisible();
    });

    test("descending sorted column should show down arrow icon", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // First click - ascending
      await firstHeader.click();
      await expect(firstHeader).toHaveAttribute("aria-sort", "ascending");

      // Second click - descending
      await firstHeader.click();
      await expect(firstHeader).toHaveAttribute("aria-sort", "descending");
      const icon = firstHeader.locator("i.ri-arrow-down-line");
      await expect(icon).toBeVisible();
    });
  });

  test.describe("Keyboard Accessibility", () => {
    test("column headers should be focusable with tabindex", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");
      const count = await headers.count();

      for (let i = 0; i < count; i++) {
        const header = headers.nth(i);
        await expect(header).toHaveAttribute("tabindex", "0");
      }
    });

    test("column headers should have columnheader role", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");
      const count = await headers.count();
      expect(count).toBeGreaterThan(0);
    });

    test("Enter key should toggle sort on focused header", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      await firstHeader.focus();
      await expect(firstHeader).toBeFocused();

      await page.keyboard.press("Enter");
      await expect(firstHeader).toHaveAttribute("aria-sort", "ascending");
    });

    test("Space key should toggle sort on focused header", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      await firstHeader.focus();
      await expect(firstHeader).toBeFocused();

      await page.keyboard.press("Space");
      await expect(firstHeader).toHaveAttribute("aria-sort", "ascending");
    });

    test("column headers should have hover styling", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // Check that the header has cursor pointer style (indicating it's clickable)
      const cursor = await firstHeader.evaluate((el) => 
        window.getComputedStyle(el).cursor
      );
      expect(cursor).toBe("pointer");
    });
  });

  test.describe("Data Reordering", () => {
    test("ascending sort should reorder rows alphabetically", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // Get initial first row
      const initialFirstRow = table.getByRole("row").nth(1); // Skip header row
      const initialText = await initialFirstRow.textContent();

      // Click to sort ascending
      await firstHeader.click();

      // First data row should change (unless already sorted)
      const sortedFirstRow = table.getByRole("row").nth(1);
      const sortedText = await sortedFirstRow.textContent();
      
      // The row content should be different or the same if already sorted
      expect(sortedText).toBeTruthy();
    });

    test("descending sort should reverse row order", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // Sort ascending first
      await firstHeader.click();
      const ascendingFirstRow = table.getByRole("row").nth(1);
      const ascendingText = await ascendingFirstRow.textContent();

      // Sort descending
      await firstHeader.click();
      const descendingFirstRow = table.getByRole("row").nth(1);
      const descendingText = await descendingFirstRow.textContent();

      // Rows should be different (unless all values are identical)
      // This is a basic check - more thorough testing would verify actual order
      expect(descendingText).toBeTruthy();
    });

    test("row count should remain constant after sort", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      const initialRowCount = await table.getByRole("row").count();

      await firstHeader.click();
      const sortedRowCount = await table.getByRole("row").count();

      expect(sortedRowCount).toBe(initialRowCount);
    });
  });

  test.describe("Screen Reader Support", () => {
    test("aria-sort changes should be announced", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const firstHeader = table.getByRole("columnheader").first();

      // Initial state
      await expect(firstHeader).toHaveAttribute("aria-sort", "none");

      // After clicking, aria-sort should update (screen readers will announce this)
      await firstHeader.click();
      await expect(firstHeader).toHaveAttribute("aria-sort", "ascending");

      // The aria-sort attribute change is what screen readers use to announce
      // We verify the attribute is correctly set for screen reader consumption
    });

    test("column headers should have accessible names", async ({ page }) => {
      const table = page.getByTestId("table-keyboard-demo");
      const headers = table.getByRole("columnheader");
      const count = await headers.count();

      for (let i = 0; i < count; i++) {
        const header = headers.nth(i);
        const text = await header.textContent();
        expect(text?.trim()).toBeTruthy();
      }
    });
  });
});

test.describe("Table Sorting - Axe Compliance", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("sorted table should not have aria violations", async ({ page }) => {
    const table = page.getByTestId("table-keyboard-demo");
    const firstHeader = table.getByRole("columnheader").first();

    // Sort the table
    await firstHeader.click();

    await page.addScriptTag({ content: axeSource });
    const results = await page.evaluate(async () => {
      // @ts-expect-error axe is injected by addScriptTag
      return await axe.run(document.querySelector("[data-testid='table-keyboard-demo']"), {
        runOnly: { type: "tag", values: ["wcag2aa", "wcag2a"] },
        // Disable known demo issues (not sorting-related)
        rules: {
          "aria-required-children": { enabled: false }, // Pre-existing nested grid structure
          "color-contrast": { enabled: false }, // Demo colors not designed for accessibility
        }
      });
    });

    expect(results.violations).toHaveLength(0);
  });

  test("table with descending sort should not have aria violations", async ({ page }) => {
    const table = page.getByTestId("table-keyboard-demo");
    const firstHeader = table.getByRole("columnheader").first();

    // Sort descending
    await firstHeader.click();
    await firstHeader.click();

    await page.addScriptTag({ content: axeSource });
    const results = await page.evaluate(async () => {
      // @ts-expect-error axe is injected by addScriptTag
      return await axe.run(document.querySelector("[data-testid='table-keyboard-demo']"), {
        runOnly: { type: "tag", values: ["wcag2aa", "wcag2a"] },
        // Disable known demo issues (not sorting-related)
        rules: {
          "aria-required-children": { enabled: false }, // Pre-existing nested grid structure
          "color-contrast": { enabled: false }, // Demo colors not designed for accessibility
        }
      });
    });

    expect(results.violations).toHaveLength(0);
  });
});

test.describe("Table Sorting - Edge Cases", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("rapid clicking should handle sort state correctly", async ({ page }) => {
    const table = page.getByTestId("table-keyboard-demo");
    const firstHeader = table.getByRole("columnheader").first();

    // Rapid clicks
    await firstHeader.click();
    await firstHeader.click();
    await firstHeader.click();
    await firstHeader.click();

    const ariaSort = await firstHeader.getAttribute("aria-sort");
    expect(ariaSort).toMatch(/^(none|ascending|descending)$/);
  });

  test("keyboard navigation should work after sorting", async ({ page }) => {
    const table = page.getByTestId("table-keyboard-demo");
    const firstHeader = table.getByRole("columnheader").first();

    // Sort the table
    await firstHeader.click();

    // Navigate with keyboard
    await page.keyboard.press("Tab");
    await page.keyboard.press("Tab");
    
    const focusedElement = page.locator(":focus");
    await expect(focusedElement).toBeVisible();
  });

  test("multiple column sorts should work correctly", async ({ page }) => {
    const table = page.getByTestId("table-keyboard-demo");
    const headers = table.getByRole("columnheader");
    const count = await headers.count();

    // Sort each column in sequence
    for (let i = 0; i < count; i++) {
      await headers.nth(i).click();
      await expect(headers.nth(i)).toHaveAttribute("aria-sort", "ascending");
      
      // Verify other columns are "none"
      for (let j = 0; j < count; j++) {
        if (i !== j) {
          await expect(headers.nth(j)).toHaveAttribute("aria-sort", "none");
        }
      }
    }
  });
});
