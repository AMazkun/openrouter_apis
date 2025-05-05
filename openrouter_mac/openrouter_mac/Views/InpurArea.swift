//
//  InputArea.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI
import Cocoa

struct InputArea: View {
    @ObservedObject var conversation: Conversation
    @EnvironmentObject var charts: AIChartVeiwModel
    @State private var addImage: Bool = false
    @State private var showUrl: Bool = false
    @State private var showPicker: Bool = false

    @ViewBuilder
    var buttonPanel: some View {
        HStack(spacing: 12) {
            let imageOn = showUrl || conversation.selectedImage != nil
            if imageOn {
                Button(action: {
                    showUrl = false
                    conversation.imageUrl = ""
                    conversation.selectedImage = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(PlainButtonStyle())

            } else {
                Menu {
                    Button("URL", action: {
                        showUrl = true
                        conversation.imageUrl = ""
                    })
                    Button("Gallery", action: {
                        showPicker = true
                    })
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!conversation.modelAllowImage())
            }
            
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
                conversation.appendQuestion()
                charts.update.toggle()
            }) {
                Image(systemName: "waveform")
                    .resizable()
                    .padding(6)
                    .background(Circle().fill(.background))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(conversation.question.isEmpty)
        }
    }
    
    var body: some View {
        // Input Area
        VStack(spacing: 8) {
            
            TextField("Ask anything...", text: $conversation.question, axis: .vertical)
                .lineLimit(2...10)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    addImage = false
                    conversation.appendQuestion()
                    charts.update.toggle()
                }
            
            VStack(alignment: .leading) {
                let imageUrl = conversation.imageUrl
                if let image = conversation.selectedImage {
                    HStack {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                        Spacer()
                    }
                } else if !imageUrl.isEmpty {
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
                
                if showUrl {
                    TextField("Image URL", text: $conversation.imageUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            buttonPanel
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12.0).fill(Color(NSColor.gray).opacity(0.2)))
        .sheet(isPresented: $showPicker) {
            ImagePickerView() { selection in
                conversation.selectedImage = selection
                showPicker = false
            }
        }
    }
}

// Preview provider
struct InputArea_Previews: PreviewProvider {
    static var previews: some View {
        InputArea(conversation: mokeConversation)
            .environmentObject(mokeConversationModel)
            .preferredColorScheme(.dark)
            .frame(width: 1000, height: 200)
    }
}
