import SwiftUI

extension Text {
    func Pro(size: CGFloat,
             color: Color = .black)  -> some View {
        self.font(.custom("PaytoneOne-Regular", size: size))
            .foregroundColor(color)
    }
}

struct PigeonGroupsView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var showingAddGroup = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Image(.back)
                    .resizable()
                    .ignoresSafeArea()
                
                Image(.topLayer)
                    .resizable()
                    .frame(height: 150)
                    .offset(y: -80)
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Text("MY PIGEONS")
                            .Pro(size: 25, color: Color(red: 236/255, green: 192/255, blue: 22/255))
                            .padding(.leading, 45)
                            .shadow(radius: 1, y: 3)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddGroup = true
                        }) {
                            Image(.addBtn)
                                .resizable()
                                .frame(width: 48, height: 44)
                        }
                        .offset(y: 20)
                    }
                    
                    if diaryManager.pigeonGroups.isEmpty {
                        VStack(spacing: 20) {
                            Image("house")
                                .resizable()
                                .frame(width: 52, height: 50)
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
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(diaryManager.pigeonGroups.indices, id: \.self) { index in
                                    SwipeToDeleteRow {
                                        NavigationLink(destination: GroupDetailView(group: diaryManager.pigeonGroups[index])) {
                                            PigeonGroupRow(group: diaryManager.pigeonGroups[index])
                                                .padding(.vertical, 8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } onDelete: {
                                        diaryManager.deletePigeonGroup(diaryManager.pigeonGroups[index])
                                    }
                                    
                                    if index < diaryManager.pigeonGroups.count - 1 {
                                        Rectangle()
                                            .fill(Color(red: 107/255, green: 99/255, blue: 99/255))
                                            .frame(height: 3)
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white)
                                    )
                                    .shadow(color: .white, radius: 2, y: 2)
                            )
                            .padding()
                        }

                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGroup) {
                AddGroupView()
            }
        }
    }
}

struct SwipeToDeleteRow<Content: View>: View {
    @State private var offsetX: CGFloat = 0
    @GestureState private var isDragging = false

    let content: Content
    let onDelete: () -> Void

    init(@ViewBuilder content: () -> Content, onDelete: @escaping () -> Void) {
        self.content = content()
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Color.red
                .cornerRadius(10)
                .frame(height: 60)
                .overlay(
                    Button(action: {
                        withAnimation {
                            onDelete()
                            offsetX = 0
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                    }
                        .offset(x: 130)
                )

            content
                .background(Color(red: 255/255, green: 220/255, blue: 103/255))
                .cornerRadius(10)
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { value, state, _ in
                            if value.translation.width < 0 {
                                state = true
                                offsetX = value.translation.width
                            }
                        }
                        .onEnded { value in
                            withAnimation {
                                if value.translation.width < -80 {
                                    offsetX = -80
                                } else {
                                    offsetX = 0
                                }
                            }
                        }
                )
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: offsetX)
    }
}



