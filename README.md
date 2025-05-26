# QR Menu Card for Restaurants
(Under development 🔨)
(mobile 1st 📱)

https://github.com/user-attachments/assets/d72ea4b1-970d-4ce5-b340-17e25bd211e7

---

<img width="432" alt="image" src="https://github.com/user-attachments/assets/a8ecccf5-4f44-4639-8c9b-3117392d4463">
<img width="432" alt="image" src="https://github.com/user-attachments/assets/9ae58413-a1eb-4bb0-bb5e-0426640510ac">
<img width="432" alt="image" src="https://github.com/user-attachments/assets/6ea2c41e-dfbe-41a9-9bc2-d54bb7ce2b3a">
<img width="432" alt="image" src="https://github.com/user-attachments/assets/c64a29b0-d8d8-4315-b8be-ed26d88f79ea">

## Give it a try!
- https://cartly.fly.dev/
- email: test@test.com
- password: Abc123..

This application allows restaurants to create and manage their menu of food and drinks in QR format. Customers can scan the QR code with their mobile phones to quickly and easily access the restaurant's menu.

## Main features

- Mobile first 📲
- Auto translation in the background each time a new product / wine is created / updated. (`GeminiAI` 🔮 + `i18n`) `[ES, IT, FR, EN, RU, IT]`
- Auto generative descriptions based on the name of the product AND / OR the image (AI 🔮)
- Activate / Deactivate / Modify / Delete products on the fly, the user wont have to refresh the page to see the updates (`WebSocket`)
- User authentication: Allowing restaurant owners to access their account and manage the data on the fly using a smartphone / tablet / desktop.
- Automatic image processing and compression to improve the performance while reducing the storage cost. (`libvips`)
- Theme switcher (`Dark` 🌙 / `Light` 🌞)
- Menu creation and editing: restaurants can create and edit their menu of food and drinks in the application.
    - Allergens
    - Wines
    - Starters
    - Main courses
    - Desserts
    - Special menus

## Technologies used

- Ruby on Rails 7
- Tailwind CSS
- ImportMaps
- MySQL
- Hotwire

## Installation and configuration

1. Clone the GitHub repository: `git clone https://github.com/BraisonCrece/Restaurant_QR_menu_dashboard`
2. Go to the main directory
3. Run `make install`
4. That's all

## Testing 🧪

Cartly includes comprehensive end-to-end testing with Playwright covering all critical user flows.

### Quick Start

```bash
# Install test dependencies (included in make install)
make test.install

# Run all core tests
make test

# Run quick smoke tests
make test.smoke
```

### Available Test Commands

```bash
# Core authentication tests
make test.auth

# Mobile device testing
make test.mobile  

# Cross-browser testing (Chrome, Firefox, Safari)
make test.desktop

# Visual testing with browser UI
make test.headed

# Debug mode (step through tests)
make test.debug

# View test results report
make test.report

# Generate new tests interactively
make test.codegen
```

### Test Suites

- **🔐 Authentication**: Login, registration, logout, password recovery
- **📱 Mobile-first**: iPhone, Android, responsive design
- **🌐 Cross-browser**: Chrome, Firefox, Safari compatibility
- **🔒 Security**: XSS protection, input validation, session management
- **♿ Accessibility**: Keyboard navigation, screen readers

### CI/CD Integration

Tests run automatically on:
- Every push to `main` and `develop` branches
- All pull requests
- Can be triggered manually

```bash
# Run CI test suite locally
npm run test:ci:full

# Individual CI test modes
npm run test:ci:smoke    # Quick validation
npm run test:ci:auth     # Authentication flow
npm run test:ci:mobile   # Mobile devices
```

### Test Results

- **HTML Report**: Detailed results with screenshots and videos
- **Screenshots**: Captured on failures for debugging
- **Videos**: Full test execution recordings
- **Cross-browser**: Matrix testing across all supported browsers

All test artifacts are automatically uploaded and available for review in failed builds.

## Contributions

If you want to contribute to the application, please follow these steps:

1. Fork the repository.
2. Create a new branch: `git checkout -b my-new-feature`
3. Make your changes and commit: `git commit -am 'Add some feature'`
4. Push your changes to the branch: `git push origin my-new-feature`
5. Create a pull request.

## License

This application is under the MIT license. See the LICENSE file for more details.
