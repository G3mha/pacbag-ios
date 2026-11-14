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
            List {
                Section {
                    Picker("Show", selection: $selectedSegment) {
                        Text("All").tag(0)
                        Text("Popular").tag(1)
                        Text("Recent").tag(2)
                    }
                    .pickerStyle(.menu)

                    Button {
                        showingAnalytics = true
                    } label: {
                        HStack {
                            Text("Category Analytics")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                Section {
                    if filteredCategories.isEmpty {
                        Text(searchText.isEmpty ? "No categories here yet" : "No categories match")
                            .foregroundColor(.secondary)
                    }

                    ForEach(filteredCategories, id: \.id) { category in
                        CategoryManagementRow(
                            category: category,
                            onEdit: { showingEditCategory = category },
                            onDelete: { showingDeleteAlert = category }
                        )
                    }
                } header: {
                    Text("\(filteredCategories.count) Categories")
                        .solidSectionHeader()
                } footer: {
                    Text("Swipe a category to edit or delete it. The default categories can't be deleted.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search categories")
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCategory = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("New Category")
                }
            }
        }
        .plainFormSheet()
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
                    showingDeleteAlert = nil
                }
            }
            Button("Cancel", role: .cancel) {
                showingDeleteAlert = nil
            }
        } message: {
            if let category = showingDeleteAlert {
                let itemCount = category.itemsArray.count
                let categoryName = category.name
                return Text("Are you sure you want to delete '\(categoryName)'? This will remove the category from \(itemCount) items.")
            } else {
                return Text("")
            }
        }
    }
    
    private func deleteCategory(_ category: Category) {
        // Store category information before deletion to avoid accessing deleted object
        _ = category.objectID
        _ = category.name
        
        // Clear UI state immediately to prevent further access to the object
        showingDeleteAlert = nil
        showingEditCategory = nil
        
        // Perform deletion without animation to avoid UI conflicts
        Task {
            // Ensure General category exists and get it
            let generalCategory = categoryManager.ensureGeneralCategoryExists()
            
            // Delete the category and move items to General
            categoryManager.deleteCategory(category, moveItemsTo: generalCategory)
        }
    }
}

struct CategoryManagementRow: View {
    @ObservedObject var category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var details: String {
        var parts: [String] = []
        if category.isDefault {
            parts.append("Default")
        }
        let subcategoryCount = category.subcategoriesArray.count
        if subcategoryCount > 0 {
            parts.append(subcategoryCount == 1 ? "1 subcategory" : "\(subcategoryCount) subcategories")
        }
        let itemCount = category.itemsArray.count
        parts.append(itemCount == 1 ? "1 item" : "\(itemCount) items")
        parts.append(category.usageCount == 1 ? "1 use" : "\(category.usageCount) uses")
        return parts.joined(separator: " · ")
    }
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .foregroundColor(.primary)

                    Text(details)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let lastUsed = category.lastUsedDate {
                        Text("Last used \(lastUsed, style: .relative) ago")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
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

/// The icon and colour pickers shared by the new and edit category forms.
struct CategoryAppearanceSection: View {
    @Binding var icon: String
    @Binding var color: Color

    static let icons = [
        "folder.fill", "tshirt.fill", "iphone", "drop.fill", "doc.fill",
        "shoe.fill", "eyeglasses", "cross.fill", "camera.fill", "book.fill",
        "music.note", "gamecontroller.fill", "car.fill", "airplane", "house.fill"
    ]

    static let colors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .indigo, .teal, .mint
    ]

    var body: some View {
        Section(header: Text("Appearance").solidSectionHeader()) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Icon")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                    ForEach(Self.icons, id: \.self) { option in
                        Button(action: { icon = option }) {
                            Image(systemName: option)
                                .font(.title3)
                                .foregroundColor(icon == option ? color : .secondary)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(icon == option ? color : Color.clear, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(option.replacingOccurrences(of: ".fill", with: "").replacingOccurrences(of: ".", with: " "))
                        .accessibilityAddTraits(icon == option ? .isSelected : [])
                    }
                }
            }
            .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 8) {
                Text("Colour")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                    ForEach(Self.colors, id: \.self) { option in
                        Button(action: { color = option }) {
                            Circle()
                                .fill(option)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(color == option ? Color.primary : Color.clear, lineWidth: 2)
                                        .frame(width: 36, height: 36)
                                )
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(option.description)
                        .accessibilityAddTraits(color == option ? .isSelected : [])
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

/// The subcategory list shared by the new and edit category forms.
struct SubcategoriesSection: View {
    let title: String
    @Binding var subcategories: [String]
    var isEditable = true

    @State private var newSubcategory = ""

    private var trimmedNew: String {
        newSubcategory.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Section(header: Text(title).solidSectionHeader()) {
            ForEach(subcategories.indices, id: \.self) { index in
                HStack {
                    Text(subcategories[index])
                    Spacer()
                    if isEditable {
                        Button("Remove") {
                            subcategories.remove(at: index)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.red)
                    }
                }
            }

            if isEditable {
                HStack {
                    TextField("Add subcategory", text: $newSubcategory)
                        .onSubmit(add)

                    Button("Add", action: add)
                        .buttonStyle(.borderless)
                        .disabled(trimmedNew.isEmpty)
                }
            }
        }
    }

    private func add() {
        guard !trimmedNew.isEmpty else { return }
        subcategories.append(trimmedNew)
        newSubcategory = ""
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
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: selectedIcon)
                            .foregroundColor(selectedColor)
                            .frame(width: 24)
                            .accessibilityHidden(true)

                        TextField("Category Name", text: $categoryName)
                    }
                }

                CategoryAppearanceSection(icon: $selectedIcon, color: $selectedColor)

                SubcategoriesSection(title: "Subcategories (Optional)", subcategories: $subcategories)
            }
            .listStyle(.plain)
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
        .plainFormSheet()
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
    
    init(category: Category) {
        self.category = category
        self._categoryName = State(initialValue: category.name)
        self._selectedIcon = State(initialValue: category.iconName ?? "folder.fill")
        self._selectedColor = State(initialValue: category.color)
        self._subcategories = State(initialValue: category.subcategoriesArray.map { $0.name })
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: selectedIcon)
                            .foregroundColor(selectedColor)
                            .frame(width: 24)
                            .accessibilityHidden(true)

                        TextField("Category Name", text: $categoryName)
                            .disabled(category.isDefault)
                    }
                } footer: {
                    if category.isDefault {
                        Text("Default categories keep their name, icon and subcategories.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !category.isDefault {
                    CategoryAppearanceSection(icon: $selectedIcon, color: $selectedColor)
                }

                SubcategoriesSection(title: "Subcategories", subcategories: $subcategories, isEditable: !category.isDefault)
                
                Section(header: Text("Usage").solidSectionHeader()) {
                    LabeledContent("Times used", value: "\(category.usageCount)")
                    LabeledContent("Items using it", value: "\(category.itemsArray.count)")
                    
                    if let lastUsed = category.lastUsedDate {
                        HStack {
                            Text("Last used")
                            Spacer()
                            Text("\(lastUsed, style: .relative) ago")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .listStyle(.plain)
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
        .plainFormSheet()
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