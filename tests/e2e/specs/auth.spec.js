import { test, expect } from "@playwright/test";
import { AuthPage } from "../pages/auth.page.js";
import { TestFixtures } from "../utils/fixtures.js";

test.describe("Authentication", () => {
  let authPage;

  test.beforeEach(async ({ page }) => {
    authPage = new AuthPage(page);
  });

  test.afterEach(async ({ page }) => {
    await authPage.clearSession();
  });

  test.describe("Login", () => {
    test("should login successfully with valid credentials", async () => {
      const credentials = TestFixtures.getLoginCredentials();

      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password,
        "/admin/productos",
      );

      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test("should show error with invalid email", async () => {
      await authPage.login("invalid@email.com", "wrongpassword");

      expect(await authPage.hasLoginError()).toBe(true);
      const errorMessage = await authPage.getErrorMessage();
      expect(errorMessage).toBeTruthy();
    });

    test("should show error with empty fields", async () => {
      await authPage.goToLogin();
      await authPage.submitLogin();

      expect(await authPage.hasLoginError()).toBe(true);
    });

    test("should show error with invalid password", async () => {
      const credentials = TestFixtures.getLoginCredentials();
      await authPage.login(credentials.email, "wrongpassword");

      expect(await authPage.hasLoginError()).toBe(true);
    });

    test("should handle remember me functionality", async () => {
      const credentials = TestFixtures.getLoginCredentials();

      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password,
        "/admin/productos",
        true,
      );

      // Check if session persists after closing browser
      await authPage.page.context().close();
      const newContext = await authPage.page.context().browser().newContext();
      const newPage = await newContext.newPage();
      const newAuthPage = new AuthPage(newPage);

      await newAuthPage.goto("/admin/productos");
      expect(await newAuthPage.isLoggedIn()).toBe(true);

      await newContext.close();
    });

    test("should enforce rate limiting after multiple failed attempts", async () => {
      const results = await authPage.attemptMultipleLogins(
        "test@invalid.com",
        "wrongpassword",
        5,
      );

      const lastAttempt = results[results.length - 1];
      expect(lastAttempt.hasError).toBe(true);

      // Check if rate limiting is triggered
      const rateLimitedAttempts = results.filter((r) => r.isRateLimited);
      expect(rateLimitedAttempts.length).toBeGreaterThan(0);
    });

    test("should redirect to login when accessing protected route while logged out", async () => {
      await authPage.goto("/admin/productos");
      await authPage.waitForUrl(/\/admin\/sign_in/);

      expect(await authPage.isLoggedOut()).toBe(true);
    });

    test("should handle tab navigation through login form", async () => {
      await authPage.goToLogin();
      const focusedElementType = await authPage.tabThroughLoginForm();
      expect(focusedElementType).toBe("submit");
    });

    test("should mask password input", async () => {
      await authPage.goToLogin();
      expect(await authPage.checkPasswordVisibility()).toBe(true);
    });
  });

  test.describe("Registration", () => {
    test("should register successfully with valid data", async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
      });

      await authPage.registerAndWaitForRedirect(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        "/admin/productos",
      );

      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test("should show error with existing email", async () => {
      const existingCredentials = TestFixtures.getLoginCredentials();
      const restaurantData = TestFixtures.getRestaurantData({
        email: existingCredentials.email,
      });

      await authPage.register(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
      );

      expect(await authPage.hasRegistrationError()).toBe(true);
      const errorMessage = await authPage.getErrorMessage();
      expect(errorMessage).toContain("email");
    });

    test("should show error with mismatched passwords", async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
      });

      await authPage.register(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        "differentpassword",
      );

      expect(await authPage.hasRegistrationError()).toBe(true);
    });

    test("should show error with weak password", async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
        password: "123",
      });

      await authPage.register(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
      );

      expect(await authPage.hasRegistrationError()).toBe(true);
    });

    test("should show error with empty required fields", async () => {
      await authPage.goToRegistration();
      await authPage.submitRegistration();

      expect(await authPage.hasRegistrationError()).toBe(true);
    });

    test("should show error with invalid email format", async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        email: "invalid-email-format",
      });

      await authPage.register(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
      );

      expect(await authPage.hasRegistrationError()).toBe(true);
    });

    test("should validate restaurant name length", async () => {
      const restaurantData = TestFixtures.getRestaurantData({
        name: "A".repeat(256), // Exceeds 255 character limit
        email: TestFixtures.generateRandomEmail(),
      });

      await authPage.register(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
      );

      expect(await authPage.hasRegistrationError()).toBe(true);
    });
  });

  test.describe("Password Recovery", () => {
    test("should request password reset with valid email", async () => {
      const credentials = TestFixtures.getLoginCredentials();

      await authPage.requestPasswordReset(credentials.email);

      // Should show success message or redirect
      expect(
        (await authPage.hasSuccessMessage()) ||
          authPage.page.url().includes("sign_in"),
      ).toBe(true);
    });

    test("should handle password reset with invalid email", async () => {
      await authPage.requestPasswordReset("nonexistent@email.com");

      // Should still show success to prevent email enumeration
      expect(
        (await authPage.hasSuccessMessage()) ||
          authPage.page.url().includes("sign_in"),
      ).toBe(true);
    });

    test("should show error with empty email field", async () => {
      await authPage.goToPasswordRecovery();
      await authPage.submitPasswordRecovery();

      expect(await authPage.hasLoginError()).toBe(true);
    });

    test("should show error with invalid email format", async () => {
      await authPage.requestPasswordReset("invalid-email");

      expect(await authPage.hasLoginError()).toBe(true);
    });
  });

  test.describe("Logout", () => {
    test("should logout successfully", async () => {
      const credentials = TestFixtures.getLoginCredentials();

      // Login first
      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password,
      );

      // Then logout
      await authPage.logout();

      expect(await authPage.isLoggedOut()).toBe(true);
    });

    test("should redirect to homepage after logout", async () => {
      const credentials = TestFixtures.getLoginCredentials();

      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password,
      );

      await authPage.logout();
      await authPage.waitForUrl("/");

      expect(authPage.page.url()).toMatch(/\/$|\/\?/);
    });

    test("should prevent access to protected routes after logout", async () => {
      const credentials = TestFixtures.getLoginCredentials();

      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password,
      );

      await authPage.logout();
      await authPage.goto("/admin/productos");

      await authPage.waitForUrl(/\/admin\/sign_in/);
      expect(await authPage.isLoggedOut()).toBe(true);
    });
  });

  test.describe("Navigation", () => {
    test("should navigate from login to registration", async () => {
      await authPage.goToLogin();
      await authPage.clickSignUpLink();

      await authPage.waitForUrl(/\/admin\/sign_up/);
      expect(await authPage.isVisible(authPage.registrationNameInput)).toBe(
        true,
      );
    });

    test("should navigate from registration to login", async () => {
      await authPage.goToRegistration();
      await authPage.clickSignInLink();

      await authPage.waitForUrl(/\/admin\/sign_in/);
      expect(await authPage.isVisible(authPage.loginEmailInput)).toBe(true);
    });

    test("should navigate from login to password recovery", async () => {
      await authPage.goToLogin();
      await authPage.clickForgotPasswordLink();

      await authPage.waitForUrl(/\/admin\/password/);
      expect(
        await authPage.isVisible(authPage.passwordRecoveryEmailInput),
      ).toBe(true);
    });

    test("should navigate back to login from password recovery", async () => {
      await authPage.goToPasswordRecovery();
      await authPage.clickSignInLink();

      await authPage.waitForUrl(/\/admin\/sign_in/);
      expect(await authPage.isVisible(authPage.loginEmailInput)).toBe(true);
    });
  });

  test.describe("Mobile Authentication", () => {
    test("should login successfully on mobile device", async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });

      const credentials = TestFixtures.getLoginCredentials();
      await authPage.loginOnMobile(credentials.email, credentials.password);

      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test("should register successfully on mobile device", async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });

      const restaurantData = TestFixtures.getRestaurantData({
        email: TestFixtures.generateRandomEmail(),
      });

      await authPage.goToRegistration();
      await authPage.fillRegistrationForm(
        restaurantData.name,
        restaurantData.email,
        restaurantData.password,
        restaurantData.password,
      );
      await authPage.scrollToElement(authPage.registrationSubmitButton);
      await authPage.submitRegistration();

      await authPage.waitForUrl(/\/admin\/productos/);
      expect(await authPage.isLoggedIn()).toBe(true);
    });

    test("should handle form validation on mobile", async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });

      await authPage.goToLogin();
      await authPage.submitLogin();

      expect(await authPage.hasLoginError()).toBe(true);
    });
  });

  test.describe("Security", () => {
    test("should not expose sensitive information in error messages", async () => {
      await authPage.login("test@example.com", "wrongpassword");

      const errorMessage = await authPage.getErrorMessage();
      expect(errorMessage).not.toContain("password");
      expect(errorMessage).not.toContain("database");
      expect(errorMessage).not.toContain("sql");
    });

    test("should handle XSS attempts in login form", async () => {
      const xssPayload = '<script>alert("xss")</script>';

      await authPage.login(xssPayload, xssPayload);

      // Should not execute script
      const alertDialogs = [];
      authPage.page.on("dialog", (dialog) => {
        alertDialogs.push(dialog);
        dialog.dismiss();
      });

      expect(alertDialogs.length).toBe(0);
    });

    test("should clear sensitive data on logout", async () => {
      const credentials = TestFixtures.getLoginCredentials();

      await authPage.loginAndWaitForRedirect(
        credentials.email,
        credentials.password,
      );

      await authPage.logout();

      // Check that session data is cleared
      const sessionData = await authPage.page.evaluate(() => {
        return {
          localStorage: Object.keys(localStorage),
          sessionStorage: Object.keys(sessionStorage),
        };
      });

      expect(sessionData.localStorage.length).toBe(0);
      expect(sessionData.sessionStorage.length).toBe(0);
    });
  });
});
