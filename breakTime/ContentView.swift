import SwiftUI
import ServiceManagement
import UserNotifications

struct ContentView: View {
    @ObservedObject var breakTimer: BreakTimer
    @State private var tempInterval: String = ""
    @State private var notificationStatus: String = "Checking..."
    @State private var showingLoginItemsInstructions = false
    @State private var isHoveringStart = false
    @State private var isHoveringReset = false
    @State private var isHoveringTest = false
    @State private var isHoveringUpdate = false
    @State private var pulseAnimation = false
    @State private var lightPosition: CGFloat = 0
    
    let statusBarController: StatusBarController?
    
    init(breakTimer: BreakTimer, statusBarController: StatusBarController? = nil) {
        self.breakTimer = breakTimer
        self.statusBarController = statusBarController
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    // Header with status
                    headerSection
                    
                    // Timer display with circular progress
                    timerSection
                    
                    // Interval controls
                    intervalSection
                    
                    // Action buttons
                    actionButtonsSection
                    
                    // Settings menu
                    settingsMenuSection
                    
                    // Bottom links
                    bottomLinksSection
                }
                .padding(16)
            }
        }
        .frame(width: 320, height: 460)
        .onAppear {
            updateNotificationStatus()
            tempInterval = String(breakTimer.intervalMinutes)
            startPulseAnimation()
            startLightAnimation()
        }
        .sheet(isPresented: $showingLoginItemsInstructions) {
            LoginItemsInstructionsView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 6) {
            // Minimal icon
            Image(systemName: "clock.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        )
                )
            
            Text("Break Reminder")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Minimal status
            HStack(spacing: 3) {
                Circle()
                    .fill(notificationStatus == "Enabled" ? Color.green : Color.orange)
                    .frame(width: 4, height: 4)
                
                Text(notificationStatus)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.2), lineWidth: 0.5)
                    )
            )
            
            if notificationStatus != "Enabled" {
                Button(action: {
                    statusBarController?.openNotificationSettings()
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(
                            Circle()
                                .fill(Color.orange.opacity(0.7))
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.25), lineWidth: 0.5)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Timer Section
    private var timerSection: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.cyan.opacity(0.15), .clear],
                        center: .center,
                        startRadius: 45,
                        endRadius: 65
                    )
                )
                .frame(width: 130, height: 130)
                .blur(radius: 12)
            
            // Circular progress background
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 5)
                .frame(width: 110, height: 110)
            
            // Circular progress
            Circle()
                .trim(from: 0, to: progressValue)
                .stroke(
                    LinearGradient(
                        colors: [.cyan, .blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 110, height: 110)
                .rotationEffect(.degrees(-90))
                .shadow(color: .cyan.opacity(0.4), radius: 6, x: 0, y: 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progressValue)
            
            // Inner glass circle
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 95, height: 95)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            
            // Timer display
            VStack(spacing: 2) {
                Text(breakTimer.formattedTimeRemaining)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 2)
                
                Text(breakTimer.isRunning ? "remaining" : "paused")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
        }
        .scaleEffect(pulseAnimation && breakTimer.isRunning ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulseAnimation)
        .padding(.vertical, 8)
    }
    
    private var progressValue: CGFloat {
        let total = TimeInterval(breakTimer.intervalMinutes * 60)
        guard total > 0 else { return 0 }
        return CGFloat(breakTimer.timeRemaining / total)
    }
    
    // MARK: - Interval Section
    private var intervalSection: some View {
        VStack(spacing: 8) {
            Text("Break Interval")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.75))
                .textCase(.uppercase)
                .tracking(1)
            
            HStack(spacing: 8) {
                TextField("", text: $tempInterval)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .white.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                    )
                
                Text("min")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    if let interval = Int(tempInterval), interval > 0 {
                        breakTimer.updateInterval(interval)
                    }
                }) {
                    Text("Update")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                        .scaleEffect(isHoveringUpdate ? 1.05 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isHoveringUpdate = hovering
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                LiquidGlassCard()
            )
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 8) {
            // Start/Pause button
            Button(action: {
                if breakTimer.isRunning {
                    breakTimer.stopTimer()
                } else {
                    breakTimer.startTimer()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: breakTimer.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 12, weight: .bold))
                    Text(breakTimer.isRunning ? "Pause" : "Start")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: breakTimer.isRunning ? 
                                    [.orange, .red] :
                                    [.green, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: (breakTimer.isRunning ? Color.orange : Color.green).opacity(0.5), radius: 10, x: 0, y: 5)
                )
                .scaleEffect(isHoveringStart ? 1.05 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isHoveringStart = hovering
                }
            }
            
            // Reset button
            Button(action: {
                breakTimer.resetTimer()
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12, weight: .bold))
                    Text("Reset")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LiquidGlassCard(cornerRadius: 10)
                )
                .scaleEffect(isHoveringReset ? 1.05 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isHoveringReset = hovering
                }
            }
            
            // Test button
            Button(action: {
                testNotification()
            }) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40)
                    .padding(.vertical, 10)
                    .background(
                        LiquidGlassCard(cornerRadius: 10)
                    )
                    .scaleEffect(isHoveringTest ? 1.05 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isHoveringTest = hovering
                }
            }
        }
    }
    
    // MARK: - Settings Menu Section
    private var settingsMenuSection: some View {
        VStack(spacing: 6) {
            Text("Settings & Permissions")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.75))
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 6) {
                SettingsMenuItem(
                    icon: "checkmark.shield.fill",
                    title: "Enable Auto-Start",
                    description: "Launch app on system startup"
                ) {
                    enableAutoStart()
                }
                
                SettingsMenuItem(
                    icon: "book.fill",
                    title: "Setup Guide",
                    description: "Manual configuration instructions"
                ) {
                    showingLoginItemsInstructions = true
                }
                
                SettingsMenuItem(
                    icon: "arrow.clockwise",
                    title: "Recheck Permissions",
                    description: "Verify notification settings"
                ) {
                    statusBarController?.recheckPermissions()
                    updateNotificationStatus()
                }
            }
            .padding(10)
            .background(
                LiquidGlassCard()
            )
        }
    }
    
    // MARK: - Bottom Links
    private var bottomLinksSection: some View {
        VStack(spacing: 10) {
            Divider()
                .background(Color.white.opacity(0.3))
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Quit Application")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Helper Functions
    private func startPulseAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pulseAnimation = true
        }
    }
    
    private func startLightAnimation() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            lightPosition = 1.0
        }
    }
    
    private func enableAutoStart() {
        if #available(macOS 13.0, *) {
            do {
                try SMAppService.mainApp.register()
                showSuccessAlert("Auto-start enabled successfully!")
            } catch {
                print("ServiceManagement failed: \(error)")
                showManualInstructions()
            }
        } else {
            tryLegacyLoginItems()
        }
    }
    
    private func tryLegacyLoginItems() {
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

// MARK: - Liquid Glass Card Component
struct LiquidGlassCard: View {
    var cornerRadius: CGFloat = 14
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .overlay(
                // Inner glow
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                // Border with gradient
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .shadow(color: .white.opacity(0.1), radius: 1, x: 0, y: -1)
    }
}

// MARK: - Settings Menu Item
struct SettingsMenuItem: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.25), .purple.opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                    Text(description)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? .white.opacity(0.08) : .clear)
            )
            .scaleEffect(isHovering ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.2, blue: 0.7),
                Color(red: 0.2, green: 0.4, blue: 0.9),
                Color(red: 0.5, green: 0.2, blue: 0.8),
                Color(red: 0.3, green: 0.5, blue: 0.9)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Login Items Instructions View
struct LoginItemsInstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Auto-Start Setup")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                Text("Follow these steps to make BreakReminder start automatically:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                VStack(alignment: .leading, spacing: 14) {
                    InstructionStep(
                        number: "1",
                        title: "Open System Settings",
                        description: "Click the Apple menu → System Settings"
                    )
                    
                    InstructionStep(
                        number: "2",
                        title: "Go to Login Items",
                        description: "Click 'General' → 'Login Items'"
                    )
                    
                    InstructionStep(
                        number: "3",
                        title: "Add BreakReminder",
                        description: "Click the '+' button and select the app"
                    )
                    
                    InstructionStep(
                        number: "4",
                        title: "Alternative Method",
                        description: "Right-click app → Options → 'Open at Login'"
                    )
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Text("Open System Settings")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(.white.opacity(0.4), lineWidth: 1.5)
                                    )
                                    .shadow(color: .blue.opacity(0.5), radius: 12, x: 0, y: 6)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            .padding(32)
        }
        .frame(width: 520, height: 480)
    }
}

struct InstructionStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 4)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(14)
        .background(
            LiquidGlassCard(cornerRadius: 12)
        )
    }
}

#Preview {
    ContentView(breakTimer: BreakTimer())
}
