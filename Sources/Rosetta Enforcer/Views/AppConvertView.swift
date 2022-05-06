//
//  AppConvertView.swift
//  Rosetta Enforcer
//
//  Created by John Seong on 2022-04-28.
//

import SwiftUI

struct AppConvertView: View {
    @State var fileReturnValues = Array<String>(repeating: "", count: 30)
    // Make sure you add a method that resets the fileReturnValues array!
    @State var convertingInProgress = Array<Bool>(repeating: false, count: 30)
    @State var convertingCompleted = Array<Bool>(repeating: false, count: 30)
    
    @State var previousIndex: Int = 0
    @State var requestTimeOut: Bool = false
    
    @Binding var isConvertOptions: Bool
    @Binding var fileName: [String]
    @Binding var filePath: [String]
    @Binding var fileArchitecture: [String?]
    
    // Detect whether OS is on dark mode or light mode
    @Environment(\.colorScheme) var colorScheme
    
    init(isConvertOptions: Binding<Bool>, fileName: Binding<[String]>, filePath: Binding<[String]>, fileArchitecture: Binding<[String?]>) {
        self._isConvertOptions = isConvertOptions
        self._fileName = fileName
        self._filePath = filePath
        self._fileArchitecture = fileArchitecture
    }
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            Button(action: { isConvertOptions = false }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                        .font(.title3)
                }
                .padding(8)
                .contentShape(Rectangle())
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(lineWidth: 2.0)
                )
            }
            
            HStack {
                Text("Convert")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.gray)
                
                Text("Options")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            ScrollView {
                ForEach(Array(zip(self.filePath.indices, self.filePath)), id: \.0) { index, name in
                    LazyHStack(alignment: .center) {
                        Text("\(index + 1). \(name)")
                            .foregroundColor(Color.gray)
                        
                        // Remove this section?
                        if !self.convertingInProgress[index] && !self.convertingCompleted[index] {
                            Text(" | ")
                            
                            displayArchitecture(index: index)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onAppear() {
                                    print("Running displayArchitecture method...")
                                }
                        }
                        
                        if !self.convertingInProgress[index] && !self.convertingCompleted[index] {
                            if self.fileArchitecture[index]!.contains("x86_64") && self.fileArchitecture[index]!.contains("arm64") {
                                Text(" | ")
                                    .onAppear() {
                                        self.fileReturnValues[index] = ""
                                    }
                                
                                Button(action: {
                                    startConversion(fileName: name, filePath: self.filePath[index], index: index, commandState: .UniversalToArm)
                                } ) {
                                    HStack {
                                        Text("Convert to ARM")
                                    }
                                }
                                .buttonStyle(LinkButtonStyle())
                                
                                Text(" | ")
                                    .onAppear() {
                                        // Make the array's size dynamic...
                                        let currentIndex = (index + 1) % 30
                                        
                                        if currentIndex == 0 && self.previousIndex != currentIndex {
                                            self.fileReturnValues.append(contentsOf: repeatElement("", count: 30))
                                            self.convertingInProgress.append(contentsOf: repeatElement(false, count: 30))
                                            self.convertingCompleted.append(contentsOf: repeatElement(false, count: 30))
                                            
                                            self.previousIndex = currentIndex
                                        }
                                        self.fileReturnValues[index] = ""
                                    }
                                
                                Button(action: {
                                    startConversion(fileName: name, filePath: self.filePath[index], index: index, commandState: .UniversalToIntel)
                                } ) {
                                    HStack {
                                        Text("Convert to Intel")
                                    }
                                }
                                .buttonStyle(LinkButtonStyle())
                            }
                        }
                        
                        if self.convertingInProgress[index] {
                            Text(" | ")
                            
                            Text("Converting in progress...")
                        }
                        
                        // Update the architecture label when the converting process is completed...
                        if self.convertingCompleted[index] {
                            Text(" | ")
                                .onAppear() {
                                    let file = ConvertModel(fileName: name, filePath: self.filePath[index])
                                    self.fileArchitecture[index] = file.runLipoCommand(commandState: .CheckArchitecture) ?? ""
                                }
                            
                            if !(self.fileArchitecture[index]?.isEmpty ?? false) {
                                Text(self.fileArchitecture[index]!)
                                    .foregroundColor(self.fileArchitecture[index]!.contains("x86_64") && self.fileArchitecture[index]!.contains("arm64") ? Color.green : Color.pink)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .buttonStyle(PlainButtonStyle())
        .frame(width: 800, alignment: .leading)
    }
    
    private func displayArchitecture(index: Int) -> some View {
        return (
            HStack {
                Text(self.fileArchitecture[index]!)
                    .foregroundColor(self.fileArchitecture[index]!.contains("x86_64") && self.fileArchitecture[index]!.contains("arm64") ? Color.green : Color.pink)
            }
        )
    }
    
    private func startConversion(fileName: String, filePath: String, index: Int, commandState: LipoCommands) {
        // Semaphore allows the asyncronous thread to be temporarily frozen (deadlock) while the task is still running...
        // let semaphore = DispatchSemaphore(value: 0)
        
        self.convertingCompleted[index] = false
        self.convertingInProgress[index] = true
        
        print("Swift Concurrency has started...")
        
        let conversionHelper = ConversionHelper()
        
        // Implemented the recently released Swift Concurrency...
        Task {
            let startTime = DispatchTime.now()
            
            // Wait until the conversion process is finished up to 20 seconds... (Models returns a non-nil value)
            while self.fileReturnValues[index].isEmpty || self.fileReturnValues[index].contains("Fatal Error") {
                self.fileReturnValues[index] = await conversionHelper.universalToSingle(fileName: fileName, filePath: filePath, index: index, commandState: commandState) ?? ""
                
                let thisTime = DispatchTime.now()
                let deltaNanoSeconds = thisTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                let deltaTime = Double(deltaNanoSeconds) / 1_000_000_000 // deltaTime in seconds
                
                // If the time elapsed is longer than 3 seconds...
                if deltaTime >= 3.0 {
                    self.requestTimeOut = true
                    break
                }
                // The above part of code has to be more optimized...
            }
            print("Within async task - self.fileReturnValue: \(self.fileReturnValues[index])")
            
            Task { @MainActor in
                self.convertingCompleted[index] = true
                self.convertingInProgress[index] = false
            }
            // semaphore.signal()
        }
        // semaphore.wait()
        
        resetTheFileArchitectureArray(fileName: fileName, filePath: filePath, index: index)
    }
    
    private func resetTheFileArchitectureArray(fileName: String, filePath: String, index: Int) {
        print("Resetting the file architecture array...")
        
        let file = ConvertModel(fileName: fileName, filePath: filePath)
        
        self.fileArchitecture[index] = file.runLipoCommand(commandState: .CheckArchitecture) ?? ""
    }
}

// If the goal is to run slow code in the background, use an actor. Then you can cleanly call an actor method with await.

actor ConversionHelper {
    func universalToSingle(fileName: String, filePath: String, index: Int, commandState: LipoCommands) async -> String? {
        let file = ConvertModel(fileName: fileName, filePath: filePath)
        
        return file.runLipoCommand(commandState: commandState) ?? ""
    }
}

extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}

struct AppConvertView_Previews: PreviewProvider {
    @State static var isConvertOptions = true
    
    static var previews: some View {
        ContentView()
    }
}
