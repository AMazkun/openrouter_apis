//
//  openrouter_mac.swift
//  openrouter_mac
//
//  Created by admin on 05.05.2025.
//

import SwiftUI

@main
struct openrouter_mac: App {
    @StateObject private var conversation = AIChartVeiwModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .preferredColorScheme(.dark)
                .environmentObject(conversation)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
