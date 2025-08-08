import SwiftUI

struct GroupDetailView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State var group: PigeonGroup
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddEntry = false
    @State private var showingAddPigeon = false

    var body: some View {
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
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(.btnBack)
                            .resizable()
                            .overlay {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color(red: 165/255, green: 95/255, blue: 37/255))
                                    .shadow(radius: 2)
                            }
                            .frame(width: 36, height: 36)
                    }
                    .offset(y: 20)
                    
                    Spacer()
                    
                    Text(group.name)
                        .Pro(size: 25, color: Color(red: 236/255, green: 192/255, blue: 22/255))
                    //                            .padding(.leading, 45)
                        .shadow(radius: 1, y: 3)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddPigeon = true
                    }) {
                        Image(.addBtn)
                            .resizable()
                            .frame(width: 48, height: 44)
                    }
                    .offset(y: 20)
                }
                ScrollView(showsIndicators: false) {
                    Rectangle()
                        .fill(Color(red: 255/255, green: 221/255, blue: 103/255))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 3)
                                .overlay {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("GROUP INFORMATION")
                                            .Pro(size: 13)
                                        
                                        Rectangle()
                                            .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                            .frame(height: 70)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white, lineWidth: 3)
                                                HStack {
                                                    Image("house")
                                                        .resizable()
                                                        .frame(width: 55, height: 52)
                                                    
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(group.name)
                                                            .Pro(size: 18)
                                                        Text("Created \(group.dateCreated, style: .date)")
                                                            .Pro(size: 12, color: Color(red: 98/255, green: 98/255, blue: 98/255))
                                                    }
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 10)
                                            }
                                            .cornerRadius(16)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical)
                                }
                        }
                        .frame(height: 114)
                        .cornerRadius(16)
                        .padding(.top, 25)
                    
                    // PIGEONS
                    Rectangle()
                        .fill(Color(red: 255/255, green: 221/255, blue: 103/255))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 3)
                                .overlay {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Pigeons (\(group.pigeons.count))")
                                            .Pro(size: 13)
                                            .padding(.leading, 16)
                                            .padding(.vertical, 10)
                                        
                                        if group.pigeons.isEmpty {
                                            Text("No pigeons in this group")
                                                .foregroundColor(.secondary)
                                                .Pro(size: 14)
                                                .padding(.leading, 16)
                                                .padding(.bottom, 10)
                                        } else {
                                            ScrollView(showsIndicators: false) {
                                                VStack(spacing: 5) {
                                                    ForEach(group.pigeons.indices, id: \.self) { index in
                                                        Rectangle()
                                                            .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                            .frame(height: 70)
                                                            .overlay {
                                                                RoundedRectangle(cornerRadius: 16)
                                                                    .stroke(Color.white, lineWidth: 3)
                                                                HStack(spacing: 12) {
                                                                    Image("pigeon2")
                                                                        .resizable()
                                                                        .frame(width: 39, height: 52)
                                                                    
                                                                    VStack(alignment: .leading, spacing: 4) {
                                                                        Text(group.pigeons[index].name)
                                                                            .Pro(size: 18)
                                                                        Text("\(group.pigeons[index].color) \(group.pigeons[index].breed)")
                                                                            .Pro(size: 12, color: Color(red: 98/255, green: 98/255, blue: 98/255))
                                                                    }
                                                                    Spacer()
                                                                }
                                                                .padding(.horizontal, 16)
                                                            }
                                                            .cornerRadius(16)
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 10)
                                                        
                                                        if index < group.pigeons.count - 1 {
                                                            Rectangle()
                                                                .fill(Color(red: 107/255, green: 99/255, blue: 99/255))
                                                                .frame(height: 3)
                                                                .cornerRadius(10)
                                                                .padding(.horizontal, 16)
                                                        }
                                                    }
                                                    
                                                    // Add pigeon button below list
                                                    Rectangle()
                                                        .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                        .frame(height: 70)
                                                        .overlay {
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(Color.white, lineWidth: 3)
                                                            HStack {
                                                                Button(action: {
                                                                    showingAddPigeon = true
                                                                }) {
                                                                    Image("addBtn")
                                                                        .resizable()
                                                                        .frame(width: 47, height: 44)
                                                                }
                                                                VStack(alignment: .leading, spacing: 4) {
                                                                    Text("ADD PIGEON")
                                                                        .Pro(size: 12, color: Color(red: 98/255, green: 98/255, blue: 98/255))
                                                                }
                                                                Spacer()
                                                            }
                                                            .padding(.horizontal, 10)
                                                        }
                                                        .cornerRadius(16)
                                                        .padding(.horizontal, 10)
                                                        .padding(.top, 4)
                                                }
                                                .padding(.bottom, 10)
                                            }
                                            .frame(maxHeight: min(CGFloat(group.pigeons.count) * 90 + 90, 400))
                                        }
                                    }
                                }
                        }
                        .cornerRadius(16)
                        .frame(height: 214)
                    
                    // RECENT ENTRIES
                    Rectangle()
                        .fill(Color(red: 255/255, green: 221/255, blue: 103/255))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 3)
                                .overlay {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Recent Entries")
                                            .Pro(size: 13)
                                            .padding(.leading, 16)
                                            .padding(.top, 10)
                                        
                                        let entries = diaryManager.getEntriesForGroup(group.id)
                                        
                                        if entries.isEmpty {
                                            VStack(spacing: 0) {
                                                Rectangle()
                                                    .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                    .frame(height: 70)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.white, lineWidth: 3)
                                                        HStack {
                                                            Image("diary")
                                                                .resizable()
                                                                .frame(width: 50, height: 38)
                                                            
                                                            VStack(alignment: .leading, spacing: 4) {
                                                                Text("NO DIARY ENTRIES YET")
                                                                    .Pro(size: 12, color: Color(red: 98/255, green: 98/255, blue: 98/255))
                                                            }
                                                            Spacer()
                                                        }
                                                        .padding(.horizontal, 10)
                                                    }
                                                    .cornerRadius(16)
                                                    .padding(.horizontal)
                                                    .padding(.bottom, 10)
                                                
                                                Rectangle()
                                                    .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                    .frame(height: 70)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.white, lineWidth: 3)
                                                        HStack {
                                                            Button(action: {
                                                                showingAddEntry = true
                                                            }) {
                                                                Image("addBtn")
                                                                    .resizable()
                                                                    .frame(width: 47, height: 44)
                                                            }
                                                            VStack(alignment: .leading, spacing: 4) {
                                                                Text("ADD DIARY ENTRY")
                                                                    .Pro(size: 12, color: Color(red: 98/255, green: 98/255, blue: 98/255))
                                                            }
                                                            Spacer()
                                                        }
                                                        .padding(.horizontal, 10)
                                                    }
                                                    .cornerRadius(16)
                                                    .padding(.horizontal)
                                                    .padding(.top, 4)
                                            }
                                        } else {
                                            ScrollView(showsIndicators: false) {
                                                VStack(spacing: 5) {
                                                    ForEach(entries.indices, id: \.self) { index in
                                                        DiaryEntryRow(entry: entries[index])
                                                            .padding(.horizontal, 16)
                                                            .padding(.vertical, 8)
                                                        
                                                        if index < entries.count - 1 {
                                                            Rectangle()
                                                                .fill(Color(red: 107/255, green: 99/255, blue: 99/255))
                                                                .frame(height: 3)
                                                                .cornerRadius(10)
                                                                .padding(.horizontal, 16)
                                                        }
                                                    }
                                                    
                                                    // Add diary entry button below list
                                                    Rectangle()
                                                        .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                        .frame(height: 70)
                                                        .overlay {
                                                            RoundedRectangle(cornerRadius: 16)
                                                                .stroke(Color.white, lineWidth: 3)
                                                            HStack {
                                                                Button(action: {
                                                                    showingAddEntry = true
                                                                }) {
                                                                    Image("addBtn")
                                                                        .resizable()
                                                                        .frame(width: 47, height: 44)
                                                                }
                                                                VStack(alignment: .leading, spacing: 4) {
                                                                    Text("ADD DIARY ENTRY")
                                                                        .Pro(size: 12, color: Color(red: 98/255, green: 98/255, blue: 98/255))
                                                                }
                                                                Spacer()
                                                            }
                                                            .padding(.horizontal, 10)
                                                        }
                                                        .cornerRadius(16)
                                                        .padding(.horizontal, 10)
                                                        .padding(.top, 4)
                                                }
                                                .padding(.bottom, 10)
                                            }
                                            .frame(maxHeight: min(CGFloat(entries.count) * 90 + 90, 400))
                                        }
                                    }
                                }
                        }
                        .cornerRadius(16)
                        .frame(height: 214)
                    
                    Color.clear.frame(height: 80)
                }
            }
                .padding(.horizontal)
