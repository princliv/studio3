# Profile Screen Components

This directory contains the modularized components for the Artist Profile screen in Studio 3. The refactor breaks down the monolithic `profile_page.dart` into smaller, maintainable, and testable pieces.

## Directory Structure

```text
lib/screens/profile/
├── models/
│   └── profile_series_data.dart    # Data structures for the series tab
├── widgets/
│   ├── profile_header.dart         # Avatar, bio, stats, and action buttons
│   ├── profile_tabs.dart           # Custom tab bar with animations
│   ├── profile_masonry_grid.dart   # Generic masonry layout for pieces/scenes
│   ├── profile_series_grid.dart    # Grid layout for fanned series stacks
│   └── profile_tab_content.dart    # Tab switching logic
├── profile_constants.dart          # Shared UI constants (colors, padding)
└── README.md                       # This documentation
```

## Component Overview

### 🧩 Models
- **`ProfileSeriesData`**: Defines the data required for a series, including logic to calculate "stack seeds" for the visual fanning effect in the series grid.

### 🎨 Widgets
- **`ProfileHeader`**: A stateless widget that displays the artist's identity. It includes sub-components for stats (`_StatBlock`) and primary actions (`_FollowButton`, `_MessageButton`).
- **`ProfileTabs`**: A custom tab navigation bar. It manages its own visual active state and notifies the parent of tab changes via a callback.
- **`ProfileMasonryGrid`**: Implements a two-column masonry layout. It is used by both the "Pieces" and "Scenes" tabs.
- **`ProfileSeriesGrid`**: A specialized grid for the "Series" tab. It uses `_StackedSeriesCovers` to create the overlapping card effect (fan stack) based on the number of pieces in a series.
- **`ProfileTabContent`**: The controller widget for the bottom half of the profile. It handles the logic for rendering the correct grid or "coming soon" placeholders based on the active tab string.

### ⚙️ Constants
- **`profile_constants.dart`**: Houses shared design tokens specific to the profile section, such as `kProfileTextMuted` and standard padding values, ensuring visual consistency across all sub-components.

## Usage

The main `ProfilePage` (`lib/screens/profile_page.dart`) acts as the orchestrator. It holds the screen state (active tab) and passes data down to these components.

```dart
// Example integration in ProfilePage
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: ProfileHeader(...)),
    SliverToBoxAdapter(child: ProfileTabs(
      currentTab: _tab,
      onTabChanged: (newTab) => setState(() => _tab = newTab),
    )),
    SliverToBoxAdapter(child: ProfileTabContent(
      currentTab: _tab,
      // ... data
    )),
  ],
)
```
