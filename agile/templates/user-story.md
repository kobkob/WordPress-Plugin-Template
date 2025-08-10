# User Story: [Story Title]

**Story ID**: US-XXX
**Epic**: [Epic Name]
**Sprint**: [Sprint Number]
**Priority**: [High/Medium/Low]
**Story Points**: [1,2,3,5,8,13,21]

## User Story

**As a** [type of user]  
**I want** [to perform some task]  
**So that** [I can achieve some goal/benefit]

## Acceptance Criteria

### Scenario 1: [Happy Path]
- **Given** [initial context/state]
- **When** [action/event occurs]  
- **Then** [expected outcome]
- **And** [additional expected outcome]

### Scenario 2: [Edge Case]
- **Given** [different context]
- **When** [different action occurs]
- **Then** [different expected outcome]

### Scenario 3: [Error Handling]
- **Given** [error condition]
- **When** [action that triggers error]
- **Then** [appropriate error handling]

## Technical Requirements

- [ ] [Technical requirement 1]
- [ ] [Technical requirement 2] 
- [ ] [Technical requirement 3]

## UI/UX Requirements

- [ ] [UI requirement 1]
- [ ] [UX requirement 2]
- [ ] [Accessibility requirement]

## Security Requirements

- [ ] [Security consideration 1]
- [ ] [Data validation requirement]
- [ ] [Permission/capability check]

## Performance Requirements

- [ ] [Performance requirement 1]
- [ ] [Caching consideration]
- [ ] [Database optimization]

## Dependencies

- **Depends on**: [Other stories this depends on]
- **Blocks**: [Stories this story blocks]
- **Related**: [Related stories]

## Definition of Done

- [ ] **Development Complete**
  - [ ] Code implemented following WordPress standards
  - [ ] All acceptance criteria met
  - [ ] Error handling implemented
  - [ ] Security measures in place

- [ ] **Testing Complete**
  - [ ] Unit tests written and passing
  - [ ] Integration tests written and passing
  - [ ] Manual testing completed
  - [ ] Edge cases tested

- [ ] **Quality Assurance**
  - [ ] Code review completed
  - [ ] PHPCS standards check passed
  - [ ] Security review completed
  - [ ] Performance impact assessed

- [ ] **Documentation**
  - [ ] Code documentation updated
  - [ ] User documentation updated
  - [ ] API documentation updated (if applicable)
  - [ ] README updated (if needed)

## Notes

[Any additional notes, assumptions, or considerations]

## Test Cases

### Test Case 1: [Primary Flow]
```php
/**
 * @test
 * @story US-XXX
 */
public function test_primary_user_flow() {
    // Given: [setup]
    
    // When: [action]
    
    // Then: [assertions]
}
```

### Test Case 2: [Error Handling]
```php
/**
 * @test
 * @story US-XXX
 */
public function test_error_handling() {
    // Given: [error setup]
    
    // When: [action that causes error]
    
    // Then: [error assertions]
}
```

## AI Assistance Prompts

### For Test Generation
```
Generate PHPUnit tests for the following user story:
[Copy user story and acceptance criteria]

Requirements:
- Follow WordPress testing best practices
- Include both positive and negative test cases
- Use Given-When-Then structure
- Test all acceptance criteria
```

### For Implementation
```
Implement the following WordPress plugin feature:
[Copy user story and technical requirements]

Requirements:
- Follow WordPress coding standards
- Include proper validation and sanitization
- Add appropriate hooks and filters
- Include comprehensive error handling
- Ensure security best practices
```

---

**Story Status**: [Todo/In Progress/Testing/Done/Blocked]
**Assigned to**: [Developer Name]
**Started**: [Date]
**Completed**: [Date]
