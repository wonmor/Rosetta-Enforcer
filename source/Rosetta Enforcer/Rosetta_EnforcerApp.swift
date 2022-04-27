//
//  Rosetta_EnforcerApp.swift
//  Rosetta Enforcer
//
//  Created by John Seong on 2022-04-07.
//

import SwiftUI

@main
struct Rosetta_EnforcerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            SidebarCommands() // 1
        }
    }
}
