import { test, expect } from '@playwright/test';
import { AuthPage } from '../pages/auth.page.js';
import { TestFixtures } from '../utils/fixtures.js';

test.describe('Authentication Edge Cases', () => {
  let authPage;

  test.beforeEach(async ({ page }) => {
    authPage = new AuthPage(page);
  });

  test.afterEach(async () => {
    await authPage.clearSession();
  });

  test.describe('Session Management', () => {
    test('should handle session timeout gracefully', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password
      );

      // Simulate session expiration by clearing cookies
      await authPage.page.context().clearCookies();
      
      await authPage.goto('/admin/productos');
      await authPage.waitForUrl(/\/admin\/sign_in/);
      
      expect(await authPage.isLoggedOut()).toBe(true);
    });

    test('should handle concurrent login attempts', async ({ browser }) => {
      const credentials = TestFixtures.getLoginCredentials();
      
      // Create multiple browser contexts
      const context1 = await browser.newContext();
      const context2 = await browser.newContext();
      
      const page1 = await context1.newPage();
      const page2 = await context2.newPage();
      
      const authPage1 = new AuthPage(page1);
      const authPage2 = new AuthPage(page2);
      
      // Login simultaneously from both contexts
      await Promise.all([
        authPage1.loginAndWaitForRedirect(credentials.email, credentials.password),
        authPage2.loginAndWaitForRedirect(credentials.email, credentials.password)
      ]);
      
      expect(await authPage1.isLoggedIn()).toBe(true);
      expect(await authPage2.isLoggedIn()).toBe(true);
      
      await context1.close();
      await context2.close();
    });

    test('should maintain session across page refreshes', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password
      );
      
      await authPage.refresh();
      expect(await authPage.isLoggedIn()).toBe(true);
      
      await authPage.page.reload();
      await authPage.waitForPageLoad();
      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test('should handle session conflicts between tabs', async ({ context }) => {
      const credentials = TestFixtures.getLoginCredentials();
      
      // Login in first tab
      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password
      );
      
      // Open second tab and logout
      const secondPage = await context.newPage();
      const secondAuthPage = new AuthPage(secondPage);
      await secondAuthPage.logout();
      
      // Check first tab is also logged out
      await authPage.goto('/admin/productos');
      await authPage.waitForUrl(/\/admin\/sign_in/);
      expect(await authPage.isLoggedOut()).toBe(true);
      
      await secondPage.close();
    });
  });

  test.describe('Form Submission Edge Cases', () => {
    test('should handle rapid form submissions', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      
      // Submit form multiple times rapidly
      await Promise.all([
        authPage.submitLogin(),
        authPage.submitLogin(),
        authPage.submitLogin()
      ]);
      
      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test('should handle form submission with disabled JavaScript', async ({ page }) => {
      await page.setJavaScriptEnabled(false);
      
      const credentials = TestFixtures.getLoginCredentials();
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      await authPage.submitLogin();
      
      // Should still work with server-side processing
      await authPage.waitForUrl(/\/admin\/productos/);
    });

    test('should handle form submission during page navigation', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      
      // Start navigation while submitting form
      await Promise.all([
        authPage.submitLogin(),
        authPage.page.goBack()
      ]);
      
      // Should eventually end up in the right place
      await authPage.page.waitForTimeout(2000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/\/admin|\/sign_in/);
    });

    test('should handle form submission with network interruption', async ({ page }) => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      
      // Simulate network interruption
      await page.route('**/*', route => route.abort());
      
      try {
        await authPage.submitLogin();
      } catch (error) {
        // Expected to fail due to network interruption
      }
      
      // Restore network and retry
      await page.unroute('**/*');
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      await authPage.submitLogin();
      
      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });
  });

  test.describe('Input Validation Edge Cases', () => {
    test('should handle extremely long email addresses', async () => {
      const longEmail = 'a'.repeat(300) + '@example.com';
      
      await authPage.login(longEmail, 'password123');
      expect(await authPage.hasLoginError()).toBe(true);
    });

    test('should handle special characters in email', async () => {
      const specialEmails = [
        'user+tag@example.com',
        'user.name@example.com',
        'user_name@example.com',
        'user-name@example.com'
      ];
      
      for (const email of specialEmails) {
        await authPage.login(email, 'password123');
        expect(await authPage.hasLoginError()).toBe(true);
      }
    });

    test('should handle unicode characters in inputs', async () => {
      const unicodeData = {
        name: 'Café Münchën 日本語',
        email: 'test@café.com',
        password: 'pássword123!'
      };
      
      await authPage.register(
        unicodeData.name,
        unicodeData.email,
        unicodeData.password
      );
      
      // Should handle unicode gracefully
      expect(await authPage.hasRegistrationError()).toBe(true);
    });

    test('should handle null byte injection attempts', async () => {
      const nullByteEmail = 'test@example.com\x00.evil.com';
      const nullBytePassword = 'password\x00123';
      
      await authPage.login(nullByteEmail, nullBytePassword);
      expect(await authPage.hasLoginError()).toBe(true);
    });

    test('should handle leading/trailing whitespace', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.login(
        '  ' + credentials.email + '  ',
        '  ' + credentials.password + '  '
      );
      
      // Should trim whitespace and login successfully
      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });
  });

  test.describe('Browser Compatibility Edge Cases', () => {
    test('should handle missing form validation API', async ({ page }) => {
      // Disable HTML5 form validation
      await page.addInitScript(() => {
        HTMLFormElement.prototype.checkValidity = undefined;
        HTMLInputElement.prototype.setCustomValidity = undefined;
      });
      
      await authPage.goToLogin();
      await authPage.submitLogin();
      
      // Should still show server-side validation errors
      expect(await authPage.hasLoginError()).toBe(true);
    });

    test('should handle cookies disabled', async ({ context }) => {
      // Disable cookies
      await context.addCookies([]);
      await context.route('**/*', async route => {
        const response = await route.fetch();
        const headers = { ...response.headers() };
        delete headers['set-cookie'];
        route.fulfill({ response, headers });
      });
      
      const credentials = TestFixtures.getLoginCredentials();
      await authPage.login(credentials.email, credentials.password);
      
      // Should show appropriate error message
      expect(await authPage.hasLoginError()).toBe(true);
    });

    test('should handle local storage unavailable', async ({ page }) => {
      await page.addInitScript(() => {
        Object.defineProperty(window, 'localStorage', {
          value: null,
          writable: false
        });
      });
      
      const credentials = TestFixtures.getLoginCredentials();
      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password
      );
      
      expect(await authPage.isLoggedIn()).toBe(true);
    });
  });

  test.describe('Rate Limiting Edge Cases', () => {
    test('should reset rate limit after time window', async () => {
      // Trigger rate limit
      await authPage.attemptMultipleLogins('invalid@email.com', 'wrong', 5);
      
      // Wait for rate limit window to reset (assuming 1 minute)
      await authPage.page.waitForTimeout(61000);
      
      // Should be able to login again
      const credentials = TestFixtures.getLoginCredentials();
      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password
      );
      
      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test('should handle rate limiting per IP vs per user', async ({ browser }) => {
      // Test from different browser contexts (simulating different IPs)
      const context1 = await browser.newContext();
      const context2 = await browser.newContext();
      
      const page1 = await context1.newPage();
      const page2 = await context2.newPage();
      
      const authPage1 = new AuthPage(page1);
      const authPage2 = new AuthPage(page2);
      
      // Trigger rate limit on first context
      await authPage1.attemptMultipleLogins('invalid1@email.com', 'wrong', 5);
      
      // Second context should still be able to login
      const credentials = TestFixtures.getLoginCredentials();
      await authPage2.loginAndWaitForRedirect(
        credentials.email,
        credentials.password
      );
      
      expect(await authPage2.isLoggedIn()).toBe(true);
      
      await context1.close();
      await context2.close();
    });
  });

  test.describe('Accessibility Edge Cases', () => {
    test('should be navigable with keyboard only', async () => {
      await authPage.goToLogin();
      
      // Navigate form using only keyboard
      await authPage.page.keyboard.press('Tab'); // Focus email
      await authPage.page.keyboard.type('test@test.com');
      await authPage.page.keyboard.press('Tab'); // Focus password
      await authPage.page.keyboard.type('Abc123..');
      await authPage.page.keyboard.press('Tab'); // Focus remember me
      await authPage.page.keyboard.press('Tab'); // Focus submit
      await authPage.page.keyboard.press('Enter'); // Submit
      
      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test('should handle screen reader compatibility', async ({ page }) => {
      await authPage.goToLogin();
      
      // Check for proper ARIA labels and roles
      const emailInput = page.locator(authPage.loginEmailInput);
      const passwordInput = page.locator(authPage.loginPasswordInput);
      
      expect(await emailInput.getAttribute('type')).toBe('email');
      expect(await passwordInput.getAttribute('type')).toBe('password');
      
      // Check for associated labels
      const emailLabel = await emailInput.getAttribute('aria-label') || 
                        await page.locator('label[for]').textContent();
      expect(emailLabel).toBeTruthy();
    });

    test('should handle high contrast mode', async ({ page }) => {
      // Simulate high contrast mode
      await page.addStyleTag({
        content: `
          @media (prefers-contrast: high) {
            * { filter: contrast(2) !important; }
          }
        `
      });
      
      await authPage.goToLogin();
      
      // Form should still be usable
      const credentials = TestFixtures.getLoginCredentials();
      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password
      );
      
      expect(await authPage.isLoggedIn()).toBe(true);
    });
  });

  test.describe('Data Persistence Edge Cases', () => {
    test('should handle partial form data loss', async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail()
      });
      
      await authPage.goToRegistration();
      await authPage.fillInput(authPage.registrationNameInput, restaurantData.name);
      await authPage.fillInput(authPage.registrationEmailInput, restaurantData.email);
      
      // Simulate page refresh losing partial data
      await authPage.refresh();
      
      // Continue filling form
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        restaurantData.password
      );
      await authPage.submitRegistration();
      
      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test('should handle browser back/forward with form data', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      
      // Navigate away and back
      await authPage.goto('/');
      await authPage.goBack();
      
      // Form data might be preserved by browser
      const emailValue = await authPage.page.inputValue(authPage.loginEmailInput);
      
      if (!emailValue) {
        // If not preserved, fill again
        await authPage.fillLoginForm(credentials.email, credentials.password);
      }
      
      await authPage.submitLogin();
      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });
  });
});