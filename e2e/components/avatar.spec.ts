/**
 * Avatar Component Tests
 */

import { test, expect, type Page } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

const AVATARS = {
  default: { testId: "avatar-default" },
  small: { testId: "avatar-small" },
  medium: { testId: "avatar-medium" },
  large: { testId: "avatar-large" },
} as const;

async function waitForAppRender(page: Page): Promise<void> {
  await page.waitForLoadState("networkidle");
  await page.waitForSelector("#app");
  await page.waitForFunction(() => {
    const app = document.querySelector("#app");
    return app && app.innerHTML.length > 0;
  });
}

test.describe("Avatar Component", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await waitForAppRender(page);
  });

  test.describe("Avatar Variants", () => {
    for (const [key, { testId }] of Object.entries(AVATARS)) {
      test(`should render ${key} avatar`, async ({ page }) => {
        const avatar = page.getByTestId(testId);
        await expect(avatar).toBeVisible();
      });
    }

    test("all avatars should be visible", async ({ page }) => {
      for (const { testId } of Object.values(AVATARS)) {
        const avatar = page.getByTestId(testId);
        await expect(avatar).toBeVisible();
      }
    });
  });

  test.describe("Avatar Styling", () => {
    test("should be rounded/circular", async ({ page }) => {
      const avatar = page.getByTestId("avatar-default");
      await expect(avatar).toHaveClass(/rounded/);
    });
  });

  test.describe("Avatar Layout", () => {
    test("should have proper dimensions", async ({ page }) => {
      const avatar = page.getByTestId("avatar-default");
      const box = await avatar.boundingBox();
      expect(box).not.toBeNull();
      expect(box!.width).toBeGreaterThan(0);
      expect(box!.height).toBeGreaterThan(0);
    });

    test("large avatar should be bigger than small", async ({ page }) => {
      const small = await page.getByTestId("avatar-small").boundingBox();
      const large = await page.getByTestId("avatar-large").boundingBox();
      expect(small).not.toBeNull();
      expect(large).not.toBeNull();
      expect(large!.width).toBeGreaterThan(small!.width);
      expect(large!.height).toBeGreaterThan(small!.height);
    });
  });

  test.describe("Avatar Accessibility", () => {
    test("should be visible", async ({ page }) => {
      const avatar = page.getByTestId("avatar-default");
      await expect(avatar).toBeVisible();
    });
  });

  test.describe("Axe Accessibility", () => {
    test("avatar should not have WCAG violations", async ({ page }, testInfo) => {
      const avatar = page.getByTestId("avatar-default");
      await expect(avatar).toBeVisible();

      const accessibilityScanResults = await new AxeBuilder({ page })
        .withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"])
        .include("[data-testid='avatar-default']")
        .disableRules(["color-contrast", "image-alt"])
        .analyze();

      await testInfo.attach("avatar-accessibility-scan", {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: "application/json",
      });

      expect(accessibilityScanResults.violations).toHaveLength(0);
    });
  });
});
