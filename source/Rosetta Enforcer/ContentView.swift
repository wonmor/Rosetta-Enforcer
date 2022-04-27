//
//  ContentView.swift
//  Rosetta Enforcer
//
//  Created by John Seong on 2022-04-07.
//

import SwiftUI

struct Choice: Identifiable {
    let id = UUID().uuidString
    let name: String
}

final class ViewModel: ObservableObject {
    init(choices: [Choice] = ViewModel.defaultChoices) {
        self.choices = choices
        self.selectedId = choices[0].id
    }
    @Published var choices: [Choice]
    @Published var selectedId: String?
    
    // What is the question mark after the type: https://stackoverflow.com/questions/24009449/question-mark-after-data-type
    
    static let defaultChoices: [Choice] = ["Home", "Convert", "Settings"].map({ Choice(name: $0) })
}

// For the back button
final class PreviousViewIndex: ObservableObject {
    @Published var items = [Int]()
    
    func addNewIndex(newIndex: Int) {
        guard items.count <= 10 else {
            items.removeAll()
            items.append(newIndex)
            return
        }
        items += [newIndex]
        
        // Does not work properly for some reason; fix it!
    }
}

// Unless using class-specific features, struct is the default go-to in Swift
struct ContentView: View {
    @State var isFooterHidden = true
    @State var stateOpacity = 1.0
    @State var currentSelection: String? = nil
    @State private var visible: Bool = false
    @State private var isStartUp: Bool = true
    @State var filename = [String]()
    @State var previousUrlPath = [String]()
    @State var tooManyFilesError = false
    @State var isNotAppError = false
    
    @ObservedObject var previousViewIndex = PreviousViewIndex()
    
    @AppStorage("showFooter") var showFooter: Bool = true
    @AppStorage("verboseMode") var verboseMode: Bool = true
    
    // Detect whether OS is on dark mode or light mode
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel = ViewModel()
    
