//
//  ContentView.swift
//  Todo App
//
//  Created by Jose Gonzalez on 12/6/23.
//

import SwiftUI
import CoreData


class Model : ObservableObject {
    @Published var savedHabits : [Habit] = []
    
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
        fetchHabits()
    }
    
    func fetchHabits() {
        let request = NSFetchRequest<Habit>(entityName: "Habit")
        do{
            savedHabits = try container.viewContext.fetch(request)
        } catch let error{
            print("error while fetching the data \(error)")
        }
    }
    
    func addHabit(text: String) {
        let newHabit = Habit(context: container.viewContext)
        newHabit.name = text
        newHabit.isCompleted = false
        newHabit.streak_counter = 0
        newHabit.timestamp = Date()
        saveData()
    }
    
    func saveData(){
        do{
            try container.viewContext.save()
            fetchHabits()
        } catch let error {
            print("Error is \(error)")
        }

    }
    
    func deleteHabit(indexSet: IndexSet) {
            guard let index = indexSet.first else { return }
            let entity = savedHabits[index]
            container.viewContext.delete(entity)
            saveData()
        }

}

struct ContentView: View {
    @StateObject var vm = Model()
    
    var today = Date().formatted(date: .numeric, time: .omitted)
    @State var dd : Date = Date()
    
    
    @State var textFieldString: String = ""
    
    
    var body : some View {
        NavigationView{
                VStack{
                    HStack{
                        TextField("Add ToDo Here", text:$textFieldString)
                            .font(.headline)
                            .padding(.leading)
                            .frame(height: 55)
                            .background(Color("Color 1"))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .foregroundColor(Color.white)
                        Button(action: {
                            guard !textFieldString.isEmpty else { return }
                            vm.addHabit(text: textFieldString)
                            textFieldString = ""
                        }, label: {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(Color("Color 3"))
                                .frame(height: 55)
                                .frame(maxWidth: 100)
                                .background(Color("Color 1"))
                                .cornerRadius(10)
                        })
                        .padding(.trailing)
                    }
                    if(vm.savedHabits.isEmpty){
                        Text("\n\n\nHere you can list tasks for the day.\nDelete or keep them as reccurring tasks")
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(.lightGray))
                    }
                    List{
                        
                        ForEach(vm.savedHabits) { Habit in
                            Button(action: {
                                Habit.isCompleted = !Habit.isCompleted
                                vm.saveData()
                            }
                                   ,label: {
                                Text(Habit.name ?? "No Name")
                                    .foregroundColor(Color(.white))
                            })
                            .frame(width: 360, height: 60, alignment: .center)
                            .background(Habit.isCompleted ? Color("Color 2") : Color("Color 5"))
                            .animation(.easeInOut, value: Habit.isCompleted)
                        }
                        .onDelete(perform: vm.deleteHabit)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .navigationTitle("ToDo's for \(today)")
                    .toolbar{
                        NavigationLink(destination: FutureTodoView().navigationBarBackButtonHidden()){
                            Label("Todos", systemImage: "bookmark.circle")
                                .foregroundColor(Color("Color 1"))
                        }
                    }
                }
                
        }
    }
}



struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
