#!/bin/bash
set -e

echo "🚀 Starting CI Test Suite for Cartly"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up..."
    if [ ! -z "$RAILS_PID" ]; then
        kill $RAILS_PID 2>/dev/null || true
    fi
    docker compose down 2>/dev/null || true
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is required but not installed"
        exit 1
    fi
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is required but not installed"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm is required but not installed"
        exit 1
    fi
}

# Setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Install Node.js dependencies
    npm install
    
    # Install Playwright browsers
    npm run test:install
    
    # Setup Rails environment
    docker compose build
    docker compose run --rm app bundle install
    docker compose run --rm app bin/rails db:setup RAILS_ENV=test
}

# Start services
start_services() {
    print_status "Starting services..."
    
    # Start Rails server in background
    docker compose up -d app
    
    # Wait for Rails server to be ready
    print_status "Waiting for Rails server..."
    timeout=60
    while [ $timeout -gt 0 ]; do
        if curl -f http://localhost:3000 &>/dev/null; then
            print_status "Rails server is ready"
            break
        fi
        sleep 1
        timeout=$((timeout-1))
    done
    
    if [ $timeout -eq 0 ]; then
        print_error "Rails server failed to start"
        exit 1
    fi
}

# Run tests
run_tests() {
    print_status "Running test suites..."
    
    # Run smoke tests first (quick validation)
    print_status "Running smoke tests..."
    if ! npm test -- auth-smoke.spec.js --project=chromium-desktop; then
        print_error "Smoke tests failed"
        return 1
    fi
    
    # Run core authentication tests
    print_status "Running core authentication tests..."
    if ! npm test -- auth-core.spec.js --project=chromium-desktop; then
        print_error "Core authentication tests failed"
        return 1
    fi
    
    # Run mobile tests
    print_status "Running mobile tests..."
    if ! npm run test:mobile -- auth-core.spec.js; then
        print_error "Mobile tests failed"
        return 1
    fi
    
    # Run cross-browser tests
    print_status "Running cross-browser tests..."
    if ! npm run test:desktop -- auth-smoke.spec.js; then
        print_error "Cross-browser tests failed"
        return 1
    fi
    
    print_status "All tests passed successfully! ✅"
}

# Main execution
main() {
    print_status "Starting CI pipeline..."
    
    check_dependencies
    setup_environment
    start_services
    
    if run_tests; then
        print_status "🎉 CI pipeline completed successfully!"
        exit 0
    else
        print_error "❌ CI pipeline failed!"
        exit 1
    fi
}

# Handle different execution modes
case "${1:-}" in
    "smoke")
        start_services
        npm test -- auth-smoke.spec.js --project=chromium-desktop
        ;;
    "auth")
        start_services
        npm test -- auth-core.spec.js --project=chromium-desktop
        ;;
    "mobile")
        start_services
        npm run test:mobile -- auth-core.spec.js
        ;;
    "full")
        main
        ;;
    *)
        main
        ;;
esac