import SwiftUI
import Observation

@Observable
class CurrentPracticeSession {
    var currentSession: PracticeSession?
    var currentItem: PracticeItem?
    var currentSubItem: PracticeSubItem?
    
    var timer: Timer?
    
    public func toggleTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        } else {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if let currentSession = self.currentSession,
                    let currentSubItem = self.currentSubItem {
                    currentSession.incrementSecsSpentOnSubItem(currentSubItem)
                }
           }
        }
    }
    
    public func isTimerRunning() -> Bool {
        return timer != nil
    }
    
    public func isCurrentTask(practiceSession: PracticeSession, item: PracticeItem) -> Bool {
        guard let currentSession = self.currentSession else { return false }
        guard let currentItem = self.currentItem else { return false }
        return practiceSession == currentSession
               && item == currentItem;
    }
    
    public func isCurrentSubTask(practiceSession: PracticeSession, item: PracticeItem, subItem: PracticeSubItem) -> Bool {
        guard let currentSession = self.currentSession else { return false }
        guard let currentItem = self.currentItem else { return false }
        guard let currentSubItem = self.currentSubItem else { return false }
        return practiceSession == currentSession
            && item == currentItem
            && subItem == currentSubItem;
    }
}