//                .offset(y: -35)
            
        }
        .navigationBarBackButtonHidden(true)
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


//struct GroupDetailView: View {
//    @EnvironmentObject var diaryManager: PigeonDiaryManager
//    @State var group: PigeonGroup
//    @State private var showingAddEntry = false
//    @State private var showingAddPigeon = false
//    
//    var body: some View {
//        List {
//            Section(header: Text("Group Information")) {
//                HStack {
//                    Image(systemName: "house.fill")
//                        .font(.title2)
//                        .foregroundColor(.orange)
//                        .frame(width: 40, height: 40)
//                        .background(Color.orange.opacity(0.2))
//                        .clipShape(Circle())
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(group.name)
//                            .font(.headline)
//                        Text("Created \(group.dateCreated, style: .date)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            
//            Section(header: Text("Pigeons (\(group.pigeons.count))")) {
//                if group.pigeons.isEmpty {
//                    HStack {
//                        Image(systemName: "bird.fill")
//                            .foregroundColor(.blue)
//                        Text("No pigeons in this group")
//                            .foregroundColor(.secondary)
//                    }
//                } else {
//                    ForEach(group.pigeons) { pigeon in
//                        HStack {
//                            Image(systemName: "bird.fill")
//                                .foregroundColor(.blue)
//                            VStack(alignment: .leading, spacing: 2) {
//                                Text(pigeon.name)
//                                    .font(.headline)
//                                Text("\(pigeon.color) \(pigeon.breed)")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
//                
//                Button(action: {
//                    showingAddPigeon = true
//                }) {
//                    HStack {
//                        Image(systemName: "plus.circle")
//                        Text("Add Pigeon")
//                    }
//                }
//            }
//            
//            Section(header: Text("Recent Entries")) {
//                let entries = diaryManager.getEntriesForGroup(group.id)
//                if entries.isEmpty {
//                    HStack {
//                        Image(systemName: "book.fill")
//                            .foregroundColor(.orange)
//                        Text("No diary entries yet")
//                            .foregroundColor(.secondary)
//                    }
//                } else {
//                    ForEach(Array(entries.prefix(3))) { entry in
//                        DiaryEntryRow(entry: entry)
//                    }
//                    
//                    if entries.count > 3 {
//                        NavigationLink("View All Entries (\(entries.count))") {
//                            DiaryListView(selectedGroupId: group.id)
//                        }
//                    }
//                }
//                
//                Button(action: {
//                    showingAddEntry = true
//                }) {
//                    HStack {
//                        Image(systemName: "plus.circle")
//                        Text("Add Diary Entry")
//                    }
//                }
//            }
//        }
//        .navigationTitle(group.name)
//        .navigationBarTitleDisplayMode(.large)
//        .sheet(isPresented: $showingAddEntry) {
//            AddDiaryEntryView(groupId: group.id)
//        }
//        .sheet(isPresented: $showingAddPigeon) {
//            AddPigeonToGroupView(groupId: group.id)
//        }
//        .onReceive(diaryManager.$pigeonGroups) { groups in
//            if let updatedGroup = groups.first(where: { $0.id == group.id }) {
//                group = updatedGroup
//            }
//        }
//    }
//}

