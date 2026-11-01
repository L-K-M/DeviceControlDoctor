# DeviceControlDoctor

A native macOS utility for investigating apps whose Device Control and Data Access (formerly Accessibility) permission looks enabled but does not work.

![App icon](Resources/AppIcon.png)

DeviceControlDoctor keeps three things separate: the permission macOS reports, the identity of the app being checked, and a functional observation you confirm yourself. A recorded grant never becomes an automatic “healthy” result.

## Build and run

Requires macOS 14 or later and Xcode 16 or later (Swift 6 toolchain). Permission-record queries require a macOS version/configuration exposing `tccutil list`; macOS 27.2 is the locally verified version. Earlier or restricted systems can use identity inspection, the Test Pad, Settings links, and targeted repair.

```sh
swift test
./scripts/build-app.sh
open build/DeviceControlDoctor.app
```

The script builds a release `.app` with the generated icon and ad-hoc signs it for local use. For a stable signing identity:

```sh
CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/build-app.sh
```

No external packages, server, API key, or network connection is needed at runtime. The app is intentionally not App Sandbox-enabled: macOS blocks `tccutil` in a sandbox, including read-only use. The local build is not notarized. App Store distribution and a public notarized release are separate work.

## Use

1. **Add apps.** Find applications with existing permission records, or choose `.app` bundles yourself. Embedded helpers such as Keyboard Maestro Engine are separate clients. Import only the apps you want to watch.
2. **Set expectations.** “Expected” means you believe that app needs the selected permission. Discovery suggests services with existing records, including denied records; review those suggestions. Manually chosen apps start with no expectations.
3. **Check records.** Accessibility, event generation (`PostEvent`), and input monitoring (`ListenEvent`) are queried separately. Errors, missing output, unsupported commands, and timeouts are not treated as authorization denials.
4. **Test behavior.** Open the Test Pad. Invoke PopChar, Rocket, a Keyboard Maestro macro, or another app against its field/window. Select the capability and explicitly record passed, failed, or inconclusive. These are manual observations, not automated checks of another process's trust.
5. **Try restarting first.** Expand App identity and choose Restart to request a normal quit/reopen without changing permissions. This can help distinguish startup-timing failures from stale approvals. No force-quit is used.
6. **Repair a selected client.** The repair dialog shows the exact path, bundle ID, and services. Confirming runs one `tccutil reset SERVICE BUNDLE_ID` command per selected service. Reset clears approval; enable the app again in System Settings and retest. Resets affect all copies sharing that bundle ID. Path-based clients are Settings-only.

The menu bar item keeps the app accessible when its windows close. Optional checks run every minute while the app is running, after watched apps launch, and after wake. Launch at login is opt-in in Settings. Monitoring never resets permissions or restarts apps.

## Evidence and privacy

- Uses `/usr/bin/tccutil` and `/usr/bin/codesign` through fixed executable paths and argument arrays, with bounded output and timeouts. No shell interpolation, database edits, `sudo`, injection, or private TCC framework calls.
- Does not need its own Accessibility, Input Monitoring, Screen Recording, or Full Disk Access grant for its normal operation.
- Checks the current app path, fresh on-disk bundle metadata, signing identifier, Team ID, designated requirement, and signature validity. A signature change is a diagnostic clue, not proof that authorization was lost.
- Passing observations are invalidated on a new Doctor session, app launch, detected app-version/identity changes, permission-state changes, and reset. The last-known-working date and activity history remain historical evidence.
- Stores the watch list and up to 200 events in `~/Library/Application Support/DeviceControlDoctor/watchlist.json`. Settings use the app's standard preferences. No analytics or telemetry.
- Exported JSON contains app paths, identifiers, permission readings, and your notes. Review it before sharing. Test-pad text is not saved or included in reports.
- Does not universally determine another app's effective permission. Public AX/CG trust APIs test their calling process. A functional failure can also be caused by Secure Input, an app bug, a stopped helper, or target responsiveness.
- Apple describes `tccutil list` for managed devices. Availability is detected at runtime; successful read-only queries were verified on the development Mac, not every 27.x configuration.

## Project layout

- `Sources/DoctorCore`: permission/evidence models, strict CLI parsing, constrained repair plans.
- `Sources/DeviceControlDoctor`: native SwiftUI interface, discovery, command execution, identity checks, persistence, and repair orchestration.
- `Tests`: output fixtures, reset-scope constraints, command execution/timeout tests, and fresh-metadata regression coverage. Tests never reset real permissions.
- `Resources`: app metadata, generated raster/iconset/ICNS, and the exact image-generation prompt.
- `scripts/build-app.sh`: release build, app bundle packaging, and signing.

## Research behind the behavior

- [Apple: macOS 27 enterprise changes](https://support.apple.com/en-us/148830) — new permission-listing command and direct TCC database access restrictions.
- [Apple: resetting protected-resource access](https://developer.apple.com/documentation/xcode/resetting-access-to-protected-resources-in-macos) — service- and bundle-scoped resets.
- [Apple: AXIsProcessTrusted](https://developer.apple.com/documentation/applicationservices/1460720-axisprocesstrusted) — current-process scope.
- [Apple: code signing requirements](https://developer.apple.com/documentation/technotes/tn3127-inside-code-signing-requirements) — identity across updates.
- [Synergy: enabled permission that stops working](https://support.symless.com/hc/en-us/articles/35743428145169-Troubleshooting-the-macOS-Device-Control-and-Data-Access-or-Accessibility-permission).
- [Keyboard Maestro: editor/Engine permissions](https://wiki.keyboardmaestro.com/assistance/Accessibility_Permission_Problem).
- [BetterTouchTool: multi-app startup reports](https://community.folivora.ai/t/issue-with-permissions-in-macos-27/47854) — delayed startup is an observed workaround, not a confirmed universal cause.

The app icon was generated with the built-in image-generation tool. Exact prompt and provenance: [Resources/IconPrompt.txt](Resources/IconPrompt.txt).
