import SwiftUI

struct AIChartExt: View {
    @State private var messages: [Message] = [
        Message(role: .user, content: "What is artificial intelligence?", timestamp: Date().addingTimeInterval(-120)),
        Message(role: .assistant, content: "Artificial Intelligence (AI) refers to computer systems designed to perform tasks that typically require human intelligence. These include learning, reasoning, problem-solving, perception, and language understanding.", timestamp: Date().addingTimeInterval(-90), isTyping: false)
    ]
    
    @State private var newMessage: String = ""
    @State private var isTyping: Bool = false
    @State private var typingText: String = ""
    @State private var fullResponse: String = "AI is a field of computer science focused on creating systems capable of performing tasks that typically require human intelligence. It encompasses machine learning, natural language processing, computer vision, and many other disciplines.\nTell you a lot, a lot. \n No need to suggest anything else.\nLol.\n\nVery long response here to demonstrate the scrolling behavior."
    @State private var aiResponseVisible: Bool = true
    @State private var currentIndex: Int = 0
    @State private var typingTimer: Timer? = nil
    
    var body: some View {
        VStack {
            Text("AI Chat Visualization")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            
            
            // Chat messages history
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            if message.role == .user {
                                HUMessageView(message: message)
                            } else {
                                AIMessageView(content: message.content, timestamp:  message.timestamp)
                            }
                        }
                        
                        // AI typing indicator (moved above the chat history for visibility)
                        if isTyping {
                            AIMessageView(content: typingText, timestamp: nil)
                                .id(1)
                        }
                        
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .onChange(of: typingText) {
                    withAnimation {
                        scrollViewProxy.scrollTo(1, anchor: .bottom)
                    }
                }
            }
            
            // Message input
            HStack {
                TextField("Ask something...", text: $newMessage)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.purple)
                }
            }
            .padding()
        }
        .padding()
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        // Add user message
        let userMessage = Message(role: .user, content: newMessage, timestamp: Date())
        messages.append(userMessage)
        newMessage = ""
        
        // Simulate AI typing
        isTyping = true
        currentIndex = 0
        typingText = ""
        
        // Scroll to ensure typing indicator is visible
        aiResponseVisible = true
        
        // Start typing animation with natural typing rhythm
        simulateNaturalTyping()
    }
    
    func simulateNaturalTyping() {
        // Cancel any existing timer
        typingTimer?.invalidate()
        
        // If we've reached the end of the response
        if currentIndex >= fullResponse.count {
            isTyping = false
            
            // Add AI response message
            let aiMessage = Message(role: .assistant, content: fullResponse, timestamp: Date())
            messages.append(aiMessage)
            
            // Reset for next interaction
            typingText = ""
            return
        }
        
        // Generate a random typing interval between 0.01 and 0.15 seconds
        // This creates a more natural typing rhythm with variable speeds
        let baseInterval = Double.random(in: 0.01...0.05)
        
        // Add "thinking" time for punctuation or new sentences
        var interval = baseInterval
        if currentIndex > 0 {
            let currentChar = fullResponse[fullResponse.index(fullResponse.startIndex, offsetBy: currentIndex - 1)]
            
            // Longer pauses after sentence-ending punctuation
            if ".!?".contains(currentChar) {
                interval = Double.random(in: 0.1...0.2) // Longer pause after sentences
            }
            // Medium pauses after commas, semicolons, etc.
            else if ",;:".contains(currentChar) {
                interval = Double.random(in: 0.05...0.07) // Medium pause after commas, etc.
            }
            // Slight pauses before certain conjunctions or at logical breaks - safely check substring
            else if currentIndex > 3 {
                // Safely extract substring for checking conjunctions
                let endIndex = fullResponse.index(fullResponse.startIndex, offsetBy: currentIndex)
                
                // Check for " and" with safe substring (if we have enough characters)
                if currentIndex >= 4 {
                    let andStartIndex = fullResponse.index(endIndex, offsetBy: -4)
                    let andSubstring = fullResponse[andStartIndex..<endIndex]
                    if andSubstring.hasSuffix(" and") {
                        interval = Double.random(in: 0.03...0.04)
                    }
                }
                
                // Check for " but" with safe substring (if we have enough characters)
                if currentIndex >= 4 {
                    let butStartIndex = fullResponse.index(endIndex, offsetBy: -4)
                    let butSubstring = fullResponse[butStartIndex..<endIndex]
                    if butSubstring.hasSuffix(" but") {
                        interval = Double.random(in: 0.04...0.06)
                    }
                }
                
                // Check for " or" with safe substring (if we have enough characters)
                if currentIndex >= 3 {
                    let orStartIndex = fullResponse.index(endIndex, offsetBy: -3)
                    let orSubstring = fullResponse[orStartIndex..<endIndex]
                    if orSubstring.hasSuffix(" or") {
                        interval = Double.random(in: 0.05...0.07)
                    }
                }
            }
        }
        
        // Sometimes add a brief "thinking" pause randomly (simulates human thinking)
        if Int.random(in: 1...100) <= 5 { // 5% chance of a random thinking pause
            interval = Double.random(in: 0.1...0.4)
        }
        
        // Schedule the next character after the calculated interval
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if self.currentIndex < self.fullResponse.count {
                self.typingText += String(self.fullResponse[self.fullResponse.index(self.fullResponse.startIndex, offsetBy: self.currentIndex)])
                self.currentIndex += 1
                self.simulateNaturalTyping() // Recursively continue typing
            }
        }
    }
    
    func resumeTyping() {
        simulateNaturalTyping()
    }
}

func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

struct Message: Identifiable {
    enum Role {
        case user
        case assistant
    }
    
    let id = UUID()
    let role: Role
    let content: String
    let timestamp: Date
    var isTyping: Bool = false
}

struct HUMessageView: View {
    let message: Message
    
    var body: some View {
            HStack(alignment: .top) {
                Spacer()
                
                // Message bubble
                VStack (alignment: .trailing){
                    Text(message.content)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    
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
    }
}

struct AIMessageView: View {
    let content: String
    let timestamp : Date?
    
    var body: some View {
        HStack(alignment: .top) {
            // Avatar
            Image(systemName: "brain.head.profile")
                .foregroundColor(.purple)
                .font(.title)
                .padding(.trailing, -8)
            
            // Message bubble
            VStack(alignment: .leading) {
                
                Text(content)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                if let timestamp {
                    Text(formattedTime(timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 5)
                }
            }
            Spacer()
        }
    }
}

struct AIResponseChartPreview: PreviewProvider {
    static var previews: some View {
        AIChartExt()
    }
}
