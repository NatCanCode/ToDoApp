//
//  AddTaskView.swift
//  ToDo
//
//  Created by N N on 04/01/2023.
//

import SwiftUI

enum Priority: String, Identifiable, CaseIterable {
    var id: UUID {
        return UUID()
    }
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

extension Priority {
    var title: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

func foregroundColor(_ status: String) -> Color {
    switch status {
    case "Low":
        return Color.green
    case "Medium":
        return Color.orange
    case "High":
        return Color.red
    default:
        return Color.clear
    }
}
//private func styleForPriority(_ value: String) -> Color {
//    let priority = Priority(rawValue: value)
//    switch priority {
//    case .low:
//        return Color.green
//    case .medium:
//        return Color.orange
//    case .high:
//        return Color.red
//    default:
//        return Color.black
//    }
//}

struct AddTaskView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.dueDate, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>
    
    @State var title: String = ""
    @State var selectedPriority: Priority = .medium
    
    init() {
        // How to change selected segment color in SwiftUI Segmented Picker
        UISegmentedControl.appearance().selectedSegmentTintColor = .purple
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.purple], for: .normal)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("Task", text: $title)
                        //                            .textFieldStyle(.roundedBorder)
                    } header: {
                        Text("Enter task")
                            .foregroundColor(.accentColor)
                    }
                    Section {
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(Priority.allCases) { priority in
                                Text(priority.title).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
//                        .colorMultiply(.accentColor)
//                        .onChange(of: selectedPriority) { _ in }
                    } header: {
                        Text("Priority")
                            .foregroundColor(.accentColor)
                    }
                }
                Button {
                    //                        addItem()
                    saveTask()
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .navigationTitle("Add a task")
            .scrollContentBackground(.hidden)
            .scrollContentBackground(.hidden)
            //                .background(Image("")
            //                    .resizable()
            //                    .scaledToFill()
            //                    .ignoresSafeArea())
        }
    }
    
    private func saveTask() {
        do {
            let item = Item(context: viewContext)
            item.title = title
            item.priority = selectedPriority.rawValue
            item.dateCreated = Date()
            item.order = (items.last?.order ?? 0) + 1
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func styleForPriority(_ value: String) -> Color {
        let priority = Priority(rawValue: value)
        switch priority {
        case .low:
            return Color.green
        case .medium:
            return Color.orange
        case .high:
            return Color.red
        default:
            return Color.black
        }
    }
    
    //    let objectColors = SegmentColor.allCases
    //    @State private var selectedColor = SegmentColor.red
    //
    //    enum SegmentColor: String, CaseIterable, Identifiable {
    //        case red, yellow, green
    //        var id: String { rawValue }
    //
    //        var color: UIColor {
    //            switch self {
    //            case .red:      return .red
    //            case .yellow:   return .yellow
    //            case .green:    return .green
    //            }
    //        }
    //    }
    
    //    private func addItem() {
    //        withAnimation {
    //            let newItem = Item(context: viewContext)
    //            newItem.timestamp = Date()
    //            newItem.order = (items.last?.order ?? 0) + 1
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
