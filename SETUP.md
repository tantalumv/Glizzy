# Glizzy UI - Setup Guide

This guide explains how to set up and use the Glizzy UI library.

## Directory Structure

```
glizzy-ui/
├── src/                    # Source code
│   └── ui/
│       ├── button.gleam
│       └── ... (60+ components)
├── test/                   # Unit tests
│   ├── glizzy_button_test.gleam
│   └── ... (7 test files)
├── examples/lustre_app/    # Demo app using Glizzy
│   ├── src/                # App source
│   ├── test/               # App unit tests
│   ├── gleam.toml          # Uses glizzy from Hex
│   └── package.json
├── e2e/                    # Playwright E2E tests
│   ├── components/         # Component tests
│   ├── keyboard-navigation.spec.ts
│   └── table.spec.ts       # Table sorting tests
├── docs/                   # Documentation (gitignored)
├── gleam.toml              # Package config
├── manifest.toml           # Dependency lock
├── package.json            # E2E test dependencies
└── playwright.config.ts    # E2E test config
```

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/tantalumv/Glizzy.git
cd Glizzy
```

### Build the Package

```bash
# Download dependencies
gleam deps download

# Build
gleam build
```

### Run Tests

```bash
# Run package unit tests
gleam test
```

### Run the Demo App

```bash
cd examples/lustre_app

# Download dependencies
gleam deps download

# Run development server
gleam run
```

### Run E2E Tests

```bash
# Install dependencies (first time only)
bun install

# Run all E2E tests
bunx playwright test

# Run specific test
bunx playwright test e2e/components/table.spec.ts

# Run with UI mode
bunx playwright test --ui
```

## Sync from Development Repo

If you maintain a separate development repo and want to sync to this publish directory:

```bash
# Run sync script (adjust paths as needed)
./sync-from-dev.sh

# Or manually copy files from your dev repo
```

## Test Coverage

| Test Type | Location | Framework | Count |
|-----------|----------|-----------|-------|
| Package Unit | `test/` | Gleeunit | 61 tests |
| App Unit | `examples/lustre_app/test/` | Gleeunit | 157 tests |
| E2E Components | `e2e/components/` | Playwright | 200+ tests |
| E2E Keyboard | `e2e/keyboard-navigation.spec.ts` | Playwright | 51 tests |
| E2E Table | `e2e/components/table.spec.ts` | Playwright | 25 tests |
