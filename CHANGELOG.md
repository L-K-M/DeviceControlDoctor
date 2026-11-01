# Changelog

All notable changes to this project are documented in this file, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] - 2026-11-01

- Add the DeviceControlDoctor SwiftUI app: watch apps whose Device Control and
  Data Access (formerly Accessibility) permission looks enabled but does not
  work, keeping the macOS permission record, the app's on-disk identity, and a
  user-confirmed functional observation separate.
- Add `DoctorCore` with permission/evidence models, strict `tccutil` output
  parsing, and constrained bundle-scoped repair plans.
- Add app discovery for clients with existing permission records, a Test Pad
  for manual functional observations, per-client restart, user-confirmed
  `tccutil reset` repair, a diagnostic report export, a menu bar item, and
  opt-in periodic checks and launch at login.
