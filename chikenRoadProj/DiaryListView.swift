import SwiftUI

struct DiaryListView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var showingAddEntry = false
    @State private var selectedGroupId: UUID?
    @State private var selectedFilter: DiaryFilter = .all

    init(selectedGroupId: UUID? = nil) {
        self._selectedGroupId = State(initialValue: selectedGroupId)
    }

    enum DiaryFilter: CaseIterable, Identifiable {
        case all, today, thisWeek, thisMonth

        var id: DiaryFilter { self }

        var title: String {
            switch self {
            case .all: return "ALL"
            case .today: return "TODAY"
            case .thisWeek: return "THIS WEEK"
            case .thisMonth: return "THIS MONTH"
            }
        }
    }

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

                VStack(spacing: 10) {
                    // Заголовок и кнопка добавления записи
                    HStack {
                        Spacer()
                        
                        Text("DIARY")
                            .Pro(size: 25, color: Color(red: 236/255, green: 192/255, blue: 22/255))
                            .offset(y: -10)
                            .shadow(radius: 1, y: 3)
                            .padding(.leading, 45)
                        Spacer()

                        // Кнопка открытия AddDiaryEntryView
                        Button(action: {
                            showingAddEntry = true
                        }) {
                            Image(.addBtn)
                                .resizable()
                                .frame(width: 48, height: 44)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // Фильтры
                    Image(.diaryBG)
                        .resizable()
                        .overlay {
                            HStack(spacing: 10) {
                                ForEach(DiaryFilter.allCases) { filter in
                                    Button(action: {
                                        withAnimation {
                                            selectedFilter = filter
                                        }
                                    }) {
                                        Rectangle()
                                            .fill(selectedFilter == filter ?
                                                  Color(red: 80/255, green: 80/255, blue: 80/255) :
                                                  Color(red: 255/255, green: 232/255, blue: 156/255))
                                            .frame(width: 78, height: 30)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .overlay {
                                                        Text(filter.title)
                                                            .Pro(size: filter == .thisWeek || filter == .thisMonth ? 10 : 11,
                                                                 color: selectedFilter == filter ? Color(red: 235/255, green: 191/255, blue: 24/255) : .black)
                                                    }
                                            }
                                            .cornerRadius(20)
                                    }
                                }
                            }
                        }
                        .frame(height: 56)
                        .padding(.horizontal)
                        .padding(.top)

                    let filteredEntries = getFilteredEntries()

                    if filteredEntries.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 60))
                                .foregroundColor(Color(red: 235/255, green: 191/255, blue: 24/255))

                            Text(emptyStateMessage)
                                .Pro(size: 25)

                            Text(emptyStateSubtitle)
                                .Pro(size: 15)
                                .multilineTextAlignment(.center)

                            if diaryManager.pigeonGroups.isEmpty {
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
                        }
                        .padding()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 10) {
                                ForEach(filteredEntries) { entry in
                                    // Для получения имени группы
                                    let groupName = diaryManager.pigeonGroups.first { $0.id == entry.pigeonGroupId }?.name ?? "Unknown Group"
                                    
                                    SwipeToDeleteWrapper {
                                        Rectangle()
                                            .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .overlay {
                                                        VStack(spacing: 3) {
                                                            Text(groupName)
                                                                .Pro(size: 15)
                                                            Text(entry.date, formatter: dateFormatter)
                                                                .Pro(size: 12)
                                                            HStack {
                                                                Image(.pigeon1)
                                                                    .resizable()
                                                                    .frame(width: 14, height: 14)
                                                                Text(entry.mood.rawValue)
                                                                    .Pro(size: 12)
                                                                Image(.pigeon1)
                                                                    .resizable()
                                                                    .frame(width: 14, height: 14)
                                                            }
                                                            HStack {
                                                                Text("\(entry.chicksCount)")
                                                                    .Pro(size: 25)
                                                                Image(.pigeon2)
                                                                    .resizable()
                                                                    .frame(width: 27, height: 41)
                                                                    .scaleEffect(x: -1, y: 1)
                                                            }
                                                            Text(groupName)
                                                                .Pro(size: 15)
                                                        }
                                                        .padding()
                                                    }
                                            }
                                            .frame(height: 140)
                                            .cornerRadius(20)
                                            .padding(.horizontal)
                                    } onDelete: {
                                        diaryManager.deleteDiaryEntry(entry)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddDiaryEntryView()
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
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

        if let groupId = selectedGroupId {
            entries = entries.filter { $0.pigeonGroupId == groupId }
        }

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

struct SwipeToDeleteWrapper<Content: View>: View {
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
                .cornerRadius(20)
                .frame(height: 140)
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
                    .offset(x: 140)
                )
                .padding(.horizontal)

            content
//                .background(Color(red: 255/255, green: 220/255, blue: 103/255))
//                .cornerRadius(16)
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
//        .padding(.horizontal)
        .animation(.easeInOut, value: offsetX)
    }
}


