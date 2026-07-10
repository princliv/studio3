# Content Model & Posting Workflow

## Core Terminology

### Piece

A **Piece** is an individual artwork created by an artist. It is the
primary collectible content on the platform and can optionally be listed
for sale.

### Series

A **Series** is a curated collection created by a user that groups
multiple Pieces sharing a common theme, story, artistic style, or
concept.

### Scene

A **Scene** is a social post similar to an Instagram post. It may
contain artwork, behind-the-scenes content, announcements, process
shots, or any other shareable content. Scenes are **not** collectibles.

### Collect

**Collect** has two meanings depending on context:

-   **Buyer/User:** Collect = Purchase or add an available Piece to a
    personal collection.
-   **Seller Profile:** Collect = The section containing Pieces
    currently listed for sale.

------------------------------------------------------------------------

# Profile Structure

## Standard User Profile

1.  Pieces
    -   Displays all published artworks.
2.  Series
    -   Displays all created series.
    -   Each series contains related Pieces.
3.  Scenes
    -   Displays all social posts.

## Seller Profile

1.  Pieces
2.  Series
3.  Scenes
4.  Collect
    -   Shows Pieces listed for sale.
    -   Divided into:
        -   Available
        -   Sold

------------------------------------------------------------------------

# Supported Upload Formats

Only two aspect ratios are allowed:

-   **3:4**
-   **16:9**

This keeps the visual experience consistent across the platform.

------------------------------------------------------------------------

# Posting Workflow

## A. Publishing a Piece

    Create Piece
          │
          ▼
    Upload Artwork
          │
          ▼
    Choose Aspect Ratio
    (3:4 or 16:9)
          │
          ▼
    Add Piece Details
          │
          ▼
    (Optional)
    Add Listing Details
          │
          ▼
    Publish Piece

### Step 1 --- Add Piece Details

Includes artwork-related information such as: - Title - Description -
Tags - Medium - Style - Theme - Series selection (optional)

### Step 2 --- Add Listing Details (Optional)

Only required if selling.

Includes: - Price - Availability - Quantity/Edition -
Shipping/Collection information

If skipped, the Piece is published but not listed for sale.

------------------------------------------------------------------------

## B. Publishing a Scene

    Create Scene
          │
          ▼
    Upload Content
          │
          ▼
    Choose Aspect Ratio
    (3:4 or 16:9)
          │
          ▼
    Add Scene Details
          │
          ▼
    Publish Scene

Scene Details may include: - Caption - Tags - Location (optional)

Scenes cannot be collected or purchased.

------------------------------------------------------------------------

# Feed Experience

## For You Feed

### All

Random mix of: - Pieces - Scenes

### Available

Displays only Pieces that are currently available to collect/buy.

------------------------------------------------------------------------

# Personalization

## New Users

Recommendation priority: 1. Selected onboarding interests/preferences.
2. If none selected, random content.

## Returning Users

Recommendations evolve based on engagement signals such as: - Likes -
Saves - Shares - Comments - Viewing time - Collections - Preferred art
styles - Preferred subjects - Favorite creators

The personalization behaves similarly to Instagram's Home and Explore
feeds, continuously adapting to user interests.

------------------------------------------------------------------------

# Explore

Explore displays a mixed discovery feed containing: - Pieces - Scenes

The ranking is personalized over time using engagement while maintaining
content diversity.

------------------------------------------------------------------------

# Platform Summary

  --------------------------------------------------------------------------
  Content Type   Collectible    Can be Sold    Appears in     Appears in
                                               Feed           Profile
  -------------- -------------- -------------- -------------- --------------
  Piece          Yes            Yes (optional) Yes            Yes

  Scene          No             No             Yes            Yes

  Series         No             No             No             Yes

  Collect        Seller         Yes            No             Seller Profile
                 inventory                                    Only
  --------------------------------------------------------------------------
