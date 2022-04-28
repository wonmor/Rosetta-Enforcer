//
//  AppConvertView.swift
//  Rosetta Enforcer
//
//  Created by John Seong on 2022-04-28.
//

import SwiftUI

struct AppConvertView: View {
    @Binding var isConvertOptions: Bool
    @Binding var filePath: [String]
    @Binding var fileArchitecture: [String?]
    
    init(isConvertOptions: Binding<Bool>, filePath: Binding<[String]>, fileArchitecture: Binding<[String?]>) {
        self._isConvertOptions = isConvertOptions
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
            
            Text("Convert Options")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            ScrollView {
                ForEach(Array(zip(self.filePath.indices, self.filePath)), id: \.0) { index, name in
                    LazyHStack(alignment: .center) {
                        Text("\(index + 1). \(name)")
                        
                        Text(self.fileArchitecture[index]!)
                            .foregroundColor(self.fileArchitecture[index]!.contains("x86_64") && self.fileArchitecture[index]!.contains("arm64") ? Color.green : Color.red)
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
