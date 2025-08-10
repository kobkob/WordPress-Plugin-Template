#!/bin/bash

# AI-Assisted Feature Implementation Script
# Usage: ./ai-implement.sh "US-001" [implementation_type]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_message $RED "Usage: $0 \"US-XXX\" [implementation_type]"
    print_message $YELLOW "Implementation types: test, code, review, all"
    print_message $YELLOW "Example: $0 \"US-001\" \"code\""
    exit 1
fi

STORY_ID="$1"
IMPLEMENTATION_TYPE="${2:-all}"

print_message $BLUE "🤖 AI-Assisted Feature Implementation"
print_message $BLUE "====================================="
echo

# Find story file
STORY_FILE=""
for story_dir in agile/stories agile/sprints/*/stories; do
    if [ -f "$story_dir/${STORY_ID,,}.md" ]; then
        STORY_FILE="$story_dir/${STORY_ID,,}.md"
        break
    fi
done

if [ -z "$STORY_FILE" ] || [ ! -f "$STORY_FILE" ]; then
    print_message $RED "Error: Story file for $STORY_ID not found"
    print_message $YELLOW "Expected locations:"
    print_message $YELLOW "- agile/stories/${STORY_ID,,}.md"
    print_message $YELLOW "- agile/sprints/*/stories/${STORY_ID,,}.md"
    exit 1
fi

print_message $GREEN "✓ Found story: $STORY_FILE"

# Create AI collaboration directory for this story
AI_DIR="agile/ai-collaboration/$STORY_ID"
mkdir -p "$AI_DIR"/{prompts,responses,generated-code,reviews}

# Extract story details
STORY_TITLE=$(grep "^# User Story:" "$STORY_FILE" | sed 's/^# User Story: //' || echo "Unknown Story")
USER_STORY=$(grep -A 3 "^## User Story" "$STORY_FILE" | tail -n 3)
ACCEPTANCE_CRITERIA=$(sed -n '/^## Acceptance Criteria/,/^## /p' "$STORY_FILE" | head -n -1)
TECHNICAL_REQUIREMENTS=$(sed -n '/^## Technical Requirements/,/^## /p' "$STORY_FILE" | head -n -1)

print_message $YELLOW "Story: $STORY_TITLE"
print_message $YELLOW "Implementation Type: $IMPLEMENTATION_TYPE"
echo

# Function to generate AI prompts
generate_test_prompt() {
    cat > "$AI_DIR/prompts/test-generation.md" << EOF
# AI Prompt: Generate Tests for $STORY_ID

## Context
You are helping implement a WordPress plugin feature using Test-Driven Development (TDD). 

## User Story
$USER_STORY

## Acceptance Criteria
$ACCEPTANCE_CRITERIA

## Technical Requirements
$TECHNICAL_REQUIREMENTS

## Task
Generate comprehensive PHPUnit tests for this WordPress plugin feature. The tests should:

1. **Follow WordPress Testing Best Practices**
   - Use WP_UnitTestCase as base class
   - Include proper setup and teardown
   - Use WordPress test factory methods
   - Follow WordPress coding standards

2. **Test Structure Requirements**
   - Use Given-When-Then structure in comments
   - Test all acceptance criteria scenarios
   - Include both positive and negative test cases
   - Test edge cases and error conditions
   - Add @test and @story annotations

3. **WordPress-Specific Testing**
   - Test WordPress hooks and filters
   - Test database operations safely
   - Test user permissions and capabilities
   - Test sanitization and validation
   - Test REST API endpoints (if applicable)

4. **Test Coverage Requirements**
   - Test happy path scenarios
   - Test validation failures
   - Test permission failures
   - Test error handling
   - Test security aspects

## Code Structure
Place tests in appropriate directories:
- Unit tests: tests/unit/
- Integration tests: tests/integration/

Use descriptive test method names that explain the behavior being tested.

## Example Test Pattern
```php
/**
 * @test
 * @story $STORY_ID
 */
public function it_should_[describe_behavior]_when_[condition]() {
    // Given: [setup condition]
    
    // When: [perform action]
    
    // Then: [assert expected outcome]
}
```

Generate the complete test file(s) with all necessary test cases.
EOF

    print_message $GREEN "✓ Generated test generation prompt"
}