    // This is the main view
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.choices) { item in
                    NavigationLink(item.name, tag: item.id, selection: $viewModel.selectedId) {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            switch item.name {
                            case "Home":
                                printHeading(text: item.name, colorCode: 0)
                                printBody(text: "Welcome to Rosetta Enforcer", isHeader: true)
                                printBody(text: "A native-like utility that can easily convert an Universal Binary app to be Single Architecture: e.g. Intel-only, forcing Rosetta to run on M1 (ARM) Macs", isHeader: false)
                                displayHomeElements()
                                    .padding()
                                    .onAppear() {
                                        guard isStartUp else {
                                            self.previousViewIndex.addNewIndex(newIndex: 0)
                                            return
                                        }
                                        isStartUp = false
                                    }
                                
                            case "Convert":
                                printHeading(text: item.name, colorCode: 1)
                                printBody(text: "Let us do all the heavy lifting; you may as well take a break", isHeader: true)
                                printBody(text: "Please select the files you would like to convert", isHeader: false)
                                displayConvertElements()
                                    .padding()
                                    .onAppear() {
                                        self.previousViewIndex.addNewIndex(newIndex: 1)
                                    }
                                
                            case "Settings":
                                printHeading(text: item.name, colorCode: 2)
                                printBody(text: "This is where you can tinker with the nitty-gritty of this software", isHeader: true)
                                printBody(text: "Just don't spend too much time here... unless you're a giant nerd like me", isHeader: false)
                                displaySettingsElements()
                                    .padding()
                                    .onAppear() {
                                        self.previousViewIndex.addNewIndex(newIndex: 2)
                                    }
                                
                            default:
                                printHeading(text: item.name, colorCode: 0)
                                printBody(text: "Oops, you're on the wrong page", isHeader: true)
                                printBody(text: "404 Error Occured", isHeader: false)
                            }
                        }
                        .onAppear {
                            footerFadeIn(selection: item.name)
                        }
                        Spacer()
                    }
                }
                .padding(8)
            }
            .padding(2)
        }
        .listStyle(.sidebar)
        // .accentColor(.gray)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack {
                    Button(action: toggleSidebar, label: { // 1
                        Image(systemName: "sidebar.leading")
                    })
                    if previousViewIndex.items.count != 0 && previousViewIndex.items.count != 1 {
                        Button(action: { viewModel.selectedId = viewModel.choices[previousViewIndex.items[previousViewIndex.items.count - 2]].id }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                    else if previousViewIndex.items.count == 1 {
                        Button(action: { viewModel.selectedId = viewModel.choices[0].id }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
        }
        
        // Display the footer
        if showFooter {
            if self.currentSelection != nil {
                Text(self.currentSelection!)
                    .opacity(self.visible ? 1 : 0)
                    .opacity(stateOpacity)
                    .onAppear() {
                        footerFadeOut()
                    }
                    .onChange(of: self.currentSelection) { newValue in
                        footerFadeOut()
                    }
                Spacer()
            }
            else {
                Text("Developed and Designed by John Seong. All Rights Reserved.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
    
    private func toggleSidebar() { // 2
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private func printHeading(text: String, colorCode: Int?) -> some View {
        var color1 = Color.orange // Color scheme for dark mode
        var color2 = Color.blue // Color scheme for light mode
        
        if colorCode == 0 {
            color1 = Color.orange
            color2 = Color.blue
        }
        
        else if colorCode == 1 {
            color1 = Color.yellow
            color2 = Color.pink
        }
        
        else if colorCode == 2 {
            color1 = Color.green
            color2 = Color.purple
        }
        
        return (
            Text(text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? color1 : color2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationTitle(text)
                .padding()
        )
    }
    
    private func printBody(text: String, isHeader: Bool) -> some View {
        Text(text)
            .font(isHeader ? .title : .title2)
            .fontWeight(isHeader ? .regular : .thin)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .padding(.trailing)
    }
    
    private func footerFadeIn(selection: String) {
        self.currentSelection = selection
        self.visible = true
    }
    
    private func footerFadeOut() {
        withAnimation(.linear(duration: 3)) {
            self.visible = false
            self.currentSelection = nil
        }
    }
    
    private func displayHomeElements() -> some View {
        let glyphDict = [
            "Convert": "arrow.left.arrow.right",
            "Settings": "gearshape.fill"
        ]
        return (
            LazyHStack {
                ForEach(viewModel.choices) { item in
                    if item.name != "Home" {
                        Button(action: {
                            if item.name == "Convert" {
                                viewModel.selectedId = viewModel.choices[1].id
                            }
                            else if item.name == "Settings" {
                                viewModel.selectedId = viewModel.choices[2].id
                            }
                        }) {
                            HStack {
                                Image(systemName: glyphDict[item.name] ?? "questionmark")
                                Text("\(item.name)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(10.0)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(lineWidth: 2.0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        )
    }
    
    private func displayConvertElements() -> some View {
        return (
            VStack {
                HStack {
                    Button(action: {
                        let panel = NSOpenPanel()
                        
                        panel.allowsMultipleSelection = true
                        panel.canChooseDirectories = false
                        
                        // If the user selects the files, get their paths and store them...
                        if panel.runModal() == .OK {
                            self.tooManyFilesError = false
                            self.isNotAppError = false
                            
                            for url in panel.urls {
                                if self.previousUrlPath.contains(url.path) == false && url.path.contains(".app") {
                                    self.filename.append(url.path)
                                }
                                else if url.path.contains(".app") {
                                    self.isNotAppError = true
                                }
                                self.previousUrlPath.append(url.path)
                            }
                            print(self.filename)
                            
                            if panel.urls.count > 10 {
                                self.tooManyFilesError = true
                            }
                            // BUG: When files are added individually, tooManyFilesError condition doesn't get applied
                        }
                        
                    }) {
                        HStack {
                            Image(systemName: "questionmark.folder.fill")
                            Text("Select files")
                        }
                        .padding(10.0)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .contentShape(Rectangle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 10.0)
                                .stroke(lineWidth: 2.0)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if self.filename.count != 0 && self.tooManyFilesError == false {
                        Button(action: { print("button") }) {
                            HStack {
                                Image(systemName: "play.rectangle.on.rectangle.fill")
                                Text("Start converting")
                            }
                            .padding(10.0)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .contentShape(Rectangle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(lineWidth: 2.0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            self.filename.removeAll()
                            self.previousUrlPath.removeAll()
                        }) {
                            HStack {
                                Image(systemName: "x.square.fill")
                                Text("Clear queue")
                            }
                            .padding(10.0)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .contentShape(Rectangle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(lineWidth: 2.0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    if self.filename.count != 0 {
                        HStack {
                            Image(systemName: self.tooManyFilesError ? "xmark.octagon.fill" : "checkmark.seal.fill")
                            Text(self.tooManyFilesError ? "Too many files selected; I am not a competitive eater (max. 10 files at once)" : "Selected files")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    if self.tooManyFilesError == false {
                        ScrollView {
                            ForEach(self.filename, id: \.self) { name in
                                Text(name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                        }
                        .frame(maxHeight: 80)
                    }
                }
                .padding(.top)
            }
        )
    }
    
    private func displaySettingsElements() -> some View {
        return (
            VStack {
                HStack {
                    Image(systemName: "sparkles.tv.fill")
                    Text("User interface")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Toggle("Verbose mode", isOn: $verboseMode)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Toggle("Show footer", isOn: $showFooter)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

// For Xcode Preview...
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// CMD + A and then CTRL + I to auto format the code
