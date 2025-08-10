# 🚀 Agile/XP Development Guide

This guide provides a complete Agile/XP methodology framework for WordPress plugin development, including sprint planning, user story management, test-driven development, and AI-assisted implementation.

## 📋 Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Sprint Planning](#sprint-planning)
- [User Stories & Requirements](#user-stories--requirements)
- [Test-Driven Development](#test-driven-development)
- [AI-Assisted Development](#ai-assisted-development)
- [Development Workflow](#development-workflow)
- [Tools & Templates](#tools--templates)

## 🎯 Overview

### Agile Principles for WordPress Development

1. **User-Centric Design** - Always start with user needs and pain points
2. **Iterative Development** - Build in small, testable increments
3. **Continuous Feedback** - Get user feedback early and often
4. **Test-Driven Development** - Write tests before code
5. **AI-Enhanced Productivity** - Leverage AI for code generation and testing
6. **Continuous Integration** - Automated testing and deployment

### XP Practices We Implement

- **Planning Game** - Sprint planning with user stories
- **Small Releases** - Frequent, small feature releases
- **Simple Design** - YAGNI (You Ain't Gonna Need It)
- **Test-Driven Development** - Red-Green-Refactor cycle
- **Pair Programming** - Human + AI collaboration
- **Continuous Integration** - Automated testing pipeline

## 🚀 Getting Started

### Prerequisites

- WordPress Plugin Template with Docker environment
- Basic understanding of Agile/XP principles
- AI assistant access (Claude, ChatGPT, or similar)

### Setup Your Development Environment

```bash
# Start your development environment
docker-compose up -d

# Access the development dashboard
open http://localhost:8000/wp-admin

# Set up your sprint workspace
mkdir -p agile/{sprints,stories,tests,docs}
```

## 📅 Sprint Planning

### 1. Define Your Product Vision

Create a clear product vision that guides all development decisions:

```markdown
## Product Vision Template

**Product Name**: [Your Plugin Name]

**Vision Statement**: 
In 1-2 sentences, describe what your plugin does and why it matters.

**Target Users**:
- Primary: [Who are your main users?]
- Secondary: [Who else might benefit?]

**Key Problems Solved**:
1. [Problem 1]
2. [Problem 2]
3. [Problem 3]

**Success Metrics**:
- [Metric 1]: [Target]
- [Metric 2]: [Target]
- [Metric 3]: [Target]
```

### 2. Sprint Planning Process

#### Phase 1: Backlog Creation
```bash
# Create your product backlog
cp agile/templates/backlog-template.md agile/product-backlog.md
```

#### Phase 2: Sprint Planning Meeting
```bash
# Start a new sprint
./agile/scripts/start-sprint.sh "Sprint 1" "2024-08-10" "2024-08-24"
```

#### Phase 3: Story Estimation
Use Planning Poker or Story Points (1, 2, 3, 5, 8, 13, 21)

### 3. Sprint Structure

**Sprint Duration**: 1-2 weeks
**Sprint Goal**: One clear, testable outcome
**Capacity**: Based on team velocity

```markdown
## Sprint Planning Template

**Sprint**: [Number]
**Duration**: [Start Date] - [End Date]
**Goal**: [One sentence describing the sprint goal]

### Sprint Backlog
| Story | Priority | Points | Status | Assignee |
|-------|----------|--------|---------|-----------|
| As a... | High | 5 | Todo | Developer |

### Definition of Done
- [ ] Code written and tested
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Code review completed
- [ ] Documentation updated
- [ ] User acceptance criteria met
```

## 📝 User Stories & Requirements

### 1. User Story Format

```markdown
## User Story Template

**As a** [type of user]
**I want** [to perform some task]
**So that** [I can achieve some goal/benefit]

### Acceptance Criteria
- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]
- [ ] Given [context], when [action], then [outcome]

### Technical Requirements
- [ ] [Technical requirement 1]
- [ ] [Technical requirement 2]

### Definition of Done
- [ ] Story criteria met
- [ ] Tests written and passing
- [ ] Code reviewed
- [ ] Documentation updated
```

### 2. Story Examples for WordPress Plugins

```markdown
## Example: Settings Management

**As a** WordPress administrator
**I want** to configure plugin settings through an intuitive interface
**So that** I can customize the plugin behavior without touching code

### Acceptance Criteria
- [ ] Given I'm on the plugin settings page, when I change a setting, then it should be saved automatically
- [ ] Given I'm on the settings page, when I enter invalid data, then I should see helpful error messages
- [ ] Given I have saved settings, when I reload the page, then my settings should persist

### Technical Requirements
- [ ] Settings API integration
- [ ] AJAX form submission
- [ ] Input validation and sanitization
- [ ] REST API endpoints for settings

### Definition of Done
- [ ] Settings page renders correctly
- [ ] All form fields work as expected
- [ ] Validation prevents invalid data
- [ ] Settings persist across page reloads
- [ ] Unit tests cover all scenarios
- [ ] Integration tests verify API endpoints
```

## 🧪 Test-Driven Development

### 1. TDD Cycle: Red-Green-Refactor

```bash
# 1. RED: Write a failing test
./agile/scripts/create-test.sh "SettingsManager" "should_save_settings_correctly"

# 2. GREEN: Write minimal code to pass
./agile/scripts/implement-feature.sh "SettingsManager" "save_settings"

# 3. REFACTOR: Clean up the code
./agile/scripts/refactor-code.sh "SettingsManager"
```

### 2. Test Structure

```php
<?php
/**
 * Test for Settings Manager functionality
 * 
 * @group settings
 * @group agile-sprint-1
 */
class Test_Settings_Manager extends WP_UnitTestCase {

    protected $settings_manager;
    
    public function setUp(): void {
        parent::setUp();
        $this->settings_manager = new Settings_Manager();
    }

    /**
     * @test
     * @story As an admin, I want to save plugin settings
     */
    public function it_should_save_settings_correctly() {
        // Given: I have some settings data
        $settings_data = [
            'api_key' => 'test-key-123',
            'enable_feature' => true,
            'cache_timeout' => 3600
        ];

        // When: I save the settings
        $result = $this->settings_manager->save_settings($settings_data);

        // Then: The settings should be saved successfully
        $this->assertTrue($result);
        
        // And: I should be able to retrieve them
        $saved_settings = $this->settings_manager->get_all_settings();
        $this->assertEquals($settings_data['api_key'], $saved_settings['api_key']);
        $this->assertEquals($settings_data['enable_feature'], $saved_settings['enable_feature']);
        $this->assertEquals($settings_data['cache_timeout'], $saved_settings['cache_timeout']);
    }

    /**
     * @test
     * @story As an admin, I want validation for invalid settings
     */
    public function it_should_reject_invalid_settings() {
        // Given: I have invalid settings data
        $invalid_settings = [
            'api_key' => '', // Empty API key should fail
            'cache_timeout' => -1 // Negative timeout should fail
        ];

        // When: I try to save invalid settings
        $result = $this->settings_manager->save_settings($invalid_settings);

        // Then: The save should fail
        $this->assertFalse($result);
        
        // And: I should get validation errors
        $errors = $this->settings_manager->get_validation_errors();
        $this->assertArrayHasKey('api_key', $errors);
        $this->assertArrayHasKey('cache_timeout', $errors);
    }
}
```

### 3. Behavior-Driven Development (BDD)

```php
<?php
/**
 * BDD-style test for user workflows
 * 
 * @group bdd
 * @group user-workflows
 */
class Test_Admin_Settings_Workflow extends WP_UnitTestCase {

    use BDD_Test_Helpers;

    /**
     * @scenario Admin configures plugin settings
     */
    public function test_admin_configures_plugin_settings() {
        $this->given('I am logged in as an administrator')
             ->and('I navigate to the plugin settings page')
             ->when('I fill in the API key field with "sk-test-123"')
             ->and('I enable the "Cache Results" option')
             ->and('I click "Save Settings"')
             ->then('I should see a success message')
             ->and('The settings should be saved in the database')
             ->and('The API key should be encrypted for security');
    }

    /**
     * @scenario User with insufficient permissions tries to access settings
     */
    public function test_insufficient_permissions_for_settings() {
        $this->given('I am logged in as a subscriber')
             ->when('I try to access the plugin settings page')
             ->then('I should see an access denied message')
             ->and('I should be redirected to the WordPress dashboard');
    }
}
```

## 🤖 AI-Assisted Development

### 1. AI Development Workflow

```markdown
## AI-Assisted Feature Implementation

### Step 1: Requirements Analysis
**Human**: Defines user story and acceptance criteria
**AI**: Suggests technical approaches and potential issues

### Step 2: Test Generation
**Human**: Describes expected behavior
**AI**: Generates comprehensive test cases

### Step 3: Implementation
**Human**: Reviews and guides implementation
**AI**: Writes code following WordPress standards

### Step 4: Code Review
**Human**: Reviews code for business logic
**AI**: Checks for security, performance, and standards compliance
```

### 2. AI Prompts for WordPress Development

```markdown
## Effective AI Prompts

### For Test Generation:
"Generate PHPUnit tests for a WordPress plugin feature that allows administrators to manage API settings. The tests should cover:
- Valid settings submission
- Invalid data validation  
- Permission checks
- Data persistence
- Security considerations

Use WordPress testing best practices and include BDD-style scenarios."

### For Implementation:
"Implement a WordPress settings manager class that:
- Follows WordPress coding standards
- Includes proper sanitization and validation
- Has REST API endpoints
- Uses WordPress Settings API
- Includes security checks (nonces, capabilities)
- Has comprehensive error handling

Base it on the provided test cases and ensure all tests pass."

### For Code Review:
"Review this WordPress plugin code for:
- Security vulnerabilities (XSS, SQL injection, CSRF)
- WordPress coding standards compliance
- Performance implications
- Accessibility considerations
- Code maintainability
- Missing error handling

Suggest specific improvements with code examples."
```

### 3. AI-Human Collaboration Tools

```bash
# Create AI collaboration workspace
mkdir -p agile/ai-collaboration/{prompts,responses,reviews}

# Save effective prompts for reuse
echo "AI prompt templates saved to agile/ai-collaboration/prompts/"

# Track AI-generated code
git tag -a "ai-generated-v1.0" -m "Code generated with AI assistance"
```

## 🔄 Development Workflow

### 1. Daily Development Cycle

```bash
#!/bin/bash
# Daily development workflow

# 1. Start your day
./agile/scripts/daily-standup.sh

# 2. Pick a user story
./agile/scripts/start-story.sh "US-001"

# 3. Write tests first (TDD)
./agile/scripts/create-tests.sh "US-001"

# 4. Implement with AI assistance
./agile/scripts/ai-implement.sh "US-001"

# 5. Run tests and verify
composer test

# 6. Code review (human + AI)
./agile/scripts/code-review.sh "US-001"

# 7. Complete story
./agile/scripts/complete-story.sh "US-001"
```

### 2. Sprint Ceremonies

#### Daily Standup (Async)
```bash
# Generate standup report
./agile/scripts/generate-standup.sh
```

Output:
```markdown
## Daily Standup - August 10, 2024

### Yesterday
- ✅ Completed user story US-001 (Settings Manager)
- ✅ Fixed 3 failing tests
- 🔍 Code review completed

### Today
- 🎯 Starting US-002 (API Integration)
- 📝 Writing tests for authentication
- 🤖 AI pair programming session

### Blockers
- None currently

### Sprint Progress
- 🏃‍♂️ Sprint 1: Day 3 of 10
- 📊 Velocity: 8 points completed, 12 remaining
- 🎯 On track for sprint goal
```

#### Sprint Review & Retrospective
```bash
# End of sprint review
./agile/scripts/sprint-review.sh "Sprint-1"

# Generate retrospective
./agile/scripts/retrospective.sh "Sprint-1"
```

### 3. Continuous Integration Integration

```yaml
# .github/workflows/agile-ci.yml
name: Agile CI/CD

on:
  push:
    branches: [ main, develop, 'feature/*', 'sprint/*' ]
  pull_request:
    branches: [ main, develop ]

jobs:
  agile-validation:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Validate User Stories
      run: ./agile/scripts/validate-stories.sh
    
    - name: Check Test Coverage
      run: |
        composer test-coverage
        ./agile/scripts/check-coverage.sh
    
    - name: Story Completion Check
      run: ./agile/scripts/check-story-completion.sh
    
    - name: Generate Sprint Report
      run: ./agile/scripts/generate-sprint-report.sh
```

## 🛠️ Tools & Templates

### 1. File Structure

```
agile/
├── docs/
│   ├── product-vision.md
│   ├── user-personas.md
│   └── architecture-decisions.md
├── sprints/
│   ├── sprint-1/
│   │   ├── plan.md
│   │   ├── stories/
│   │   ├── retrospective.md
│   │   └── metrics.json
├── stories/
│   ├── backlog.md
│   ├── us-001-settings-manager.md
│   ├── us-002-api-integration.md
├── tests/
│   ├── acceptance/
│   ├── integration/
│   └── unit/
├── scripts/
│   ├── start-sprint.sh
│   ├── create-story.sh
│   ├── ai-implement.sh
│   └── sprint-review.sh
└── templates/
    ├── user-story.md
    ├── test-case.md
    └── sprint-plan.md
```

### 2. Metrics & Tracking

```json
{
  "sprint_metrics": {
    "sprint_number": 1,
    "start_date": "2024-08-10",
    "end_date": "2024-08-24",
    "planned_points": 20,
    "completed_points": 18,
    "velocity": 18,
    "stories_completed": 4,
    "stories_carried_over": 1,
    "bugs_found": 2,
    "bugs_fixed": 2,
    "test_coverage": "94%",
    "ai_assistance_used": {
      "code_generation": "60%",
      "test_creation": "80%",
      "code_review": "90%"
    }
  }
}
```

### 3. Quality Gates

```bash
#!/bin/bash
# agile/scripts/quality-gates.sh

echo "🚪 Running Quality Gates..."

# 1. All tests must pass
if ! composer test; then
    echo "❌ Tests failing - cannot proceed"
    exit 1
fi

# 2. Code coverage minimum
COVERAGE=$(./scripts/get-coverage.sh)
if (( $(echo "$COVERAGE < 80" | bc -l) )); then
    echo "❌ Code coverage below 80% ($COVERAGE%) - cannot proceed"
    exit 1
fi

# 3. All acceptance criteria must be met
if ! ./agile/scripts/check-acceptance-criteria.sh; then
    echo "❌ Acceptance criteria not met - cannot proceed"
    exit 1
fi

# 4. Code review must be completed
if ! ./agile/scripts/check-code-review.sh; then
    echo "❌ Code review not completed - cannot proceed"
    exit 1
fi

echo "✅ All quality gates passed!"
```

## 🎯 Best Practices

### 1. User Story Best Practices
- Keep stories small (1-3 days of work)
- Include clear acceptance criteria
- Write from user perspective
- Focus on business value
- Make stories testable

### 2. Test-Driven Development
- Write tests before code (Red-Green-Refactor)
- Test behavior, not implementation
- Keep tests simple and focused
- Use descriptive test names
- Maintain high test coverage

### 3. AI Collaboration
- Be specific in prompts
- Review AI-generated code carefully
- Use AI for repetitive tasks
- Maintain human oversight
- Document AI assistance usage

### 4. Sprint Management
- Set realistic goals
- Focus on sprint goal
- Limit work in progress
- Adapt based on feedback
- Celebrate achievements

## 🚀 Getting Started Checklist

- [ ] Set up development environment with Docker
- [ ] Define product vision and user personas
- [ ] Create initial product backlog
- [ ] Plan first sprint (1-2 weeks)
- [ ] Write first user story with acceptance criteria
- [ ] Set up testing framework
- [ ] Configure AI development tools
- [ ] Establish quality gates
- [ ] Set up continuous integration
- [ ] Schedule regular ceremonies

## 📚 Additional Resources

- [Agile Manifesto](https://agilemanifesto.org/)
- [Extreme Programming Explained](http://www.extremeprogramming.org/)
- [WordPress Testing Handbook](https://make.wordpress.org/core/handbook/testing/)
- [Test-Driven Development by Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

---

**Happy Agile Development!** 🎉

*This guide provides a complete framework for Agile/XP WordPress plugin development with AI assistance. Adapt it to your team's needs and context.*