//struct DiaryListView: View {
//    @EnvironmentObject var diaryManager: PigeonDiaryManager
//    @State private var showingAddEntry = false
//    @State private var selectedGroupId: UUID?
//    @State private var selectedFilter: DiaryFilter = .all
//
//    init(selectedGroupId: UUID? = nil) {
//        self._selectedGroupId = State(initialValue: selectedGroupId)
//    }
//
//    enum DiaryFilter {
//        case all, today, thisWeek, thisMonth
//
//        var title: String {
//            switch self {
//            case .all: return "All"
//            case .today: return "Today"
//            case .thisWeek: return "This Week"
//            case .thisMonth: return "This Month"
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if diaryManager.pigeonGroups.isEmpty {
//                    VStack(spacing: 20) {
//                        Image(systemName: "book.fill")
//                            .font(.system(size: 60))
//                            .foregroundColor(.blue)
//
//                        Text("No Diary Entries Yet!")
//                            .font(.title2)
//                            .fontWeight(.semibold)
//
//                        Text("Create a pigeon group first, then add your first diary entry!")
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.secondary)
//
//                        NavigationLink(destination: PigeonGroupsView()) {
//                            HStack {
//                                Image(systemName: "house.fill")
//                                Text("Go to My Pigeons")
//                            }
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                        }
//                    }
//                    .padding()
//                } else {
//                    List {
//                        if !diaryManager.pigeonGroups.isEmpty {
//                            Section {
//                                Picker("Filter", selection: $selectedFilter) {
//                                    ForEach([DiaryFilter.all, .today, .thisWeek, .thisMonth], id: \.self) { filter in
//                                        Text(filter.title).tag(filter)
//                                    }
//                                }
//                                .pickerStyle(SegmentedPickerStyle())
//                                .padding(.vertical, 8)
//                            }
//                        }
//
//                        let filteredEntries = getFilteredEntries()
//
//                        if filteredEntries.isEmpty {
//                            Section {
//                                VStack(spacing: 16) {
//                                    Image(systemName: "book.closed")
//                                        .font(.system(size: 40))
//                                        .foregroundColor(.blue)
//
//                                    Text(emptyStateMessage)
//                                        .font(.headline)
//                                        .multilineTextAlignment(.center)
//
//                                    Text(emptyStateSubtitle)
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                        .multilineTextAlignment(.center)
//                                }
//                                .padding()
//                                .listRowBackground(Color.clear)
//                            }
//                        } else {
//                            ForEach(filteredEntries) { entry in
//                                DiaryEntryDetailRow(entry: entry)
//                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                                        Button(role: .destructive) {
//                                            diaryManager.deleteDiaryEntry(entry)
//                                        } label: {
//                                            Label("Delete", systemImage: "trash")
//                                        }
//                                    }
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Diary")
//            .toolbar {
//                if !diaryManager.pigeonGroups.isEmpty {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button(action: {
//                            showingAddEntry = true
//                        }) {
//                            Image(systemName: "plus")
//                        }
//                    }
//                }
//            }
//            .sheet(isPresented: $showingAddEntry) {
//                AddDiaryEntryView()
//            }
//        }
//    }
//
//    private var emptyStateMessage: String {
//        switch selectedFilter {
//        case .all:
//            return "No diary entries yet!"
//        case .today:
//            return "No entries for today"
//        case .thisWeek:
//            return "No entries this week"
//        case .thisMonth:
//            return "No entries this month"
//        }
//    }
//
//    private var emptyStateSubtitle: String {
//        switch selectedFilter {
//        case .all:
//            return "Add your first diary entry to start tracking your pigeons!"
//        case .today:
//            return "Add an entry to record today's pigeon activities"
//        case .thisWeek:
//            return "No entries recorded this week yet"
//        case .thisMonth:
//            return "No entries recorded this month yet"
//        }
//    }
//
//    private func getFilteredEntries() -> [DiaryEntry] {
//        var entries = diaryManager.diaryEntries
//
//        // Filter by selected group if specified
//        if let groupId = selectedGroupId {
//            entries = entries.filter { $0.pigeonGroupId == groupId }
//        }
//
//        // Apply time filter
//        let calendar = Calendar.current
//        let now = Date()
//
//        switch selectedFilter {
//        case .all:
//            break
//        case .today:
//            entries = entries.filter { calendar.isDate($0.date, inSameDayAs: now) }
//        case .thisWeek:
//            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
//            entries = entries.filter { $0.date >= weekStart }
//        case .thisMonth:
//            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
//            entries = entries.filter { $0.date >= monthStart }
//        }
//
//        return entries.sorted { $0.date > $1.date }
//    }
//}

