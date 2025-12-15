#!/bin/bash
# Workflow Validation Script
# This script validates GitHub Actions workflow files

echo "🔍 Validating GitHub Actions Workflows"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for results
PASSED=0
FAILED=0

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
echo "Checking required tools..."

if ! command_exists python3; then
    echo -e "${RED}✗ python3 not found${NC}"
    echo "  Install python3 to validate YAML syntax"
    exit 1
fi

if ! command_exists docker; then
    echo -e "${YELLOW}⚠ docker not found${NC}"
    echo "  Docker is optional for validation but required to build images"
fi

echo -e "${GREEN}✓ Required tools available${NC}"
echo ""

# Validate YAML syntax
echo "Validating YAML syntax..."
echo "------------------------"

for workflow in .github/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        echo -n "Checking $(basename "$workflow")... "
        if python3 -c "import yaml, sys; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
            echo -e "${GREEN}✓ Valid${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ Invalid YAML${NC}"
            python3 -c "import yaml, sys; yaml.safe_load(open('$workflow'))" 2>&1
            ((FAILED++))
        fi
    fi
done

echo ""

# Check for required workflow components
echo "Checking workflow structure..."
echo "----------------------------"

check_workflow() {
    local file=$1
    local name=$2
    
    echo "Checking $name workflow:"
    
    # Check for 'on' trigger
    if grep -q "^on:" "$file"; then
        echo -e "  ${GREEN}✓${NC} Has trigger configuration"
        ((PASSED++))
    else
        echo -e "  ${RED}✗${NC} Missing trigger configuration"
        ((FAILED++))
    fi
    
    # Check for jobs
    if grep -q "^jobs:" "$file"; then
        echo -e "  ${GREEN}✓${NC} Has jobs defined"
        ((PASSED++))
    else
        echo -e "  ${RED}✗${NC} Missing jobs"
        ((FAILED++))
    fi
    
    # Check for steps
    if grep -q "steps:" "$file"; then
        echo -e "  ${GREEN}✓${NC} Has steps defined"
        ((PASSED++))
    else
        echo -e "  ${RED}✗${NC} Missing steps"
        ((FAILED++))
    fi
    
    echo ""
}

if [ -f ".github/workflows/build.yml" ]; then
    check_workflow ".github/workflows/build.yml" "Build"
fi

if [ -f ".github/workflows/release.yml" ]; then
    check_workflow ".github/workflows/release.yml" "Release"
fi

# Validate docker-compose.yml
echo "Validating docker-compose.yml..."
echo "-------------------------------"

if [ -f "docker-compose.yml" ]; then
    if command_exists docker; then
        echo -n "Checking docker-compose.yml syntax... "
        if docker compose config > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Valid${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗ Invalid${NC}"
            docker compose config 2>&1
            ((FAILED++))
        fi
    else
        echo -e "${YELLOW}⚠ Skipping (docker not available)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ docker-compose.yml not found${NC}"
fi

echo ""

# Check for required files
echo "Checking documentation..."
echo "------------------------"

DOCS=(
    "README.md"
    "docs/RELEASE_GUIDE.md"
    "docs/SECRETS_SETUP.md"
    "CHANGELOG.md"
)

for doc in "${DOCS[@]}"; do
    echo -n "Checking $(basename "$doc")... "
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✓ Exists${NC}"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ Not found${NC}"
    fi
done

echo ""

# Summary
echo "======================================"
echo "Summary"
echo "======================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
else
    echo -e "Failed: $FAILED"
fi
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    echo "Please fix the issues above before continuing."
    exit 1
fi
