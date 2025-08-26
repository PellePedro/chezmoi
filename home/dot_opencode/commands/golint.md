---
name: golint
description: Run Go linters, fix errors, and rerun until all checks pass
---

# Run Go linters and fix errors

Running comprehensive Go linting checks and fixing any issues found...

```bash
echo "🔍 Starting Go linting process with auto-fix..."
echo ""

# Install tools if needed
if ! command -v goimports &> /dev/null; then
    echo "Installing goimports..."
    go install golang.org/x/tools/cmd/goimports@latest
fi

if ! command -v golangci-lint &> /dev/null; then
    echo "Installing golangci-lint..."
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
fi

if ! command -v staticcheck &> /dev/null; then
    echo "Installing staticcheck..."
    go install honnef.co/go/tools/cmd/staticcheck@latest
fi

max_attempts=5
attempt=1

while [ $attempt -le $max_attempts ]; do
    echo "🔄 Linting attempt $attempt of $max_attempts"
    echo ""
    
    all_passed=true
    
    # Run goimports
    echo "📝 Running goimports to format and fix imports..."
    goimports -w ./cmd ./pkg ./internal
    echo "✅ goimports complete (auto-fixed)"
    echo ""
    
    # Run golangci-lint with auto-fix where possible
    echo "🔧 Running golangci-lint..."
    if golangci-lint run --fix; then
        echo "✅ golangci-lint passed"
    else
        echo "⚠️  golangci-lint found issues"
        all_passed=false
        
        # Try to fix common issues
        echo "Attempting to auto-fix common issues..."
        
        # Fix ineffassign issues
        golangci-lint run --disable-all --enable ineffassign --fix 2>/dev/null || true
        
        # Fix gofmt issues
        golangci-lint run --disable-all --enable gofmt --fix 2>/dev/null || true
        
        # Fix goimports issues
        golangci-lint run --disable-all --enable goimports --fix 2>/dev/null || true
        
        # Fix misspell issues
        golangci-lint run --disable-all --enable misspell --fix 2>/dev/null || true
    fi
    echo ""
    
    # Run staticcheck
    echo "🔍 Running staticcheck..."
    if staticcheck ./...; then
        echo "✅ staticcheck passed"
    else
        echo "⚠️  staticcheck found issues"
        all_passed=false
        
        # Display staticcheck issues for manual review
        echo ""
        echo "Staticcheck issues require manual fixes. Common fixes:"
        echo "  - Remove unused variables/functions"
        echo "  - Fix deprecated API usage"
        echo "  - Resolve nil pointer dereferences"
        echo ""
    fi
    echo ""
    
    if [ "$all_passed" = true ]; then
        echo "✨ All linters passed successfully!"
        exit 0
    fi
    
    if [ $attempt -lt $max_attempts ]; then
        echo "🔄 Some issues remain. Running linters again..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi
    
    attempt=$((attempt + 1))
done

echo "❌ Maximum attempts reached. Some linting issues remain."
echo "Please review the errors above and fix them manually."
exit 1
```