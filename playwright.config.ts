// Playwright configuration for Glizzy UI testing
// https://playwright.dev/docs/test-configuration

import { defineConfig, devices } from "@playwright/test";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  testDir: "./e2e",

  // Output directories
  outputDir: "./test-results",
  snapshotDir: "./e2e/snapshots",

  // Run tests in files in parallel
  fullyParallel: true,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry on CI only
  retries: process.env.CI ? 2 : 0,

  // Opt out of parallel tests on CI
  workers: process.env.CI ? 1 : undefined,

  // Reporter to use
  reporter: [
    ["html", { open: "never", outputFolder: "./playwright-report" }],
    ["list", { printSteps: true }],
  ],

  // Shared settings for all projects
  use: {
    // Base URL for tests
    baseURL: "http://localhost:4000",

    // Collect trace on failure
    trace: "retain-on-failure",

    // Screenshot on failure
    screenshot: "only-on-failure",

    // Actionability settings
    actionTimeout: 15000,
    navigationTimeout: 45000,

    // Locale and timezone
    locale: "en-US",
    timezoneId: "UTC",
  },

  // Configure projects for major browsers
  projects: [
    // Main tests on lustre_app (port 4000) - excludes CSS inline tests
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1920, height: 1080 },
      },
      testIgnore: /layout-css\.spec\.ts$/,
    },
    // Pure Gleam CSS inline tests (port 5001)
    // Note: Start server manually with: cd examples/pure_gleam && gleam run -t erlang
    {
      name: "pure_gleam",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1920, height: 1080 },
        baseURL: "http://localhost:5001",
      },
      testMatch: /layout-css\.spec\.ts$/,
    },
  ],

  // Run local dev server before starting tests
  // Note: pure_gleam server must be started manually with: cd examples/pure_gleam && gleam run -t erlang
  webServer: {
    command: "bun run dev",
    url: "http://localhost:4000",
    reuseExistingServer: !process.env.CI,
    cwd: "./examples/lustre_app",
    timeout: 120000,
    env: {
      NODE_ENV: "test",
    },
  },

  // Global setup and teardown
  globalSetup: path.join(__dirname, "./e2e/global-setup.ts"),
  globalTeardown: path.join(__dirname, "./e2e/global-teardown.ts"),

  // Timeout for each test
  timeout: 60000,

  // Expect settings
  expect: {
    timeout: 10000,
  },
});
