#!/bin/bash

# Agile Sprint Management - Start Sprint Script
# Usage: ./start-sprint.sh "Sprint 1" "2024-08-10" "2024-08-24"

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

# Function to validate date format (YYYY-MM-DD)
validate_date() {
    local date=$1
    if [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 1
    fi
    return 0
}

# Function to calculate sprint duration
calculate_duration() {
    local start_date=$1
    local end_date=$2
    
    # Convert dates to seconds since epoch
    start_seconds=$(date -d "$start_date" +%s)
    end_seconds=$(date -d "$end_date" +%s)
    
    # Calculate difference in days
    diff_seconds=$((end_seconds - start_seconds))
    duration_days=$((diff_seconds / 86400))
    
    echo $duration_days
}

# Check arguments
if [ $# -lt 3 ]; then
    print_message $RED "Usage: $0 \"Sprint Name\" \"Start Date (YYYY-MM-DD)\" \"End Date (YYYY-MM-DD)\""
    print_message $YELLOW "Example: $0 \"Sprint 1\" \"2024-08-10\" \"2024-08-24\""
    exit 1
fi

SPRINT_NAME="$1"
START_DATE="$2"
END_DATE="$3"

print_message $BLUE "🚀 Starting New Agile Sprint"
print_message $BLUE "============================="
echo

# Validate inputs
if ! validate_date "$START_DATE"; then
    print_message $RED "Error: Invalid start date format. Use YYYY-MM-DD"
    exit 1
fi

if ! validate_date "$END_DATE"; then
    print_message $RED "Error: Invalid end date format. Use YYYY-MM-DD"
    exit 1
fi

# Calculate sprint duration
DURATION=$(calculate_duration "$START_DATE" "$END_DATE")
if [ $DURATION -le 0 ]; then
    print_message $RED "Error: End date must be after start date"
    exit 1
fi

if [ $DURATION -gt 21 ]; then
    print_message $YELLOW "Warning: Sprint duration is $DURATION days. Consider shorter sprints (7-14 days)."
fi

print_message $GREEN "✓ Sprint Configuration Valid"
print_message $YELLOW "Sprint: $SPRINT_NAME"
print_message $YELLOW "Duration: $START_DATE to $END_DATE ($DURATION days)"
echo

# Extract sprint number from name
SPRINT_NUMBER=$(echo "$SPRINT_NAME" | grep -o '[0-9]\+' | head -1)
if [ -z "$SPRINT_NUMBER" ]; then
    SPRINT_NUMBER="1"
fi

# Create sprint directory
SPRINT_DIR="agile/sprints/sprint-$SPRINT_NUMBER"
mkdir -p "$SPRINT_DIR"/{stories,docs,reviews}

print_message $YELLOW "Creating sprint structure..."

# Create sprint plan from template
cp "agile/templates/sprint-plan.md" "$SPRINT_DIR/plan.md"

# Replace placeholders in sprint plan
sed -i "s/\[Number\]/$SPRINT_NUMBER/g" "$SPRINT_DIR/plan.md"
sed -i "s/\[Start Date\]/$START_DATE/g" "$SPRINT_DIR/plan.md"
sed -i "s/\[End Date\]/$END_DATE/g" "$SPRINT_DIR/plan.md"
sed -i "s/X days/$DURATION days/g" "$SPRINT_DIR/plan.md"

# Create initial sprint metrics file
cat > "$SPRINT_DIR/metrics.json" << EOF
{
  "sprint_number": $SPRINT_NUMBER,
  "sprint_name": "$SPRINT_NAME",
  "start_date": "$START_DATE",
  "end_date": "$END_DATE",
  "duration_days": $DURATION,
  "planned_points": 0,
  "completed_points": 0,
  "stories_planned": 0,
  "stories_completed": 0,
  "stories_carried_over": 0,
  "velocity": 0,
  "team_capacity": 0,
  "burndown_data": [],
  "daily_progress": {},
  "ai_assistance": {
    "code_generation_tasks": 0,
    "test_generation_tasks": 0,
    "code_review_tasks": 0,
    "total_ai_time_saved": 0
  },
  "quality_metrics": {
    "bugs_found": 0,
    "bugs_fixed": 0,
    "code_review_time_avg": 0,
    "test_coverage": 0
  }
}
EOF

# Create daily standup template
cat > "$SPRINT_DIR/standup-template.md" << EOF
# Daily Standup - [Date]

## Team Member: [Name]

### Yesterday
- [ ] [What did you complete yesterday?]
- [ ] [Any blockers resolved?]

### Today
- [ ] [What will you work on today?]
- [ ] [Any planned AI assistance sessions?]

### Blockers
- [ ] [Any current blockers?]
- [ ] [Need help with anything?]

### Sprint Progress Notes
- Current story: [US-XXX]
- Story status: [In Progress/Testing/Review]
- Estimated completion: [Date]

---
**AI Assistance Used**: [None/Code Generation/Testing/Review]
**Hours Logged**: [X hours]
EOF

# Create sprint backlog from product backlog
if [ -f "agile/stories/backlog.md" ]; then
    print_message $YELLOW "Initializing sprint backlog from product backlog..."
    
    cat > "$SPRINT_DIR/backlog.md" << EOF
# Sprint $SPRINT_NUMBER Backlog

**Sprint Goal**: [Define your sprint goal here]
**Sprint Capacity**: [Team capacity in story points]

## Committed Stories

| Story ID | Title | Priority | Points | Assignee | Status | Notes |
|----------|--------|----------|---------|----------|---------|-------|
| | | | | | Todo | |

## Sprint Burndown

- Day 1: X points remaining
- Day 2: X points remaining
- ...

## Sprint Notes

### Sprint Planning Notes
[Notes from sprint planning meeting]

### Daily Progress
[Daily progress updates]

### Blockers & Risks
[Track blockers and risks here]

EOF
else
    print_message $YELLOW "No product backlog found. Creating empty sprint backlog..."
    echo "# Sprint $SPRINT_NUMBER Backlog" > "$SPRINT_DIR/backlog.md"
fi

# Create README for sprint
cat > "$SPRINT_DIR/README.md" << EOF
# Sprint $SPRINT_NUMBER: $SPRINT_NAME

## Overview

**Duration**: $START_DATE to $END_DATE ($DURATION days)
**Sprint Goal**: [To be defined in sprint planning]

## Quick Links

- [Sprint Plan](plan.md) - Detailed sprint planning document
- [Sprint Backlog](backlog.md) - Stories committed for this sprint
- [Daily Standups](standups/) - Daily progress updates
- [Sprint Reviews](reviews/) - Sprint review and retrospective notes

## Sprint Commands

\`\`\`bash
# Daily standup
./agile/scripts/daily-standup.sh $SPRINT_NUMBER

# Create new user story
./agile/scripts/create-story.sh "US-XXX" "Story Title"

# Complete user story
./agile/scripts/complete-story.sh "US-XXX"

# Generate sprint report
./agile/scripts/sprint-report.sh $SPRINT_NUMBER

# End sprint
./agile/scripts/end-sprint.sh $SPRINT_NUMBER
\`\`\`

## Sprint Status

**Status**: Planning
**Stories**: 0 committed, 0 completed
**Velocity**: TBD
**Burndown**: [Sprint not started]

Last updated: $(date)
EOF

# Create directories for daily standups
mkdir -p "$SPRINT_DIR/standups"

# Create git branch for sprint
BRANCH_NAME="sprint-$SPRINT_NUMBER"
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    print_message $YELLOW "Branch '$BRANCH_NAME' already exists"
else
    git checkout -b "$BRANCH_NAME"
    print_message $GREEN "✓ Created git branch: $BRANCH_NAME"
fi

# Create initial commit for sprint
git add "$SPRINT_DIR"
git commit -m "Start Sprint $SPRINT_NUMBER: $SPRINT_NAME

Sprint Details:
- Duration: $START_DATE to $END_DATE ($DURATION days)
- Branch: $BRANCH_NAME
- Sprint directory: $SPRINT_DIR

Created:
- Sprint plan template
- Sprint backlog
- Metrics tracking
- Daily standup template
"

print_message $GREEN "✅ Sprint $SPRINT_NUMBER Created Successfully!"
echo
print_message $BLUE "📋 Next Steps:"
echo "1. Edit sprint plan: $SPRINT_DIR/plan.md"
echo "2. Define sprint goal and capacity"
echo "3. Add user stories to sprint backlog"
echo "4. Start first daily standup: ./agile/scripts/daily-standup.sh $SPRINT_NUMBER"
echo "5. Begin development with TDD approach"
echo
print_message $YELLOW "Sprint Directory: $SPRINT_DIR"
print_message $YELLOW "Git Branch: $BRANCH_NAME"

# Open sprint plan in default editor if available
if command -v code >/dev/null 2>&1; then
    print_message $BLUE "Opening sprint plan in VS Code..."
    code "$SPRINT_DIR/plan.md"
elif command -v nano >/dev/null 2>&1; then
    print_message $BLUE "Opening sprint plan in nano..."
    nano "$SPRINT_DIR/plan.md"
fi

echo
print_message $GREEN "Happy Sprint Planning! 🎯"
