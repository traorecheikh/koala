# UI/UX Audit Prompt for Koaa Finance App

## Context
You are auditing a Flutter-based personal finance management app called "Koaa". The app has several screens, but we're focusing on the problematic ones that need significant improvements. The home screen and settings are acceptable and should NOT be audited.

## Screens to Audit

### 1. Analytics/Statistics View (`lib/app/modules/analytics/views/analytics_view.dart`)
**Current Purpose:** Displays income, expenses, savings goals, jobs, and category breakdowns
**Key Issues to Identify:**
- UI design quality and modern design patterns
- Data visualization effectiveness (charts, graphs, visual hierarchy)
- Dialog forms usability and validation UX
- Information architecture and content organization
- Interaction patterns and user feedback
- Mobile responsiveness and touch targets
- Visual polish and consistency

### 2. Recurring Transactions View (`lib/app/modules/settings/views/recurring_transactions_view.dart`)
**Current Purpose:** Manage recurring transactions with frequency settings
**Key Issues to Identify:**
- Feature completeness (edit, view details, batch operations)
- Information display (what data is shown vs what should be shown)
- User interaction patterns (gestures, tap targets, affordances)
- Visual design and card layout effectiveness
- Empty states and onboarding
- Consistency with rest of app

### 3. Add Recurring Transaction Dialog (`lib/app/modules/settings/widgets/add_recurring_transaction_dialog.dart`)
**Current Purpose:** Form to add new recurring transactions
**Key Issues to Identify:**
- Form design and input field UX
- Validation patterns and error messaging
- Frequency selector usability
- Visual feedback during data entry
- Language/localization inconsistencies (some text is in English, app is primarily French)

### 4. User Setup/Onboarding Dialog (`lib/app/modules/home/widgets/user_setup_dialog.dart`)
**Current Purpose:** Multi-step first-run setup wizard for user profile and jobs
**Key Issues to Identify:**
- Flow complexity and user cognitive load
- Step progression logic and UX
- Jobs configuration complexity
- Input constraints (e.g., salary range 50k-500k)
- Escape hatches (ability to skip, go back, save progress)
- Form validation timing and feedback
- Visual guidance and progress indication

### 5. Categories Screen
**Current Status:** Does NOT appear to exist as a standalone screen
**Key Issues to Identify:**
- Missing functionality that should exist
- How categories are currently managed (if at all)
- Where category selection/management happens in the app

## Audit Dimensions

For each screen, evaluate:

1. **Visual Design Quality**
   - Modern design patterns vs outdated approaches
   - Use of whitespace, typography, color
   - Visual hierarchy and scanability
   - Consistency with Material/Cupertino guidelines

2. **Information Architecture**
   - Content organization and grouping
   - Progressive disclosure
   - Information density
   - Priority of information

3. **Interaction Design**
   - Touch targets and gesture affordances
   - Feedback mechanisms (haptics, animations, states)
   - Navigation patterns
   - Error prevention and recovery

4. **User Experience Flows**
   - Task completion efficiency
   - Cognitive load and complexity
   - Onboarding and empty states
   - Edge cases and error scenarios

5. **Accessibility & Usability**
   - Touch target sizes (minimum 44x44dp)
   - Color contrast
   - Text readability
   - Error messages clarity

6. **Technical UX Debt**
   - Hardcoded values that should be configurable
   - Missing features (edit, delete, search, filter)
   - Language/localization inconsistencies
   - Performance issues (if observable in code)

## Expected Output Format

For each screen, provide:

```
### Screen Name

**Severity Rating:** Critical / High / Medium / Low

**Major Flaws Identified:**
1. [Specific issue with impact description]
2. [Specific issue with impact description]
...

**UX Problems:**
1. [User experience issue]
2. [User experience issue]
...

**UI Problems:**
1. [Visual/design issue]
2. [Visual/design issue]
...

**Logic/Technical Problems:**
1. [Code or implementation issue]
2. [Code or implementation issue]
...

**Missing Features:**
1. [Feature that should exist]
2. [Feature that should exist]
...

**Quick Wins:** (Easy fixes with high impact)
- [Quick fix suggestion]
- [Quick fix suggestion]

**Recommended Redesign Priority:** Critical / High / Medium / Low
```

## Important Notes
- Be SPECIFIC. Point to exact line numbers, components, or patterns in the code
- Consider mobile-first design principles
- Evaluate against modern 2024/2025 mobile app standards
- Don't just list problems—explain the USER IMPACT
- Prioritize based on user friction and business impact
- Consider the target audience: personal finance users in French-speaking Africa (FCFA currency)

## Constraints
- DO NOT audit home screen or settings screen (they are acceptable)
- Focus on UI flaws, UX friction, and logical inconsistencies
- Consider that this is a production app used by real users

Begin your audit now. Be thorough, critical, and specific.
