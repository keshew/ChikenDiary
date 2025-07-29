import SwiftUI

struct GroupDetailView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State var group: PigeonGroup
    @State private var showingAddEntry = false
    @State private var showingAddPigeon = false
    
    var body: some View {
        List {
            Section(header: Text("Group Information")) {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .frame(width: 40, height: 40)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(.headline)
                        Text("Created \(group.dateCreated, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Pigeons (\(group.pigeons.count))")) {
                if group.pigeons.isEmpty {
                    HStack {
                        Image(systemName: "bird.fill")
                            .foregroundColor(.blue)
                        Text("No pigeons in this group")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(group.pigeons) { pigeon in
                        HStack {
                            Image(systemName: "bird.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pigeon.name)
                                    .font(.headline)
                                Text("\(pigeon.color) \(pigeon.breed)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Button(action: {
                    showingAddPigeon = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Pigeon")
                    }
                }
            }
            
            Section(header: Text("Recent Entries")) {
                let entries = diaryManager.getEntriesForGroup(group.id)
                if entries.isEmpty {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.orange)
                        Text("No diary entries yet")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(Array(entries.prefix(3))) { entry in
                        DiaryEntryRow(entry: entry)
                    }
                    
                    if entries.count > 3 {
                        NavigationLink("View All Entries (\(entries.count))") {
                            DiaryListView(selectedGroupId: group.id)
                        }
                    }
                }
                
                Button(action: {
                    showingAddEntry = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Diary Entry")
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingAddEntry) {
            AddDiaryEntryView(groupId: group.id)
        }
        .sheet(isPresented: $showingAddPigeon) {
            AddPigeonToGroupView(groupId: group.id)
        }
        .onReceive(diaryManager.$pigeonGroups) { groups in
            if let updatedGroup = groups.first(where: { $0.id == group.id }) {
                group = updatedGroup
            }
        }
    }
}

struct DiaryEntryRow: View {
    let entry: DiaryEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: entry.mood.icon)
                        .foregroundColor(moodColor(entry.mood))
                    Text(entry.mood.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "egg.fill")
                        .foregroundColor(.yellow)
                    Text("\(entry.chicksCount) chick\(entry.chicksCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
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

struct AddPigeonToGroupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var pigeonName = ""
    @State private var selectedColor = "Blue Bar"
    @State private var selectedBreed = "Unknown"
    
    let groupId: UUID
    
    private let colors = ["Blue Bar", "Checker", "Red", "Spread", "White", "Black"]
    private let breeds = ["Unknown", "Homing", "Racing", "Fantail", "King", "Modena", "Tumbler"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pigeon Information")) {
                    TextField("Pigeon Name", text: $pigeonName)
                    
                    Picker("Color", selection: $selectedColor) {
                        ForEach(colors, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                    
                    Picker("Breed", selection: $selectedBreed) {
                        ForEach(breeds, id: \.self) { breed in
                            Text(breed).tag(breed)
                        }
                    }
                }
            }
            .navigationTitle("Add Pigeon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let pigeon = Pigeon(name: pigeonName, color: selectedColor, breed: selectedBreed)
                        diaryManager.addPigeonToGroup(pigeon, groupId: groupId)
                        dismiss()
                    }
                    .disabled(pigeonName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        GroupDetailView(group: PigeonGroup(name: "My Flock", pigeons: [
            Pigeon(name: "Henny", color: "Brown", breed: "Rhode Island Red"),
            Pigeon(name: "Penny", color: "White", breed: "Leghorn")
        ]))
        .environmentObject(PigeonDiaryManager())
    }
} 