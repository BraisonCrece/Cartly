import { BasePage } from './base.page.js';

export class AuthPage extends BasePage {
  constructor(page) {
    super(page);
    
    // Login selectors
    this.loginEmailInput = '[name="restaurant[email]"]';
    this.loginPasswordInput = '[name="restaurant[password]"]';
    this.rememberMeCheckbox = '[name="restaurant[remember_me]"]';
    this.loginSubmitButton = '[type="submit"]';
    
    // Registration selectors
    this.registrationNameInput = '[name="restaurant[name]"]';
    this.registrationEmailInput = '[name="restaurant[email]"]';
    this.registrationPasswordInput = '[name="restaurant[password]"]';
    this.registrationPasswordConfirmationInput = '[name="restaurant[password_confirmation]"]';
    this.registrationSubmitButton = '[type="submit"]';
    
    // Password recovery selectors
    this.passwordRecoveryEmailInput = '[name="restaurant[email]"]';
    this.passwordRecoverySubmitButton = '[type="submit"]';
    
    // Common selectors
    this.errorMessages = '#error_explanation, .bg-red-100, [role="alert"]';
    this.successMessages = '.bg-green-100, [data-controller="notifications"]';
    this.formErrors = '#error_explanation';
    this.deviseLinks = 'a[href*="sign"], a[href*="password"]';
  }

  // Navigation methods
  async goToLogin() {
    await this.goto('/admin/sign_in');
    await this.waitForElement(this.loginEmailInput);
  }

  async goToRegistration() {
    await this.goto('/admin/sign_up');
    await this.waitForElement(this.registrationNameInput);
  }

  async goToPasswordRecovery() {
    await this.goto('/admin/password/new');
    await this.waitForElement(this.passwordRecoveryEmailInput);
  }

  async goToLogout() {
    await this.goto('/admin/sign_out');
  }

  // Login methods
  async fillLoginForm(email, password, rememberMe = false) {
    await this.fillInput(this.loginEmailInput, email);
    await this.fillInput(this.loginPasswordInput, password);
    
    if (rememberMe) {
      await this.clickElement(this.rememberMeCheckbox);
    }
  }

  async submitLogin() {
    await this.clickElement(this.loginSubmitButton);
  }

  async login(email, password, rememberMe = false) {
    await this.goToLogin();
    await this.fillLoginForm(email, password, rememberMe);
    await this.submitLogin();
  }

  async loginAndWaitForRedirect(email, password, expectedUrl = '/admin/productos') {
    await this.login(email, password);
    await this.page.waitForTimeout(2000); // Wait for any redirects
    const currentUrl = this.page.url();
    if (!currentUrl.includes(expectedUrl) && !currentUrl.includes('sign_in')) {
      await this.waitForUrl(new RegExp(expectedUrl));
    }
  }

  // Registration methods
  async fillRegistrationForm(name, email, password, passwordConfirmation) {
    await this.fillInput(this.registrationNameInput, name);
    await this.fillInput(this.registrationEmailInput, email);
    await this.fillInput(this.registrationPasswordInput, password);
    await this.fillInput(this.registrationPasswordConfirmationInput, passwordConfirmation);
  }

  async submitRegistration() {
    await this.clickElement(this.registrationSubmitButton);
  }

  async register(name, email, password, passwordConfirmation = null) {
    const confirmPassword = passwordConfirmation || password;
    await this.goToRegistration();
    await this.fillRegistrationForm(name, email, password, confirmPassword);
    await this.submitRegistration();
  }

  async registerAndWaitForRedirect(name, email, password, expectedUrl = '/admin/productos') {
    await this.register(name, email, password);
    await this.page.waitForTimeout(2000); // Wait for any redirects
    const currentUrl = this.page.url();
    if (!currentUrl.includes(expectedUrl) && !currentUrl.includes('sign_up')) {
      await this.waitForUrl(new RegExp(expectedUrl));
    }
  }

  // Password recovery methods
  async fillPasswordRecoveryForm(email) {
    await this.fillInput(this.passwordRecoveryEmailInput, email);
  }

  async submitPasswordRecovery() {
    await this.clickElement(this.passwordRecoverySubmitButton);
  }

  async requestPasswordReset(email) {
    await this.goToPasswordRecovery();
    await this.fillPasswordRecoveryForm(email);
    await this.submitPasswordRecovery();
  }

