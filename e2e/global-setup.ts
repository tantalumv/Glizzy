/**
 * Global Test Setup
 *
 * Runs once before all tests.
 */

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default async function globalSetup(): Promise<void> {
  // Clean up old test artifacts
  const testResultsDir = path.join(__dirname, "..", "test-results");
  const playwrightReportDir = path.join(__dirname, "..", "playwright-report");

  if (fs.existsSync(testResultsDir)) {
    fs.rmSync(testResultsDir, { recursive: true, force: true });
  }

  if (fs.existsSync(playwrightReportDir)) {
    fs.rmSync(playwrightReportDir, { recursive: true, force: true });
  }

  // Create fresh directories
  fs.mkdirSync(testResultsDir, { recursive: true });
  fs.mkdirSync(playwrightReportDir, { recursive: true });

  console.log("✓ Global setup complete - cleaned test artifacts");
}
