import SwiftUI
import Observation

@Observable
class CurrentPracticeSession {
    var currentSession: PracticeSession?
    var currentTask: PracticeTask?
    var currentSubTask: PracticeSubTask?
    
    var timer: Timer?
    
    public func setPractice(session: PracticeSession, task: PracticeTask, subTask: PracticeSubTask) {
        self.currentSession = session
        self.currentTask = task
        self.currentSubTask = subTask
    }
    
    public func isPracticeSet() -> Bool {
        return currentSession != nil && currentTask != nil && currentSubTask != nil
    }
    
    public func clearSession() {
        self.currentSession = nil
        self.currentTask = nil
        self.currentSubTask = nil
        if isTimerRunning() {
            toggleTimer()
        }
    }
    
    public func toggleTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        } else {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if let currentSession = self.currentSession,
                    let currentSubItem = self.currentSubTask {
                    currentSession.incrementSecsSpentOnSubItem(currentSubItem)
                }
           }
        }
    }
    
    public func getSecsSpentOnCurrentSubTask() -> Int {
        if let currentSession = currentSession,
           let currentSubTask = currentSubTask {
            return currentSession.secsSpentPerSubItem[currentSubTask.id] ?? 0
        }
        return 0
    }
    
    public func isTimerRunning() -> Bool {
        return timer != nil
    }
    
    public func goToNextSubtask() {
        if let nextSubTask = getNextSubTaskInCurrentTask() {
            self.currentSubTask = nextSubTask
        } else if let nextTask = getNextTask() {
            self.currentTask = nextTask
            let nextSubTask = nextTask.practiceSubTasks.first
            self.currentSubTask = nextSubTask
        }
    }
    
    public func goToPrevSubtask() {
        if let prevSubTask = getPrevSubTaskInCurrentTask() {
            self.currentSubTask = prevSubTask
        } else if let prevTask = getPrevTask() {
            self.currentTask = prevTask
            let nextSubTask = prevTask.practiceSubTasks.last
            self.currentSubTask = nextSubTask
        }
    }
    
    public func getPrevSubTaskInCurrentTask() -> PracticeSubTask? {
        guard let currentTask = self.currentTask,
              let currentSubTask  = self.currentSubTask else { return nil }
        let subTasks = currentTask.practiceSubTasks
        let currentSubTaskIndex = subTasks.firstIndex(of: currentSubTask)
        guard let index = currentSubTaskIndex else { return nil }
        return subTasks.indices.contains(index - 1) ? subTasks[index - 1] : nil
    }
    
    public func getNextSubTaskInCurrentTask() -> PracticeSubTask? {
        guard let currentTask = self.currentTask,
              let currentSubTask  = self.currentSubTask else { return nil }
        let subTasks = currentTask.practiceSubTasks
        let currentSubTaskIndex = subTasks.firstIndex(of: currentSubTask)
        guard let index = currentSubTaskIndex else { return nil }
        return subTasks.indices.contains(index + 1) ? subTasks[index + 1] : nil
    }
    
    public func getNextTask() -> PracticeTask? {
        guard let currentSession = self.currentSession,
              let currentTask = self.currentTask else { return nil }
        let practiceTasks = currentSession.practiceTasks
        let currentTaskIndex = practiceTasks.firstIndex(of: currentTask)
        guard let index = currentTaskIndex else { return nil }
        return practiceTasks.indices.contains(index + 1) ? practiceTasks[index + 1] : nil
    }
    
    public func getPrevTask() -> PracticeTask? {
        guard let currentSession = self.currentSession,
              let currentTask = self.currentTask else { return nil }
        let practiceTasks = currentSession.practiceTasks
        let currentTaskIndex = practiceTasks.firstIndex(of: currentTask)
        guard let index = currentTaskIndex else { return nil }
        return practiceTasks.indices.contains(index - 1) ? practiceTasks[index - 1] : nil
    }
    
    public func hasNextSubTask() -> Bool {
        if getNextSubTaskInCurrentTask() != nil {
            return true
        }
        if getNextTask() != nil {
            return true
        }
        return false
    }
    
    public func hasPrevSubTask() -> Bool {
        if getPrevSubTaskInCurrentTask() != nil {
            return true
        }
        if getPrevTask() != nil {
            return true
        }
        return false
    }
    
    public func isCurrentTask(practiceSession: PracticeSession, item: PracticeTask) -> Bool {
        guard let currentSession = self.currentSession else { return false }
        guard let currentItem = self.currentTask else { return false }
        return practiceSession == currentSession
               && item == currentItem;
    }
    
    public func isCurrentSubTask(practiceSession: PracticeSession, item: PracticeTask, subItem: PracticeSubTask) -> Bool {
        guard let currentSession = self.currentSession else { return false }
        guard let currentItem = self.currentTask else { return false }
        guard let currentSubItem = self.currentSubTask else { return false }
        return practiceSession == currentSession
            && item == currentItem
            && subItem == currentSubItem;
    }
}
