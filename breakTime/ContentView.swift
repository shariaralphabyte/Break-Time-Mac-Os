import SwiftUI
import ServiceManagement
import UserNotifications

struct ContentView: View {
    @ObservedObject var breakTimer: BreakTimer
    @State private var tempInterval: String = ""
    @State private var notificationStatus: String = "Checking..."
    @State private var showingLoginItemsInstructions = false
    
    let statusBarController: StatusBarController?
    
    init(breakTimer: BreakTimer, statusBarController: StatusBarController? = nil) {
        self.breakTimer = breakTimer
        self.statusBarController = statusBarController
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "clock.badge")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Break Reminder")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            // Notification Status
            VStack(spacing: 5) {
                HStack {
                    Image(systemName: notificationStatus == "Enabled" ? "bell.fill" : "bell.slash")
                        .foregroundColor(notificationStatus == "Enabled" ? .green : .orange)
                    Text("Notifications: \(notificationStatus)")
                        .font(.caption)
                }
                
                if notificationStatus != "Enabled" {
                    Button("Fix Notifications") {
                        statusBarController?.openNotificationSettings()
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
            }
            
            // Timer Status
            VStack(spacing: 10) {
                Text("Next break in:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(breakTimer.formattedTimeRemaining)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(breakTimer.isRunning ? .primary : .secondary)
            }
            
            // Controls
            VStack(spacing: 15) {
                HStack {
                    Text("Break interval:")
                    Spacer()
                    TextField("Minutes", text: $tempInterval)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                        .onAppear {
                            tempInterval = String(breakTimer.intervalMinutes)
                        }
                    
                    Button("Update") {
                        if let interval = Int(tempInterval), interval > 0 {
                            breakTimer.updateInterval(interval)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack(spacing: 10) {
                    Button(breakTimer.isRunning ? "Pause" : "Start") {
                        if breakTimer.isRunning {
                            breakTimer.stopTimer()
                        } else {
                            breakTimer.startTimer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Reset") {
                        breakTimer.resetTimer()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Test") {
                        testNotification()
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            Divider()
            
            // Auto-start options
            VStack(spacing: 8) {
                // Method 1: Modern approach
                Button("Enable Auto-Start") {
                    enableAutoStart()
                }
                .buttonStyle(.link)
                
                // Method 2: Manual instructions
                Button("Manual Setup Instructions") {
                    showingLoginItemsInstructions = true
                }
                .buttonStyle(.link)
                
                Button("Recheck Permissions") {
                    statusBarController?.recheckPermissions()
                    updateNotificationStatus()
                }
                .buttonStyle(.link)
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.link)
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 320)
        .onAppear {
            updateNotificationStatus()
        }
        .sheet(isPresented: $showingLoginItemsInstructions) {
            LoginItemsInstructionsView()
        }
    }
    
    private func enableAutoStart() {
        // Method 1: Try modern ServiceManagement (macOS 13+)
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
                showSuccessAlert("Auto-start enabled successfully!")
            } catch {
                print("ServiceManagement failed: \(error)")
                // Fallback to manual instructions
                showManualInstructions()
            }
        } else {
            // Fallback for older macOS versions
            tryLegacyLoginItems()
        }
    }
    
    private func tryLegacyLoginItems() {
        // Try the AppleScript approach with better error handling
        let appPath = Bundle.main.bundleURL.path
        let script = """
        try
            tell application "System Events"
                if not (exists login item "breakTime") then
                    make login item at end with properties {path:"\(appPath)", hidden:false}
                    return "success"
                else
                    return "already exists"
                end if
            end tell
        on error
            return "failed"
        end try
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let result = scriptObject.executeAndReturnError(&error)
            
            if let output = result.stringValue {
                if output == "success" {
                    showSuccessAlert("Auto-start enabled successfully!")
                } else if output == "already exists" {
                    showSuccessAlert("Auto-start was already enabled!")
                } else {
                    showManualInstructions()
                }
            } else {
                print("AppleScript error: \(error?.description ?? "Unknown error")")
                showManualInstructions()
            }
        } else {
            showManualInstructions()
        }
    }
    
    private func showSuccessAlert(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Success! ✅"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func showManualInstructions() {
        showingLoginItemsInstructions = true
    }
    
    private func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification 🔔"
        content.body = "If you see this, notifications are working!"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Test Alert"
                    alert.informativeText = "Notifications aren't working, but alerts are!"
                    alert.runModal()
                }
            }
        }
    }
    
    private func updateNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    notificationStatus = "Enabled"
                case .denied:
                    notificationStatus = "Denied"
                case .notDetermined:
                    notificationStatus = "Not Set"
                case .provisional:
                    notificationStatus = "Provisional"
                case .ephemeral:
                    notificationStatus = "Temporary"
                @unknown default:
                    notificationStatus = "Unknown"
                }
            }
        }
    }
}

struct LoginItemsInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Auto-Start Setup")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            
            Divider()
            
            Text("Follow these steps to make BreakReminder start automatically:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionStep(
                    number: "1",
                    title: "Open System Settings",
                    description: "Click the Apple menu → System Settings (or System Preferences on older macOS)"
                )
                
                InstructionStep(
                    number: "2",
                    title: "Go to Login Items",
                    description: "Click 'General' → 'Login Items' (or 'Users & Groups' → your user → 'Login Items' on older macOS)"
                )
                
                InstructionStep(
                    number: "3",
                    title: "Add BreakReminder",
                    description: "Click the '+' button and navigate to your BreakReminder app to add it"
                )
                
                InstructionStep(
                    number: "4",
                    title: "Alternative Method",
                    description: "Right-click the BreakReminder app in Applications → Options → 'Open at Login'"
                )
            }
            
            Divider()
            
            HStack {
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Text("💡 Tip: Move the app to Applications folder first")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 450, height: 400)
    }
}

struct InstructionStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.blue))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView(breakTimer: BreakTimer())
}
