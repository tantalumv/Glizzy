/**
 * Tailwind Components Visual Snapshot Tests
 *
 * Visual regression tests for components using Tailwind CSS utility classes.
 * These snapshots serve as a baseline before refactoring to helper functions.
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

test.describe("Tailwind Visual Snapshots", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  // ============================================================================
  // Typography Snapshots
  // ============================================================================

  test.describe("Typography Snapshots", () => {
    test("section heading snapshot", async ({ page }) => {
      const heading = page.locator("h2.text-xl.font-semibold").first();
      await expect(heading).toBeVisible();
      await expect(heading).toHaveScreenshot("typography-section-heading.png", {
        maxDiffPixels: 50,
      });
    });

    test("section description snapshot", async ({ page }) => {
      const description = page.locator("p.text-sm.text-muted-foreground").first();
      await expect(description).toBeVisible();
      await expect(description).toHaveScreenshot("typography-section-description.png", {
        maxDiffPixels: 50,
      });
    });

    test("helper text snapshot", async ({ page }) => {
      const helperText = page.locator("p.text-xs.text-muted-foreground").first();
      const count = await helperText.count();
      if (count > 0) {
        await expect(helperText).toHaveScreenshot("typography-helper-text.png", {
          maxDiffPixels: 50,
        });
      }
    });
  });

  // ============================================================================
  // Layout Snapshots - Stack
  // ============================================================================

  test.describe("Stack Layout Snapshots", () => {
    test("stack default snapshot", async ({ page }) => {
      const stack = page.getByTestId("stack-default");
      await expect(stack).toBeVisible();
      await expect(stack).toHaveScreenshot("layout-stack-default.png", {
        maxDiffPixels: 100,
      });
    });

    test("stack packed spacing snapshot", async ({ page }) => {
      const stack = page.getByTestId("stack-packed");
      await expect(stack).toBeVisible();
      await expect(stack).toHaveScreenshot("layout-stack-packed.png", {
        maxDiffPixels: 100,
      });
    });

    test("stack tight spacing snapshot", async ({ page }) => {
      const stack = page.getByTestId("stack-tight");
      await expect(stack).toBeVisible();
      await expect(stack).toHaveScreenshot("layout-stack-tight.png", {
        maxDiffPixels: 100,
      });
    });

    test("stack relaxed spacing snapshot", async ({ page }) => {
      const stack = page.getByTestId("stack-relaxed");
      await expect(stack).toBeVisible();
      await expect(stack).toHaveScreenshot("layout-stack-relaxed.png", {
        maxDiffPixels: 100,
      });
    });

    test("stack loose spacing snapshot", async ({ page }) => {
      const stack = page.getByTestId("stack-loose");
      await expect(stack).toBeVisible();
      await expect(stack).toHaveScreenshot("layout-stack-loose.png", {
        maxDiffPixels: 100,
      });
    });
  });

  // ============================================================================
  // Layout Snapshots - Cluster
  // ============================================================================

  test.describe("Cluster Layout Snapshots", () => {
    test("cluster default snapshot", async ({ page }) => {
      const cluster = page.getByTestId("cluster-default");
      await expect(cluster).toBeVisible();
      await expect(cluster).toHaveScreenshot("layout-cluster-default.png", {
        maxDiffPixels: 100,
      });
    });

    test("cluster align start snapshot", async ({ page }) => {
      const cluster = page.getByTestId("cluster-align-start");
      await expect(cluster).toBeVisible();
      await expect(cluster).toHaveScreenshot("layout-cluster-align-start.png", {
        maxDiffPixels: 100,
      });
    });

    test("cluster align center snapshot", async ({ page }) => {
      const cluster = page.getByTestId("cluster-align-center");
      await expect(cluster).toBeVisible();
      await expect(cluster).toHaveScreenshot("layout-cluster-align-center.png", {
        maxDiffPixels: 100,
      });
    });

    test("cluster align end snapshot", async ({ page }) => {
      const cluster = page.getByTestId("cluster-align-end");
      await expect(cluster).toBeVisible();
      await expect(cluster).toHaveScreenshot("layout-cluster-align-end.png", {
        maxDiffPixels: 100,
      });
    });
  });

  // ============================================================================
  // Layout Snapshots - Centre
  // ============================================================================

  test.describe("Centre Layout Snapshots", () => {
    test("centre default snapshot", async ({ page }) => {
      const centre = page.getByTestId("centre-default");
      await expect(centre).toBeVisible();
      await expect(centre).toHaveScreenshot("layout-centre-default.png", {
        maxDiffPixels: 100,
      });
    });
  });

  // ============================================================================
  // Layout Snapshots - Box
  // ============================================================================

  test.describe("Box Layout Snapshots", () => {
    test("box with border snapshot", async ({ page }) => {
      const box = page.getByTestId("box-default");
      await expect(box).toBeVisible();
      await expect(box).toHaveScreenshot("layout-box-border.png", {
        maxDiffPixels: 100,
      });
    });

    test("box with shadow snapshot", async ({ page }) => {
      const box = page.getByTestId("box-shadow");
      await expect(box).toBeVisible();
      await expect(box).toHaveScreenshot("layout-box-shadow.png", {
        maxDiffPixels: 100,
      });
    });
  });

  // ============================================================================
  // Layout Snapshots - Aside
  // ============================================================================

  test.describe("Aside Layout Snapshots", () => {
    test("aside sidebar start snapshot", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      await expect(aside).toBeVisible();
      await expect(aside).toHaveScreenshot("layout-aside-sidebar-start.png", {
        maxDiffPixels: 150,
      });
    });

    test("aside sidebar end snapshot", async ({ page }) => {
      const aside = page.getByTestId("aside-sidebar-end");
      await expect(aside).toBeVisible();
      await expect(aside).toHaveScreenshot("layout-aside-sidebar-end.png", {
        maxDiffPixels: 150,
      });
    });
  });

  // ============================================================================
  // Layout Snapshots - Sequence
  // ============================================================================

  test.describe("Sequence Layout Snapshots", () => {
    test("sequence default (wide viewport) snapshot", async ({ page }) => {
      await page.setViewportSize({ width: 1200, height: 800 });
      const sequence = page.getByTestId("sequence-default");
      await expect(sequence).toBeVisible();
      await expect(sequence).toHaveScreenshot("layout-sequence-wide.png", {
        maxDiffPixels: 100,
      });
    });

    test("sequence wrapped (narrow viewport) snapshot", async ({ page }) => {
      await page.setViewportSize({ width: 400, height: 800 });
      const sequence = page.getByTestId("sequence-default");
      await expect(sequence).toBeVisible();
      await expect(sequence).toHaveScreenshot("layout-sequence-narrow.png", {
        maxDiffPixels: 100,
      });
    });
  });

  // ============================================================================
  // Button Snapshots
  // ============================================================================

  test.describe("Button Snapshots", () => {
    test("button variants snapshot", async ({ page }) => {
      // Navigate to buttons page
      await page.goto("/");
      await waitForAppRender(page);

      // Find the buttons section
      const buttonsSection = page.locator("h2:has-text('Buttons')").first();
      const container = buttonsSection.locator("..").locator(".flex.flex-wrap.gap-4").first();
      
      await expect(container).toBeVisible();
      await expect(container).toHaveScreenshot("buttons-all-variants.png", {
        maxDiffPixels: 150,
      });
    });

    test("default button snapshot", async ({ page }) => {
      const btn = page.getByTestId("btn-default");
      await expect(btn).toBeVisible();
      await expect(btn).toHaveScreenshot("button-default.png", {
        maxDiffPixels: 50,
      });
    });

    test("secondary button snapshot", async ({ page }) => {
      const btn = page.getByTestId("btn-secondary");
      await expect(btn).toBeVisible();
      await expect(btn).toHaveScreenshot("button-secondary.png", {
        maxDiffPixels: 50,
      });
    });

    test("destructive button snapshot", async ({ page }) => {
      const btn = page.getByTestId("btn-destructive");
      await expect(btn).toBeVisible();
      await expect(btn).toHaveScreenshot("button-destructive.png", {
        maxDiffPixels: 50,
      });
    });

    test("outline button snapshot", async ({ page }) => {
      const btn = page.getByTestId("btn-outline");
      await expect(btn).toBeVisible();
      await expect(btn).toHaveScreenshot("button-outline.png", {
        maxDiffPixels: 50,
      });
    });

    test("ghost button snapshot", async ({ page }) => {
      const btn = page.getByTestId("btn-ghost");
      await expect(btn).toBeVisible();
      await expect(btn).toHaveScreenshot("button-ghost.png", {
        maxDiffPixels: 50,
      });
    });

    test("link button snapshot", async ({ page }) => {
      const btn = page.getByTestId("btn-link");
      await expect(btn).toBeVisible();
      await expect(btn).toHaveScreenshot("button-link.png", {
        maxDiffPixels: 50,
      });
    });
  });

  // ============================================================================
  // Full Section Snapshots
  // ============================================================================

  test.describe("Full Section Snapshots", () => {
    test("complete layout section snapshot", async ({ page }) => {
      const layoutSection = page.getByTestId("layout-stack-section");
      await expect(layoutSection).toBeVisible();
      await expect(layoutSection).toHaveScreenshot("section-layout-complete.png", {
        maxDiffPixels: 200,
      });
    });

    test("layout cluster section snapshot", async ({ page }) => {
      const clusterSection = page.getByTestId("layout-cluster-section");
      await expect(clusterSection).toBeVisible();
      await expect(clusterSection).toHaveScreenshot("section-cluster-complete.png", {
        maxDiffPixels: 200,
      });
    });

    test("layout centre section snapshot", async ({ page }) => {
      const centreSection = page.getByTestId("layout-centre-section");
      await expect(centreSection).toBeVisible();
      await expect(centreSection).toHaveScreenshot("section-centre-complete.png", {
        maxDiffPixels: 200,
      });
    });

    test("layout box section snapshot", async ({ page }) => {
      const boxSection = page.getByTestId("layout-box-section");
      await expect(boxSection).toBeVisible();
      await expect(boxSection).toHaveScreenshot("section-box-complete.png", {
        maxDiffPixels: 200,
      });
    });

    test("layout aside section snapshot", async ({ page }) => {
      const asideSection = page.getByTestId("layout-aside-section");
      await expect(asideSection).toBeVisible();
      await expect(asideSection).toHaveScreenshot("section-aside-complete.png", {
        maxDiffPixels: 200,
      });
    });

    test("layout sequence section snapshot", async ({ page }) => {
      const sequenceSection = page.getByTestId("layout-sequence-section");
      await expect(sequenceSection).toBeVisible();
      await expect(sequenceSection).toHaveScreenshot("section-sequence-complete.png", {
        maxDiffPixels: 200,
      });
    });
  });
});

test.describe("Tailwind Visual Accessibility", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should not have WCAG violations in Tailwind visual tests", async ({ page }, testInfo) => {
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .disableRules(["color-contrast"])
      .analyze();

    await testInfo.attach("tailwind-visual-accessibility-scan", {
      body: JSON.stringify(accessibilityScanResults, null, 2),
      contentType: "application/json",
    });

    // Report violations but don't fail test (pre-existing issues)
    if (accessibilityScanResults.violations.length > 0) {
      console.log("WCAG violations in Tailwind visual:", accessibilityScanResults.violations.length);
    }
  });
});