//struct DiaryEntryDetailRow: View {
//    let entry: DiaryEntry
//    @EnvironmentObject var diaryManager: PigeonDiaryManager
//
//    private var groupName: String {
//        diaryManager.pigeonGroups.first { $0.id == entry.pigeonGroupId }?.name ?? "Unknown Group"
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(groupName)
//                        .font(.headline)
//                        .foregroundColor(.primary)
//
//                    Text(entry.date, style: .date)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//
//                Spacer()
//
//                VStack(alignment: .trailing, spacing: 4) {
//                    HStack {
//                        Image(systemName: entry.mood.icon)
//                            .foregroundColor(moodColor(entry.mood))
//                        Text(entry.mood.rawValue)
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//
//                    HStack {
//                        Image(systemName: "bird")
//                            .foregroundColor(.blue)
//                        Text("\(entry.chicksCount)")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//
//            if !entry.notes.isEmpty {
//                Text(entry.notes)
//                    .font(.body)
//                    .foregroundColor(.primary)
//                    .padding(.top, 4)
//            }
//        }
//        .padding(.vertical, 8)
//    }
//
//    private func moodColor(_ mood: Mood) -> Color {
//        switch mood {
//        case .veryHappy: return .green
//        case .happy: return .blue
//        case .neutral: return .orange
//        case .sad: return .yellow
//        case .verySad: return .red
//        }
//    }
//}

//struct AddDiaryEntryView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var diaryManager: PigeonDiaryManager
//    @State private var selectedGroupId: UUID?
//    @State private var selectedMood: Mood = .happy
//    @State private var chicksCount = 0
//    @State private var notes = ""
//    
//    init(groupId: UUID? = nil) {
//        self._selectedGroupId = State(initialValue: groupId)
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Select Pigeon Group")) {
//                    if diaryManager.pigeonGroups.isEmpty {
//                        Text("No pigeon groups available")
//                            .foregroundColor(.secondary)
//                    } else {
//                        Picker("Pigeon Group", selection: $selectedGroupId) {
//                            Text("Select a group").tag(nil as UUID?)
//                            ForEach(diaryManager.pigeonGroups) { group in
//                                Text(group.name).tag(group.id as UUID?)
//                            }
//                        }
//                        .disabled(selectedGroupId != nil) // Disable if group is pre-selected
//                    }
//                }
//                
//                Section(header: Text("How are your pigeons feeling?")) {
//                    Picker("Mood", selection: $selectedMood) {
//                        ForEach(Mood.allCases, id: \.self) { mood in
//                            HStack {
//                                Image(systemName: mood.icon)
//                                    .foregroundColor(moodColor(mood))
//                                Text(mood.rawValue)
//                            }
//                            .tag(mood)
//                        }
//                    }
//                    .pickerStyle(WheelPickerStyle())
//                }
//                
//                Section(header: Text("Chicks Hatched")) {
//                    Stepper("\(chicksCount) chick\(chicksCount == 1 ? "" : "s")", value: $chicksCount, in: 0...50)
//                    
//                    HStack {
//                        Image(systemName: "bird")
//                            .foregroundColor(.blue)
//                            .font(.title2)
//                        Text("\(chicksCount)")
//                            .font(.title)
//                            .fontWeight(.bold)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue.opacity(0.1))
//                    .cornerRadius(10)
//                }
//                
//                Section(header: Text("Notes (Optional)")) {
//                    TextEditor(text: $notes)
//                        .frame(minHeight: 100)
//                }
//            }
//            .navigationTitle("New Diary Entry")
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
//                        if let groupId = selectedGroupId {
//                            let entry = DiaryEntry(
//                                pigeonGroupId: groupId,
//                                mood: selectedMood,
//                                chicksCount: chicksCount,
//                                notes: notes
//                            )
//                            diaryManager.addDiaryEntry(entry)
//                            dismiss()
//                        }
//                    }
//                    .disabled(selectedGroupId == nil && diaryManager.pigeonGroups.isEmpty)
//                }
//            }
//        }
//    }
//    
//    private func moodColor(_ mood: Mood) -> Color {
//        switch mood {
//        case .veryHappy: return .green
//        case .happy: return .blue
//        case .neutral: return .orange
//        case .sad: return .yellow
//        case .verySad: return .red
//        }
//    }
//}

