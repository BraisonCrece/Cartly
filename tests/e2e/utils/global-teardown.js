async function globalTeardown() {
  const { chromium } = require('@playwright/test');
  
  console.log('🧹 Starting global test teardown...');
  
  try {
    // Launch browser for cleanup tasks
    const browser = await chromium.launch();
    const page = await browser.newPage();
    
    try {
      // Login as test user to perform cleanup
      await page.goto('http://localhost:3000/admin/sign_in');
      await page.fill('[name="restaurant[email]"]', 'test@test.com');
      await page.fill('[name="restaurant[password]"]', 'Abc123..');
      await page.click('[type="submit"]');
      
      await page.waitForTimeout(2000);
      
      // Logout to ensure clean state
      await page.goto('http://localhost:3000/admin/sign_out');
      await page.waitForTimeout(1000);
      
      console.log('✅ Test session cleanup completed');
      
    } catch (error) {
      console.log('⚠️  Cleanup error (non-critical):', error.message);
    } finally {
      await browser.close();
    }
    
    // Clean up any remaining test artifacts
    const fs = require('fs').promises;
    const path = require('path');
    
    try {
      // Clean up temporary screenshots if they exist
      const screenshotsDir = path.join(__dirname, '../../../tests/screenshots');
      const files = await fs.readdir(screenshotsDir).catch(() => []);
      
      for (const file of files) {
        if (file.startsWith('temp-') || file.startsWith('test-')) {
          await fs.unlink(path.join(screenshotsDir, file)).catch(() => {});
        }
      }
      
      console.log('✅ Temporary files cleaned up');
    } catch (error) {
      console.log('⚠️  File cleanup warning:', error.message);
    }
    
  } catch (error) {
    console.log('⚠️  Global teardown error:', error.message);
  }
  
  console.log('✅ Global teardown completed');
}

module.exports = globalTeardown;