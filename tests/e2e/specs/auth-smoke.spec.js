import { test, expect } from '@playwright/test';
import { AuthPage } from '../pages/auth.page.js';
import { TestFixtures } from '../utils/fixtures.js';

test.describe('Authentication Smoke Tests', () => {
  let authPage;

  test.beforeEach(async ({ page }) => {
    authPage = new AuthPage(page);
  });

  test('should load login page', async () => {
    await authPage.goToLogin();
    expect(await authPage.isVisible(authPage.loginEmailInput)).toBe(true);
    expect(await authPage.isVisible(authPage.loginPasswordInput)).toBe(true);
  });

  test('should load registration page', async () => {
    await authPage.goToRegistration();
    expect(await authPage.isVisible(authPage.registrationNameInput)).toBe(true);
    expect(await authPage.isVisible(authPage.registrationEmailInput)).toBe(true);
  });

  test('should login with valid credentials', async () => {
    const credentials = TestFixtures.getLoginCredentials();
    
    await authPage.goToLogin();
    await authPage.fillLoginForm(credentials.email, credentials.password);
    await authPage.submitLogin();
    
    await authPage.page.waitForTimeout(3000);
    const currentUrl = authPage.page.url();
    expect(currentUrl).toMatch(/admin|productos/);
  });

  test('should show error with invalid credentials', async () => {
    await authPage.goToLogin();
    await authPage.fillLoginForm('invalid@test.com', 'wrongpassword');
    await authPage.submitLogin();
    
    await authPage.page.waitForTimeout(2000);
    const hasError = await authPage.hasLoginError();
    expect(hasError).toBe(true);
  });

  test('should logout successfully', async () => {
    const credentials = TestFixtures.getLoginCredentials();
    
    await authPage.goToLogin();
    await authPage.fillLoginForm(credentials.email, credentials.password);
    await authPage.submitLogin();
    
    await authPage.page.waitForTimeout(2000);
    await authPage.goToLogout();
    
    await authPage.page.waitForTimeout(2000);
    const currentUrl = authPage.page.url();
    expect(currentUrl).toMatch(/\/$|sign_in|sign_out/);
  });
});