import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e/specs',
  fullyParallel: false,
  forbidOnly: true,
  retries: 2,
  workers: 1,
  reporter: [
    ['html', { outputFolder: 'tests/results/html-report' }],
    ['junit', { outputFile: 'tests/results/junit.xml' }],
    ['github']
  ],
  
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    headless: true,
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },

  projects: [
    {
      name: 'chromium-ci',
      use: { 
        ...devices['Desktop Chrome'],
        channel: 'chromium'
      },
    },
    {
      name: 'mobile-ci',
      use: { 
        ...devices['Pixel 5']
      },
    },
  ],

  timeout: 60 * 1000,
  expect: {
    timeout: 10000
  },

  outputDir: 'tests/results/test-results',
});