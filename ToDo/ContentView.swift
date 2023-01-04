//
//  ContentView.swift
//  ToDo
//
//  Created by N N on 04/01/2023.
//

import SwiftUI
import CoreData

//enum Priority: String, Identifiable, CaseIterable {
//    var id: UUID {
//        return UUID()
//    }
//    case low = "Low"
//    case medium = "Medium"
//    case high = "High"
//}
//
//extension Priority {
//    var title: String {
//        switch self {
//        case .low:
//            return "Low"
//        case .medium:
//            return "Medium"
//        case .high:
//            return "High"
//        }
//    }
//}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.order, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest (
        sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)],
        animation: .default)
    private var allTasks: FetchedResults<Item>
//    (key: "dateCreated, ascending: false)

    @State private var title: String = ""
    @State private var selectedPriority: Priority = .medium
    
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
    
    private func updateTask(_ task: Item) {
        task.isFavorite = !task.isFavorite
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.purple]
//        Use this if NavigationBarTitle is with displayMode = .inline
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
            VStack {
                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(Priority.allCases) { priority in
                        Text(priority.title).tag(priority)
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(.accentColor)
                
                Spacer()
                
                Button("Save") {
                    saveTask()
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                List {
                    ForEach(allTasks) { task in
                        HStack {
                            Circle()
                                .fill(styleForPriority(task.priority!))
                                .frame(width: 15, height: 15)
                            
                            Spacer()
                            
                                .frame(width: 20)
                            Text(task.title ?? "")
                            Text("\(task.order)")
                            
                            Spacer()
                            
                            Image(systemName: task.isFavorite ? "heart.fill": "heart")
                                .foregroundColor(.purple)
                                .onTapGesture {
                                    updateTask(task)
                                }
                        }
                    }
                    .onDelete(perform: deleteItem)
                    .onMove(perform: moveItem)
                }
            }
            .padding()
            .navigationTitle("To do")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.order = (items.last?.order ?? 0) + 1

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func moveItem(at sets: IndexSet, destination: Int) {
        withAnimation {
            let itemToMove = sets.first!
            
            if itemToMove < destination {
                var startIndex = itemToMove + 1
                let endIndex = destination - 1
                var startOrder = items[itemToMove].order
                while startIndex <= endIndex {
                    items[startIndex].order = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                items[itemToMove].order = startOrder
            }
            else if destination < itemToMove {
                var startIndex = destination
                let endIndex = itemToMove - 1
                var startOrder = items[destination].order + 1
                let newOrder = items[destination].order
                while startIndex <= endIndex {
                    items[startIndex].order = startOrder
                    startOrder = startOrder + 1
                    startIndex = startIndex + 1
                }
                items[itemToMove].order = newOrder
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
