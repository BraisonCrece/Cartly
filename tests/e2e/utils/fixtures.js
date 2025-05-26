export class TestFixtures {
  static getRestaurantData(overrides = {}) {
    return {
      name: 'Test Restaurant',
      email: 'test@restaurant.com',
      password: 'Test123!',
      password_confirmation: 'Test123!',
      ...overrides
    };
  }

  static getLoginCredentials() {
    return {
      email: 'test@test.com',
      password: 'Abc123..'
    };
  }

  static getDishData(overrides = {}) {
    return {
      name: 'Test Dish',
      description: 'A delicious test dish',
      price: '15.99',
      category: 'Starters',
      allergens: ['Gluten'],
      ...overrides
    };
  }

  static getDrinkData(overrides = {}) {
    return {
      name: 'Test Drink',
      description: 'A refreshing test drink',
      price: '5.99',
      category: 'Beverages',
      alcohol_content: '5%',
      ...overrides
    };
  }

  static getWineData(overrides = {}) {
    return {
      name: 'Test Wine',
      description: 'A fine test wine',
      price: '25.99',
      grape_variety: 'Tempranillo',
      year: '2020',
      origin_denomination: 'Rioja',
      alcohol_content: '13.5%',
      ...overrides
    };
  }

  static getCategoryData(overrides = {}) {
    return {
      name: 'Test Category',
      description: 'A test category',
      position: 1,
      ...overrides
    };
  }

  static getAllergenData(overrides = {}) {
    return {
      name: 'Test Allergen',
      icon: 'test-icon',
      ...overrides
    };
  }

  static getSettingsData(overrides = {}) {
    return {
      restaurant_name: 'Updated Restaurant Name',
      theme: 'dark',
      language: 'en',
      currency: 'EUR',
      ...overrides
    };
  }

  static getValidImageFile() {
    return {
      name: 'test-image.jpg',
      type: 'image/jpeg',
      size: 1024 * 1024
    };
  }

  static getInvalidImageFile() {
    return {
      name: 'test-file.txt',
      type: 'text/plain',
      size: 1024
    };
  }

  static getMenuCategories() {
    return [
      'Starters',
      'Main Courses',
      'Desserts',
      'Beverages',
      'Wines'
    ];
  }

  static getCommonAllergens() {
    return [
      'Gluten',
      'Dairy',
      'Nuts',
      'Seafood',
      'Eggs',
      'Soy'
    ];
  }

  static getTestTranslations() {
    return {
      spanish: 'Plato de prueba',
      english: 'Test dish',
      french: 'Plat de test',
      italian: 'Piatto di prova'
    };
  }

  static generateRandomString(length = 8) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  static generateRandomEmail() {
    return `test_${this.generateRandomString(6)}@example.com`;
  }

  static generateRandomPrice() {
    return (Math.random() * 50 + 5).toFixed(2);
  }
}

export class DatabaseHelpers {
  static async cleanDatabase(page) {
    // Helper to clean test data if needed
    await page.evaluate(() => {
      // This would need to be implemented based on your cleanup strategy
      console.log('Database cleanup would go here');
    });
  }

  static async seedTestData(page) {
    // Helper to seed minimal test data
    await page.evaluate(() => {
      console.log('Database seeding would go here');
    });
  }
}

export class ApiHelpers {
  static async createTestRestaurant(page, restaurantData = {}) {
    const data = TestFixtures.getRestaurantData(restaurantData);
    
    await page.goto('/admin/sign_up');
    await page.fill('[name="restaurant[email]"]', data.email);
    await page.fill('[name="restaurant[password]"]', data.password);
    await page.fill('[name="restaurant[password_confirmation]"]', data.password_confirmation);
    await page.click('[type="submit"]');
    
    return data;
  }

  static async loginAsRestaurant(page, credentials = {}) {
    const loginData = { ...TestFixtures.getLoginCredentials(), ...credentials };
    
    await page.goto('/admin/sign_in');
    await page.fill('[name="restaurant[email]"]', loginData.email);
    await page.fill('[name="restaurant[password]"]', loginData.password);
    await page.click('[type="submit"]');
    
    await page.waitForURL(/\/admin/);
  }

  static async logoutRestaurant(page) {
    await page.goto('/admin/sign_out');
    await page.waitForURL('/');
  }
}