//
//  InpurArea.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI
import Cocoa

struct InpurArea: View {
    @ObservedObject var convarsation: Conversation
    @EnvironmentObject var charts: AIChartVeiwModel
    @State var addImage: Bool = false
    
    @ViewBuilder
    var button_panel: some View {
        HStack (spacing: 12) {
            Button(action: {
                addImage.toggle()
                convarsation.imageUrl = ""
            }) {
                Image(systemName: addImage ? "xmark.circle.fill" : "plus")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!convarsation.modelAllowImage())
            
            Button(action: {}) {
                Image(systemName: "globe")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(true)

            Button(action: {}) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(true)

            Button(action: {}) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(true)

            Spacer()
            
            Button(action: {}) {
                Image(systemName: "mic")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(true)

            Button(action: {
                addImage = false
                convarsation.appendQuestion()
                charts.update.toggle()
            }) {
                Image(systemName: "waveform")
                    .resizable()
                    .padding(6)
                    .background(Circle().fill(.background))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(convarsation.question.isEmpty)
        }
    }
    
    var body: some View {
        // Input Area
        VStack(spacing: 8) {
            
            TextField("Ask anything...", text: $convarsation.question, axis: .vertical)
                .lineLimit(2...10)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    addImage = false
                    convarsation.appendQuestion()
                    charts.update.toggle()
                }
            
            VStack (alignment: .leading) {
                let imageUrl = convarsation.imageUrl
                if !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 100)
                    }
                }
                
                if addImage {
                    TextField("Image URL", text: $convarsation.imageUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            button_panel
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12.0).fill(Color(NSColor.gray).opacity(0.6)))
    }
}

// Preview provider
struct ContentView1_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(mokeConversationModel)
            .preferredColorScheme(.dark)
            .frame(width: 1000, height: 700)
    }
}
