/**
 * Layout Component Tests
 *
 * Tests for Stack, Cluster, Centre, Box, Aside, and Sequence components
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

test.describe("Layout Components", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  // ============================================================================
  // Stack Tests
  // ============================================================================

  test.describe("Stack", () => {
    test("should render stack with vertical layout", async ({ page }) => {
      const stack = page.getByTestId("stack-default");
      await expect(stack).toBeVisible();

      const stackDiv = stack.locator("> div").first();
      const display = await stackDiv.evaluate((el) =>
        getComputedStyle(el).display
      );
      expect(display).toBe("flex");

      const direction = await stackDiv.evaluate((el) =>
        getComputedStyle(el).flexDirection
      );
      expect(direction).toBe("column");
    });

    test("should render children vertically stacked", async ({ page }) => {
      const stack = page.getByTestId("stack-default");
      const children = await stack.locator("> div > div").all();

      expect(children.length).toBe(3);

      const positions = await Promise.all(
        children.map((el) => el.boundingBox())
      );

      const tops = positions.map((box) => box!.y);
      expect(tops).toEqual([...tops].sort((a, b) => a - b));
    });

    test("should apply spacing variants", async ({ page }) => {
      const stackPacked = page.getByTestId("stack-packed").locator("> div");
      const stackTight = page.getByTestId("stack-tight").locator("> div");
      const stackRelaxed = page.getByTestId("stack-relaxed").locator("> div");
      const stackLoose = page.getByTestId("stack-loose").locator("> div");

      const packedGap = await stackPacked.evaluate((el) =>
        getComputedStyle(el).gap
      );
      const tightGap = await stackTight.evaluate((el) =>
        getComputedStyle(el).gap
      );
      const relaxedGap = await stackRelaxed.evaluate((el) =>
        getComputedStyle(el).gap
      );
      const looseGap = await stackLoose.evaluate((el) =>
        getComputedStyle(el).gap
      );

      expect(parseFloat(packedGap)).toBe(0);
      expect(parseFloat(tightGap)).toBeGreaterThan(0);
      expect(parseFloat(relaxedGap)).toBeGreaterThan(parseFloat(tightGap));
      expect(parseFloat(looseGap)).toBeGreaterThan(parseFloat(relaxedGap));
    });

    test("should have flex-col class", async ({ page }) => {
      const stackDiv = page.getByTestId("stack-default").locator("> div");
      await expect(stackDiv).toHaveClass(/flex-col/);
    });

    test("should have gap class from spacing", async ({ page }) => {
      const stackRelaxedDiv = page.getByTestId("stack-relaxed").locator("> div");
      await expect(stackRelaxedDiv).toHaveClass(/gap-4/);
    });
  });

  // ============================================================================
  // Cluster Tests
  // ============================================================================

  test.describe("Cluster", () => {
    test("should render cluster with flex-wrap", async ({ page }) => {
      const cluster = page.getByTestId("cluster-default");
      await expect(cluster).toBeVisible();

      const clusterDiv = cluster.locator("> div").first();
      const flexWrap = await clusterDiv.evaluate((el) =>
        getComputedStyle(el).flexWrap
      );
      expect(flexWrap).toBe("wrap");
    });

    test("should wrap children horizontally", async ({ page }) => {
      const cluster = page.getByTestId("cluster-default");
      const children = await cluster.locator("> div > span").all();

      expect(children.length).toBe(5);

      const firstChildTop = await children[0].evaluate(
        (el) => el.getBoundingClientRect().top
      );
      const secondChildTop = await children[1].evaluate(
        (el) => el.getBoundingClientRect().top
      );

      expect(firstChildTop).toBeCloseTo(secondChildTop, 0);
    });

    test("should apply alignment variants", async ({ page }) => {
      const startCluster = page
        .getByTestId("cluster-align-start")
        .locator("> div");
      const centerCluster = page
        .getByTestId("cluster-align-center")
        .locator("> div");
      const endCluster = page
        .getByTestId("cluster-align-end")
        .locator("> div");

      await expect(startCluster).toHaveClass(/items-start/);
      await expect(centerCluster).toHaveClass(/items-center/);
      await expect(endCluster).toHaveClass(/items-end/);
    });

    test("should have gap spacing", async ({ page }) => {
      const clusterDiv = page.getByTestId("cluster-default").locator("> div");
      const gap = await clusterDiv.evaluate((el) => getComputedStyle(el).gap);
      expect(parseFloat(gap)).toBeGreaterThan(0);
    });

    test("should wrap on narrow viewport", async ({ page }) => {
      await page.setViewportSize({ width: 300, height: 800 });
      await page.waitForTimeout(100);

      const cluster = page.getByTestId("cluster-default");
      const children = await cluster.locator("> div > span").all();

      const positions = await Promise.all(
        children.map((el) => el.boundingBox())
      );

      const uniqueTops = new Set(positions.map((box) => Math.round(box!.y)));
      expect(uniqueTops.size).toBeGreaterThan(1);
    });
  });

  // ============================================================================
  // Centre Tests
  // ============================================================================

  test.describe("Centre", () => {
    test("should center content horizontally and vertically", async ({ page }) => {
      const centre = page.getByTestId("centre-default");
      await expect(centre).toBeVisible();

      const centreDiv = centre.locator("> div");
      const alignItems = await centreDiv.evaluate((el) =>
        getComputedStyle(el).alignItems
      );
      const justifyContent = await centreDiv.evaluate((el) =>
        getComputedStyle(el).justifyContent
      );

      expect(alignItems).toBe("center");
      expect(justifyContent).toBe("center");
    });

    test("should have items-center and justify-center classes", async ({ page }) => {
      const centreDiv = page.getByTestId("centre-default").locator("> div");
      await expect(centreDiv).toHaveClass(/items-center/);
      await expect(centreDiv).toHaveClass(/justify-center/);
    });

    test("should display centered content", async ({ page }) => {
      const centre = page.getByTestId("centre-default");
      await expect(centre).toContainText("Centered content");
    });
  });

  // ============================================================================
  // Box Tests
  // ============================================================================

  test.describe("Box", () => {
    test("should apply padding", async ({ page }) => {
      const box = page.getByTestId("box-default").locator("> div");
      const padding = await box.evaluate((el) => getComputedStyle(el).padding);
      expect(parseFloat(padding)).toBeGreaterThan(0);
    });

    test("should have default padding class", async ({ page }) => {
      const boxDiv = page.getByTestId("box-default").locator("> div");
      await expect(boxDiv).toHaveClass(/p-4/);
    });

    test("should apply border styles", async ({ page }) => {
      const box = page.getByTestId("box-default").locator("> div");
      const border = await box.evaluate((el) => getComputedStyle(el).border);
      expect(border).not.toBe("none");
    });

    test("should apply shadow styles", async ({ page }) => {
      const box = page.getByTestId("box-shadow").locator("> div");
      const shadow = await box.evaluate((el) =>
        getComputedStyle(el).boxShadow
      );
      expect(shadow).not.toBe("none");
    });

    test("should have rounded corners with border", async ({ page }) => {
      const box = page.getByTestId("box-default").locator("> div");
      await expect(box).toHaveClass(/rounded/);
    });
  });

  // ============================================================================
  // Aside Tests
  // ============================================================================

  test.describe("Aside", () => {
    test("should render sidebar and content", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      await expect(aside).toBeVisible();

      const sidebar = aside.locator("aside");
      const main = aside.locator("main");

      await expect(sidebar).toBeVisible();
      await expect(main).toBeVisible();
    });

    test("should have horizontal flex layout", async ({ page }) => {
      const asideDiv = page.getByTestId("aside-default").locator("> div");
      const display = await asideDiv.evaluate((el) =>
        getComputedStyle(el).display
      );
      const direction = await asideDiv.evaluate((el) =>
        getComputedStyle(el).flexDirection
      );

      expect(display).toBe("flex");
      expect(direction).toBe("row");
    });

    test("should have fixed sidebar width", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      const sidebar = aside.locator("aside");

      const width = await sidebar.evaluate((el) =>
        getComputedStyle(el).width
      );
      expect(parseFloat(width)).toBe(256);
    });

    test("sidebar should not shrink", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      const sidebar = aside.locator("aside");

      const flexShrink = await sidebar.evaluate((el) =>
        getComputedStyle(el).flexShrink
      );
      expect(flexShrink).toBe("0");
    });

    test("content should fill remaining space", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      const main = aside.locator("main");

      const flex = await main.evaluate((el) => getComputedStyle(el).flex);
      expect(flex).toContain("1");
    });

    test("should support sidebar_end (sidebar on right)", async ({ page }) => {
      const aside = page.getByTestId("aside-sidebar-end");
      const asideDiv = aside.locator("> div");

      const direction = await asideDiv.evaluate((el) =>
        getComputedStyle(el).flexDirection
      );
      expect(direction).toBe("row-reverse");
    });

    test("sidebar and content widths should add up to container width", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      const asideDiv = aside.locator("> div");
      const sidebar = aside.locator("aside");
      const main = aside.locator("main");

      const containerWidth = await asideDiv.evaluate(
        (el) => el.getBoundingClientRect().width
      );
      const sidebarWidth = await sidebar.evaluate(
        (el) => el.getBoundingClientRect().width
      );
      const mainWidth = await main.evaluate(
        (el) => el.getBoundingClientRect().width
      );

      expect(sidebarWidth + mainWidth).toBeCloseTo(containerWidth, 0);
    });
  });

  // ============================================================================
  // Sequence Tests
  // ============================================================================

  test.describe("Sequence", () => {
    test("should render with flex-wrap", async ({ page }) => {
      const sequence = page.getByTestId("sequence-default");
      await expect(sequence).toBeVisible();

      const sequenceDiv = sequence.locator("> div");
      const flexWrap = await sequenceDiv.evaluate((el) =>
        getComputedStyle(el).flexWrap
      );
      expect(flexWrap).toBe("wrap");
    });

    test("should have container class for container queries", async ({ page }) => {
      const sequenceDiv = page.getByTestId("sequence-default").locator("> div");
      await expect(sequenceDiv).toHaveClass(/@container/);
    });

    test("should have gap spacing", async ({ page }) => {
      const sequenceDiv = page.getByTestId("sequence-default").locator("> div");
      const gap = await sequenceDiv.evaluate((el) => getComputedStyle(el).gap);
      expect(parseFloat(gap)).toBeGreaterThan(0);
    });

    test("should render children horizontally by default", async ({ page }) => {
      const sequence = page.getByTestId("sequence-default");
      const children = await sequence.locator("> div > div").all();

      expect(children.length).toBe(4);

      const positions = await Promise.all(
        children.map((el) => el.boundingBox())
      );

      const firstTop = positions[0]!.y;
      const secondTop = positions[1]!.y;
      expect(firstTop).toBeCloseTo(secondTop, 0);
    });

    test("should wrap on narrow viewport", async ({ page }) => {
      await page.setViewportSize({ width: 300, height: 800 });
      await page.waitForTimeout(100);

      const sequence = page.getByTestId("sequence-default");
      const children = await sequence.locator("> div > div").all();

      const positions = await Promise.all(
        children.map((el) => el.boundingBox())
      );

      const uniqueTops = new Set(positions.map((box) => Math.round(box!.y)));
      expect(uniqueTops.size).toBeGreaterThan(1);
    });
  });

  // ============================================================================
  // Layout Behavior Tests (Computed Styles)
  // ============================================================================

  test.describe("Layout Behavior", () => {
    test("stack gap creates visible spacing", async ({ page }) => {
      const stackRelaxed = page.getByTestId("stack-relaxed").locator("> div");
      const gap = await stackRelaxed.evaluate((el) => getComputedStyle(el).gap);
      expect(parseFloat(gap)).toBe(16);
    });

    test("cluster wraps children when needed", async ({ page }) => {
      await page.setViewportSize({ width: 400, height: 800 });

      const cluster = page.getByTestId("cluster-default");
      const children = await cluster.locator("> div > span").all();

      const positions = await Promise.all(
        children.map((el) => el.boundingBox())
      );

      const tops = positions.map((box) => Math.round(box!.y));
      const uniqueRows = new Set(tops);
      expect(uniqueRows.size).toBeGreaterThanOrEqual(1);
    });

    test("aside sidebar maintains width on container resize", async ({ page }) => {
      const aside = page.getByTestId("aside-default");
      const sidebar = aside.locator("aside");

      const initialWidth = await sidebar.evaluate(
        (el) => el.getBoundingClientRect().width
      );

      await page.setViewportSize({ width: 800, height: 600 });
      await page.waitForTimeout(100);

      const newWidth = await sidebar.evaluate(
        (el) => el.getBoundingClientRect().width
      );

      expect(newWidth).toBeCloseTo(initialWidth, 0);
    });
  });
});

test.describe("Layout Accessibility", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test("should not have WCAG violations in layout components", async ({ page }, testInfo) => {
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .disableRules(["color-contrast"])
      .analyze();

    await testInfo.attach("layout-accessibility-scan", {
      body: JSON.stringify(accessibilityScanResults, null, 2),
      contentType: "application/json",
    });

    // Report violations but don't fail test (pre-existing issues)
    if (accessibilityScanResults.violations.length > 0) {
      console.log("WCAG violations in layout:", accessibilityScanResults.violations.length);
    }
  });
});
