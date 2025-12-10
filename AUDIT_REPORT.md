# Koaa Finance App - UI/UX Audit Report

## 1. Analytics/Statistics View (`lib/app/modules/analytics/views/analytics_view.dart`)

**Severity Rating:** High

**Major Flaws Identified:**
1. **Poor Data Visualization:** The app uses basic `LinearProgressIndicator` bars (lines 352-364) to represent category spending. This is hard to read for comparison. A proper visualization like a Pie Chart or Donut Chart (via `fl_chart`) is standard for 2024/2025 finance apps.
2. **Static & Non-Interactive:** The "charts" are static. Tapping on a category (line 335) does nothing. Users expect to tap a category to see the transaction history for that specific category.
3. **Hardcoded Styling:** Colors like `Color(0xFF1A1B1E)` (line 126) and font sizes like `38.sp` (line 144) are hardcoded. This breaks theme consistency and makes dark/light mode support difficult.

**UX Problems:**
1. **Month Navigation:** The navigation arrows (lines 77, 106) rely on standard icon buttons. The touch targets might be small for some users. A swipe gesture on the whole card to change months would be more intuitive.
2. **Empty States:** The empty state for jobs (line 274) is functional but uninspiring. It lacks a clear "Call to Action" button directly in the empty state view.
3. **Feedback:** Custom containers (like `_buildSummaryCard`) lack visual feedback (ripple effect) when tapped, making the app feel "dead" or unresponsive.

**UI Problems:**
1. **Inconsistent Shadows:** The "Net Balance" card (line 130) uses a specific hardcoded shadow, while other cards use different or no elevation, leading to a disjointed visual hierarchy.
2. **Typography:** The mix of `Get.textTheme` and manual `TextStyle` (lines 144, 153) results in inconsistent font weights and spacing.

**Logic/Technical Problems:**
1. **Performance:** The entire body is wrapped in `Obx` (lines 43, 47, etc.), but complex widgets are rebuilt unnecessarily.
2. **Formatting Logic:** `_formatAmount` (line 415) is a utility function that likely duplicates logic found elsewhere in the app.

**Missing Features:**
1. **Trend Analysis:** There is no comparison with the previous month (e.g., "You spent 20% less than last month").
2. **Export:** No ability to export the monthly report to PDF or Excel.

**Quick Wins:**
- Wrap `_buildSummaryCard` in `InkWell` for touch feedback.
- Extract `_formatAmount` to a shared utility class.

**Recommended Redesign Priority:** High

---

## 2. Recurring Transactions View (`lib/app/modules/settings/views/recurring_transactions_view.dart`)

**Severity Rating:** Medium

**Major Flaws Identified:**
1. **No Edit Capability:** Users can delete a transaction (line 127) but cannot edit it. If a user needs to change the amount or date, they must delete and recreate it. This is a high-friction user flow.
2. **Dangerous Deletion:** The delete button (line 127) calls `controller.deleteRecurringTransaction(index)` immediately. There is no confirmation dialog mentioned in the view code. Accidental touches could destroy data.

**UX Problems:**
1. **List Identification:** The list item uses a generic refresh icon (line 109) for all transactions. It should use the category icon (e.g., House for Rent, WiFi for Internet) to be scannable.
2. **Information Density:** The subtitle shows frequency but misses the "Next Payment Date", which is crucial for recurring bills.

**UI Problems:**
1. **Animation Overuse:** While animations are nice, animating every list item on every build (line 36) can feel busy.

**Logic/Technical Problems:**
1. **Index-based Deletion:** Deleting by index (`index`) is risky in mutable lists. It should delete by `transaction.id`.

**Missing Features:**
1. **Pause/Resume:** Users often want to pause a subscription, not delete it entirely.
2. **Sort/Filter:** No way to sort by amount or frequency.

**Quick Wins:**
- Add a confirmation dialog before deletion.
- Show the specific category icon instead of the generic refresh icon.

**Recommended Redesign Priority:** Medium

---

## 3. Add Recurring Transaction Dialog (`lib/app/modules/settings/widgets/add_recurring_transaction_dialog.dart`)

