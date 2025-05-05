//
//  MainChartHeader.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI

struct MainChartHeader: View {
    @EnvironmentObject var conversations: AIChartVeiwModel
    var body: some View {
        VStack(alignment: .leading){
            // Header
            HStack {
                let aiModel = conversations.selectedConversation?.aiModel ?? "No AI Model"
                Text(aiModel)
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
                Button(action: {}) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.gray)
                }
            }

            let topic = conversations.selectedConversation?.topic ?? ""
            Text(topic)
        }
        .padding(.horizontal)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.2))
    }
}

#Preview {
    MainChartHeader()
        .environmentObject(mokeConversationModel)
}
