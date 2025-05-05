//
//  SideBar.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var charts: AIChartVeiwModel
    @State var searchText: String = ""
    
    // Function to handle deletion
    func deleteConversation(at id : UUID) {
        charts.conversations.removeAll(where: {$0.id == id})
    }
    
    @ViewBuilder
    func ConversationRow(conversation: Conversation)-> some View {
        HStack(spacing: 12) {
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.aiModel)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formattedDate(conversation.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(conversation.topic)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    var ConversationList: some View {
        // Conversations List
        List {
            ForEach(TimeSection.allCases.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.self) { section in
                if !charts.conversationsForSection(section, searchText: searchText).isEmpty {
                    Section{
                        let sectionCharts = charts.conversationsForSection(section, searchText: searchText)
                        ForEach(sectionCharts) { conversation in
                            let lightup = conversation.id == charts.selectedConversation?.id
                            HStack {
                                ConversationRow(conversation: conversation)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        charts.selectedConversation = conversation
                                    }
                                Button {
                                    deleteConversation(at: conversation.id)
                                } label : {
                                    Image(systemName: "trash")
                                }
                            }
                            .padding(.horizontal, 8)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(lightup ? Color(.blue).opacity(0.2) : .clear)
                            )
                        }
                    } header: {
                        HStack {
                            Text(section.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.top, 12)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        //.scrollContentBackground(.hidden)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.3))
    }
    
    @ViewBuilder
    var UserInfo: some View {
        // User Info
        HStack {
            Circle()
                .fill(Color.white)
                .frame(width: 32, height: 32)
                .overlay(
                    Text("UP")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))
                )
            
            Text("user@pumabrowser.com")
                .foregroundColor(.white)
                .font(.system(size: 13))
                .lineLimit(1)
            
            Spacer()
        }
        .padding(10)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(8)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.3))
            .cornerRadius(6)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            // Model Selection
            VStack(alignment: .leading, spacing: 8) {
                SidebarButton(icon: "paintpalette.fill", text: "Somethig here", isSelected: false)
                ChooseButton(icon: "bubble.left.fill", text: "Choose model", isSelected: true)
            }
            .padding(.vertical, 8)
            
            
            ConversationList
            
            UserInfo
        }
        .frame(width: 260)
        .background(Color(NSColor.darkGray).opacity(0.4))
    }
}

// Preview provider
#Preview {
    ContentView()
        .environmentObject(mokeConversationModel)
        .preferredColorScheme(.dark)
        .frame(width: 1000, height: 700)
}
