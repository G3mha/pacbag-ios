import SwiftUI
import CoreData

struct CategoryManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoryManager = CategoryManager.shared
    
    @State private var showingAddCategory = false
    @State private var showingEditCategory: Category?
    @State private var showingDeleteAlert: Category?
    @State private var searchText = ""
    @State private var selectedSegment = 0 // 0: All, 1: Popular, 2: Recent
    @State private var showingAnalytics = false
    
    private var filteredCategories: [Category] {
        let baseCategories: [Category]
        
        switch selectedSegment {
        case 1:
            baseCategories = categoryManager.popularCategories
        case 2:
            baseCategories = categoryManager.recentCategories
        default:
            baseCategories = categoryManager.categories
        }
        
        if searchText.isEmpty {
            return baseCategories
        } else {
            return categoryManager.searchCategories(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Segment Control
                Picker("Filter", selection: $selectedSegment) {
                    Text("All").tag(0)
                    Text("Popular").tag(1)
                    Text("Recent").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Analytics Summary
                if selectedSegment == 0 {
                    CategoryAnalyticsSummary(categoryManager: categoryManager)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
                
                // Categories List
                List {
                    ForEach(filteredCategories, id: \.id) { category in
                        CategoryManagementRow(
                            category: category,
                            onEdit: { showingEditCategory = category },
                            onDelete: { showingDeleteAlert = category }
                        )
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Category Management")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { showingAnalytics = true }) {
                            Image(systemName: "chart.bar.fill")
                        }
                        
                        Button(action: { showingAddCategory = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
        }
        .sheet(item: $showingEditCategory) { category in
            EditCategoryView(category: category)
        }
        .sheet(isPresented: $showingAnalytics) {
            CategoryAnalyticsView()
        }
        .alert("Delete Category", isPresented: .constant(showingDeleteAlert != nil)) {
            Button("Delete", role: .destructive) {
                if let category = showingDeleteAlert {
                    deleteCategory(category)
                }
                showingDeleteAlert = nil
            }
            Button("Cancel", role: .cancel) {
                showingDeleteAlert = nil
            }
        } message: {
            if let category = showingDeleteAlert {
                Text("Are you sure you want to delete '\(category.name)'? This will remove the category from \(category.itemsArray.count) items.")
            }
        }
    }
    
    private func deleteCategory(_ category: Category) {
        withAnimation {
            // Move items to General category
            let generalCategory = categoryManager.category(named: "General")
            categoryManager.deleteCategory(category, moveItemsTo: generalCategory)
        }
    }
}

struct CategoryManagementRow: View {
    @ObservedObject var category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon and Color
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                // Category Name
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    if category.isDefault {
                        Text("Default")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                // Subcategories
                if !category.subcategoriesArray.isEmpty {
                    Text("\(category.subcategoriesArray.count) subcategories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Usage Stats
                HStack(spacing: 16) {
                    Label("\(category.usageCount)", systemImage: "chart.bar.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(category.itemsArray.count)", systemImage: "cube.box.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let lastUsed = category.lastUsedDate {
                        Text("Last used: \(lastUsed, style: .relative)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                if !category.isDefault {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !category.isDefault {
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
            
            Button("Edit") {
                onEdit()
            }
            .tint(.blue)
        }
    }
}

struct CategoryAnalyticsSummary: View {
    @ObservedObject var categoryManager: CategoryManager
    @State private var showingFullAnalytics = false
    
    var totalCategories: Int {
        categoryManager.categories.count
    }
    
    var totalSubcategories: Int {
        categoryManager.categories.reduce(0) { $0 + $1.subcategoriesArray.count }
    }
    
    var totalUsage: Int32 {
        categoryManager.categories.reduce(0) { $0 + $1.usageCount }
    }
    
    var mostUsedCategory: Category? {
        categoryManager.categories.max { $0.usageCount < $1.usageCount }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Analytics")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("View All") {
                    showingFullAnalytics = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 16) {
                AnalyticsCard(
                    title: "Categories",
                    value: "\(totalCategories)",
                    icon: "folder.fill",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Subcategories",
                    value: "\(totalSubcategories)",
                    icon: "folder.badge.plus",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Total Usage",
                    value: "\(totalUsage)",
                    icon: "chart.bar.fill",
                    color: .orange
                )
            }
            
            if let mostUsed = mostUsedCategory, mostUsed.usageCount > 0 {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Most used: **\(mostUsed.name)** (\(mostUsed.usageCount) times)")
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingFullAnalytics) {
            CategoryAnalyticsView()
        }
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search categories..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SearchBar
        
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoryManager = CategoryManager.shared
    
    @State private var categoryName = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = Color.blue
    @State private var subcategories: [String] = []
    @State private var newSubcategory = ""
    
    private let availableIcons = [
        "folder.fill", "tshirt.fill", "iphone", "drop.fill", "doc.fill",
        "shoe.fill", "eyeglasses", "cross.fill", "camera.fill", "book.fill",
        "music.note", "gamecontroller.fill", "car.fill", "airplane", "house.fill"
    ]
    
    private let availableColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .indigo, .teal, .mint
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Appearance")) {
                    // Icon Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                                        .frame(width: 40, height: 40)
                                        .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                                .frame(width: 36, height: 36)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Section(header: Text("Preview")) {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundColor(selectedColor)
                            .font(.title2)
                        
                        Text(categoryName.isEmpty ? "New Category" : categoryName)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding()
                    .background(selectedColor.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Section(header: Text("Subcategories (Optional)")) {
                    ForEach(subcategories.indices, id: \.self) { index in
                        HStack {
                            Text(subcategories[index])
                            Spacer()
                            Button("Remove") {
                                subcategories.remove(at: index)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        TextField("Add subcategory", text: $newSubcategory)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Add") {
                            if !newSubcategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                subcategories.append(newSubcategory.trimmingCharacters(in: .whitespacesAndNewlines))
                                newSubcategory = ""
                            }
                        }
                        .disabled(newSubcategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let category = categoryManager.createCategory(
            trimmedName,
            icon: selectedIcon,
            color: selectedColor.hexString,
            isDefault: false
        )
        
        for subcategoryName in subcategories {
            categoryManager.createSubcategory(subcategoryName, in: category, isDefault: false)
        }
        
        categoryManager.saveContext()
        categoryManager.loadCategories()
        
        dismiss()
    }
}

struct EditCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var categoryManager = CategoryManager.shared
    
    @ObservedObject var category: Category
    
    @State private var categoryName: String
    @State private var selectedIcon: String
    @State private var selectedColor: Color
    @State private var subcategories: [String]
    @State private var newSubcategory = ""
    
    private let availableIcons = [
        "folder.fill", "tshirt.fill", "iphone", "drop.fill", "doc.fill",
        "shoe.fill", "eyeglasses", "cross.fill", "camera.fill", "book.fill",
        "music.note", "gamecontroller.fill", "car.fill", "airplane", "house.fill"
    ]
    
    private let availableColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .indigo, .teal, .mint
    ]
    
    init(category: Category) {
        self.category = category
        self._categoryName = State(initialValue: category.name)
        self._selectedIcon = State(initialValue: category.iconName ?? "folder.fill")
        self._selectedColor = State(initialValue: category.color)
        self._subcategories = State(initialValue: category.subcategoriesArray.map { $0.name })
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(category.isDefault)
                }
                
                if !category.isDefault {
                    Section(header: Text("Appearance")) {
                        // Icon Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(selectedIcon == icon ? selectedColor : .secondary)
                                            .frame(width: 40, height: 40)
                                            .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                                    .frame(width: 36, height: 36)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Preview")) {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundColor(selectedColor)
                            .font(.title2)
                        
                        Text(categoryName.isEmpty ? "Category" : categoryName)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding()
                    .background(selectedColor.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Section(header: Text("Subcategories")) {
                    ForEach(subcategories.indices, id: \.self) { index in
                        HStack {
                            Text(subcategories[index])
                            Spacer()
                            if !category.isDefault {
                                Button("Remove") {
                                    subcategories.remove(at: index)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    if !category.isDefault {
                        HStack {
                            TextField("Add subcategory", text: $newSubcategory)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !newSubcategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    subcategories.append(newSubcategory.trimmingCharacters(in: .whitespacesAndNewlines))
                                    newSubcategory = ""
                                }
                            }
                            .disabled(newSubcategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                
                Section(header: Text("Usage Statistics")) {
                    HStack {
                        Text("Times Used")
                        Spacer()
                        Text("\(category.usageCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Items Using Category")
                        Spacer()
                        Text("\(category.itemsArray.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastUsed = category.lastUsedDate {
                        HStack {
                            Text("Last Used")
                            Spacer()
                            Text(lastUsed, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        categoryManager.updateCategory(
            category,
            name: trimmedName,
            icon: selectedIcon,
            color: selectedColor.hexString
        )
        
        // Update subcategories
        let currentSubcategoryNames = Set(category.subcategoriesArray.map { $0.name })
        let newSubcategoryNames = Set(subcategories)
        
        // Remove deleted subcategories
        for subcategoryToRemove in currentSubcategoryNames.subtracting(newSubcategoryNames) {
            if let subcategory = category.subcategoriesArray.first(where: { $0.name == subcategoryToRemove }) {
                viewContext.delete(subcategory)
            }
        }
        
        // Add new subcategories
        for subcategoryToAdd in newSubcategoryNames.subtracting(currentSubcategoryNames) {
            categoryManager.createSubcategory(subcategoryToAdd, in: category, isDefault: false)
        }
        
        categoryManager.saveContext()
        categoryManager.loadCategories()
        
        dismiss()
    }
}

#Preview {
    CategoryManagementView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}