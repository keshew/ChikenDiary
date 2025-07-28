import Foundation

// MARK: - Data Models

enum Mood: String, CaseIterable, Codable {
    case veryHappy = "Very Happy"
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
    case verySad = "Very Sad"
    
    var icon: String {
        switch self {
        case .veryHappy: return "face.smiling"
        case .happy: return "face.smiling"
        case .neutral: return "face.neutral"
        case .sad: return "face.frown"
        case .verySad: return "face.dashed"
        }
    }
    
    var color: String {
        switch self {
        case .veryHappy: return "green"
        case .happy: return "blue"
        case .neutral: return "orange"
        case .sad: return "yellow"
        case .verySad: return "red"
        }
    }
}

struct Chicken: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: String
    var breed: String
    var dateAdded: Date
    
    init(name: String, color: String = "Brown", breed: String = "Unknown") {
        self.name = name
        self.color = color
        self.breed = breed
        self.dateAdded = Date()
    }
}

struct ChickenGroup: Identifiable, Codable {
    let id = UUID()
    var name: String
    var chickens: [Chicken]
    var dateCreated: Date
    
    init(name: String, chickens: [Chicken] = []) {
        self.name = name
        self.chickens = chickens
        self.dateCreated = Date()
    }
}

struct DiaryEntry: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var chickenGroupId: UUID
    var mood: Mood
    var eggsCount: Int
    var notes: String
    
    init(chickenGroupId: UUID, mood: Mood, eggsCount: Int, notes: String) {
        self.date = Date()
        self.chickenGroupId = chickenGroupId
        self.mood = mood
        self.eggsCount = eggsCount
        self.notes = notes
    }
}

// MARK: - Data Manager

class ChickenDiaryManager: ObservableObject {
    @Published var chickenGroups: [ChickenGroup] = []
    @Published var diaryEntries: [DiaryEntry] = []
    
    private let groupsKey = "ChickenGroups"
    private let entriesKey = "DiaryEntries"
    
    init() {
        loadData()
    }
    
    // MARK: - Chicken Groups Management
    
    func addChickenGroup(_ group: ChickenGroup) {
        chickenGroups.append(group)
        saveData()
    }
    
    func updateChickenGroup(_ group: ChickenGroup) {
        if let index = chickenGroups.firstIndex(where: { $0.id == group.id }) {
            chickenGroups[index] = group
            saveData()
        }
    }
    
    func deleteChickenGroup(_ group: ChickenGroup) {
        chickenGroups.removeAll { $0.id == group.id }
        // Also delete related diary entries
        diaryEntries.removeAll { $0.chickenGroupId == group.id }
        saveData()
    }
    
    func addChickenToGroup(_ chicken: Chicken, groupId: UUID) {
        if let index = chickenGroups.firstIndex(where: { $0.id == groupId }) {
            chickenGroups[index].chickens.append(chicken)
            saveData()
        }
    }
    
    // MARK: - Diary Entries Management
    
    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.append(entry)
        saveData()
    }
    
    func deleteDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.removeAll { $0.id == entry.id }
        saveData()
    }
    
    func getEntriesForGroup(_ groupId: UUID) -> [DiaryEntry] {
        return diaryEntries.filter { $0.chickenGroupId == groupId }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Statistics
    
    func getTotalEggs() -> Int {
        return diaryEntries.reduce(0) { $0 + $1.eggsCount }
    }
    
    func getAverageMood() -> Mood {
        let moodValues = diaryEntries.map { entry -> Int in
            switch entry.mood {
            case .veryHappy: return 5
            case .happy: return 4
            case .neutral: return 3
            case .sad: return 2
            case .verySad: return 1
            }
        }
        
        let average = moodValues.isEmpty ? 3 : Double(moodValues.reduce(0, +)) / Double(moodValues.count)
        
        switch average {
        case 4.5...: return .veryHappy
        case 3.5..<4.5: return .happy
        case 2.5..<3.5: return .neutral
        case 1.5..<2.5: return .sad
        default: return .verySad
        }
    }
    
    func getDaysWithEntries() -> Set<Date> {
        let calendar = Calendar.current
        return Set(diaryEntries.map { calendar.startOfDay(for: $0.date) })
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        if let groupsData = try? JSONEncoder().encode(chickenGroups) {
            UserDefaults.standard.set(groupsData, forKey: groupsKey)
        }
        
        if let entriesData = try? JSONEncoder().encode(diaryEntries) {
            UserDefaults.standard.set(entriesData, forKey: entriesKey)
        }
    }
    
    private func loadData() {
        if let groupsData = UserDefaults.standard.data(forKey: groupsKey),
           let groups = try? JSONDecoder().decode([ChickenGroup].self, from: groupsData) {
            chickenGroups = groups
        }
        
        if let entriesData = UserDefaults.standard.data(forKey: entriesKey),
           let entries = try? JSONDecoder().decode([DiaryEntry].self, from: entriesData) {
            diaryEntries = entries
        }
    }
} 