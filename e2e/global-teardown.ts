/**
 * Global Test Teardown
 *
 * Runs once after all tests.
 */

export default async function globalTeardown(): Promise<void> {
  console.log("✓ Global teardown complete");
}