struct AddDiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryManager: PigeonDiaryManager

    @State private var selectedGroupId: UUID?
    @State private var selectedMood: Mood = .happy
    @State private var chicksCount = 0
    @State private var notes = ""
    
    @State private var showAlert = false

    init(groupId: UUID? = nil) {
        self._selectedGroupId = State(initialValue: groupId)
    }

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
                    // Навигация и заголовок
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

                        Text("NEW DIARY ENTRY")
                            .Pro(size: 20, color: Color(red: 236/255, green: 192/255, blue: 22/255))
                            .offset(y: -10)
                            .shadow(radius: 1, y: 3)

                        Spacer()

                        Button(action: {
                            if selectedGroupId == nil {
                                // Нет выбранной группы — показать Alert
                                showAlert = true
                            } else {
                                // Сохраняем запись
                                let entry = DiaryEntry(
                                    pigeonGroupId: selectedGroupId!,
                                    mood: selectedMood,
                                    chicksCount: chicksCount,
                                    notes: notes
                                )
                                diaryManager.addDiaryEntry(entry)
                                dismiss()
                            }
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
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    ScrollView(showsIndicators: false) {
                        // Блок выбора группы (Menu с Picker)
                        Rectangle()
                            .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                            .frame(height: 114)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                                    .overlay(
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("SELECT PIGEON GROUP")
                                                .Pro(size: 13)
                                                .padding(.horizontal)
                                            
                                            Rectangle()
                                                .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white)
                                                        .overlay(
                                                            HStack {
                                                                Menu {
                                                                    Picker(selection: $selectedGroupId, label: EmptyView()) {
                                                                        ForEach(diaryManager.pigeonGroups) { group in
                                                                            Text(group.name).tag(group.id as UUID?)
                                                                        }
                                                                    }
                                                                } label: {
                                                                    HStack {
                                                                        Text(selectedGroupName)
                                                                            .Pro(size: 15)
                                                                        Image(systemName: "chevron.right")
                                                                            .font(.system(size: 12, weight: .semibold))
                                                                            .foregroundColor(.black)
                                                                    }
                                                                    .padding(.horizontal)
                                                                }
                                                                
                                                                Spacer()
                                                            }
                                                                .padding(.horizontal)
                                                        )
                                                )
                                                .frame(height: 70)
                                                .padding(.horizontal)
                                        }
                                    )
                            )
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        
                        // Блок выбора настроения
                        Rectangle()
                            .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                                    .overlay(
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("HOW ARE YOUR PIGEONS FEELINGS?")
                                                .Pro(size: 13)
                                                .padding(.horizontal)
                                            
                                            Rectangle()
                                                .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                .cornerRadius(20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.white)
                                                        .overlay(
                                                            Picker("Mood", selection: $selectedMood) {
                                                                ForEach(Mood.allCases, id: \.self) { mood in
                                                                    HStack {
                                                                        Image(systemName: mood.icon)
                                                                            .foregroundColor(moodColor(mood))
                                                                        Text(mood.rawValue)
                                                                            .Pro(size: 17)
                                                                    }
                                                                    .tag(mood)
                                                                }
                                                            }
                                                                .pickerStyle(WheelPickerStyle())
                                                        )
                                                )
                                                .frame(height: 150)
                                                .padding(.horizontal)
                                        }
                                    )
                            )
                            .frame(height: 200)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        
                        // Блок количества птенцов с кнопками +
                        Rectangle()
                            .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                                    .overlay(
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Text("CHICKS HATCHED")
                                                    .Pro(size: 13)
                                                Spacer()
                                                HStack(spacing: 10) {
                                                    Button(action: {
                                                        chicksCount += 1
                                                    }) {
                                                        Image(.btnBack)
                                                            .resizable()
                                                            .overlay {
                                                                Text("+")
                                                                    .foregroundStyle(.brown)
                                                            }
                                                            .frame(width: 28, height: 28)
                                                            .shadow(radius: 2)
                                                    }
                                                    
                                                    Button(action: {
                                                        if chicksCount > 0 {
                                                            chicksCount -= 1
                                                        }
                                                    }) {
                                                        Image(.btnBack)
                                                            .resizable()
                                                            .overlay {
                                                                Text("-")
                                                                    .foregroundStyle(.brown)
                                                            }
                                                            .frame(width: 28, height: 28)
                                                            .shadow(radius: 2)
                                                    }
                                                }
                                            }
                                            Rectangle()
                                                .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                .cornerRadius(20)
                                                .overlay(
                                                    HStack(spacing: 15) {
                                                        Image("pigeon2")
                                                            .resizable()
                                                            .frame(width: 39, height: 59)
                                                        Text("\(chicksCount)")
                                                            .Pro(size: 30)
                                                        Spacer()
                                                    }
                                                        .padding(.horizontal)
                                                )
                                                .frame(height: 70)
                                        }
                                            .padding(.horizontal)
                                    )
                            )
                            .frame(height: 120)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        
                        // Заметки
                        Rectangle()
                            .fill(Color(red: 255/255, green: 220/255, blue: 103/255))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                                    .overlay(
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("NOTES (OPTIONAL)")
                                                .Pro(size: 13)
                                                .padding(.horizontal)
                                            
                                            Rectangle()
                                                .fill(Color(red: 255/255, green: 232/255, blue: 156/255))
                                                .cornerRadius(20)
                                                .overlay(
                                                    VStack {
                                                        CustomTextView(text: $notes, placeholder: "Note...")
                                                        Spacer()
                                                    }
                                                )
                                                .frame(height: 160)
                                                .padding(.horizontal)
                                        }
                                    )
                            )
                            .frame(height: 214)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Please select a Pigeon Group before saving.", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    var selectedGroupName: String {
        if let id = selectedGroupId,
           let group = diaryManager.pigeonGroups.first(where: { $0.id == id }) {
            return group.name
        } else {
            return "Select a group"
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
    AddDiaryEntryView()
        .environmentObject(PigeonDiaryManager())
}

struct CustomTextView: View {
    @Binding var text: String
    @FocusState var isTextFocused: Bool
    var placeholder: String
    var height: CGFloat = 130
    var body: some View {
        ZStack(alignment: .leading) {
            Color(red: 255/255, green: 232/255, blue: 156/255)
                .padding(.horizontal)
                .offset(y: 20)
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 15)
                .padding(.top, 12)
                .frame(height: height)
                .font(.custom("SFProDisplay-Regular", size: 14))
                .foregroundStyle(.black)
                .focused($isTextFocused)
            
            if text.isEmpty && !isTextFocused {
                VStack {
                    Text(placeholder)
                        .Pro(size: 14, color: .black.opacity(0.25))
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                        .onTapGesture {
                            isTextFocused = true
                        }
                    Spacer()
                }
            }
        }
        .frame(height: height)
    }
}
