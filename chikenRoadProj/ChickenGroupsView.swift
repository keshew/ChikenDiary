import SwiftUI

struct ChickenGroupsView: View {
    @EnvironmentObject var diaryManager: ChickenDiaryManager
    @State private var showingAddGroup = false
    @State private var selectedGroup: ChickenGroup?
    
    var body: some View {
        NavigationView {
            List {
                if diaryManager.chickenGroups.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("No Chicken Groups Yet!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Tap the + button to create your first chicken group and start your diary!")
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
                    ForEach(diaryManager.chickenGroups) { group in
                        NavigationLink(destination: GroupDetailView(group: group)) {
                            ChickenGroupRow(group: group)
                        }
                    }
                    .onDelete(perform: deleteGroups)
                }
            }
            .navigationTitle("My Chickens")
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
            diaryManager.deleteChickenGroup(diaryManager.chickenGroups[index])
        }
    }
}

struct ChickenGroupRow: View {
    let group: ChickenGroup
    
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
                
                Text("\(group.chickens.count) chicken\(group.chickens.count == 1 ? "" : "s")")
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
    @EnvironmentObject var diaryManager: ChickenDiaryManager
    @State private var groupName = ""
    @State private var showingAddChicken = false
    @State private var chickens: [Chicken] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Information")) {
                    TextField("Group Name", text: $groupName)
                }
                
                Section(header: Text("Chickens")) {
                    if chickens.isEmpty {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.orange)
                            Text("Add your first chicken")
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            showingAddChicken = true
                        }
                    } else {
                        ForEach(chickens) { chicken in
                            HStack {
                                Image(systemName: "bird.fill")
                                    .foregroundColor(.orange)
                                Text(chicken.name)
                                Spacer()
                                Text(chicken.breed)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteChickens)
                        
                        Button(action: {
                            showingAddChicken = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Another Chicken")
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
                        let newGroup = ChickenGroup(name: groupName, chickens: chickens)
                        diaryManager.addChickenGroup(newGroup)
                        dismiss()
                    }
                    .disabled(groupName.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddChicken) {
                AddChickenView { chicken in
                    chickens.append(chicken)
                }
            }
        }
    }
    
    private func deleteChickens(offsets: IndexSet) {
        chickens.remove(atOffsets: offsets)
    }
}

struct AddChickenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var chickenName = ""
    @State private var selectedColor = "Brown"
    @State private var selectedBreed = "Unknown"
    
    let onSave: (Chicken) -> Void
    
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
                        onSave(chicken)
                        dismiss()
                    }
                    .disabled(chickenName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ChickenGroupsView()
        .environmentObject(ChickenDiaryManager())
} 