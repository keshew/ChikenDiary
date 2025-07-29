import SwiftUI

struct PigeonGroupsView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var showingAddGroup = false
    @State private var selectedGroup: PigeonGroup?
    
    var body: some View {
        NavigationView {
            List {
                if diaryManager.pigeonGroups.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("No Pigeon Groups Yet!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Tap the + button to create your first pigeon group and start your diary!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingAddGroup = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add First Group")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(diaryManager.pigeonGroups) { group in
                        NavigationLink(destination: GroupDetailView(group: group)) {
                            PigeonGroupRow(group: group)
                        }
                    }
                    .onDelete(perform: deleteGroups)
                }
            }
            .navigationTitle("My Pigeons")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddGroup = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGroup) {
                AddGroupView()
            }
        }
    }
    
    private func deleteGroups(offsets: IndexSet) {
        for index in offsets {
            diaryManager.deletePigeonGroup(diaryManager.pigeonGroups[index])
        }
    }
}

struct PigeonGroupRow: View {
    let group: PigeonGroup
    
    var body: some View {
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
                
                Text("\(group.pigeons.count) pigeon\(group.pigeons.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AddGroupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var groupName = ""
    @State private var showingAddPigeon = false
    @State private var pigeons: [Pigeon] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Information")) {
                    TextField("Group Name", text: $groupName)
                }
                
                Section(header: Text("Pigeons")) {
                    if pigeons.isEmpty {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.orange)
                            Text("Add your first pigeon")
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            showingAddPigeon = true
                        }
                    } else {
                        ForEach(pigeons) { pigeon in
                            HStack {
                                Image(systemName: "bird.fill")
                                    .foregroundColor(.orange)
                                Text(pigeon.name)
                                Spacer()
                                Text(pigeon.breed)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deletePigeons)
                        
                        Button(action: {
                            showingAddPigeon = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Another Pigeon")
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newGroup = PigeonGroup(name: groupName, pigeons: pigeons)
                        diaryManager.addPigeonGroup(newGroup)
                        dismiss()
                    }
                    .disabled(groupName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddPigeon) {
                AddPigeonView { pigeon in
                    pigeons.append(pigeon)
                }
            }
        }
    }
    
    private func deletePigeons(offsets: IndexSet) {
        pigeons.remove(atOffsets: offsets)
    }
}

struct AddPigeonView: View {
    @Environment(\.dismiss) var dismiss
    @State private var pigeonName = ""
    @State private var selectedColor = "Blue Bar"
    @State private var selectedBreed = "Unknown"
    
    let onSave: (Pigeon) -> Void
    
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
                        onSave(pigeon)
                        dismiss()
                    }
                    .disabled(pigeonName.isEmpty)
                }
            }
        }
    }
}

//struct AddPigeonView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var pigeonName = ""
//    @State private var selectedColor = "Blue Bar"
//    @State private var selectedBreed = "Unknown"
//    let onSave: (Pigeon) -> Void
//    private let colors = ["Blue Bar", "Checker", "Red", "Spread", "White", "Black"]
//    private let breeds = ["Unknown", "Homing", "Racing", "Fantail", "King", "Modena", "Tumbler"]
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Pigeon Information")) {
//                    TextField("Pigeon Name", text: $pigeonName)
//                    Picker("Color", selection: $selectedColor) {
//                        ForEach(colors, id: \.self) { color in
//                            Text(color).tag(color)
//                        }
//                    }
//                    Picker("Breed", selection: $selectedBreed) {
//                        ForEach(breeds, id: \.self) { breed in
//                            Text(breed).tag(breed)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Add Pigeon")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        let pigeon = Pigeon(name: pigeonName, color: selectedColor, breed: selectedBreed)
//                        onSave(pigeon)
//                        dismiss()
//                    }
//                    .disabled(pigeonName.isEmpty)
//                }
//            }
//        }
//    }
//}

#Preview {
    PigeonGroupsView()
        .environmentObject(PigeonDiaryManager())
} 
