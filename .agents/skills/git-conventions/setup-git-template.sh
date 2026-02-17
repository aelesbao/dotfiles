#!/bin/bash
# Set up Git commit message template for Conventional Commits

set -e

echo "📝 Git Commit Message Template Setup"
echo "======================================"
echo ""
echo "This will create a commit message template that helps you"
echo "remember the Conventional Commits format."
echo ""

# Ask for confirmation
read -p "Do you want to install the commit message template? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Installation cancelled."
    exit 0
fi

# Create template file
TEMPLATE_FILE="$HOME/.gitmessage"

cat > "$TEMPLATE_FILE" << 'EOF'
# <type>[optional scope]: <description>
# 
# [optional body]
# 
# [optional footer(s)]
#
# ────────────────────────────────────────────────────────────
# TYPES:
#   feat:     New feature
#   fix:      Bug fix
#   docs:     Documentation only
#   style:    Code formatting, whitespace
#   refactor: Code restructuring (no behavior change)
#   perf:     Performance improvement
#   test:     Adding or updating tests
#   build:    Build system, dependencies
#   ci:       CI configuration
#   chore:    Maintenance
#   revert:   Revert previous commit
#
# SCOPE (optional):
#   - Use package/crate/module name
#   - Examples: (auth), (parser), (api)
#
# BREAKING CHANGES:
#   - Add ! before : for breaking changes
#   - Example: feat(api)!: remove status endpoint
#   - Add BREAKING CHANGE: in footer
#
# RULES:
#   ✓ Use imperative mood: "add" not "added"
#   ✓ No capital first letter
#   ✓ No period at the end
#   ✓ Keep description under 72 characters
#
# EXAMPLES:
#   feat(auth): add JWT token validation
#   fix(parser): prevent crash on empty input
#   docs(api): update authentication examples
#   refactor(db): extract connection pool logic
#
# ────────────────────────────────────────────────────────────
EOF

# Configure Git to use the template globally
git config --global commit.template "$TEMPLATE_FILE"

echo ""
echo "✅ Template installed successfully!"
echo ""
echo "📍 Template file: $TEMPLATE_FILE"
echo ""
echo "🎯 Usage:"
echo "   When you run 'git commit' (without -m), your editor will"
echo "   open with this template to guide you."
echo ""
echo "💡 Tips:"
echo "   - Lines starting with # are comments (not included in commit)"
echo "   - Delete the template text and write your commit message"
echo "   - Or use 'git commit -m' to skip the template"
echo ""
echo "🧪 Test it:"
echo "   git commit"
echo ""
echo "📚 To disable:"
echo "   git config --global --unset commit.template"
echo ""
echo "Happy committing! 📝"
