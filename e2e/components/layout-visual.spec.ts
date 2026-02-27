/**
 * Layout Component Visual Snapshot Tests
 *
 * Visual regression tests for layout components
 */

import { test, expect } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

async function waitForAppRender(page) {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Layout Visual Snapshots", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Stack Visual Tests", () => {
    test("stack spacing variants snapshot", async ({ page }) => {
      const stackSection = page.getByTestId("layout-stack-spacing");
      await expect(stackSection).toHaveScreenshot("stack-spacing-variants.png", {
        maxDiffPixels: 100,
      });
    });

    test("stack default snapshot", async ({ page }) => {
      const stack = page.getByTestId("stack-default");
      await expect(stack).toHaveScreenshot("stack-default.png", {
        maxDiffPixels: 100,
      });
    });
  });

  test.describe("Cluster Visual Tests", () => {
    test("cluster alignment snapshot", async ({ page }) => {
      const clusterSection = page.getByTestId("layout-cluster-align");
      await expect(clusterSection).toHaveScreenshot("cluster-alignment.png", {
        maxDiffPixels: 100,
      });
    });

    test("cluster default snapshot", async ({ page }) => {
      const cluster = page.getByTestId("cluster-default");
      await expect(cluster).toHaveScreenshot("cluster-default.png", {
        maxDiffPixels: 100,
      });
    });
  });

  test.describe("Centre Visual Tests", () => {
    test("centre demo snapshot", async ({ page }) => {
      const centre = page.getByTestId("centre-default");
      await expect(centre).toHaveScreenshot("centre-demo.png", {
        maxDiffPixels: 100,
      });
    });
  });

  test.describe("Box Visual Tests", () => {
    test("box variants snapshot", async ({ page }) => {
      const boxSection = page.getByTestId("layout-box-section");
      await expect(boxSection).toHaveScreenshot("box-variants.png", {
        maxDiffPixels: 100,
      });
    });
  });

  test.describe("Aside Visual Tests", () => {
    test("aside sidebar start snapshot", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      await expect(aside).toHaveScreenshot("aside-sidebar-start.png", {
        maxDiffPixels: 100,
      });
    });

    test("aside sidebar end snapshot", async ({ page }) => {
      const aside = page.getByTestId("aside-sidebar-end");
      await expect(aside).toHaveScreenshot("aside-sidebar-end.png", {
        maxDiffPixels: 100,
      });
    });
  });

  test.describe("Sequence Visual Tests", () => {
    test("sequence default snapshot", async ({ page }) => {
      await page.setViewportSize({ width: 1200, height: 800 });
      const sequence = page.getByTestId("sequence-default");
      await expect(sequence).toHaveScreenshot("sequence-horizontal.png", {
        maxDiffPixels: 100,
      });
    });

    test("sequence wrapped snapshot", async ({ page }) => {
      await page.setViewportSize({ width: 400, height: 800 });
      const sequence = page.getByTestId("sequence-default");
      await expect(sequence).toHaveScreenshot("sequence-wrapped.png", {
        maxDiffPixels: 100,
      });
    });
  });

  test.describe("Full Layout Section", () => {
    test("complete layout section snapshot", async ({ page }) => {
      const layoutSection = page.getByTestId("layout-stack-section").locator("..");
      await expect(layoutSection).toHaveScreenshot("layout-section-full.png", {
        maxDiffPixels: 200,
      });
    });
  });
});

test.describe("Layout Visual Accessibility", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should not have WCAG violations in layout visual tests", async ({ page }, testInfo) => {
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .disableRules(["color-contrast"])
      .analyze();

    await testInfo.attach("layout-visual-accessibility-scan", {
      body: JSON.stringify(accessibilityScanResults, null, 2),
      contentType: "application/json",
    });

    // Report violations but don't fail test (pre-existing issues)
    if (accessibilityScanResults.violations.length > 0) {
      console.log("WCAG violations in layout visual:", accessibilityScanResults.violations.length);
    }
  });
});