//struct PigeonGroupsView: View {
//    @EnvironmentObject var diaryManager: PigeonDiaryManager
//    @State private var showingAddGroup = false
//    @State private var selectedGroup: PigeonGroup?
//    
//    var body: some View {
//        NavigationView {
//            List {
//                if diaryManager.pigeonGroups.isEmpty {
//                    VStack(spacing: 20) {
//                        Image(systemName: "house.fill")
//                            .font(.system(size: 60))
//                            .foregroundColor(.orange)
//                        
//                        Text("No Pigeon Groups Yet!")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//                        
//                        Text("Tap the + button to create your first pigeon group and start your diary!")
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.secondary)
//                        
//                        Button(action: {
//                            showingAddGroup = true
//                        }) {
//                            HStack {
//                                Image(systemName: "plus.circle.fill")
//                                Text("Add First Group")
//                            }
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.orange)
//                            .cornerRadius(10)
//                        }
//                    }
//                    .padding()
//                    .listRowBackground(Color.clear)
//                } else {
//                    ForEach(diaryManager.pigeonGroups) { group in
//                        NavigationLink(destination: GroupDetailView(group: group)) {
//                            PigeonGroupRow(group: group)
//                        }
//                    }
//                    .onDelete(perform: deleteGroups)
//                }
//            }
//            .navigationTitle("My Pigeons")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showingAddGroup = true
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $showingAddGroup) {
//                AddGroupView()
//            }
//        }
//    }
//    
//    private func deleteGroups(offsets: IndexSet) {
//        for index in offsets {
//            diaryManager.deletePigeonGroup(diaryManager.pigeonGroups[index])
//        }
//    }
//}

struct PigeonGroupRow: View {
    let group: PigeonGroup
    
    var body: some View {
        HStack {
            Image("house")
                .resizable()
                .frame(width: 55, height: 52)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .Pro(size: 18)
                
                HStack {
                    Image(.pigeon1)
                        .resizable()
                        .frame(width: 21, height: 21)
                    
                    Text("\(group.pigeons.count) pigeon\(group.pigeons.count == 1 ? "" : "s")")
                        .Pro(size: 15, color: Color(red: 98/255, green: 98/255, blue: 98/255))
                    
                    Image(.pigeon1)
                        .resizable()
                        .frame(width: 21, height: 21)
                }
            }
            
            Spacer()
            
            Image(.next)
                .resizable()
                .frame(width: 58, height: 58)
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
            ZStack(alignment: .top) {
                Image(.back)
                    .resizable()
                    .ignoresSafeArea()
                
                Image(.topLayer)
                    .resizable()
                    .frame(height: 170)
                    .offset(y: -100)
                
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(.btnBack)
                                .resizable()
                                .overlay {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color(red: 160/255, green: 91/255, blue: 33/255))
                                        .shadow(radius: 3, y: 3)
                                }
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text("NEW GROUP")
                            .Pro(size: 25, color: Color(red: 236/255, green: 192/255, blue: 22/255))
                            .offset(y: -10)
                            .shadow(radius: 1, y: 3)
                        
                        Spacer()
                        
                        Button(action: {
                            let newGroup = PigeonGroup(name: groupName, pigeons: pigeons)
                            diaryManager.addPigeonGroup(newGroup)
                            dismiss()
                        }) {
                            Image(.btnBack)
                                .resizable()
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color(red: 160/255, green: 91/255, blue: 33/255))
                                        .shadow(radius: 3, y: 3)
                                }
                                .frame(width: 44, height: 44)
                        }
                        .disabled(groupName.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Rectangle()
                        .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white, lineWidth: 3)
                                .overlay {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("GROUP INFORMATION")
                                            .Pro(size: 13)
                                            .padding(.leading)
                                        
                                        CustomTextFiled(text: $groupName, placeholder: "GROUP NAME...")
                                    }
                                }
                        }
                        .frame(height: 114)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ZStack {
                        Rectangle()
                            .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.white, lineWidth: 3)
                                    .overlay {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text("PIGEONS")
                                                    .Pro(size: 13)
//                                                    .padding(.leading)
                                                    
                                                
                                                if pigeons.isEmpty {
                                                    Rectangle()
                                                        .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                        .overlay {
                                                            HStack {
                                                                Text("ADD PIGEONS")
                                                                    .Pro(size: 12)
                                                                    .padding(.leading)
                                                                
                                                                Spacer()
                                                            }
                                                        }
                                                        .frame(height: 70)
                                                        .cornerRadius(16)
//                                                        .padding(.horizontal, 12)
                                                } else {
                                                    // Список голубей с прокруткой
                                                    ScrollView {
                                                        VStack(spacing: 10) {
                                                            ForEach(pigeons) { pigeon in
                                                                HStack {
                                                                    Image(.pigeon1)
                                                                        .resizable()
                                                                        .frame(width: 24, height: 24)
                                                                    
                                                                    Text(pigeon.name)
                                                                    Spacer()
                                                                    Text(pigeon.breed)
                                                                        .font(.caption)
                                                                        .foregroundColor(.secondary)
                                                                    
                                                                    // Кнопка удаления голубя
                                                                    Button(action: {
                                                                        if let index = pigeons.firstIndex(where: { $0.id == pigeon.id }) {
                                                                            pigeons.remove(at: index)
                                                                        }
                                                                    }) {
                                                                        Image(systemName: "trash")
                                                                            .foregroundColor(.red)
                                                                    }
                                                                }
                                                                .padding(.horizontal)
                                                            }
                                                        }
                                                        .padding(.vertical, 10)
                                                    }
                                                    .frame(maxHeight: 150)
                                                }
                                                
                                                
                                            }
                                            .padding(.leading)
                                            .padding(.vertical)
                                            
                                            Spacer()
                                        }
                                    }
                            }
                            .frame(height: 114)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        Button(action: {
                            showingAddPigeon = true
                        }) {
                            Image(.addBtn)
                                .resizable()
                                .frame(width: 47, height: 44)
                        }
                        .offset(y: 60)
                    }
                    
                    Color.clear.frame(height: 80)
                }

                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingAddPigeon) {
                    AddPigeonView { pigeon in
                        pigeons.append(pigeon)
                    }
                }
            }
        }
    }
    
    private func deletePigeons(offsets: IndexSet) {
        pigeons.remove(atOffsets: offsets)
    }
}

