import { test as base, type Page, type TestInfo } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";

export type AxeFixture = {
  makeAxeBuilder: () => AxeBuilder;
  analyzeA11y: (page: Page, testInfo: TestInfo) => Promise<AxeBuilder["analyze"] extends () => Promise<infer R> ? R : never>;
};

const WCAG_TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"];

export const test = base.extend<AxeFixture>({
  makeAxeBuilder: async ({ page }, use) => {
    const makeAxeBuilder = () =>
      new AxeBuilder({ page })
        .withTags(WCAG_TAGS)
        .exclude("[aria-hidden='true']")
        .exclude(".ad-container")
        .exclude(".advertisement");
    await use(makeAxeBuilder);
  },

  analyzeA11y: async ({ page }, use) => {
    const makeAxeBuilder = () =>
      new AxeBuilder({ page })
        .withTags(WCAG_TAGS)
        .exclude("[aria-hidden='true']")
        .exclude(".ad-container")
        .exclude(".advertisement");

    const analyze = async (page: Page, testInfo: TestInfo) => {
      const builder = makeAxeBuilder();
      const results = await builder.analyze();
      await testInfo.attach("accessibility-scan-results", {
        body: JSON.stringify(results, null, 2),
        contentType: "application/json",
      });
      return results;
    };

    await use(analyze);
  },
});

export { expect } from "@playwright/test";
