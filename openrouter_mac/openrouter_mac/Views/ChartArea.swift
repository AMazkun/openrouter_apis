//
//  ChartArea.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI
struct HUMessageView: View {
    @EnvironmentObject var charts: AIChartVeiwModel
    let message: Message
    @State var showCopyPopup: Bool = false
    
    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                Spacer()
                
                // Message bubble
                VStack (alignment: .trailing){
                    Text(message.content)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            showCopyPopup = true
                            charts.copyToChartClipboard(message: message)
                            
                            // Auto-hide popup after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                charts.update.toggle()
                                showCopyPopup = false
                            }
                        }
                    
                    if let image = message.selectedImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                    } else if let imageUrl = message.imageUrl, !imageUrl.isEmpty {
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
                    
                    Text(formattedTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                }
                // Avatar
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title)
                    .padding(.leading, -8)
                
            }
            
            if(showCopyPopup) {
                Text("Question copied!")
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
            }
        }
    }
}

struct AIMessageView: View {
    @ObservedObject var conversation : Conversation
    let content: String
    let timestamp : Date?
    
    @State var showCopyPopup: Bool = false

    
    var body: some View {
        ZStack{
            HStack(alignment: .top) {
                // Avatar
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
                    .font(.title)
                    .padding(.trailing, -8)
                
                if content.isEmpty {
                    ProgressView()
                        .padding(.leading)
                        .padding(.bottom)
                } else {
                    // Message bubble
                    VStack(alignment: .leading) {
                        
                        Text(content)
                            .padding()
                            .background(Color.indigo.opacity(0.2))
                            .cornerRadius(12)
                        if let timestamp {
                            Text(formattedTime(timestamp))
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) {
                        showCopyPopup = true
                        setPasteboardString(content)
                        
                        // Auto-hide popup after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopyPopup = false
                        }
                    }

                }
                Spacer()
            }
            if(showCopyPopup) {
                Text("Answer copied to clipboard!")
                    .padding()
                    .background(Color.indigo.opacity(0.2))
                    .cornerRadius(12)
            }
        }
    }
}

struct ChartArea: View {
    @EnvironmentObject var charts: AIChartVeiwModel
    @ObservedObject var conversation: Conversation
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false
    @State private var typingText: String = ""
    @State private var aiResponseVisible: Bool = true
    @State private var currentIndex: Int = 0
    @State private var typingTimer: Timer? = nil
    @State private var waitingAnswer: Bool = false
    
    var body: some View {
        // Chat Area (Empty in this example)
        // Chat messages history
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(conversation.messages) { message in
                            if message.role == .user {
                                HUMessageView(message: message)
                                    .id(message.id)
                            } else {
                                AIMessageView(conversation: conversation, content: message.content, timestamp:  message.timestamp)
                                    .id(message.id)
                            }
                        }
                        
                        // AI typing indicator (moved above the chat history for visibility)
                        if isTyping {
                            AIMessageView(conversation: conversation, content: typingText, timestamp: nil)
                                .id(1)
                        }
                        if waitingAnswer {
                            AIMessageView(conversation: conversation, content: "", timestamp: nil)
                                .id(1)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .background(.background)
                .cornerRadius(12)
                .onChange(of: typingText) {
                    withAnimation {
                        scrollViewProxy.scrollTo(1, anchor: .bottom)
                    }
                }
                .onChange(of: waitingAnswer) {
                    withAnimation {
                        scrollViewProxy.scrollTo(1, anchor: .bottom)
                    }
                }
                .onChange(of: conversation.messages.count) {
                    // Scroll to the last message when a new one is added
                    if let lastMessageID = conversation.lastId() {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessageID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: conversation.requestSent) {
                    waitingAnswer = true
                }
                .onChange(of: conversation.answer) {
                    presentAnswer()
                }
                .onAppear() {
                    if let lastMessageID = conversation.lastId() {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessageID, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func presentAnswer() {
        guard let _ = conversation.answer else { return }

        // Simulate AI typing
        isTyping = true
        currentIndex = 0
        typingText = ""
        waitingAnswer = false

        // Scroll to ensure typing indicator is visible
        aiResponseVisible = true
        
        simulateNaturalTyping()
    }
    
    func simulateNaturalTyping() {
        // Cancel any existing timer
        guard let answer = conversation.answer else { return }
        
        typingTimer?.invalidate()
        
        // If we've reached the end of the response
        if currentIndex >= answer.count {
            isTyping = false
            // Reset for next interaction
            conversation.appendAnswer()
            charts.redraw()
            typingText = ""
            
            return
        }
        
        // Generate a random typing interval between 0.01 and 0.15 seconds
        // This creates a more natural typing rhythm with variable speeds
        let baseInterval = Double.random(in: 0.01...0.02)
        
        // Add "thinking" time for punctuation or new sentences
        var interval = baseInterval
        if currentIndex > 0 {
            let currentChar = answer[answer.index(answer.startIndex, offsetBy: currentIndex - 1)]
            
            // Longer pauses after sentence-ending punctuation
            if ".!?".contains(currentChar) {
                interval = Double.random(in: 0.05...0.1) // Longer pause after sentences
            }
            // Medium pauses after commas, semicolons, etc.
            else if ",;:".contains(currentChar) {
                interval = Double.random(in: 0.03...0.05) // Medium pause after commas, etc.
            }
            // Slight pauses before certain conjunctions or at logical breaks - safely check substring
            else if currentIndex > 3 {
                // Safely extract substring for checking conjunctions
                let endIndex = answer.index(answer.startIndex, offsetBy: currentIndex)
                
                // Check for " and" with safe substring (if we have enough characters)
                if currentIndex >= 4 {
                    let andStartIndex = answer.index(endIndex, offsetBy: -4)
                    let andSubstring = answer[andStartIndex..<endIndex]
                    if andSubstring.hasSuffix(" and") {
                        interval = Double.random(in: 0.03...0.04)
                    }
                }
                
                // Check for " but" with safe substring (if we have enough characters)
                if currentIndex >= 4 {
                    let butStartIndex = answer.index(endIndex, offsetBy: -4)
                    let butSubstring = answer[butStartIndex..<endIndex]
                    if butSubstring.hasSuffix(" but") {
                        interval = Double.random(in: 0.04...0.06)
                    }
                }
                
                // Check for " or" with safe substring (if we have enough characters)
                if currentIndex >= 3 {
                    let orStartIndex = answer.index(endIndex, offsetBy: -3)
                    let orSubstring = answer[orStartIndex..<endIndex]
                    if orSubstring.hasSuffix(" or") {
                        interval = Double.random(in: 0.05...0.07)
                    }
                }
            }
        }
        
        // Sometimes add a brief "thinking" pause randomly (simulates human thinking)
        if Int.random(in: 1...100) <= 5 { // 5% chance of a random thinking pause
            interval = Double.random(in: 0.05...0.2)
        }
        
        // Schedule the next character after the calculated interval
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if self.currentIndex < answer.count {
                self.typingText += String(answer[answer.index(answer.startIndex, offsetBy: self.currentIndex)])
                self.currentIndex += 1
                self.simulateNaturalTyping() // Recursively continue typing
            }
        }
    }
    
    func resumeTyping() {
        simulateNaturalTyping()
    }
    
}

#Preview {
    ChartArea(conversation: mokeConversation)
        .environmentObject(mokeConversationModel)
}
