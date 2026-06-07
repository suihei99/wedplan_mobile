<!--
	Polished release README for WedPlan Mobile App v1.0.0
	- Keep this file high-level; the USER_MANUAL.md contains user-facing instructions.
-->

# WedPlan Mobile App

![Release](https://img.shields.io/badge/release-1.0.0-blue) ![Platform](https://img.shields.io/badge/platform-mobile%20%7C%20web-lightgrey)

Forever memories, beautifully planned — WedPlan helps couples, vendors, and guests manage wedding details in one mobile-first application.

## Release Highlights (v1.0.0)

- Clean, role-based experiences for Couples, Vendors, and Guests
- Couple dashboard: budget, tasks, guests, and vendor browsing
- Vendor dashboard: service management and booking workflow
- Guest invitation lookup and QR-based RSVP/check-in
- Push notifications (Firebase) and secure session persistence

## Quick Links

- User guide: [USER_MANUAL.md](USER_MANUAL.md)
- Changelog: [CHANGELOG.md](CHANGELOG.md)

## Screenshots

Add screenshots here to show the app UI for Couple and Vendor dashboards.

- Screenshot: Dashboard (couple)
- Screenshot: Vendor bookings

## Install & Run (Development)

Clone the repo and fetch dependencies:

```bash
git clone <repo-url> && cd wedplan_mobile
flutter pub get
```

Run on a device or emulator:

```bash
flutter run
```

Point the app to a custom API server (optional):

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com/api/v1
```

Default API: `https://wedplan.projectse.io/api/v1`

## Build

```bash
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
flutter build windows # Windows
```

## Project Structure (high level)

- `lib/views/` — UI screens
- `lib/viewmodels/` — State & UI logic (Provider)
- `lib/repositories/` — API access
- `lib/services/` — auth, notifications, helpers
- `lib/models/` — typed data models
- `assets/` — images and icons

## Configuration & Notes

- Firebase: follow platform guides to configure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) for push notifications.
- API: the app expects a JSON REST API compatible with the app's repository classes.
- Secure storage: sessions use Flutter Secure Storage for tokens.

## Contributing & Local Development

- Follow standard Flutter contribution steps: create a branch, open a PR, and include screenshots for UI changes.
- Run formatting and tests before opening a PR:

```bash
flutter format .
flutter test
```

## Changelog & Release Notes

See [CHANGELOG.md](CHANGELOG.md) for release notes and version history.

## Support

For issues or questions, contact the project maintainer or open an issue in the repository.
