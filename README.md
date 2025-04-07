# flutter-belgium-meetup-2025-background-geolocation

Code and presentation for a Flutter Belgium meetup discussing background location using `flutter_background_geolocation`

This repository is a monorepo containing two main components:

1. **`flutter_presentation`**: A presentation in Markdown format.
2. **`flutter_background_tracking`**: A standard Flutter application.

---

## Viewing the Presentation

The `flutter_presentation` folder contains the presentation written in Markdown. You can view it using the [Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode) plugin. To view the presentation:

1. Install the Marp for VS Code plugin.
2. Open the `.md` file located in the `flutter_presentation` folder.
3. Use the "Marp: Open Preview" command in VS Code to render the presentation.

- The presentation has also been exported to a PDF for convenience.

---

## Running the Flutter Application

The `flutter_background_tracking` folder contains a Flutter application. Follow these steps to run it:

### Prerequisites

- Install Flutter by following the [official Flutter installation guide](https://docs.flutter.dev/get-started/install).
- Ensure you have a working Flutter development environment (e.g., Android Studio, Xcode, or VS Code with the Flutter plugin).

### Running the App

⚠️ Note: The Flutter application currently only runs on Android. iOS support has been removed.

The app can be launched in two configurations, as defined in the `launch.json` file:

1. **Flutter (Real Sendbird)**:

   - This configuration uses the real Sendbird service.
   - **Known Issue**: You cannot have two Sendbird users in one Flutter app simultaneously, which may cause problems in this mode.
   - To use this configuration, select `Flutter (Real Sendbird)` in the VS Code debug menu or run:
     ```bash
     flutter run --dart-define=USE_MOCK_SENDBIRD=false
     ```

2. **Flutter (Mock Sendbird)**:
   - This configuration uses a mock Sendbird service, which works without issues.
   - To use this configuration, select `Flutter (Mock Sendbird)` in the VS Code debug menu or run:
     ```bash
     flutter run --dart-define=USE_MOCK_SENDBIRD=true
     ```

### Steps to Run

1. Navigate to the `flutter_background_tracking` folder:
   ```bash
   cd flutter_background_tracking
   ```
2. Fetch the dependencies:
   ```bash
   flutter pub get
   ```
3. Launch the app using one of the configurations above.

---

## Folder Structure

- **`flutter_presentation`**: Contains the Markdown presentation.
- **`flutter_background_tracking`**: Contains the Flutter application.

---

## Additional Notes

- If you encounter issues with the real Sendbird service, use the mock service for testing and development purposes.
- The real Sendbird service has known limitations: it does not support multiple users simultaneously within the same app context, and connection issues may occur. Use the mock service during development for better stability.
- For more details on debugging Flutter apps, refer to the [Flutter Debugging Guide](https://docs.flutter.dev/testing/debugging).
- The `launch.json` file is preconfigured for both mock and real Sendbird services, making it easy to switch between them in VS Code.

## Environment Setup

To securely manage secrets like API keys, this project uses the `flutter_dotenv` package. You must create a `.env` file at the root of the repository with the following content:

```env
# .env
SENDBIRD_APP_ID=your-sendbird-app-id
SENDBIRD_API_TOKEN=your-sendbird-api-token
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

These values are automatically injected at runtime by the app.

### Android Integration

- The Google Maps API key is accessed from the `.env` file and passed to the Android `AndroidManifest.xml` using Gradle `manifestPlaceholders`.
- This avoids hardcoding sensitive keys directly into the native Android project.

### iOS Support

- The Flutter application is currently Android-only. iOS support and Google Maps iOS integration have been intentionally removed to avoid leaking sensitive API keys and due to limitations with background location tracking and Sendbird in iOS.

Feel free to reach out if you have any questions or encounter issues!
