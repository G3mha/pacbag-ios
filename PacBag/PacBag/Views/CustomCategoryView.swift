import SwiftUI

struct CustomCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var category: String
    @Binding var subcategory: String
    let onSave: (String, String) -> Void
    @StateObject private var categoryManager = CategoryManager.shared
    @State private var showingDuplicateAlert = false
    @State private var duplicateMessage = ""
    @State private var isAddingSubcategory = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    if isAddingSubcategory {
                        HStack {
                            Text("Category")
                            Spacer()
                            Text(category)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        TextField("Category Name", text: $category)
                    }

                    TextField(isAddingSubcategory ? "Subcategory Name" : "Subcategory (optional)", text: $subcategory)
                }
            }
            .listStyle(.plain)
            .navigationTitle(isAddingSubcategory ? "New Subcategory" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedSubcategory = subcategory.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        // Check for duplicates
                        if let validationError = validateCategoryAndSubcategory(category: trimmedCategory, subcategory: trimmedSubcategory) {
                            duplicateMessage = validationError
                            showingDuplicateAlert = true
                        } else {
                            onSave(trimmedCategory, trimmedSubcategory)
                        }
                    }
                    .disabled(isSaveDisabled)
                }
            }
            .alert("Duplicate Entry", isPresented: $showingDuplicateAlert) {
                Button("OK") { }
            } message: {
                Text(duplicateMessage)
            }
        }
        .plainFormSheet()
        .onAppear {
            // Decided once, when the sheet opens. The name field writes to `category`,
            // so reading it later would switch modes on the first letter typed.
            isAddingSubcategory = !category.isEmpty
        }
        .onDisappear {
            // The caller keeps these between openings, and leftover text would
            // make the next sheet open as a new subcategory.
            category = ""
            subcategory = ""
        }
    }
    
    private var isSaveDisabled: Bool {
        let categoryIsEmpty = category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let subcategoryIsEmpty = subcategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return categoryIsEmpty || (isAddingSubcategory && subcategoryIsEmpty)
    }

    private func validateCategoryAndSubcategory(category: String, subcategory: String) -> String? {
        // Check if we're creating a new category
        if category.isEmpty {
            return nil
        }
        
        // Check for duplicate category (case-insensitive)
        if subcategory.isEmpty {
            // Creating a new category without subcategory
            if categoryManager.categories.contains(where: { $0.name.lowercased() == category.lowercased() }) {
                return "A category named '\(category)' already exists. Please use a different name."
            }
        } else {
            // Creating a subcategory
            if let existingCategory = categoryManager.category(named: category) {
                // Check if subcategory already exists in this category (case-insensitive)
                if existingCategory.subcategoriesArray.contains(where: { $0.name.lowercased() == subcategory.lowercased() }) {
                    return "The subcategory '\(subcategory)' already exists in '\(category)'. Please use a different name."
                }
            }
        }
        
        return nil
    }
}

#Preview {
    CustomCategoryView(
        category: .constant(""),
        subcategory: .constant(""),
        onSave: { _, _ in }
    )
}