**Severity Rating:** Critical

**Major Flaws Identified:**
1. **Language/Localization Failure:** The entire dialog is in **English** ("Add Recurring Transaction", "Amount", "Description"), while the rest of the app (as seen in `AnalyticsView`) is in **French**. This is a critical usability issue for the target audience.
2. **Missing Category Selection:** The form asks for Amount and Description but **not Category**. Recurring transactions (like Rent or Netflix) fundamentally need categories for the analytics to work properly.
3. **Artificial Latency:** The code includes `await Future.delayed(const Duration(milliseconds: 800));` (line 49). This deliberately makes the app feel slow and unresponsive for no technical reason.

**UX Problems:**
1. **Form Length:** The form is long. On smaller devices, the "Save" button might be pushed far down.
2. **Weekly Selector:** The day selector (M T W T F S S) (line 272) uses English initials. In French, it should be (L M M J V S D).

**UI Problems:**
1. **Inconsistent Input Styling:** The inputs use `Colors.grey.shade50` with borders, which differs from the inputs in `AnalyticsView` (standard Material TextFields).

**Logic/Technical Problems:**
1. **Hardcoded Strings:** English strings are hardcoded throughout the file.

**Missing Features:**
1. **Category Picker:** As mentioned, critical for data integrity.

**Quick Wins:**
- **Translate all text to French immediately.**
- **Remove the 800ms artificial delay.**
- Add the Category Picker found in other parts of the app.

**Recommended Redesign Priority:** Critical

---

## 4. User Setup/Onboarding Dialog (`lib/app/modules/home/widgets/user_setup_dialog.dart`)

**Severity Rating:** High

**Major Flaws Identified:**
1. **Exclusionary Job List:** The job list (line 67) is exclusively IT-focused ("DevOps", "FullStack", "Data Scientist"). A generic user (Teacher, Nurse, Shopkeeper) has **no option** to select their job and no "Other" field to type it in. This effectively blocks non-tech users from accurate onboarding.
2. **Salary Constraint:** The slider (line 649) constrains salaries between 50,000 and 500,000 FCFA. Many users earn outside this range. There is no manual text input fallback.

**UX Problems:**
1. **Friction:** A 4-step wizard for what is essentially "Name + Income" is overkill. It increases the chance of drop-off.
2. **Artificial Latency:** Again, `await Future.delayed(const Duration(milliseconds: 800));` (line 148) makes the app feel sluggish.

**UI Problems:**
1. **Progress Bar:** The custom progress indicator (lines 232-246) is small and might be hard to see against the white background.

**Logic/Technical Problems:**
1. **Hive Usage:** Direct Hive box operations (line 152) inside the widget layer coupling UI to data storage logic.

**Missing Features:**
1. **"Other" Job Input:** Essential for a general-purpose finance app.
2. **Manual Salary Entry:** Essential for accessibility.

**Quick Wins:**
- Add an "Autre" option to the dropdown that reveals a text field.
- Allow the salary text to be editable, not just a display for the slider.

**Recommended Redesign Priority:** High

---

## 5. Categories Screen

**Severity Rating:** High

**Major Flaws Identified:**
1. **Missing Functionality:** There is **no screen** to manage categories. Users are stuck with the hardcoded list.
2. **Rigid Architecture:** Categories are defined as an Enum (`TransactionCategory` in `local_transaction.dart`). This means adding a new category requires a code change and app update. Users cannot create custom categories (e.g., "Tontine", "Wedding Project").

**UX Problems:**
1. **User Frustration:** If a user wants to track specific expenses not in the list, they are forced to miscategorize them.

**Logic/Technical Problems:**
1. **Enum Limitations:** Using Enums for user-facing categories is an anti-pattern in personal finance apps where customization is key. It should be a database model.

**Missing Features:**
1. **Create/Edit/Delete Categories:** A standard feature in all finance apps.

**Quick Wins:**
- None. This requires a structural refactor (Migration from Enum to Model).

**Recommended Redesign Priority:** High (Strategic Technical Debt)
