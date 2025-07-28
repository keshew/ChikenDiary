import SwiftUI

struct GroupDetailView: View {
    @EnvironmentObject var diaryManager: ChickenDiaryManager
    @State var group: ChickenGroup
    @State private var showingAddEntry = false
    @State private var showingAddChicken = false
    
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
            
            Section(header: Text("Chickens (\(group.chickens.count))")) {
                if group.chickens.isEmpty {
                    HStack {
                        Image(systemName: "bird.fill")
                            .foregroundColor(.orange)
                        Text("No chickens in this group")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(group.chickens) { chicken in
                        HStack {
                            Image(systemName: "bird.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(chicken.name)
                                    .font(.headline)
                                Text("\(chicken.color) \(chicken.breed)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Button(action: {
                    showingAddChicken = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Chicken")
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
        .sheet(isPresented: $showingAddChicken) {
            AddChickenToGroupView(groupId: group.id)
        }
        .onReceive(diaryManager.$chickenGroups) { groups in
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
                    Text("\(entry.eggsCount) egg\(entry.eggsCount == 1 ? "" : "s")")
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

struct AddChickenToGroupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryManager: ChickenDiaryManager
    @State private var chickenName = ""
    @State private var selectedColor = "Brown"
    @State private var selectedBreed = "Unknown"
    
    let groupId: UUID
    
    private let colors = ["Brown", "White", "Black", "Red", "Golden", "Spotted"]
    private let breeds = ["Unknown", "Rhode Island Red", "Leghorn", "Plymouth Rock", "Sussex", "Orpington", "Wyandotte"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chicken Information")) {
                    TextField("Chicken Name", text: $chickenName)
                    
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
            .navigationTitle("Add Chicken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let chicken = Chicken(name: chickenName, color: selectedColor, breed: selectedBreed)
                        diaryManager.addChickenToGroup(chicken, groupId: groupId)
                        dismiss()
                    }
                    .disabled(chickenName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        GroupDetailView(group: ChickenGroup(name: "My Flock", chickens: [
            Chicken(name: "Henny", color: "Brown", breed: "Rhode Island Red"),
            Chicken(name: "Penny", color: "White", breed: "Leghorn")
        ]))
        .environmentObject(ChickenDiaryManager())
    }
} 