generate_implementation_prompt() {
    cat > "$AI_DIR/prompts/code-implementation.md" << EOF
# AI Prompt: Implement Feature for $STORY_ID

## Context
You are implementing a WordPress plugin feature following WordPress best practices and coding standards.

## User Story
$USER_STORY

## Acceptance Criteria
$ACCEPTANCE_CRITERIA

## Technical Requirements
$TECHNICAL_REQUIREMENTS

## Implementation Requirements

### 1. WordPress Standards Compliance
- Follow WordPress Coding Standards (WPCS)
- Use WordPress APIs and functions
- Implement proper hooks and filters
- Include appropriate action and filter hooks for extensibility

### 2. Security Requirements
- Sanitize all input data using WordPress functions
- Validate user permissions with current_user_can()
- Use nonces for form submissions
- Escape all output data
- Prevent SQL injection, XSS, and CSRF

### 3. Code Structure
- Use object-oriented programming patterns
- Follow single responsibility principle
- Include proper error handling and logging
- Add comprehensive PHPDoc comments
- Use WordPress naming conventions

### 4. Integration Points
- Settings API integration (if needed)
- REST API endpoints (if needed)
- Database operations using \$wpdb safely
- Admin interface integration
- Frontend integration (if needed)

### 5. Testing Compatibility
- Make code testable with dependency injection
- Avoid global state where possible
- Use WordPress testing-friendly patterns
- Ensure all public methods can be unit tested

## Implementation Guidelines

### File Structure
- Main classes in includes/ directory
- Helper functions in appropriate files
- Admin-specific code in admin/ subdirectory
- Frontend code in public/ subdirectory

### Error Handling
- Use WP_Error for error returns
- Log errors using error_log() or WordPress logging
- Provide user-friendly error messages
- Graceful degradation on failures

### Performance Considerations
- Use WordPress caching APIs where appropriate
- Optimize database queries
- Minimize HTTP requests
- Use transients for expensive operations

## Code Template Structure
Provide complete, working code that:
1. Implements all acceptance criteria
2. Passes the generated tests
3. Follows all requirements above
4. Is production-ready

Include necessary:
- Class definitions
- Method implementations
- Hook registrations
- Error handling
- Documentation
EOF

    print_message $GREEN "✓ Generated implementation prompt"
}

generate_review_prompt() {
    cat > "$AI_DIR/prompts/code-review.md" << EOF
# AI Prompt: Code Review for $STORY_ID

## Context
Please review the implementation for the following WordPress plugin feature:

## User Story
$USER_STORY

## Acceptance Criteria
$ACCEPTANCE_CRITERIA

## Code Review Checklist

### 1. Security Review
- [ ] All input is properly sanitized
- [ ] All output is properly escaped
- [ ] User permissions are checked
- [ ] Nonces are used for forms
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] No CSRF vulnerabilities

### 2. WordPress Standards
- [ ] Follows WordPress Coding Standards
- [ ] Uses WordPress APIs appropriately
- [ ] Proper hook usage
- [ ] Correct function naming
- [ ] Proper file organization
- [ ] PHPDoc comments present

### 3. Functionality Review
- [ ] All acceptance criteria are met
- [ ] Error handling is comprehensive
- [ ] Edge cases are handled
- [ ] Performance is optimized
- [ ] Code is maintainable

### 4. Testing Compatibility
- [ ] Code is testable
- [ ] No hard dependencies on global state
- [ ] Proper dependency injection
- [ ] Mock-friendly structure

### 5. Architecture Review
- [ ] Follows SOLID principles
- [ ] Proper separation of concerns
- [ ] Extensible design
- [ ] Clean interfaces

## Review Instructions
1. Examine the code for each checklist item
2. Identify any issues or improvements needed
3. Suggest specific code changes with examples
4. Rate the overall code quality (1-10)
5. Provide summary of main concerns and recommendations

## Code Quality Criteria
- **Excellent (9-10)**: Production-ready, exemplary code
- **Good (7-8)**: Minor improvements needed
- **Acceptable (5-6)**: Several issues to address
- **Poor (3-4)**: Major refactoring needed
- **Unacceptable (1-2)**: Complete rewrite required

Provide detailed feedback with specific examples and suggestions.
EOF

    print_message $GREEN "✓ Generated code review prompt"
}

# Function to create implementation workspace
create_workspace() {
    print_message $YELLOW "Setting up AI implementation workspace..."
    
    # Create implementation tracking file
    cat > "$AI_DIR/implementation-log.md" << EOF
# Implementation Log: $STORY_ID

**Story**: $STORY_TITLE
**Started**: $(date)
**Implementation Type**: $IMPLEMENTATION_TYPE

## AI Assistance Sessions

### Session 1: $(date)
**Type**: Setup
**Status**: In Progress
**AI Tool**: [To be filled]
**Time Saved**: [To be estimated]

## Generated Assets
- [ ] Test cases generated
- [ ] Implementation code generated
- [ ] Code review completed
- [ ] Documentation updated

## Quality Checks
- [ ] All tests passing
- [ ] PHPCS standards check passed
- [ ] Security review completed
- [ ] Performance review completed

## Notes
[Add implementation notes here]

EOF

    print_message $GREEN "✓ Created implementation workspace"
}

# Function to run TDD cycle
run_tdd_cycle() {
    print_message $BLUE "🔄 Running TDD Cycle..."
    
    print_message $YELLOW "Step 1: RED - Running tests (should fail)"
    if composer test 2>/dev/null; then
        print_message $YELLOW "ℹ️  All tests currently passing"
    else
        print_message $RED "❌ Tests failing (expected in TDD)"
    fi
    
    echo
    print_message $YELLOW "Step 2: GREEN - Implement minimal code to pass tests"
    print_message $BLUE "Use the AI-generated implementation as a starting point"
    
    echo
    print_message $YELLOW "Step 3: REFACTOR - Clean up and optimize code"
    print_message $BLUE "Use AI code review to identify improvements"
}

