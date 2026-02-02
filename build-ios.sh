#!/bin/bash

# =====================================================
# iOS Build Preparation Script for Picky Load
# =====================================================
# This script automates the iOS build setup process including:
# - Copying platform-specific pubspec
# - Running icons launcher
# - Renaming package
# - Cleaning and reinstalling CocoaPods
# =====================================================

set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
ARROW="→"

# Get script directory (project root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Progress bar function
progress_bar() {
    local progress=$1
    local total=100
    local width=30
    local filled=$((progress * width / total))
    local empty=$((width - filled))
    
    printf "\r${CYAN}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${progress}%%${NC}"
}

# Print step header
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}${ARROW} $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Success message
print_success() {
    echo -e "${GREEN}${CHECK_MARK} $1${NC}"
}

# Error message
print_error() {
    echo -e "${RED}${CROSS_MARK} $1${NC}"
}

# Warning message
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Header
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}      ${GREEN}Picky Load - iOS Setup Script${NC}               ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}      ${YELLOW}Automating iOS Build Preparation${NC}           ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# =====================================================
# Step 1: Copy iOS-specific pubspec (if exists)
# =====================================================
print_step "Step 1/7: Checking for iOS-specific pubspec"

if [ -f "pubspec.ios.yaml" ]; then
    cp pubspec.ios.yaml pubspec.yaml
    print_success "Copied pubspec.ios.yaml to pubspec.yaml"
else
    print_warning "pubspec.ios.yaml not found, using existing pubspec.yaml"
fi
progress_bar 14

# =====================================================
# Step 2: Run Icons Launcher
# =====================================================
print_step "Step 2/7: Running Icons Launcher"

if grep -q "icons_launcher" pubspec.yaml 2>/dev/null || grep -q "icons_launcher" pubspec.lock 2>/dev/null; then
    dart run icons_launcher:create
    print_success "Icons launcher completed"
else
    print_warning "icons_launcher not found in dependencies, skipping..."
fi
progress_bar 28

# =====================================================
# Step 3: Run Package Rename Plus
# =====================================================
print_step "Step 3/7: Running Package Rename Plus"

if grep -q "package_rename_plus" pubspec.yaml 2>/dev/null || grep -q "package_rename_plus" pubspec.lock 2>/dev/null; then
    dart run package_rename_plus
    print_success "Package rename completed"
else
    print_warning "package_rename_plus not found in dependencies, skipping..."
fi
progress_bar 42

# =====================================================
# Step 4: Pod Deintegrate
# =====================================================
print_step "Step 4/7: Deintegrating CocoaPods"

if [ -d "ios" ]; then
    cd ios
    if command -v pod &> /dev/null; then
        pod deintegrate
        print_success "Pod deintegrate completed"
    else
        print_error "CocoaPods not installed. Please install with: sudo gem install cocoapods"
        exit 1
    fi
    cd ..
else
    print_error "ios directory not found!"
    exit 1
fi
progress_bar 56

# =====================================================
# Step 5: Remove Podfile.lock
# =====================================================
print_step "Step 5/7: Removing Podfile.lock"

if [ -f "ios/Podfile.lock" ]; then
    rm -f ios/Podfile.lock
    print_success "Podfile.lock removed"
else
    print_warning "Podfile.lock not found, nothing to remove"
fi
progress_bar 70

# =====================================================
# Step 6: Flutter Packages Get
# =====================================================
print_step "Step 6/7: Running Flutter Packages Get"

flutter packages get
print_success "Flutter packages get completed"
progress_bar 85

# =====================================================
# Step 7: Pod Install with Repo Update
# =====================================================
print_step "Step 7/7: Installing CocoaPods with Repo Update"

cd ios
pod install --repo-update
cd ..
print_success "Pod install completed"
progress_bar 100

# =====================================================
# Completion Summary
# =====================================================
echo ""
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}         ${GREEN}${CHECK_MARK} iOS Setup Completed Successfully!${NC}       ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo -e "  ${ARROW} Open ${YELLOW}ios/Runner.xcworkspace${NC} in Xcode"
echo -e "  ${ARROW} Or run ${YELLOW}flutter run -d ios${NC} to build and run"
echo ""
