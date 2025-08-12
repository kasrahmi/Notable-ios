# Notable iOS App

A SwiftUI-based iOS note-taking application that mirrors the Android Notable app exactly.

## Features

- **User Authentication**: Login/Register with JWT token management
- **Notes Management**: Create, read, update, delete notes with colored backgrounds
- **Search Functionality**: Real-time search with 300ms debouncing, shows "No search results" when no matches
- **Offline Support**: Core Data persistence with network sync
- **Modern UI**: SwiftUI with MVVM architecture and Combine

## Architecture

- **MVVM Pattern**: ViewModels with @Published properties
- **Combine Framework**: Reactive programming for search debouncing and state management
- **Core Data**: Local persistence with CDNote entity
- **URLSession**: Network layer with automatic token refresh
- **Keychain**: Secure token storage

## Project Structure

```
Notable/
├── App/
│   ├── NotableApp.swift          # App entry point
│   └── ContentView.swift         # Main navigation
├── Models/
│   ├── User.swift                # User domain model
│   ├── Note.swift                # Note domain model
│   └── APIResponse.swift         # API DTOs
├── ViewModels/
│   ├── AuthViewModel.swift       # Authentication state
│   ├── NotesViewModel.swift      # Notes management & search
│   └── SettingsViewModel.swift   # User settings
├── Views/
│   ├── Authentication/
│   │   ├── OnboardingView.swift
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Notes/
│   │   ├── HomeView.swift        # Main screen with search & grid
│   │   ├── NoteCardView.swift    # Individual note cards
│   │   ├── NoteEditView.swift    # Create/edit notes
│   │   ├── NoteDetailView.swift  # View note details
│   │   └── EmptyHomeView.swift   # Empty state
│   ├── Settings/
│   │   ├── SettingsView.swift    # User settings
│   │   └── ChangePasswordView.swift
│   └── Components/
│       ├── CustomButton.swift
│       ├── CustomTextField.swift
│       └── LoadingView.swift
├── Services/
│   ├── NetworkManager.swift      # HTTP client with auth
│   ├── AuthService.swift         # Authentication endpoints
│   ├── NotesService.swift        # Notes CRUD operations
│   ├── KeychainManager.swift     # Secure storage
│   └── PersistenceController.swift # Core Data stack
└── Extensions/
    ├── Color+Extensions.swift    # Hex color support
    └── View+Extensions.swift     # Common view modifiers
```

## Key Implementation Details

### Search Behavior (Matches Android Exactly)
- Search bar always visible on home screen
- 300ms debouncing (same as Android)
- Filters by title and description
- Shows "No search results" when no matches (NOT empty notes screen)
- Clear button (X) appears when typing

### Authentication Flow
- JWT tokens stored in Keychain
- Automatic token refresh (5 min before expiry)
- 401 handling with retry after refresh
- Persistent login state

### Notes Management
- Random background colors matching Android palette
- Grid layout (2 columns)
- Floating action button for adding notes
- Offline-first with network sync

## Backend Configuration

The app uses the same backend URLs as Android:
- **Simulator**: `http://10.0.2.2:8000/api/`
- **Device**: `http://192.168.1.100:8000/` (update with your IP)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Open the project in Xcode
2. Update the backend URL in `NetworkManager.swift` if needed
3. Build and run on simulator or device

## API Endpoints

Matches Android's `NotableApi` interface:
- `POST /auth/token/` - Login
- `POST /auth/register/` - Registration
- `POST /auth/token/refresh/` - Token refresh
- `GET /auth/userinfo/` - User info
- `POST /auth/change-password/` - Change password
- `GET /notes/` - Fetch notes
- `POST /notes/` - Create note
- `PUT /notes/{id}/` - Update note
- `DELETE /notes/{id}/` - Delete note

## State Management

- **@StateObject**: For ViewModels that need to persist
- **@EnvironmentObject**: For app-wide state (AuthViewModel)
- **@Published**: For reactive properties in ViewModels
- **Combine**: For search debouncing and async operations

## Error Handling

- Network errors displayed as alerts
- Form validation with visual feedback
- Graceful fallback to local data when offline

