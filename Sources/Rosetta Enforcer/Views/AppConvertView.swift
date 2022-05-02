//
//  AppConvertView.swift
//  Rosetta Enforcer
//
//  Created by John Seong on 2022-04-28.
//

import SwiftUI

struct AppConvertView: View {
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
                        
                        Text(" | ")
                    
                        Text(self.fileArchitecture[index]!)
                            .foregroundColor(self.fileArchitecture[index]!.contains("x86_64") && self.fileArchitecture[index]!.contains("arm64") ? Color.green : Color.pink)
                        
                        if self.fileArchitecture[index]!.contains("x86_64") && self.fileArchitecture[index]!.contains("arm64") {
                            Text(" | ")
                            
                            Button(action: {
                                // Write more code here...
                            } ) {
                                HStack {
                                    Text("Convert to ARM")
                                }
                            }
                            .buttonStyle(LinkButtonStyle())
                            
                            Text(" | ")
                            
                            Button(action: {
                                // Write more code here...
                            } ) {
                                HStack {
                                    Text("Convert to Intel")
                                }
                            }
                            .buttonStyle(LinkButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .buttonStyle(PlainButtonStyle())
        .frame(width: 650, alignment: .leading)
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
