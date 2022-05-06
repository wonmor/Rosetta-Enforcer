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

// Unless using class-specific features, struct is the default go-to in Swift
struct ContentView: View {
    @State var stateOpacity = 1.0
    @State var currentSelection: String? = nil
    
    @State public var isConvertOptions = false
    
    @State private var visible: Bool = false
    @State private var isStartUp: Bool = true
    
    @State var filePath = [String]()
    @State var fileName = [String]()
    @State var fileArchitecture = [String?]()
    @State var previousUrlPath = [String]()
    
    @State var tooManyFilesError = false
    @State var isNotAppError = false
    @State var isFooterHidden = true
    
    @AppStorage("showFooter") var showFooter: Bool = true
    @AppStorage("verboseMode") var verboseMode: Bool = true
    
    // Detect whether OS is on dark mode or light mode
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel = ViewModel()
    @StateObject var previousViewModel = PreviousViewModel()
    
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
                                            self.previousViewModel.addNewIndex(newIndex: 0)
                                            return
                                        }
                                        isStartUp = false
                                    }
                                    .onChange(of: item.name) { newValue in
                                        guard isStartUp else {
                                            self.previousViewModel.addNewIndex(newIndex: 0)
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
                                        self.previousViewModel.addNewIndex(newIndex: 1)
                                    }
                                    .onChange(of: item.name) { newValue in
                                        self.previousViewModel.addNewIndex(newIndex: 1)
                                    }
                                
                            case "Settings":
                                printHeading(text: item.name, colorCode: 2)
                                printBody(text: "This is where you can tinker with the nitty-gritty of this software", isHeader: true)
                                printBody(text: "Just don't spend too much time here... unless you're a giant nerd like me", isHeader: false)
                                displaySettingsElements()
                                    .padding()
                                    .onAppear() {
                                        self.previousViewModel.addNewIndex(newIndex: 2)
                                    }
                                    .onChange(of: item.name) { newValue in
                                        self.previousViewModel.addNewIndex(newIndex: 2)
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
                    if previousViewModel.items.count != 0 && previousViewModel.items.count != 1 {
                        Button(action: { viewModel.selectedId = viewModel.choices[previousViewModel.items[previousViewModel.items.count - 2]].id }) {
                            Image(systemName: "chevron.left")
                        }
                    }
                    else if previousViewModel.items.count == 1 {
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
                    .padding(.bottom, 8)
                    .onAppear() {
                        footerFadeOut()
                    }
                    .onChange(of: self.currentSelection) { newValue in
                        footerFadeOut()
                    }
            }
            else {
                Text("Developed and Designed by John Seong. All Rights Reserved.")
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
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
            LazyVStack {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // TEMPORARY ADDITION TO THE CODE - START
                
                ZStack {
                    if colorScheme == .dark {
                        Color(white: 255)
                    }
                    else {
                        Color(red: 0, green: 0, blue: 0)
                    }
                    
                    VStack {
                        Text("Currently in the development phase")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .padding(.top)
                            .padding(.bottom, 5)
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        Text("Please note that some of the features might not work as intended. The Universal to Single Architecture conversion, in particular: if you have already clicked either the \"Convert to ARM\" or \"Convert to Intel\" button, assume that the conversion process is done although no alert message shows up following by. ")
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                
                // TEMPORARY ADDITION TO THE CODE - END
                
            }
        )
    }
    
    private func displayConvertElements() -> some View {
        return (
            VStack {
                HStack {
                    Button(action: {
                        let panel = NSOpenPanel()
                        
                        var file: ConvertModel
                        
                        panel.allowsMultipleSelection = true
                        panel.canChooseDirectories = false
                        
                        // When tooManyFilesError is trigged, on button click followed after, remove all previous file selections and disable the error (clearing up)
                        if self.tooManyFilesError {
                            removeAllFileSelections()
                            
                            self.tooManyFilesError = false
                            self.isNotAppError = false
                        }
                        
                        // If the user selects the files, get their paths and store them...
                        if panel.runModal() == .OK {
                            self.tooManyFilesError = false
                            self.isNotAppError = false
                            
                            for url in panel.urls {
                                if self.previousUrlPath.contains(url.path) == false && url.lastPathComponent.contains(".app") {
                                    self.filePath.append(url.path)
                                    
                                    // self.fileName.append(url.lastPathComponent)
                                    self.fileName.append(url.deletingPathExtension().lastPathComponent) // Filename without extension as it is obvious that it ends with .app
                                    
                                    file = ConvertModel(fileName: url.deletingPathExtension().lastPathComponent, filePath: url.path)
                                    
                                    self.fileArchitecture.append(file.runLipoCommand(commandState: .CheckArchitecture) ?? nil)
                                    
                                    // This line limits the max. file count to 10...
                                    if self.filePath.count > 10 {
                                        self.tooManyFilesError = true
                                    }
                                }
                                else if url.path.contains(".app") {
                                    self.isNotAppError = true
                                }
                                self.previousUrlPath.append(url.path)
                            }
                        }
                        
                    }) {
                        HStack {
                            Image(systemName: self.tooManyFilesError ? "x.square.fill" : "questionmark.folder.fill")
                            Text(self.tooManyFilesError ? "Clear queue and reselect files" : "Select files")
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
                    
                    if self.filePath.count != 0 && self.tooManyFilesError == false {
                        Button(action: { self.isConvertOptions = true }
                        ) {
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
                        .sheet(isPresented: $isConvertOptions, content: {
                            AppConvertView(isConvertOptions: $isConvertOptions, fileName: $fileName, filePath: $filePath, fileArchitecture: $fileArchitecture)
                        })
                        
                        Button(action: {
                            removeAllFileSelections()
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
                    if self.filePath.count != 0 {
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
                            ForEach(Array(zip(self.filePath.indices, self.filePath)), id: \.0) { index, name in
                                LazyHStack(alignment: .center) {
                                    Text("\(index + 1). \(name)")
                                        .foregroundColor(Color.gray)
                                    
                                    Text(self.fileArchitecture[index]!)
                                        .foregroundColor(self.fileArchitecture[index]!.contains("x86_64") && self.fileArchitecture[index]!.contains("arm64") ? Color.green : Color.pink)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 80)
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
                    .padding(.bottom)
                
                VStack {
                    Text("Licensed under BSD-2-Clause")
                        .font(.title)
                        .fontWeight(.thin)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Link("Source Code", destination: URL(string: "https://github.com/wonmor/Rosetta-Enforcer")!)
                            .font(.title3)
                        
                        Text(" | ")
                        
                        Link("Developer's Website", destination: URL(string: "https://johnseong.info")!)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 2.0)
                )
            }
        )
    }
    
    func removeAllFileSelections() {
        self.filePath.removeAll()
        self.fileName.removeAll()
        self.fileArchitecture.removeAll()
        self.previousUrlPath.removeAll()
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var isConvertOptions = true
    
    static var previews: some View {
        ContentView()
    }
}

// CMD + A and then CTRL + I to auto format the code
