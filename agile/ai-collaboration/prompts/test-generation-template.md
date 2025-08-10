# AI Prompt Template: Test Generation

## Context
You are a WordPress plugin development expert helping to implement Test-Driven Development (TDD) for a WordPress plugin feature.

## Instructions for AI Assistant

### 1. Analyze the User Story
- Read the user story and acceptance criteria carefully
- Identify all the behaviors that need to be tested
- Consider edge cases and error scenarios
- Think about WordPress-specific considerations

### 2. Generate Test Structure
Create comprehensive PHPUnit tests that follow these patterns:

```php
<?php
/**
 * Tests for [Feature Name]
 * 
 * @group [feature-group]
 * @group agile-sprint-[X]
 */
class Test_[Feature_Class] extends WP_UnitTestCase {

    protected $feature_instance;
    protected $test_user_id;
    
    public function setUp(): void {
        parent::setUp();
        
        // Set up test environment
        $this->feature_instance = new [Feature_Class]();
        
        // Create test user if needed
        $this->test_user_id = $this->factory->user->create([
            'role' => 'administrator'
        ]);
    }

    /**
     * @test
     * @story [US-XXX]
     * @scenario [Happy path description]
     */
    public function it_should_[expected_behavior]_when_[condition]() {
        // Given: [Setup the initial state]
        
        // When: [Perform the action]
        
        // Then: [Assert the expected outcome]
        
        // And: [Additional assertions if needed]
    }
    
    /**
     * @test
     * @story [US-XXX]
     * @scenario [Error handling description]
     */
    public function it_should_[error_behavior]_when_[error_condition]() {
        // Given: [Setup error condition]
        
        // When: [Perform action that should fail]
        
        // Then: [Assert appropriate error handling]
    }
}
```

### 3. Test Categories to Include

#### Happy Path Tests
- Test main functionality with valid inputs
- Test successful workflows
- Test expected outputs and side effects

#### Validation Tests
- Test input validation (required fields, format validation)
- Test business rule validation
- Test boundary conditions

#### Permission Tests
- Test user capability checks
- Test authentication requirements
- Test role-based access control

#### Security Tests
- Test input sanitization
- Test output escaping
- Test nonce verification
- Test SQL injection prevention

#### Integration Tests
- Test WordPress hook interactions
- Test database operations
- Test API endpoints (if applicable)
- Test third-party integrations

#### Error Handling Tests
- Test graceful error handling
- Test user-friendly error messages
- Test logging and debugging

### 4. WordPress Testing Best Practices
- Use WordPress test factories for creating test data
- Clean up after tests (handled by parent::tearDown())
- Use appropriate WordPress assertions
- Test with different user roles and capabilities
- Use transactional tests when possible

### 5. Test Naming Convention
- Use descriptive method names that explain the scenario
- Follow the pattern: `it_should_[outcome]_when_[condition]()`
- Group related tests with similar prefixes
- Use @test annotation for clarity

### 6. Assertions to Use
```php
// WordPress-specific assertions
$this->assertTrue(is_plugin_active('plugin-name/plugin.php'));
$this->assertEquals($expected, get_option('option_name'));
$this->assertInstanceOf('WP_Error', $result);

// Standard PHPUnit assertions
$this->assertEquals($expected, $actual);
$this->assertTrue($condition);
$this->assertFalse($condition);
$this->assertNull($value);
$this->assertNotNull($value);
$this->assertArrayHasKey('key', $array);
$this->assertContains($needle, $haystack);
$this->assertCount($expected_count, $array);
```

## Example Output Format

Provide complete, runnable test files with:
- Proper class structure and inheritance
- All necessary setup and teardown
- Comprehensive test coverage
- Clear, descriptive test names
- Proper annotations and documentation
- WordPress coding standards compliance

## Quality Checklist
Before submitting generated tests, ensure:
- [ ] All acceptance criteria are covered by tests
- [ ] Both positive and negative scenarios are tested
- [ ] WordPress security considerations are addressed
- [ ] Tests are isolated and don't depend on each other
- [ ] Setup and teardown are properly handled
- [ ] Test names clearly describe the scenario
- [ ] Code follows WordPress coding standards
