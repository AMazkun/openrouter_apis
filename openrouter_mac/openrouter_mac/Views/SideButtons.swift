//
//  SideButtons.swift
//  AI View Test
//
//  Created by admin on 04.05.2025.
//

import SwiftUI

struct SidebarButton: View {
    @EnvironmentObject var charts: AIChartVeiwModel
    let icon: String
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if icon == "paintpalette.fill" {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue, .green, .yellow, .orange, .red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 28, height: 28)
                }
                
                Image(systemName: icon)
                    .foregroundColor(icon == "paintpalette.fill" ? .white : .gray)
                    .font(.system(size: 14))
            }
            
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 14))
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
        .cornerRadius(6)
        .padding(.horizontal, 5)
    }
}

struct ChooseButton: View {
    @EnvironmentObject var charts: AIChartVeiwModel
    let icon: String
    let text: String
    let isSelected: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ZStack {
                    if icon == "paintpalette.fill" {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue, .green, .yellow, .orange, .red]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 28, height: 28)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 28, height: 28)
                    }
                    
                    Image(systemName: icon)
                        .foregroundColor(icon == "paintpalette.fill" ? .white : .gray)
                        .font(.system(size: 14))
                }
                
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                
                Spacer()
            }
                        
            Picker("", selection: $charts.defaultModel) {
                ForEach(availableModels.sorted(by: { $0.key < $1.key }), id: \.value) { name, _ in
                    Text(name)
                        .tag(name)
                }
            }
            .pickerStyle(MenuPickerStyle())

        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
        .cornerRadius(6)
        .padding(.horizontal, 5)
    }
}


#Preview {
        ContentView()
            .environmentObject(mokeConversationModel)
            .preferredColorScheme(.dark)
            .frame(width: 1000, height: 700)
}