struct CustomTextFiled: View {
    @Binding var text: String
    @FocusState var isTextFocused: Bool
    var placeholder: String
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                .frame(height: 70)
                .cornerRadius(16)
                .padding(.horizontal, 12)
            
            TextField("", text: $text, onEditingChanged: { isEditing in
                if !isEditing {
                    isTextFocused = false
                }
            })
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
//            .padding(.horizontal, 16)
            .frame(height: 47)
            .font(.custom("PaytoneOne-Regular", size: 12))
            .cornerRadius(9)
            .foregroundStyle(.black)
            .focused($isTextFocused)
            .padding(.horizontal, 25)
            
            if text.isEmpty && !isTextFocused {
                Text(placeholder)
                    .Pro(size: 12)
                    .frame(height: 50)
                    .padding(.leading, 25)
                    .onTapGesture {
                        isTextFocused = true
                    }
            }
        }
    }
}

struct CustomTextFiled2: View {
    @Binding var text: String
    @FocusState var isTextFocused: Bool
    var placeholder: String
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white, lineWidth: 4)
                }
                .frame(height: 50)
                .cornerRadius(16)
                .padding(.horizontal, 12)
            
            TextField("", text: $text, onEditingChanged: { isEditing in
                if !isEditing {
                    isTextFocused = false
                }
            })
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
//            .padding(.horizontal, 16)
            .frame(height: 47)
            .font(.custom("PaytoneOne-Regular", size: 12))
            .cornerRadius(9)
            .foregroundStyle(.black)
            .focused($isTextFocused)
            .padding(.horizontal, 25)
            
            if text.isEmpty && !isTextFocused {
                Text(placeholder)
                    .Pro(size: 12)
                    .frame(height: 50)
                    .padding(.leading, 25)
                    .onTapGesture {
                        isTextFocused = true
                    }
            }
        }
    }
}

//struct AddGroupView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var diaryManager: PigeonDiaryManager
//    @State private var groupName = ""
//    @State private var showingAddPigeon = false
//    @State private var pigeons: [Pigeon] = []
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Group Information")) {
//                    TextField("Group Name", text: $groupName)
//                }
//                
//                Section(header: Text("Pigeons")) {
//                    if pigeons.isEmpty {
//                        HStack {
//                            Image(systemName: "plus.circle")
//                                .foregroundColor(.orange)
//                            Text("Add your first pigeon")
//                                .foregroundColor(.secondary)
//                        }
//                        .onTapGesture {
//                            showingAddPigeon = true
//                        }
//                    } else {
//                        ForEach(pigeons) { pigeon in
//                            HStack {
//                                Image(systemName: "bird.fill")
//                                    .foregroundColor(.orange)
//                                Text(pigeon.name)
//                                Spacer()
//                                Text(pigeon.breed)
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        .onDelete(perform: deletePigeons)
//                        
//                        Button(action: {
//                            showingAddPigeon = true
//                        }) {
//                            HStack {
//                                Image(systemName: "plus.circle")
//                                Text("Add Another Pigeon")
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("New Group")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        let newGroup = PigeonGroup(name: groupName, pigeons: pigeons)
//                        diaryManager.addPigeonGroup(newGroup)
//                        dismiss()
//                    }
//                    .disabled(groupName.isEmpty)
//                }
//            }
//            .sheet(isPresented: $showingAddPigeon) {
//                AddPigeonView { pigeon in
//                    pigeons.append(pigeon)
//                }
//            }
//        }
//    }
//    
//    private func deletePigeons(offsets: IndexSet) {
//        pigeons.remove(atOffsets: offsets)
//    }
//}

