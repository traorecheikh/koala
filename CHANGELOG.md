# Changelog

## [1.7.1] - 2025-12-21

### Fixed
- **Intelligence IA**: Fixed an issue where the "Top Categories" chart would incorrectly group transactions under "Autre" (Other) even if they were categorized.
- **Data Migration**: Implemented V10 "Aggressive" rescue script to fix legacy transactions that were stuck with generic identifiers.
- **Icons**: Fixed "Zombie" custom categories that had correct names (e.g., "Transport") but displayed the wrong icon.
- **Smart Analytics**: Enhanced the Financial Brain to identify categories by their description (e.g., "Uber" -> Transport) if the strict category ID checks fail.
- **Debt Reconciliation**: Silenced false warnings about "Unexpected transaction type" when viewing debt funding transactions (Initial Loan Income).

### Added
- **Fallback Logic**: Added description-based categorization fallback for charts to ensure visual accuracy even with imperfect metadata.
