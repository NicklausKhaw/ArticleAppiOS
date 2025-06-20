# Article App

A modern iOS application built with MVVM architecture that integrates with the New York Times APIs to display and search articles.

## Features

- **MVVM Architecture**: Clean separation of concerns with ViewModels handling business logic.
- **RxSwift Framework**: Reactive programming for data binding and event handling.
- **NYTimes API Integration**: Uses both Most Popular and Article Search APIs.
- **Home Screen**: Displays app title, search button, and selection for Most Viewed, Most Shared, or Most Emailed articles.
- **Search Screen**: Allows users to search for articles using keywords.
- **Article Listing Screen**:
    - Displays articles in a list with thumbnail images.
    - Placeholder images for articles without a thumbnail.
    - Dropdown menu to filter "Most Popular" articles by time period (1, 7, or 30 days).
- **Efficient Image Loading**: Asynchronous image downloading and caching to improve performance.
- **Robust Error Handling**: Handles API decoding errors and network issues gracefully.

## Setup Instructions

### 1. Install Dependencies

This project uses **CocoaPods** for dependency management.

1.  Open your terminal and navigate to the project directory.
2.  Install the required pods by running:
    ```sh
    pod install
    ```

### 2. Build and Run

1. Open the generated `ArticleApp.xcworkspace` file in Xcode (do not use the `.xcodeproj` file).
2. Select your target device or simulator.
3. Build and run the project (⌘+R).

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models**: Data structures for articles and API responses.
- **Views**: UI components (ViewControllers and custom views).
- **ViewModels**: Business logic and data binding using **RxSwift** and **RxCocoa**.
- **Services**: Network and image loading services.

## Dependencies

- iOS 13.0+
- Swift 5.0+
- **RxSwift** & **RxCocoa**
- **CocoaPods**