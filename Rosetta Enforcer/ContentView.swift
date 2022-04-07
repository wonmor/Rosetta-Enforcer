//
//  ContentView.swift
//  Rosetta Enforcer
//
//  Created by John Seong on 2022-04-07.
//

import SwiftUI


struct Fruit: Identifiable {
    let id = UUID().uuidString
    let name: String
}
final class ViewModel: ObservableObject {
    init(fruits: [Fruit] = ViewModel.defaultFruits) {
        self.fruits = fruits
        self.selectedId = fruits[0].id
    }
    @Published var fruits: [Fruit]
    @Published var selectedId: String?
    
    // What is the question mark after the type: https://stackoverflow.com/questions/24009449/question-mark-after-data-type
    
    static let defaultFruits: [Fruit] = ["Home", "Convert", "Settings"].map({ Fruit(name: $0) })
}

struct ContentView: View {
    @State var isFooterHidden = true
    @State var stateOpacity = 1.0
    @State var currentSelection: String? = nil
    @State private var visible: Bool = false
    
    // Detect whether OS is on dark mode or light mode
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.fruits) { item in
                    NavigationLink(item.name, tag: item.id, selection: $viewModel.selectedId) {
                        VStack(alignment: .leading, spacing: 6) {
                            
                            Text(item.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? Color.orange : Color.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .navigationTitle(item.name)
                                .padding()
                            
                            Text("Welcome to Rosetta Enforcer")
                                .font(.title)
                                .fontWeight(.regular)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                            
                            Text("Please select the options")
                                .font(.title2)
                                .fontWeight(.thin)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                            
                            Spacer()
                        }
                        .onAppear {
                            self.currentSelection = item.name
                            self.visible = true
                        }
                    }
                    
                }
                .padding(8)
            }
        }
        .listStyle(.sidebar)
        if self.currentSelection != nil {
            Text(self.currentSelection!)
                .opacity(self.visible ? 1 : 0)
                .opacity(stateOpacity)
            Spacer()
                .onAppear {
                    withAnimation(.linear(duration: 1)) {
                        self.currentSelection = nil
                        self.visible = false
                    }
                    
                    // Fix the spam not disappearing error
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// CMD + A and then CTRL + I to auto format the code
