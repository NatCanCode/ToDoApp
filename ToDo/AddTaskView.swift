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

struct AddTaskView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>
    
    @State var title: String = ""
    @State var selectedPriority: Priority = .medium
    
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.purple]
        //        Use this if NavigationBarTitle is with displayMode = .inline
        //        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("Task", text: $title)
//                            .textFieldStyle(.roundedBorder)
                    } header: {
                        Text("Detail task")
                            .foregroundColor(.accentColor)
                    }
                    
                    Section {
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(Priority.allCases) { priority in
                                Text(priority.title).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                        .colorMultiply(.accentColor)
                    } header: {
                        Text("Priority")
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()
                    Spacer()
                    
                    Button {
                        saveTask()
//                        addItem()
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
                //                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
            }
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