# Function to validate story completion
validate_story_completion() {
    print_message $BLUE "🔍 Validating story completion..."
    
    local all_valid=true
    
    # Check if tests exist
    if find tests/ -name "*${STORY_ID,,}*" -type f | grep -q .; then
        print_message $GREEN "✓ Tests found for $STORY_ID"
    else
        print_message $RED "❌ No tests found for $STORY_ID"
        all_valid=false
    fi
    
    # Check if tests pass
    if composer test --group="$STORY_ID" 2>/dev/null; then
        print_message $GREEN "✓ All tests passing"
    else
        print_message $YELLOW "⚠️  Some tests failing"
    fi
    
    # Check acceptance criteria
    if grep -q "- \[x\]" "$STORY_FILE"; then
        print_message $GREEN "✓ Some acceptance criteria marked complete"
    else
        print_message $YELLOW "⚠️  No acceptance criteria marked complete"
    fi
    
    if $all_valid; then
        print_message $GREEN "✅ Story validation passed"
    else
        print_message $YELLOW "⚠️  Story needs additional work"
    fi
}

# Main execution flow
case $IMPLEMENTATION_TYPE in
    "test"|"all")
        print_message $YELLOW "📝 Generating test cases..."
        generate_test_prompt
        print_message $BLUE "Next: Use your AI assistant with the prompt in:"
        print_message $BLUE "$AI_DIR/prompts/test-generation.md"
        echo
        ;&
    "code")
        if [ "$IMPLEMENTATION_TYPE" = "code" ] || [ "$IMPLEMENTATION_TYPE" = "all" ]; then
            print_message $YELLOW "💻 Generating implementation code..."
            generate_implementation_prompt
            print_message $BLUE "Next: Use your AI assistant with the prompt in:"
            print_message $BLUE "$AI_DIR/prompts/code-implementation.md"
            echo
        fi
        ;&
    "review")
        if [ "$IMPLEMENTATION_TYPE" = "review" ] || [ "$IMPLEMENTATION_TYPE" = "all" ]; then
            print_message $YELLOW "🔍 Generating code review prompt..."
            generate_review_prompt
            print_message $BLUE "Next: Use your AI assistant with the prompt in:"
            print_message $BLUE "$AI_DIR/prompts/code-review.md"
            echo
        fi
        ;;
    *)
        print_message $RED "Error: Invalid implementation type: $IMPLEMENTATION_TYPE"
        print_message $YELLOW "Valid types: test, code, review, all"
        exit 1
        ;;
esac

# Create workspace and run validation
create_workspace

if [ "$IMPLEMENTATION_TYPE" = "all" ] || [ "$IMPLEMENTATION_TYPE" = "test" ]; then
    run_tdd_cycle
fi

validate_story_completion

print_message $GREEN "🎉 AI implementation setup complete!"
echo
print_message $BLUE "📋 Next Steps:"
echo "1. Use the generated AI prompts to get code/tests"
echo "2. Copy AI responses to: $AI_DIR/responses/"
echo "3. Implement the generated code"
echo "4. Run: composer test"
echo "5. Review and refactor code"
echo "6. Complete story: ./agile/scripts/complete-story.sh $STORY_ID"
echo
print_message $YELLOW "AI Workspace: $AI_DIR"
print_message $YELLOW "Implementation Log: $AI_DIR/implementation-log.md"

# Update sprint metrics if in an active sprint
CURRENT_SPRINT=$(git branch --show-current | grep -o 'sprint-[0-9]\+' || echo "")
if [ -n "$CURRENT_SPRINT" ]; then
    SPRINT_DIR="agile/sprints/$CURRENT_SPRINT"
    if [ -f "$SPRINT_DIR/metrics.json" ]; then
        print_message $BLUE "📊 Updating sprint metrics..."
        # Update AI assistance metrics
        python3 -c "
import json
import sys

try:
    with open('$SPRINT_DIR/metrics.json', 'r') as f:
        data = json.load(f)
    
    # Increment AI assistance counters
    if '$IMPLEMENTATION_TYPE' in ['test', 'all']:
        data['ai_assistance']['test_generation_tasks'] += 1
    if '$IMPLEMENTATION_TYPE' in ['code', 'all']:
        data['ai_assistance']['code_generation_tasks'] += 1
    if '$IMPLEMENTATION_TYPE' in ['review', 'all']:
        data['ai_assistance']['code_review_tasks'] += 1
    
    with open('$SPRINT_DIR/metrics.json', 'w') as f:
        json.dump(data, f, indent=2)
    
    print('✓ Sprint metrics updated')
except Exception as e:
    print(f'Warning: Could not update metrics: {e}')
" 2>/dev/null || print_message $YELLOW "⚠️  Could not update sprint metrics"
    fi
fi

echo
print_message $GREEN "Happy AI-Assisted Development! 🤖✨"
