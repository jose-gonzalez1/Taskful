//
//  FutureTodos.swift
//  Todo App
//
//  Created by Jose Gonzalez on 12/8/23.
//

import SwiftUI
import CoreData


class TasksModel : ObservableObject {
    @Published var savedTodos : [Todo] = [] // List to hold tasks
    
    let container: NSPersistentContainer
    
    init(){
        container = NSPersistentContainer(name: "HabitsContainer")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failed to load the data \(error)")
            } else {
                print("Successful connection!")
            }
        }
        fetchTodo()
    }
    
    func fetchTodo() {
        let request = NSFetchRequest<Todo>(entityName: "Todo")
        do{
            savedTodos = try container.viewContext.fetch(request)
        } catch let error{
            print("error while fetching the data \(error)")
        }
    }
    
    func addTodo(name: String, dets: String, date: Date) { // Pass name, description and date to create longterm task
        let newTodo = Todo(context: container.viewContext)
        newTodo.name = name
        newTodo.details = dets
        newTodo.date = date
        saveData()
    }
    
    func saveData(){
        do{
            try container.viewContext.save()
            fetchTodo()
        } catch let error {
            print("Error is \(error)")
        }

    }
    
    func deleteTodo(indexSet: IndexSet) {
            guard let index = indexSet.first else { return }
            let entity = savedTodos[index]
            container.viewContext.delete(entity)
            saveData()
        }

}


struct FutureTodoView : View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject var todoModel = TasksModel()
    
    @State var addingTodo = false
    @State var dd : Date = Date()
    @State var textFieldEntry : String = ""
    @State var descFieldEntry : String = ""
    @State var dayString : String = ""
    
    // Function that returns a string from a date
    func stringify(day : Date) -> String{
            return day.formatted(date: .numeric, time: .omitted)
    }
    
    var body : some View {
        NavigationView{
            VStack{
                // Message when list is empty
                if(todoModel.savedTodos.isEmpty){
                    Text("\n\n\nHere you can list any future Todos.\nDelete by swiping right.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.lightGray))
                }
                List{
                    ForEach(todoModel.savedTodos) { Todo in
                        Button(action: { // Button is used to fill background color
                            todoModel.saveData()
                        }
                               ,label: {
                            Text(Todo.name ?? "No Name")
                                .foregroundColor(Color(.white))
                            Text(Todo.details ?? "")
                                .foregroundColor(Color(.white))
                            Text(stringify(day : Todo.date!))
                                .foregroundColor(Color(.white))
                            
                        })
                        .frame(width: 360, height: 60, alignment: .center)
                        .background(Color("Color 1"))
                    }
                    .onDelete(perform: todoModel.deleteTodo)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .navigationTitle("Future ToDos")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){ // Returns to current day's tasks
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "calendar.day.timeline.leading")
                            .foregroundColor(Color("Color 1"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){ // Add Button ( + )
                    Button {
                        addingTodo.toggle() // Change adding bool to true
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(Color("Color 1"))
                    }
                    .sheet(isPresented: $addingTodo){ // Sheet appears when adding is true
                        VStack(alignment: .center){
                            TextField("Todo's Name", text: $textFieldEntry) // Enter name
                                .frame(width:350, height:60)
                                .background(Color("Color 5"))
                                .multilineTextAlignment(.center)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            TextField("Description", text: $descFieldEntry) // Enter descriptions
                                .frame(width:350, height:100)
                                .background(Color("Color 5"))
                                .multilineTextAlignment(.center)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            DatePicker("", selection: $dd, displayedComponents: .date) // Displays calendar for user to pick date
                                .datePickerStyle(.graphical)
                            Button("Submit", // Submit button
                                   action: {
                                if(textFieldEntry.isEmpty){return} // If name is empty do not submit
                                addingTodo.toggle() // set adding bool to false
                                todoModel.addTodo(name: textFieldEntry, dets: descFieldEntry, date: dd)
                                // enter new task to list
                            }
                            )
                        }
                    }
                }
            }
        }
        
    }
}

struct FutureTodoPreview: PreviewProvider {
    static var previews: some View {
        FutureTodoView()
    }
}
