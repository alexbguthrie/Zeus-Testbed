# Zeus-Testbed

Zeus-Testbed is a SwiftUI sandbox application that explores building a modern "Smart Files" experience. It uses an MVVM architecture with a custom theming system and a local file storage layer.

## Requirements
- macOS with Xcode 15 or later
- Swift 5.9

## Building
1. Clone the repository.
2. Open `Zeus-Testbed.xcodeproj` in Xcode.
3. Select the `Zeus-Testbed` scheme and run (`Cmd+R`).

The app stores imported files and metadata inside the user's Application Support directory under `com.zeus-testbed.smartfiles`.

## Features
- Hierarchical folder navigation with breadcrumb trail
- Inline file renaming, duplication, and favorites
- Drag‑and‑drop import and batch operations (move, copy, delete)
- Search and filtering by type, tags, and date
- Toast‑style notifications for all file actions
- Rich file previews for text, images and PDFs
- Smart sidebar groups for Recents and Favorites

## Tests
The project includes minimal unit and UI test targets. Run them from Xcode with `Cmd+U`.
