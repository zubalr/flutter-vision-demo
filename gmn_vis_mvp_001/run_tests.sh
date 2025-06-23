#!/bin/bash

# Flutter Vision Demo - Test Runner Script
# This script helps you run different test categories for presentation metrics

echo "🎯 Flutter Vision Demo - Test Metrics Runner"
echo "=============================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}$1${NC}"
    echo "$(printf '%*s' ${#1} '' | tr ' ' '=')"
}

# Function to run tests with error handling
run_test() {
    local test_file=$1
    local test_name=$2
    
    print_header "Running $test_name"
    echo "Test file: $test_file"
    
    if flutter test "$test_file"; then
        echo -e "${GREEN}✅ $test_name PASSED${NC}"
    else
        echo -e "${RED}❌ $test_name FAILED (some tests may need camera permissions)${NC}"
    fi
    
    echo ""
}

# Check if we're in the right directory
if [[ ! -f "pubspec.yaml" ]]; then
    echo -e "${RED}Error: Please run this script from the Flutter project root directory${NC}"
    exit 1
fi

# Install dependencies
print_header "Installing Dependencies"
flutter pub get

# Menu for test selection
while true; do
    echo -e "${YELLOW}Choose test category to run:${NC}"
    echo "1. Unit Tests (Data Models & Core Logic)"
    echo "2. Widget Tests (UI Components & Layouts)"  
    echo "3. Performance Tests (Metrics & Benchmarks)"
    echo "4. Integration Tests (End-to-End Flow)"
    echo "5. All Tests (Complete Test Suite)"
    echo "6. Generate Test Report"
    echo "7. Exit"
    echo ""
    read -p "Enter your choice (1-7): " choice
    
    case $choice in
        1)
            run_test "test/unit_tests.dart" "Unit Tests"
            ;;
        2)
            run_test "test/widget_tests.dart" "Widget Tests"
            ;;
        3)
            run_test "test/performance_metrics_test.dart" "Performance Tests"
            ;;
        4)
            run_test "integration_test/app_integration_test.dart" "Integration Tests"
            ;;
        5)
            print_header "Running All Tests"
            run_test "test/unit_tests.dart" "Unit Tests"
            run_test "test/widget_tests.dart" "Widget Tests" 
            run_test "test/performance_metrics_test.dart" "Performance Tests"
            echo -e "${YELLOW}Note: Integration tests require a connected device/emulator${NC}"
            echo "To run integration tests: flutter test integration_test/app_integration_test.dart"
            ;;
        6)
            print_header "Generating Test Report"
            echo "Test report available at: TEST_METRICS_REPORT.md"
            echo ""
            echo "📊 Quick Test Summary:"
            echo "• Unit Tests: Data models, validation, edge cases"
            echo "• Widget Tests: UI components, responsive design, accessibility"
            echo "• Performance Tests: Startup time, frame rates, memory usage"
            echo "• Integration Tests: End-to-end functionality"
            echo ""
            echo "🎯 Key Metrics Collected:"
            echo "• App startup performance"
            echo "• UI responsiveness (FPS)"
            echo "• Memory efficiency"
            echo "• Code coverage indicators"
            echo "• Error handling robustness"
            echo "• Feature completeness validation"
            echo ""
            ;;
        7)
            echo "Exiting test runner. Happy presenting! 🚀"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1-7.${NC}"
            ;;
    esac
done
