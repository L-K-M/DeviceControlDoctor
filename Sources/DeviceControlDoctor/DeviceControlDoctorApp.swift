import SwiftUI
import AppKit

@main struct DeviceControlDoctorApp: App {
    @NSApplicationDelegateAdaptor(DoctorAppDelegate.self) var appDelegate
    @StateObject private var doctor = DoctorStore()
    var body: some Scene {
        WindowGroup("DeviceControlDoctor", id: "main") {
            MainView().environmentObject(doctor).tint(.teal)
        }
        .defaultSize(width: 1100, height: 760)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Add Applications…") { doctor.chooseApps() }.keyboardShortcut("o")
                Button("Refresh Permissions") { doctor.refresh() }.keyboardShortcut("r")
                    .disabled(doctor.isChecking || doctor.isRepairing)
                Button("Export Diagnostic Report…") { doctor.exportReport() }.keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }
        Window("Test Pad", id: "test-pad") {
            TestPadView().environmentObject(doctor).tint(.teal)
        }
        .defaultSize(width: 700, height: 640)
        Settings { SettingsView().environmentObject(doctor).tint(.teal) }
        MenuBarExtra("DeviceControlDoctor", systemImage: "stethoscope") {
            DoctorMenu().environmentObject(doctor)
        }
    }
}

private struct DoctorMenu: View {
    @EnvironmentObject private var doctor: DoctorStore
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Text("\(doctor.apps.count) watched apps")
        if doctor.apps.contains(where: { $0.hasDeniedExpectedPermission || $0.hasFailedTest }) {
            Text("Some apps need review")
        }
        Button("Open DeviceControlDoctor") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }
        Button("Open Test Pad") { openWindow(id: "test-pad"); NSApp.activate(ignoringOtherApps: true) }
        Button(doctor.isChecking ? "Checking…" : "Refresh Permissions") { doctor.refresh() }
            .disabled(doctor.isChecking || doctor.isRepairing)
        Toggle("Check every minute", isOn: $doctor.monitorEnabled)
        Divider()
        Button("Quit DeviceControlDoctor") { NSApp.terminate(nil) }.keyboardShortcut("q")
    }
}

final class DoctorAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}
