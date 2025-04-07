# Live Location Tracking POC

## Overview

This project is a **Proof of Concept (POC)** for implementing **real-time driver tracking** for GetDriven. The feature enables customers to track drivers' locations during rides, even when the app is closed. The system ensures privacy by allowing users to opt out of tracking.

## Features wanted

- **Real-time driver location updates** (foreground & background)
- **Persistent tracking** even when the app is closed
- **Route history tracking** to visualize the driver’s past locations
- **Manual location requests** in case of missing updates
- **Privacy options** allowing drivers to disable tracking per ride

## Technologies Used

- **Flutter** (Cross-platform framework for iOS & Android)
- **Firebase** (Interim backend for storing location data)
- **Background Location SDK**: [flutter_background_geolocation](https://pub.dev/packages/flutter_background_geolocation)

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/your-repo-url.git
   ```
2. Navigate to the project directory:
   ```sh
   cd live_location_tracking_poc
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```

## Usage

1. Run the app on an emulator or physical device:
   ```sh
   flutter run
   ```
2. Ensure location permissions are enabled.
3. Test location updates by moving the device or using GPS mocking tools.

## De feature houdt in dat:

- Wanneer drivers een rit doen hun device locatie updates doorstuurt (zowel als de app open staat, als wanneer hij gekilled is)
- De driver app dwingt ook de location permissions af
- Klanten kunnen tijdens de rit zien waar de driver zich bevindt
- De huidige locatie van de driver
- Een historiek op een kaart (route) van alle punten
- Klanten kunnen ook een directe locatie update vragen, moest de driver al een tijdje geen "location ping" meer hebben gestuurd
- Klanten kunnen ook kiezen om geen tracking te activeren voor een rit (privacy)
