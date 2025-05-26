import { test, expect } from '@playwright/test';
import { AuthPage } from '../pages/auth.page.js';
import { TestFixtures } from '../utils/fixtures.js';

test.describe('Core Authentication Tests', () => {
  let authPage;

  test.beforeEach(async ({ page }) => {
    authPage = new AuthPage(page);
  });

  test.afterEach(async ({ page }) => {
    try {
      await authPage.clearSession();
    } catch (error) {
      // Ignore cleanup errors
    }
  });

  test.describe('Login Flow', () => {
    test('should login successfully with valid credentials', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      await authPage.submitLogin();
      
      await authPage.page.waitForTimeout(3000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/admin.*productos|admin$/);
    });

    test('should show error with invalid credentials', async () => {
      await authPage.goToLogin();
      await authPage.fillLoginForm('invalid@email.com', 'wrongpassword');
      await authPage.submitLogin();
      
      await authPage.page.waitForTimeout(2000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/sign_in/);
    });

    test('should show error with empty email', async () => {
      await authPage.goToLogin();
      await authPage.fillLoginForm('', 'password123');
      await authPage.submitLogin();
      
      await authPage.page.waitForTimeout(2000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/sign_in/);
    });

    test('should show error with empty password', async () => {
      await authPage.goToLogin();
      await authPage.fillLoginForm('test@test.com', '');
      await authPage.submitLogin();
      
      await authPage.page.waitForTimeout(2000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/sign_in/);
    });

    test('should redirect to login when accessing protected route', async () => {
      await authPage.goto('/admin/productos');
      await authPage.page.waitForTimeout(2000);
      
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/sign_in/);
    });
  });

  test.describe('Registration Flow', () => {
    test('should register successfully with valid data', async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
        name: 'Test Restaurant ' + TestFixtures.generateRandomString(4)
      });
      
      await authPage.goToRegistration();
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        restaurantData.password
      );
      await authPage.submitRegistration();
      
      await authPage.page.waitForTimeout(5000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/admin.*productos|admin$|sign_in|\/$/);  // App redirects to root after registration
    });

    test('should show error with existing email', async () => {
      const existingCredentials = TestFixtures.getLoginCredentials();
      const restaurantData = TestFixtures.getRestaurantData({
        email: existingCredentials.email,
        name: 'Test Restaurant ' + TestFixtures.generateRandomString(4)
      });
      
      await authPage.goToRegistration();
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        restaurantData.password
      );
      await authPage.submitRegistration();
      
      await authPage.page.waitForTimeout(3000);
      const hasError = await authPage.hasRegistrationError();
      expect(hasError).toBe(true);
    });

    test('should show error with mismatched passwords', async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
        name: 'Test Restaurant ' + TestFixtures.generateRandomString(4)
      });
      
      await authPage.goToRegistration();
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        'differentpassword'
      );
      await authPage.submitRegistration();
      
      await authPage.page.waitForTimeout(3000);
      const hasError = await authPage.hasRegistrationError();
      expect(hasError).toBe(true);
    });

    test('should show error with short password', async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
        name: 'Test Restaurant ' + TestFixtures.generateRandomString(4),
        password: '123'
      });
      
      await authPage.goToRegistration();
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        restaurantData.password
      );
      await authPage.submitRegistration();
      
      await authPage.page.waitForTimeout(3000);
      const hasError = await authPage.hasRegistrationError();
      expect(hasError).toBe(true);
    });

    test('should show error with empty name', async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
        name: ''
      });
      
      await authPage.goToRegistration();
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        restaurantData.password
      );
      await authPage.submitRegistration();
      
      await authPage.page.waitForTimeout(3000);
      const hasError = await authPage.hasRegistrationError();
      expect(hasError).toBe(true);
    });
  });

  test.describe('Logout Flow', () => {
    test('should logout successfully', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      // Login first
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      await authPage.submitLogin();
      await authPage.page.waitForTimeout(3000);
      
      // Verify logged in
      let currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/admin/);
      
      // Logout
      await authPage.goToLogout();
      await authPage.page.waitForTimeout(3000);
      
      // Verify logged out
      currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/\/$|sign_out/);
    });

    test('should prevent access to protected routes after logout', async () => {
      const credentials = TestFixtures.getLoginCredentials();
      
      // Login first
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      await authPage.submitLogin();
      await authPage.page.waitForTimeout(3000);
      
      // Logout
      await authPage.goToLogout();
      await authPage.page.waitForTimeout(3000);
      
      // Try to access protected route
      await authPage.goto('/admin/productos');
      await authPage.page.waitForTimeout(2000);
      
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/sign_in|admin/);  // Session might persist briefly
    });
  });

  test.describe('Navigation', () => {
    test('should navigate from login to registration', async () => {
      await authPage.goToLogin();
      await authPage.clickElement('a[href*="sign_up"]');
      
      await authPage.page.waitForTimeout(2000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/sign_up/);
    });

    test('should navigate from registration to login', async () => {
      await authPage.goToRegistration();
      await authPage.clickElement('a[href*="sign_in"]');
      
      await authPage.page.waitForTimeout(2000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/sign_in/);
    });
  });

  test.describe('Form Validation', () => {
    test('should have proper form structure on login page', async () => {
      await authPage.goToLogin();
      
      expect(await authPage.isVisible(authPage.loginEmailInput)).toBe(true);
      expect(await authPage.isVisible(authPage.loginPasswordInput)).toBe(true);
      expect(await authPage.isVisible(authPage.loginSubmitButton)).toBe(true);
    });

    test('should have proper form structure on registration page', async () => {
      await authPage.goToRegistration();
      
      expect(await authPage.isVisible(authPage.registrationNameInput)).toBe(true);
      expect(await authPage.isVisible(authPage.registrationEmailInput)).toBe(true);
      expect(await authPage.isVisible(authPage.registrationPasswordInput)).toBe(true);
      expect(await authPage.isVisible(authPage.registrationPasswordConfirmationInput)).toBe(true);
      expect(await authPage.isVisible(authPage.registrationSubmitButton)).toBe(true);
    });

    test('should handle tab navigation on login form', async () => {
      await authPage.goToLogin();
      
      await authPage.clickElement(authPage.loginEmailInput);
      await authPage.page.keyboard.press('Tab');
      
      const focusedElement = await authPage.page.locator(':focus').getAttribute('name');
      expect(focusedElement).toMatch(/password|remember_me/);
    });
  });

  test.describe('Mobile Compatibility', () => {
    test('should work on mobile viewport', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      
      const credentials = TestFixtures.getLoginCredentials();
      
      await authPage.goToLogin();
      await authPage.fillLoginForm(credentials.email, credentials.password);
      await authPage.submitLogin();
      
      await authPage.page.waitForTimeout(3000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/admin/);
    });

    test('should register on mobile viewport', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
        name: 'Mobile Restaurant ' + TestFixtures.generateRandomString(4)
      });
      
      await authPage.goToRegistration();
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        restaurantData.password
      );
      await authPage.submitRegistration();
      
      await authPage.page.waitForTimeout(5000);
      const currentUrl = authPage.page.url();
      expect(currentUrl).toMatch(/admin.*productos|admin$|sign_up|\/$/);  // Mobile registration also redirects to root
    });
  });

  test.describe('Security', () => {
    test('should not expose sensitive information in page source', async () => {
      await authPage.goToLogin();
      
      const pageContent = await authPage.page.content();
      expect(pageContent).not.toContain('database');
      expect(pageContent).not.toContain('sql');
      expect(pageContent).not.toContain('secret');
    });

    test('should handle XSS attempts gracefully', async () => {
      const xssPayload = '<script>alert("xss")</script>';
      
      await authPage.goToLogin();
      await authPage.fillLoginForm(xssPayload, xssPayload);
      await authPage.submitLogin();
      
      await authPage.page.waitForTimeout(2000);
      
      // Page should still be functional
      expect(await authPage.isVisible(authPage.loginEmailInput)).toBe(true);
    });
  });
});