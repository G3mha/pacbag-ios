import SwiftUI

struct CustomCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var category: String
    @Binding var subcategory: String
    let onSave: (String, String) -> Void
    @StateObject private var categoryManager = CategoryManager.shared
    @State private var showingDuplicateAlert = false
    @State private var duplicateMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(category.isEmpty ? "Create Category" : "Add Subcategory")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if category.isEmpty {
                                TextField("e.g., Sports Equipment", text: $category)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                // Show as read-only when adding subcategory to existing category
                                HStack {
                                    Text(category)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("(existing)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subcategory\(category.isEmpty ? " (optional)" : "")")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("e.g., Running Gear", text: $subcategory)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                Section(header: Text("Preview")) {
                    if !category.isEmpty {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Your new category:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(subcategory.isEmpty ? category : "\(category) > \(subcategory)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("How it works")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Create new categories that will be saved for future use")
                        Text("• Add subcategories to organize items even better")
                        Text("• Your custom categories will appear in the main category picker")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle(category.isEmpty ? "New Category" : "New Subcategory")
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
                    .disabled(category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Duplicate Entry", isPresented: $showingDuplicateAlert) {
                Button("OK") { }
            } message: {
                Text(duplicateMessage)
            }
        }
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