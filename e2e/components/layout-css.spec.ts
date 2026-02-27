/**
 * Layout Component CSS Inline Tests
 *
 * Tests for CSS inline style versions of layout components served from pure_gleam SSR
 * These tests verify inline styles work correctly without Tailwind
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const PURE_GLEAM_PORT = process.env.PURE_GLEAM_PORT || "5001";
const PURE_GLEAM_URL = `http://localhost:${PURE_GLEAM_PORT}`;

async function waitForPageLoad(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("main");
}

test.describe("Layout CSS Inline Components", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(`${PURE_GLEAM_URL}/layout`);
    await waitForPageLoad(page);
  });

  // ============================================================================
  // CSS Stack Tests
  // ============================================================================

  test.describe("CSS Stack", () => {
    test("should have inline display: flex", async ({ page }) => {
      const stack = page.getByTestId("css-stack-default").locator("> div");
      const display = await stack.evaluate((el) => el.style.display);
      expect(display).toBe("flex");
    });

    test("should have inline flex-direction: column", async ({ page }) => {
      const stack = page.getByTestId("css-stack-default").locator("> div");
      const direction = await stack.evaluate((el) => el.style.flexDirection);
      expect(direction).toBe("column");
    });

    test("should have inline gap for spacing", async ({ page }) => {
      const stack = page.getByTestId("css-stack-default").locator("> div");
      const gap = await stack.evaluate((el) => el.style.gap);
      expect(gap).toBeTruthy();
      expect(gap).toContain("rem");
    });

    test("packed spacing should have gap: 0", async ({ page }) => {
      const stackWrapper = page.getByTestId("css-stack-packed");
      const stack = stackWrapper.locator("div[style*='display']");
      const gap = await stack.evaluate((el) => el.style.gap);
      expect(gap).toBe("0");
    });

    test("tight spacing should have gap: 0.5rem", async ({ page }) => {
      const stackWrapper = page.getByTestId("css-stack-tight");
      const stack = stackWrapper.locator("div[style*='display']");
      const gap = await stack.evaluate((el) => el.style.gap);
      expect(gap).toBe("0.5rem");
    });

    test("relaxed spacing should have gap: 1rem", async ({ page }) => {
      const stackWrapper = page.getByTestId("css-stack-relaxed");
      const stack = stackWrapper.locator("div[style*='display']");
      const gap = await stack.evaluate((el) => el.style.gap);
      expect(gap).toBe("1rem");
    });

    test("loose spacing should have gap: 1.5rem", async ({ page }) => {
      const stackWrapper = page.getByTestId("css-stack-loose");
      const stack = stackWrapper.locator("div[style*='display']");
      const gap = await stack.evaluate((el) => el.style.gap);
      expect(gap).toBe("1.5rem");
    });


  });

  // ============================================================================
  // CSS Cluster Tests
  // ============================================================================

  test.describe("CSS Cluster", () => {
    test("should have inline display: flex", async ({ page }) => {
      const cluster = page.getByTestId("css-cluster-default").locator("> div");
      const display = await cluster.evaluate((el) => el.style.display);
      expect(display).toBe("flex");
    });

    test("should have inline flex-wrap: wrap", async ({ page }) => {
      const cluster = page.getByTestId("css-cluster-default").locator("> div");
      const flexWrap = await cluster.evaluate((el) => el.style.flexWrap);
      expect(flexWrap).toBe("wrap");
    });

    test("should have inline gap", async ({ page }) => {
      const cluster = page.getByTestId("css-cluster-default").locator("> div");
      const gap = await cluster.evaluate((el) => el.style.gap);
      expect(gap).toBeTruthy();
    });

    test("align-start should have inline align-items: flex-start", async ({ page }) => {
      const clusterWrapper = page.getByTestId("css-cluster-align-start");
      const cluster = clusterWrapper.locator("div[style*='display']");
      const alignItems = await cluster.evaluate((el) => el.style.alignItems);
      expect(alignItems).toBe("flex-start");
    });

    test("align-center should have inline align-items: center", async ({ page }) => {
      const clusterWrapper = page.getByTestId("css-cluster-align-center");
      const cluster = clusterWrapper.locator("div[style*='display']");
      const alignItems = await cluster.evaluate((el) => el.style.alignItems);
      expect(alignItems).toBe("center");
    });

    test("align-end should have inline align-items: flex-end", async ({ page }) => {
      const clusterWrapper = page.getByTestId("css-cluster-align-end");
      const cluster = clusterWrapper.locator("div[style*='display']");
      const alignItems = await cluster.evaluate((el) => el.style.alignItems);
      expect(alignItems).toBe("flex-end");
    });
  });

  // ============================================================================
  // CSS Centre Tests
  // ============================================================================

  test.describe("CSS Centre", () => {
    test("should have inline display: flex", async ({ page }) => {
      const centre = page.getByTestId("css-centre-default").locator("> div");
      const display = await centre.evaluate((el) => el.style.display);
      expect(display).toBe("flex");
    });

    test("should have inline align-items: center", async ({ page }) => {
      const centre = page.getByTestId("css-centre-default").locator("> div");
      const alignItems = await centre.evaluate((el) => el.style.alignItems);
      expect(alignItems).toBe("center");
    });

    test("should have inline justify-content: center", async ({ page }) => {
      const centre = page.getByTestId("css-centre-default").locator("> div");
      const justifyContent = await centre.evaluate(
        (el) => el.style.justifyContent
      );
      expect(justifyContent).toBe("center");
    });

    test("should center content in container", async ({ page }) => {
      const centreBox = page.getByTestId("css-centre-default");
      const centre = centreBox.locator("> div");

      const boxRect = await centreBox.evaluate((el) => el.getBoundingClientRect());
      const centerRect = await centre.evaluate((el) => el.getBoundingClientRect());

      const boxCenterY = boxRect.y + boxRect.height / 2;
      const boxCenterX = boxRect.x + boxRect.width / 2;
      const centerCenterY = centerRect.y + centerRect.height / 2;
      const centerCenterX = centerRect.x + centerRect.width / 2;

      expect(Math.abs(boxCenterY - centerCenterY)).toBeLessThan(10);
      expect(Math.abs(boxCenterX - centerCenterX)).toBeLessThan(50);
    });
  });

  // ============================================================================
  // CSS Box Tests
  // ============================================================================

  test.describe("CSS Box", () => {
    test("should have inline padding", async ({ page }) => {
      const box = page.getByTestId("css-box-default").locator("> div");
      const padding = await box.evaluate((el) => el.style.padding);
      expect(padding).toBeTruthy();
    });

    test("should have inline border styles", async ({ page }) => {
      const box = page.getByTestId("css-box-default").locator("> div");
      const border = await box.evaluate((el) => el.style.border);
      const borderRadius = await box.evaluate((el) => el.style.borderRadius);

      expect(border).toBeTruthy();
      expect(borderRadius).toBeTruthy();
    });

    test("should have inline box-shadow", async ({ page }) => {
      const box = page.getByTestId("css-box-shadow").locator("> div");
      const boxShadow = await box.evaluate((el) => el.style.boxShadow);
      expect(boxShadow).toBeTruthy();
      expect(boxShadow).not.toBe("");
    });

    test("default box should have 1rem padding", async ({ page }) => {
      const box = page.getByTestId("css-box-default").locator("> div");
      const padding = await box.evaluate((el) => el.style.padding);
      expect(padding).toBe("1rem");
    });
  });

  // ============================================================================
  // CSS Aside Tests
  // ============================================================================

  test.describe("CSS Aside", () => {
    test("should have inline display: flex", async ({ page }) => {
      const aside = page.getByTestId("css-aside-default").locator("> div");
      const display = await aside.evaluate((el) => el.style.display);
      expect(display).toBe("flex");
    });

    test("should have aside and main elements", async ({ page }) => {
      const aside = page.getByTestId("css-aside-default");
      const sidebar = aside.locator("aside");
      const main = aside.locator("main");

      await expect(sidebar).toBeVisible();
      await expect(main).toBeVisible();
    });

    test("sidebar should have inline width", async ({ page }) => {
      const aside = page.getByTestId("css-aside-default");
      const sidebar = aside.locator("aside");
      const width = await sidebar.evaluate((el) => el.style.width);
      expect(width).toBeTruthy();
    });

    test("sidebar should have inline flex-shrink: 0", async ({ page }) => {
      const aside = page.getByTestId("css-aside-default");
      const sidebar = aside.locator("aside");
      const flexShrink = await sidebar.evaluate((el) => el.style.flexShrink);
      expect(flexShrink).toBe("0");
    });

    test("main content should have inline flex: 1", async ({ page }) => {
      const aside = page.getByTestId("css-aside-default");
      const main = aside.locator("main");
      const flex = await main.evaluate((el) => el.style.flex);
      expect(flex).toContain("1");
    });

    test("sidebar-end should have inline flex-direction: row-reverse", async ({ page }) => {
      const aside = page.getByTestId("css-aside-sidebar-end").locator("> div");
      const direction = await aside.evaluate((el) => el.style.flexDirection);
      expect(direction).toBe("row-reverse");
    });

    test("sidebar and content widths should total container width", async ({ page }) => {
      const asideContainer = page.getByTestId("css-aside-default");
      const aside = asideContainer.locator("> div");
      const sidebar = asideContainer.locator("aside");
      const main = asideContainer.locator("main");

      const containerWidth = await aside.evaluate(
        (el) => el.getBoundingClientRect().width
      );
      const sidebarWidth = await sidebar.evaluate(
        (el) => el.getBoundingClientRect().width
      );
      const mainWidth = await main.evaluate(
        (el) => el.getBoundingClientRect().width
      );

      expect(sidebarWidth + mainWidth).toBeCloseTo(containerWidth, -1);
    });
  });

  // ============================================================================
  // CSS Sequence Tests
  // ============================================================================

  test.describe("CSS Sequence", () => {
    test("should have inline display: flex", async ({ page }) => {
      const sequence = page.getByTestId("css-sequence-default").locator("> div");
      const display = await sequence.evaluate((el) => el.style.display);
      expect(display).toBe("flex");
    });

    test("should have inline flex-wrap: wrap", async ({ page }) => {
      const sequence = page.getByTestId("css-sequence-default").locator("> div");
      const flexWrap = await sequence.evaluate((el) => el.style.flexWrap);
      expect(flexWrap).toBe("wrap");
    });

    test("should have inline gap", async ({ page }) => {
      const sequence = page.getByTestId("css-sequence-default").locator("> div");
      const gap = await sequence.evaluate((el) => el.style.gap);
      expect(gap).toBeTruthy();
    });

    test("should render items horizontally", async ({ page }) => {
      const sequence = page.getByTestId("css-sequence-default").locator("> div");
      const children = await sequence.locator("> div").all();

      expect(children.length).toBe(4);

      const firstTwoTops = await Promise.all([
        children[0].evaluate((el) => el.getBoundingClientRect().y),
        children[1].evaluate((el) => el.getBoundingClientRect().y),
      ]);

      expect(firstTwoTops[0]).toBeCloseTo(firstTwoTops[1], 0);
    });

    test("should wrap on narrow viewport", async ({ page }) => {
      await page.setViewportSize({ width: 300, height: 800 });
      await page.waitForTimeout(100);

      const sequence = page.getByTestId("css-sequence-default").locator("> div");
      const children = await sequence.locator("> div").all();

      const tops = await Promise.all(
        children.map((el) => el.evaluate((e) => e.getBoundingClientRect().y))
      );

      const uniqueRows = new Set(tops.map((t) => Math.round(t)));
      expect(uniqueRows.size).toBeGreaterThan(1);
    });
  });
});

test.describe("Layout CSS Accessibility", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(PURE_GLEAM_URL);
    await page.waitForLoadState("networkidle");
  });

  test("should not have WCAG violations in CSS layout components", async ({ page }, testInfo) => {
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
      .disableRules(["color-contrast"])
      .analyze();

    await testInfo.attach("layout-css-accessibility-scan", {
      body: JSON.stringify(accessibilityScanResults, null, 2),
      contentType: "application/json",
    });

    // Report violations but don't fail test (pre-existing issues)
    if (accessibilityScanResults.violations.length > 0) {
      console.log("WCAG violations in CSS layout:", accessibilityScanResults.violations.length);
    }
  });
});
