//
//  ContentView.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var charts: AIChartVeiwModel
    @State private var messageText = ""
    @State var SideBarShow = true
    @FocusState private var messageIsFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            
            if SideBarShow {
                SidebarView()
            }
            
            Divider()
            
            // Main Chat Area
            VStack(spacing: 0) {
                
                MainChartHeader()
                
                VStack(spacing: 0) {
                    if let conversation = charts.selectedConversation {
                        ChartArea(conversation: conversation)
                        InpurArea(convarsation: conversation)
                    } else {
                        
                        Spacer()
                    }
                }
                .padding()

            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
            Button {
                SideBarShow.toggle()
            } label: {
                    Image(systemName: "sidebar.left")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    // New conversation action
                    charts.newConversation()
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }

    }
}


// Preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(mokeConversationModel)
            .preferredColorScheme(.dark)
            .frame(width: 1000, height: 700)
    }
}