struct AddPigeonView: View {
    @Environment(\.dismiss) var dismiss
    @State private var pigeonName = ""
    @State private var selectedColor = "Blue Bar"
    @State private var selectedBreed = "Unknown"
    
    @State private var showingColorPicker = false
    @State private var showingBreedPicker = false
    
    let onSave: (Pigeon) -> Void
    
    private let colors = ["Blue Bar", "Checker", "Red", "Spread", "White", "Black"]
    private let breeds = ["Unknown", "Homing", "Racing", "Fantail", "King", "Modena", "Tumbler"]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Image(.back)
                    .resizable()
                    .ignoresSafeArea()
                
                Image(.topLayer)
                    .resizable()
                    .frame(height: 170)
                    .offset(y: -100)
                
                VStack(spacing: 20) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(.btnBack)
                                .resizable()
                                .overlay {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color(red: 160/255, green: 91/255, blue: 33/255))
                                        .shadow(radius: 3, y: 3)
                                }
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text("ADD PIGEON")
                            .Pro(size: 25, color: Color(red: 236/255, green: 192/255, blue: 22/255))
                            .offset(y: -10)
                            .shadow(radius: 1, y: 3)
                        
                        Spacer()
                        
                        Button(action: {
                            let pigeon = Pigeon(name: pigeonName, color: selectedColor, breed: selectedBreed)
                            onSave(pigeon)
                            dismiss()
                        }) {
                            Image(.btnBack)
                                .resizable()
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color(red: 160/255, green: 91/255, blue: 33/255))
                                        .shadow(radius: 3, y: 3)
                                }
                                .frame(width: 44, height: 44)
                        }
                        .disabled(pigeonName.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Rectangle()
                        .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                        .frame(height: 250)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 3)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("PIGEON INFORMATION")
                                            .Pro(size: 13)
                                            .padding(.leading)
                                        
                                        CustomTextFiled2(text: $pigeonName, placeholder: "PIGEON NAME...")
                                        
                                        Rectangle()
                                            .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.white, lineWidth: 4)
                                            }
                                            .frame(height: 50)
                                            .overlay {
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Button(action: {
                                                        showingColorPicker = true
                                                    }) {
                                                        HStack {
                                                            Text("COLOR")
                                                                .Pro(size: 12)
                                                            
                                                            Spacer()
                                                            
                                                            Text(selectedColor)
                                                                .Pro(size: 12)
                                                            
                                                            Image("send")
                                                                .resizable()
                                                                .frame(width: 27, height: 27)
                                                        }
                                                        .padding(.horizontal)
                                                        .padding(.vertical, 8)
                                                        .cornerRadius(8)
                                                    }
                                                }
                                                .sheet(isPresented: $showingColorPicker) {
                                                    SelectionListView(title: "Select color", items: colors, selectedItem: $selectedColor)
                                                }
                                            }
                                            .cornerRadius(16)
                                            .padding(.horizontal ,13)
                                        
                                        // Порода — кнопка с открытием выбора
                                        Rectangle()
                                            .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.white, lineWidth: 4)
                                            }
                                            .frame(height: 50)
                                            .overlay {
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Button(action: {
                                                        showingBreedPicker = true
                                                    }) {
                                                        HStack {
                                                            Text("BREED")
                                                                .Pro(size: 12)
                                                            
                                                            Spacer()
                                                            
                                                            Text(selectedBreed)
                                                                .Pro(size: 12)
                                                            
                                                            Image("send")
                                                                .resizable()
                                                                .frame(width: 27, height: 27)
                                                        }
                                                        .padding(.horizontal)
                                                        .padding(.vertical, 8)
                                                        .cornerRadius(8)
                                                    }
                                                }
                                                .sheet(isPresented: $showingBreedPicker) {
                                                    SelectionListView(title: "Select Breed", items: breeds, selectedItem: $selectedBreed)
                                                }
                                            }
                                            .cornerRadius(16)
                                            .padding(.horizontal, 13)
                                            
                                    }
                                    .padding(.vertical, 10)
                                )
                        )
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .padding(.top, 10)
                  
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Вспомогательный вью для выбора из списка
struct SelectionListView: View {
    let title: String
    let items: [String]
    @Binding var selectedItem: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(items, id: \.self) { item in
                Button(action: {
                    selectedItem = item
                    dismiss()
                }) {
                    HStack {
                        Text(item)
                        if item == selectedItem {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
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
