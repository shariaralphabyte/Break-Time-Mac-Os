import Cocoa
import SwiftUI
import UserNotifications

class StatusBarController: NSObject {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var breakTimer: BreakTimer
    private var notificationPermissionGranted = false
    
    override init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        breakTimer = BreakTimer()
        
        super.init()
        
        setupStatusBarButton()
        setupPopover()
        requestNotificationPermissions()
        breakTimer.delegate = self
        breakTimer.startTimer()
    }
    
    private func setupStatusBarButton() {
        statusItem.button?.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Break Reminder")
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.target = self
    }
    
    private func setupPopover() {
        popover.contentSize = NSSize(width: 300, height: 250)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView(breakTimer: breakTimer, statusBarController: self))
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = granted
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied")
                    self?.showPermissionAlert()
                }
            }
        }
        
        // Also check current settings
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = settings.authorizationStatus == .authorized
                print("Current notification status: \(settings.authorizationStatus.rawValue)")
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Notification Permission Required"
        alert.informativeText = "To receive break reminders, please enable notifications in System Settings → Notifications → breakTime"
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Use Alternative Alerts")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openNotificationSettings()
        }
    }
    
    func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func recheckPermissions() {
        requestNotificationPermissions()
    }
    
    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    private func closePopover() {
        popover.performClose(nil)
    }
}

extension StatusBarController: BreakTimerDelegate {
    func breakTimeReached() {
        if notificationPermissionGranted {
            sendBreakNotification()
        } else {
            // Fallback: Use system alert dialog
            showBreakAlert()
        }
    }
    
    private func sendBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Break Time! 🧘‍♀️"
        content.body = "Please take a break — look at something 20 feet away.Blink 5 times and stretch your legs!"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
                // Fallback to alert if notification fails
                DispatchQueue.main.async {
                    self.showBreakAlert()
                }
            } else {
                print("✅ Break notification sent successfully")
            }
        }
    }
    
    private func showBreakAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Break Time! 🧘‍♀️"
            alert.informativeText = "Time to take a break and stretch your legs!"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
