import SwiftUI

struct ProjectFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var isPresented: Bool
    let existingProject: Project?
    var onDismiss: (() -> Void)?

    @State private var name: String = ""
    @State private var selectedColorHex: String = Project.defaultColors[0]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(existingProject == nil ? "新建项目" : "编辑项目")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            // Form
            VStack(alignment: .leading, spacing: 20) {
                // Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("项目名称")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)

                    TextField("输入项目名称", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 14))
                }

                // Color
                VStack(alignment: .leading, spacing: 8) {
                    Text("颜色")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        ForEach(Project.defaultColors, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex) ?? .blue)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColorHex == colorHex ? 2 : 0)
                                        .padding(2)
                                )
                                .onTapGesture {
                                    selectedColorHex = colorHex
                                }
                        }
                    }
                }
            }
            .padding(20)

            Spacer()

            Divider()

            // Actions
            HStack {
                if existingProject != nil {
                    Button("删除", role: .destructive) {
                        if let project = existingProject {
                            dataStore.deleteProject(project)
                        }
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()

                Button("取消") {
                    dismiss()
                }
                .buttonStyle(.bordered)

                Button("保存") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(20)
        }
        .frame(width: 400, height: 320)
        .onAppear {
            if let project = existingProject {
                name = project.name
                selectedColorHex = project.colorHex
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if var project = existingProject {
            project.name = trimmedName
            project.colorHex = selectedColorHex
            dataStore.updateProject(project)
        } else {
            let project = Project(name: trimmedName, colorHex: selectedColorHex)
            dataStore.addProject(project)
        }

        dismiss()
    }

    private func dismiss() {
        onDismiss?()
        isPresented = false
    }
}

