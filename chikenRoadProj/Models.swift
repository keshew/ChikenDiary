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

struct Pigeon: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: String
    var breed: String
    var dateAdded: Date
    
    init(name: String, color: String = "Blue Bar", breed: String = "Unknown") {
        self.name = name
        self.color = color
        self.breed = breed
        self.dateAdded = Date()
    }
}

struct PigeonGroup: Identifiable, Codable {
    let id = UUID()
    var name: String
    var pigeons: [Pigeon]
    var dateCreated: Date
    
    init(name: String, pigeons: [Pigeon] = []) {
        self.name = name
        self.pigeons = pigeons
        self.dateCreated = Date()
    }
}

struct DiaryEntry: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var pigeonGroupId: UUID
    var mood: Mood
    var chicksCount: Int
    var notes: String
    
    init(pigeonGroupId: UUID, mood: Mood, chicksCount: Int, notes: String) {
        self.date = Date()
        self.pigeonGroupId = pigeonGroupId
        self.mood = mood
        self.chicksCount = chicksCount
        self.notes = notes
    }
}

// MARK: - Data Manager

class PigeonDiaryManager: ObservableObject {
    @Published var pigeonGroups: [PigeonGroup] = []
    @Published var diaryEntries: [DiaryEntry] = []
    
    private let groupsKey = "PigeonGroups"
    private let entriesKey = "DiaryEntries"
    
    init() {
        loadData()
    }
    
    // MARK: - Pigeon Groups Management
    
    func addPigeonGroup(_ group: PigeonGroup) {
        pigeonGroups.append(group)
        saveData()
    }
    
    func updatePigeonGroup(_ group: PigeonGroup) {
        if let index = pigeonGroups.firstIndex(where: { $0.id == group.id }) {
            pigeonGroups[index] = group
            saveData()
        }
    }
    
    func deletePigeonGroup(_ group: PigeonGroup) {
        pigeonGroups.removeAll { $0.id == group.id }
        // Also delete related diary entries
        diaryEntries.removeAll { $0.pigeonGroupId == group.id }
        saveData()
    }
    
    func addPigeonToGroup(_ pigeon: Pigeon, groupId: UUID) {
        if let index = pigeonGroups.firstIndex(where: { $0.id == groupId }) {
            pigeonGroups[index].pigeons.append(pigeon)
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
        return diaryEntries.filter { $0.pigeonGroupId == groupId }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Statistics
    
    func getTotalChicks() -> Int {
        return diaryEntries.reduce(0) { $0 + $1.chicksCount }
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
        if let groupsData = try? JSONEncoder().encode(pigeonGroups) {
            UserDefaults.standard.set(groupsData, forKey: groupsKey)
        }
        
        if let entriesData = try? JSONEncoder().encode(diaryEntries) {
            UserDefaults.standard.set(entriesData, forKey: entriesKey)
        }
    }
    
    private func loadData() {
        if let groupsData = UserDefaults.standard.data(forKey: groupsKey),
           let groups = try? JSONDecoder().decode([PigeonGroup].self, from: groupsData) {
            pigeonGroups = groups
        }
        
        if let entriesData = UserDefaults.standard.data(forKey: entriesKey),
           let entries = try? JSONDecoder().decode([DiaryEntry].self, from: entriesData) {
            diaryEntries = entries
        }
    }
} 