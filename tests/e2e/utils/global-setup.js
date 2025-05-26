async function globalSetup() {
  const { chromium } = require('@playwright/test');
  
  console.log('🔧 Starting global test setup...');
  
  // Wait for server to be ready
  const maxRetries = 30;
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      const response = await fetch('http://localhost:3000');
      if (response.ok) {
        console.log('✅ Rails server is ready');
        break;
      }
    } catch (error) {
      retries++;
      if (retries === maxRetries) {
        throw new Error('❌ Rails server failed to start within timeout');
      }
      console.log(`⏳ Waiting for Rails server... (${retries}/${maxRetries})`);
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
  
  // Launch browser for setup tasks
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  try {
    // Verify test user exists by attempting login
    await page.goto('http://localhost:3000/admin/sign_in');
    await page.fill('[name="restaurant[email]"]', 'test@test.com');
    await page.fill('[name="restaurant[password]"]', 'Abc123..');
    await page.click('[type="submit"]');
    
    await page.waitForTimeout(3000);
    const currentUrl = page.url();
    
    if (currentUrl.includes('admin')) {
      console.log('✅ Test user authentication verified');
    } else {
      console.log('⚠️  Test user may not exist or credentials invalid');
    }
    
    // Logout to clean state
    await page.goto('http://localhost:3000/admin/sign_out');
    await page.waitForTimeout(2000);
    
  } catch (error) {
    console.log('⚠️  Setup verification failed:', error.message);
  } finally {
    await browser.close();
  }
  
  console.log('✅ Global setup completed');
}

module.exports = globalSetup;