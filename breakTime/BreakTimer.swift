import Foundation

protocol BreakTimerDelegate: AnyObject {
    func breakTimeReached()
}

class BreakTimer: ObservableObject {
    @Published var intervalMinutes: Int = 20
    @Published var isRunning: Bool = false
    @Published var timeRemaining: TimeInterval = 0
    
    weak var delegate: BreakTimerDelegate?
    private var timer: Timer?
    
    init() {
        loadSettings()
    }
    
    func startTimer() {
        stopTimer()
        timeRemaining = TimeInterval(intervalMinutes * 60)
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = TimeInterval(intervalMinutes * 60)
    }
    
    private func updateTimer() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            delegate?.breakTimeReached()
            startTimer() // Restart the timer
        }
    }
    
    func updateInterval(_ newInterval: Int) {
        intervalMinutes = newInterval
        saveSettings()
        if isRunning {
            startTimer() // Restart with new interval
        }
    }
    

    
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Settings
    private func saveSettings() {
        UserDefaults.standard.set(intervalMinutes, forKey: "breakInterval")
    }
    
    private func loadSettings() {
        let savedInterval = UserDefaults.standard.integer(forKey: "breakInterval")
        if savedInterval > 0 {
            intervalMinutes = savedInterval
        }
    }
}