  // Logout methods
  async logout() {
    await this.goToLogout();
    await this.page.waitForTimeout(2000); // Wait for redirect to complete
    await this.waitForPageLoad();
  }

  // Validation methods
  async hasLoginError() {
    const hasFlashAlert = await this.isVisible('.bg-red-100');
    const hasFormError = await this.isVisible('#error_explanation');
    return hasFlashAlert || hasFormError;
  }

  async hasRegistrationError() {
    return await this.isVisible('#error_explanation');
  }

  async hasSuccessMessage() {
    return await this.isVisible('.bg-green-100');
  }

  async getErrorMessage() {
    if (await this.isVisible('.bg-red-100')) {
      return await this.getText('.bg-red-100');
    }
    if (await this.isVisible('#error_explanation')) {
      return await this.getText('#error_explanation');
    }
    return null;
  }

  async getSuccessMessage() {
    if (await this.isVisible('.bg-green-100')) {
      return await this.getText('.bg-green-100');
    }
    return null;
  }

  // Authentication status checks
  async isLoggedIn() {
    try {
      await this.goto('/admin/productos');
      await this.page.waitForURL(/\/admin\/productos/, { timeout: 5000 });
      return true;
    } catch {
      return false;
    }
  }

  async isLoggedOut() {
    try {
      await this.goto('/admin/productos');
      await this.page.waitForURL(/\/admin\/sign_in/, { timeout: 5000 });
      return true;
    } catch {
      return false;
    }
  }

  // Form validation helpers
  async getFieldError(fieldName) {
    const fieldErrorSelector = `[name="restaurant[${fieldName}]"] + .error, .field_with_errors [name="restaurant[${fieldName}]"]`;
    if (await this.isVisible(fieldErrorSelector)) {
      return await this.getText(fieldErrorSelector);
    }
    return null;
  }

  async isFieldHighlighted(fieldName) {
    const fieldSelector = `[name="restaurant[${fieldName}]"]`;
    const field = await this.page.locator(fieldSelector);
    const classes = await field.getAttribute('class');
    return classes && (classes.includes('error') || classes.includes('invalid'));
  }

  // Navigation link helpers
  async clickForgotPasswordLink() {
    await this.clickElement('a[href*="password"]');
  }

  async clickSignUpLink() {
    await this.clickElement('a[href*="sign_up"]');
  }

  async clickSignInLink() {
    await this.clickElement('a[href*="sign_in"]');
  }

  // Rate limiting helpers
  async attemptMultipleLogins(email, password, attempts = 5) {
    const results = [];
    
    for (let i = 0; i < attempts; i++) {
      await this.goToLogin();
      await this.fillLoginForm(email, password);
      await this.submitLogin();
      
      const hasError = await this.hasLoginError();
      const errorMessage = hasError ? await this.getErrorMessage() : null;
      
      results.push({
        attempt: i + 1,
        hasError,
        errorMessage,
        isRateLimited: errorMessage && errorMessage.includes('rate limit')
      });
    }
    
    return results;
  }

  // Session helpers
  async clearSession() {
    try {
      await this.page.context().clearCookies();
      await this.page.evaluate(() => {
        localStorage.clear();
        sessionStorage.clear();
      });
    } catch (error) {
      // Context might be closed, ignore the error
    }
  }

  // Mobile specific helpers
  async loginOnMobile(email, password) {
    await this.goToLogin();
    
    // Ensure mobile viewport
    await this.page.setViewportSize({ width: 375, height: 667 });
    
    // Mobile-specific interactions
    await this.fillInput(this.loginEmailInput, email);
    await this.page.keyboard.press('Tab'); // Move to next field
    await this.fillInput(this.loginPasswordInput, password);
    
    // Scroll to submit button if needed
    await this.scrollToElement(this.loginSubmitButton);
    await this.submitLogin();
  }

  // Form interaction helpers
  async tabThroughLoginForm() {
    await this.clickElement(this.loginEmailInput);
    await this.page.keyboard.press('Tab');
    await this.page.keyboard.press('Tab');
    await this.page.keyboard.press('Tab');
    return await this.page.locator(':focus').getAttribute('type');
  }

  async checkPasswordVisibility() {
    const passwordField = this.page.locator(this.loginPasswordInput);
    return await passwordField.getAttribute('type') === 'password';
  }
}