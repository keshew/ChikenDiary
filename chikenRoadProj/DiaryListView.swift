import SwiftUI

struct DiaryListView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var showingAddEntry = false
    @State private var selectedGroupId: UUID?
    @State private var selectedFilter: DiaryFilter = .all
    
    init(selectedGroupId: UUID? = nil) {
        self._selectedGroupId = State(initialValue: selectedGroupId)
    }
    
    enum DiaryFilter {
        case all, today, thisWeek, thisMonth
        
        var title: String {
            switch self {
            case .all: return "All"
            case .today: return "Today"
            case .thisWeek: return "This Week"
            case .thisMonth: return "This Month"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if diaryManager.pigeonGroups.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("No Diary Entries Yet!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Create a pigeon group first, then add your first diary entry!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        NavigationLink(destination: PigeonGroupsView()) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Go to My Pigeons")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    List {
                        if !diaryManager.pigeonGroups.isEmpty {
                            Section {
                                Picker("Filter", selection: $selectedFilter) {
                                    ForEach([DiaryFilter.all, .today, .thisWeek, .thisMonth], id: \.self) { filter in
                                        Text(filter.title).tag(filter)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 8)
                            }
                        }
                        
                        let filteredEntries = getFilteredEntries()
                        
                        if filteredEntries.isEmpty {
                            Section {
                                VStack(spacing: 16) {
                                    Image(systemName: "book.closed")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                    
                                    Text(emptyStateMessage)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(emptyStateSubtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .listRowBackground(Color.clear)
                            }
                        } else {
                            ForEach(filteredEntries) { entry in
                                DiaryEntryDetailRow(entry: entry)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            diaryManager.deleteDiaryEntry(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Diary")
            .toolbar {
                if !diaryManager.pigeonGroups.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddEntry = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddDiaryEntryView()
            }
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedFilter {
        case .all:
            return "No diary entries yet!"
        case .today:
            return "No entries for today"
        case .thisWeek:
            return "No entries this week"
        case .thisMonth:
            return "No entries this month"
        }
    }
    
    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case .all:
            return "Add your first diary entry to start tracking your pigeons!"
        case .today:
            return "Add an entry to record today's pigeon activities"
        case .thisWeek:
            return "No entries recorded this week yet"
        case .thisMonth:
            return "No entries recorded this month yet"
        }
    }
    
    private func getFilteredEntries() -> [DiaryEntry] {
        var entries = diaryManager.diaryEntries
        
        // Filter by selected group if specified
        if let groupId = selectedGroupId {
            entries = entries.filter { $0.pigeonGroupId == groupId }
        }
        
        // Apply time filter
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            break
        case .today:
            entries = entries.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .thisWeek:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            entries = entries.filter { $0.date >= weekStart }
        case .thisMonth:
            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            entries = entries.filter { $0.date >= monthStart }
        }
        
        return entries.sorted { $0.date > $1.date }
    }
}

struct DiaryEntryDetailRow: View {
    let entry: DiaryEntry
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    
    private var groupName: String {
        diaryManager.pigeonGroups.first { $0.id == entry.pigeonGroupId }?.name ?? "Unknown Group"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(groupName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(entry.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: entry.mood.icon)
                            .foregroundColor(moodColor(entry.mood))
                        Text(entry.mood.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "bird")
                            .foregroundColor(.blue)
                        Text("\(entry.chicksCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func moodColor(_ mood: Mood) -> Color {
        switch mood {
        case .veryHappy: return .green
        case .happy: return .blue
        case .neutral: return .orange
        case .sad: return .yellow
        case .verySad: return .red
        }
    }
}

struct AddDiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var selectedGroupId: UUID?
    @State private var selectedMood: Mood = .happy
    @State private var chicksCount = 0
    @State private var notes = ""
    
    init(groupId: UUID? = nil) {
        self._selectedGroupId = State(initialValue: groupId)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Pigeon Group")) {
                    if diaryManager.pigeonGroups.isEmpty {
                        Text("No pigeon groups available")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Pigeon Group", selection: $selectedGroupId) {
                            Text("Select a group").tag(nil as UUID?)
                            ForEach(diaryManager.pigeonGroups) { group in
                                Text(group.name).tag(group.id as UUID?)
                            }
                        }
                        .disabled(selectedGroupId != nil) // Disable if group is pre-selected
                    }
                }
                
                Section(header: Text("How are your pigeons feeling?")) {
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            HStack {
                                Image(systemName: mood.icon)
                                    .foregroundColor(moodColor(mood))
                                Text(mood.rawValue)
                            }
                            .tag(mood)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Chicks Hatched")) {
                    Stepper("\(chicksCount) chick\(chicksCount == 1 ? "" : "s")", value: $chicksCount, in: 0...50)
                    
                    HStack {
                        Image(systemName: "bird")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("\(chicksCount)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Diary Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let groupId = selectedGroupId {
                            let entry = DiaryEntry(
                                pigeonGroupId: groupId,
                                mood: selectedMood,
                                chicksCount: chicksCount,
                                notes: notes
                            )
                            diaryManager.addDiaryEntry(entry)
                            dismiss()
                        }
                    }
                    .disabled(selectedGroupId == nil && diaryManager.pigeonGroups.isEmpty)
                }
            }
        }
    }
    
    private func moodColor(_ mood: Mood) -> Color {
        switch mood {
        case .veryHappy: return .green
        case .happy: return .blue
        case .neutral: return .orange
        case .sad: return .yellow
        case .verySad: return .red
        }
    }
}

#Preview {
    DiaryListView()
        .environmentObject(PigeonDiaryManager())
} 