struct DiaryEntryRow: View {
    let entry: DiaryEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: entry.mood.icon)
                        .foregroundColor(moodColor(entry.mood))
                    Text(entry.mood.rawValue)
                        .Pro(size: 13)
                }
                
                HStack {
                    Image(systemName: "egg.fill")
                        .foregroundColor(.yellow)
                    Text("\(entry.chicksCount) chick\(entry.chicksCount == 1 ? "" : "s")")
                        .Pro(size: 10)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.date, style: .date)
                    .Pro(size: 13)
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .Pro(size: 13)
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

    @State private var showingColorPicker = false
    @State private var showingBreedPicker = false

    let groupId: UUID

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
                    // Заголовок с кнопками
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
                            // При сохранении создаём голубя и добавляем в группу
                            let pigeon = Pigeon(name: pigeonName, color: selectedColor, breed: selectedBreed)
                            diaryManager.addPigeonToGroup(pigeon, groupId: groupId)
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

                    // Основной овал с полями ввода
                    Rectangle()
                        .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                        .frame(height: 300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 3)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("PIGEON INFORMATION")
                                            .Pro(size: 13)
                                            .padding(.leading)

                                        CustomTextFiled2(text: $pigeonName, placeholder: "PIGEON NAME...")

                                        // Кнопка выбора цвета
                                        Rectangle()
                                            .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white, lineWidth: 4)
                                            }
                                            .frame(height: 50)
                                            .overlay(
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Button(action: { showingColorPicker = true }) {
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
                                            )
                                            .cornerRadius(16)
                                            .padding(.horizontal, 13)
                                            .sheet(isPresented: $showingColorPicker) {
                                                SelectionListView(title: "Select color", items: colors, selectedItem: $selectedColor)
                                            }

                                        // Кнопка выбора породы
                                        Rectangle()
                                            .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white, lineWidth: 4)
                                            }
                                            .frame(height: 50)
                                            .overlay(
                                                VStack(alignment: .leading, spacing: 5) {
                                                    Button(action: { showingBreedPicker = true }) {
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
                                            )
                                            .cornerRadius(16)
                                            .padding(.horizontal, 13)
                                            .sheet(isPresented: $showingBreedPicker) {
                                                SelectionListView(title: "Select Breed", items: breeds, selectedItem: $selectedBreed)
                                            }
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


#Preview {
    NavigationView {
        GroupDetailView(group: PigeonGroup(name: "My Flock", pigeons: [
            Pigeon(name: "Henny", color: "Brown", breed: "Rhode Island Red")
//            Pigeon(name: "Henny", color: "Brown", breed: "Rhode Island Red"),
//            Pigeon(name: "Henny", color: "Brown", breed: "Rhode Island Red"),
//            Pigeon(name: "Penny", color: "White", breed: "Leghorn")
        ]))
        .environmentObject(PigeonDiaryManager())
    }
} 
