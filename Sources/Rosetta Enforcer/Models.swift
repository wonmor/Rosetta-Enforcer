//
//  Models.swift
//  Rosetta Enforcer
//
//  Created by John Seong on 2022-04-26.
//
//  ENTITLEMENT FILE WAS MODIFIED DURING THE BUILD FIX: https://stackoverflow.com/questions/55456335/entitlements-file-was-modified-during-the-build-which-is-not-supported

import Foundation

enum LipoCommands {
    case CheckArchitecture, UniversalToArm, UniversalToIntel
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
final class PreviousViewModel: ObservableObject {
    @Published var items = [Int]()
    
    func addNewIndex(newIndex: Int) {
        guard items.count <= 10 else {
            items.removeAll()
            items.append(newIndex)
            return
        }
        items += [newIndex]
        
        // Back button does not work properly for some reason; fix it!
    }
}

final class ConvertModel: ObservableObject {
    init(fileName: String, filePath: String) {
        // Any blank spaces without backslashes in the path will trigger a fatal error while performing the lipo command
        self.fileName = fileName.replacing(target: " ", withString: "\\ ")
        self.filePath = filePath.replacing(target: " ", withString: "\\ ")
        
        self.isConvertError = false
    }
    
    @Published var fileName: String
    @Published var filePath: String
    
    @Published var isConvertError: Bool
    
    func runLipoCommand(commandState: LipoCommands) -> String? {
        var commandToRun: String
        var addExtraRemark: Bool
        
        switch commandState {
        case .CheckArchitecture:
            commandToRun = "lipo -archs"
            addExtraRemark = false
        case .UniversalToArm:
            commandToRun = "lipo -remove x86_64"
            addExtraRemark = true
        case .UniversalToIntel:
            commandToRun = "lipo -remove arm64"
            addExtraRemark = true
        }
        
        do {
            var returnValue: String
            
            if !addExtraRemark {
                returnValue = try ConvertModel.safeShell("\(commandToRun) \(self.filePath)/Contents/MacOS/\(self.fileName)")
                
                print("----------")
                print("\(self.fileName): \(returnValue)")
            }
            
            else {
                returnValue = try ConvertModel.safeShell("\(commandToRun) \(self.filePath)/Contents/MacOS/\(self.fileName) -output \(self.filePath)/Contents/MacOS/\(self.fileName)" )
            }
            
            // If the .exec file name is different from the .app name...
            if returnValue.contains("FATAL ERROR") {
                print("Exception running...")
                
                var revisedFileName = try ConvertModel.safeShell("cd \(self.filePath)/Contents/MacOS && find . -mindepth 1 -print -quit")
                
                // Remove ./ and both leading & ending whitespaces
                revisedFileName = revisedFileName.replacing(target: "./", withString: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("Revised file name: \(revisedFileName)")
                
                if !addExtraRemark {
                    return try ConvertModel.safeShell("\(commandToRun) \(self.filePath)/Contents/MacOS/\(revisedFileName)").trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                else {
                    return try ConvertModel.safeShell("\(commandToRun) \(self.filePath)/Contents/MacOS/\(revisedFileName) -output \(self.filePath)/Contents/MacOS/\(revisedFileName)").trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            else {
                print("Reformatted returnValue: \(returnValue.trimmingCharacters(in: .whitespacesAndNewlines))")
                
                print(returnValue)
                
                return returnValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        catch {
            isConvertError = true
            return nil
        }
    }
    
    static func safeShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output.contains("error") ? "FATAL ERROR: .EXEC FILE NOT FOUND" : output
    }
}

extension String
{
    func replacing(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
