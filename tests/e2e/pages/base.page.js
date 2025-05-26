export class BasePage {
  constructor(page) {
    this.page = page;
  }

  async goto(path = '/') {
    await this.page.goto(path);
    await this.waitForPageLoad();
  }

  async waitForPageLoad() {
    await this.page.waitForLoadState('networkidle');
  }

  async waitForElement(selector, options = {}) {
    return await this.page.waitForSelector(selector, { timeout: 10000, ...options });
  }

  async clickElement(selector) {
    await this.waitForElement(selector);
    await this.page.click(selector);
  }

  async fillInput(selector, value) {
    await this.waitForElement(selector);
    await this.page.fill(selector, value);
  }

  async getText(selector) {
    await this.waitForElement(selector);
    return await this.page.textContent(selector);
  }

  async isVisible(selector) {
    try {
      await this.page.waitForSelector(selector, { timeout: 5000 });
      return await this.page.isVisible(selector);
    } catch {
      return false;
    }
  }

  async scrollToElement(selector) {
    await this.page.locator(selector).scrollIntoViewIfNeeded();
  }

  async takeScreenshot(name) {
    await this.page.screenshot({ path: `tests/screenshots/${name}.png`, fullPage: true });
  }

  async waitForUrl(url) {
    await this.page.waitForURL(url);
  }

  async waitForResponse(urlPattern) {
    return await this.page.waitForResponse(urlPattern);
  }

  async selectOption(selector, value) {
    await this.waitForElement(selector);
    await this.page.selectOption(selector, value);
  }

  async uploadFile(selector, filePath) {
    await this.waitForElement(selector);
    await this.page.setInputFiles(selector, filePath);
  }

  async waitForToast() {
    await this.page.waitForSelector('[data-testid="toast"], .toast, .alert', { timeout: 5000 });
  }

  async getToastMessage() {
    const toast = await this.page.locator('[data-testid="toast"], .toast, .alert').first();
    return await toast.textContent();
  }

  async dismissToast() {
    const closeButton = this.page.locator('[data-testid="toast-close"], .toast .close, .alert .close');
    if (await closeButton.isVisible()) {
      await closeButton.click();
    }
  }

  async waitForSpinner() {
    await this.page.waitForSelector('.spinner, .loading, [data-testid="spinner"]', { state: 'hidden', timeout: 10000 });
  }

  async refresh() {
    await this.page.reload();
    await this.waitForPageLoad();
  }

  async goBack() {
    await this.page.goBack();
    await this.waitForPageLoad();
  }
}