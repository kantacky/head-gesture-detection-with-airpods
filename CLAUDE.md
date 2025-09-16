# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iOS app project for detecting head gestures using AirPods' motion sensors. The app uses CoreMotion framework to capture headphone motion data and includes a CoreML model for gesture classification (SwipeWithHeadClassifier).

## Build and Development Commands

### Building the Project
```bash
# Build for iOS Simulator
xcodebuild -scheme HeadGestureDetectionWithAirPods -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for device (requires provisioning profile)
xcodebuild -scheme HeadGestureDetectionWithAirPods -destination 'generic/platform=iOS' build
```

### Running Tests
```bash
# Run unit tests
xcodebuild test -scheme HeadGestureDetectionWithAirPods -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HeadGestureDetectionWithAirPodsTests

# Run UI tests
xcodebuild test -scheme HeadGestureDetectionWithAirPods -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HeadGestureDetectionWithAirPodsUITests
```

## Architecture

### Layer Structure
The codebase follows a clean architecture pattern with clear separation of concerns:

- **Screen Layer** (`Screen/`): SwiftUI views that compose the UI
- **Presenter Layer** (`Presenter/`): Business logic and state management using `@Observable` pattern
- **Service Layer** (`Service/`): High-level services that coordinate between repositories
- **Repository Layer** (`Repository/`): Data access and external API interactions
- **Entity Layer** (`Entity/`): Data models and domain objects
- **Component Layer** (`Component/`): Reusable UI components

### Key Dependencies
- **swift-dependencies**: Dependency injection system used throughout the app for testability
- **CoreMotion**: Apple framework for accessing AirPods motion data via CMHeadphoneMotionManager
- **RealityKit**: Used for 3D visualization of motion data
- **CoreML**: Machine learning framework for gesture classification

### CoreML Model
The project includes a trained CoreML model (`SwipeWithHeadClassifier.mlmodel`) that classifies head gestures into:
- idle
- left swipe
- right swipe

Training data is stored in `data/train/` and test data in `data/test/` as CSV files.

### Motion Tracking Flow
1. `MotionService` provides the interface for starting/stopping motion tracking
2. `HeadphoneMotionRepository` handles the actual CMHeadphoneMotionManager interactions
3. Motion data flows through an AsyncStream for real-time processing
4. `HeadGesturePresenter` manages the UI state and coordinates between services
5. Motion data can be logged to CSV files via `CSVService` for training purposes

### State Management
The app uses SwiftUI's `@Observable` macro for state management, with presenters managing screen state and dispatching actions in a unidirectional data flow pattern.