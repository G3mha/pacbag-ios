import SwiftUI

struct CustomCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var category: String
    @Binding var subcategory: String
    let onSave: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Create Category")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("e.g., Sports Equipment", text: $category)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subcategory (optional)")
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
            .navigationTitle("Custom Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(category.trimmingCharacters(in: .whitespacesAndNewlines), 
                               subcategory.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    .disabled(category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    CustomCategoryView(
        category: .constant(""),
        subcategory: .constant(""),
        onSave: { _, _ in }
    )
}