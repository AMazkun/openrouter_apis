//
//  ConversationViewModel.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import Foundation
import SwiftUI

let openRouterApiKey = "<YOU API KEY HERE>"

struct ModelOption: Identifiable, Hashable {
    var id: String
    var supportImage: Bool
}

let theDefaultModel: String = "Llama-4-maverick"

let availableModels: [String: ModelOption] = [
    "Llama-4-maverick": ModelOption(id: "meta-llama/llama-4-maverick:free", supportImage: true),
    "Llama-3.2-11b-vision-instruct": ModelOption(id: "meta-llama/llama-3.2-11b-vision-instruct:free", supportImage: true),
    "Qwen3-235B": ModelOption(id: "qwen/qwen3-235b-a22b", supportImage: false),
    "Qwen2.5-vl-72b-instruct": ModelOption(id: "qwen/qwen2.5-vl-72b-instruct:free", supportImage: true),
    "Mistral-small-3.1-24b-instruct": ModelOption(id: "mistralai/mistral-small-3.1-24b-instruct:free", supportImage: true),
    "google/gemini-2.0-flash": ModelOption(id: "google/gemini-2.0-flash-exp:free", supportImage: true),
    "google/gemma-3-4b": ModelOption(id: "google/gemma-3-4b-it:free", supportImage: true),
    "$ Claude 3.7 Sonnet": ModelOption(id: "anthropic/claude-3.7-sonnet", supportImage: true),
    "$ google/gemini-2.5-pro-exp": ModelOption(id: "google/gemini-2.5-pro-exp-03-25", supportImage: true),
    "$ GPT-4.1": ModelOption(id: "openai/gpt-4.1", supportImage: true)
]

let mokeLongAnswers: [String] = [
    "AI is a field of computer science focused on creating systems capable of performing tasks that typically require human intelligence. It encompasses machine learning, natural language processing, computer vision, and many other disciplines.\nTell you a lot, a lot. \n No need to suggest anything else.\nLol.\n\nVery long response here to demonstrate the scrolling behavior.",
    "Artificial Intelligence (AI) refers to computer systems designed to perform tasks that typically require human intelligence. These include learning, reasoning, problem-solving, perception, and language understanding.",
]

class Conversation: ObservableObject, Identifiable {
    internal init(aiModel: String, topic: String, timestamp: Date, messages: [Message] = []) {
        self.aiModel = aiModel
        self.topic = topic
        self.timestamp = timestamp
        self.messages = messages
        self.answer = nil
        self.question = ""
        self.imageUrl = ""
    }
    
    let id = UUID()
    let aiModel: String
    var timestamp: Date
    @Published var topic: String
    @Published var messages: [Message] = []
    @Published var answer: String?
    {
        didSet {
            if answer != nil {
                requestSent = false
            }
        }
    }
    @Published var question: String
    @Published var selectedImage: NSImage?
    @Published var imageUrl: String
    @Published var requestSent: Bool = false

    func modelAllowImage() -> Bool {
        return availableModels[aiModel]?.supportImage ?? false
    }
    
    func analyzeQuestion() async {

        guard let endpoint = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            await MainActor.run {
                self.answer = "Error: Invalid endpoint URL"
            }
            return
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openRouterApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("maa.dev.OpenRouter-Test", forHTTPHeaderField: "HTTP-Referer") // Required by OpenRouter
        
        var contentArray: [[String: Any]] = [["type": "text", "text": question]]
        
        // Handle image inclusion if the model supports it
        if modelAllowImage() {
            if let selectedImage {
                if  let base64String = convertImageToWebPBase64(image: selectedImage) {
                    let imageUrlDict: [String: Any] = [
                        "url": base64String,
                        "detail": "auto"
                    ]
                    contentArray.append([
                        "type": "image_url",
                        "image_url": imageUrlDict
                    ])
                } else {
                    await MainActor.run {
                        self.answer = "Error: Failed to encode selected image."
                    }
                    return
                }
            } else if !imageUrl.isEmpty {
                let imageUrlDict: [String: Any] = [
                    "url": imageUrl,
                    "detail": "auto"
                ]
                contentArray.append([
                    "type": "image_url",
                    "image_url": imageUrlDict
                ])
            }
        }

        let body: [String: Any] = [
            "model": availableModels[aiModel]?.id ?? "",
            "messages": [
                [
                    "role": "user",
                    "content": contentArray
                ]
            ],
            "max_tokens": 300
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            //mokeAnsver()
            //return
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP response
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                await MainActor.run {
                    self.answer = "Error: HTTP \(httpResponse.statusCode)"
                }
                return
            }
            
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let choices = jsonResponse?["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any] {
                let content = message["content"] as? String ?? ""
                let reasoning = message["reasoning"] as? String ?? ""
                await MainActor.run {
                    self.answer = content + reasoning
                }
            } else if let error = jsonResponse?["error"] as? [String: Any],
                      let message = error["message"] as? String {
                await MainActor.run {
                    self.answer = "Error: \(message)"
                }
            } else {
                await MainActor.run {
                    self.answer = "Failed to process the response."
                }
            }
        } catch {
            await MainActor.run {
                self.answer = "Error: \(error.localizedDescription)"
            }
        }
    }

    func lastId() -> UUID? {
        if messages.isEmpty {
            return nil
        }
        return messages.last?.id
    }
    
    func appendQuestion() {
        
        guard question.count > 0 else {
            return
        }
        
        let timeStamp = Date()
        
        var message = Message(
            role: Message.Role.user,
            content: self.question,
            timestamp: timeStamp,
        )
        
        if let selectedImage = selectedImage {
            message.selectedImage = selectedImage
        } else if !imageUrl.isEmpty {
            message.imageUrl = imageUrl
        }
         
        DispatchQueue.main.async {
            self.question = ""
            if self.imageUrl != "" { self.imageUrl = "" }
            if self.selectedImage != nil { self.selectedImage = nil }
            
            if self.messages.isEmpty {
                self.topic = message.content
            }
            self.messages.append(message)
            self.requestSent = true
            self.timestamp = timeStamp
        }

        Task {
            await analyzeQuestion()
        }
//        mokeAnswer()
    }
    
    func mokeAnswer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.answer = mokeLongAnswers.randomElement()
        }
    }
    
    func appendAnswer() {
        guard let answer = answer else {
            return
        }
        
        let now = Date()
        
        let message = Message(
            role: Message.Role.assistant,
            content: answer,
            timestamp: now,
        )
        
        messages.append(message)
        self.answer = nil
        self.timestamp = now
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }
    
    // Helper property to determine section
    var timeSection: TimeSection {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(timestamp) {
            return .today
        } else if calendar.isDateInYesterday(timestamp) {
            return .yesterday
        } else if calendar.isDate(timestamp, equalTo: now, toGranularity: .weekOfYear) {
            return .thisWeek
        } else if let lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now),
                  calendar.isDate(timestamp, equalTo: lastWeekDate, toGranularity: .weekOfYear) {
            return .lastWeek
        } else {
            return .older
        }
    }
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
    var selectedImage: NSImage? = nil
    var imageUrl: String? = nil
}


// Time sections for grouping
enum TimeSection: String, CaseIterable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case older = "Older"
    
    // Sort order for sections
    var sortOrder: Int {
        switch self {
        case .today: return 0
        case .yesterday: return 1
        case .thisWeek: return 2
        case .lastWeek: return 3
        case .older: return 4
        }
    }
}

class AIChartVeiwModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var selectedConversation: Conversation?
    @Published var defaultModel: String = theDefaultModel
    @Published var update: Bool = false

    // clipboard
    var question: String = ""
    var selectedImage: NSImage? = nil
    var imageUrl: String = ""

    var chartsClipboardEmpty : Bool {
        return question.isEmpty && selectedImage == nil && imageUrl.isEmpty
    }
    
    init() {
        mokeCOnversations()
    }
    
    func deleteConversation(at: UUID){
        if selectedConversation?.id == at {
            selectedConversation = nil
        }
        conversations.removeAll { $0.id == at }
    }
    
    func clearCurrentConversation() {
        guard let conversation = selectedConversation else { return }
        conversation.messages.removeAll()
        conversation.topic = ""
        update.toggle()
    }
    
    func copyToChartClipboard(message: Message) {
        self.question = message.content
        if let selectedImage = message.selectedImage {
            self.selectedImage = selectedImage
            self.imageUrl = ""
        } else if let url = message.imageUrl {
            self.selectedImage = nil
            self.imageUrl = url
        } else {
            self.selectedImage = nil
            self.imageUrl = ""
        }
    }
    
    func pasteFromChartClipboard() {
        guard let conversation = selectedConversation else { return }
        conversation.question = question
        if selectedImage != nil {
            conversation.imageUrl = ""
            conversation.selectedImage = selectedImage
        } else {
            conversation.imageUrl = imageUrl
            conversation.selectedImage = nil
        }
    }
    
    func redraw() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.update.toggle()
        }
    }
    
    func newConversation() {
        let newConversation: Conversation = Conversation(
            aiModel: defaultModel,
            topic: "",
            timestamp: Date(),
            messages: []
        )
        conversations.append(newConversation)
        selectedConversation = newConversation
    }
    
    // Get conversations for a specific section with optional search filtering
    func conversationsForSection(_ section: TimeSection, searchText: String = "") -> [Conversation] {
        let filtered = conversations.filter {
            $0.timeSection == section &&
            (searchText.isEmpty ||
             $0.aiModel.localizedCaseInsensitiveContains(searchText) ||
             $0.topic.localizedCaseInsensitiveContains(searchText))
        }
        return filtered.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    // Mark conversation as read
    func markAsRead(conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = Conversation(
                aiModel: conversation.aiModel,
                topic: conversation.topic,
                timestamp: conversation.timestamp,
                messages: conversation.messages
            )
        }
    }
    
    // Delete conversation
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        if selectedConversation?.id == conversation.id {
            selectedConversation = nil
        }
    }
    
    // Sample data generation
    private func mokeCOnversations() {
        
        func randomAI() -> String {
            let allAIs = Array(availableModels.keys)
            let randomIndex = Int.random(in: 0..<allAIs.count)
            return allAIs[randomIndex]
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Today
        let today1 = Conversation(
            aiModel: randomAI(),
            topic: "Are we still meeting for coffee?",
            timestamp: now.addingTimeInterval(-3600), // 1 hour ago
            messages: generateSampleMessages(count: 8)
        )
        conversations.append(today1)

        // Set initial selection
        selectedConversation = today1

        conversations.append(Conversation(
            aiModel: randomAI(),
            topic: "I sent you the report with all the quarterly figures you requested",
            timestamp: now.addingTimeInterval(-7200), // 2 hours ago
            messages: generateSampleMessages(count: 12)
        ))
        
        // Yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
            conversations.append(Conversation(
                aiModel: randomAI(),
                topic: "Thanks for your help yesterday with the presentation!",
                timestamp: yesterday.addingTimeInterval(-21600), // 6 hours into yesterday
                messages: generateSampleMessages(count: 5)
            ))
        }
        
        // This week (2-6 days ago)
        if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) {
            conversations.append(Conversation(
                aiModel: randomAI(),
                topic: "Let me know when you're free to discuss the project scope and timeline",
                timestamp: twoDaysAgo,
                messages: generateSampleMessages(count: 15)
            ))
        }
        
        if let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: now) {
            conversations.append(Conversation(
                aiModel: randomAI(),
                topic: "Did you see the latest design updates for the macOS app?",
                timestamp: fourDaysAgo,
                messages: generateSampleMessages(count: 7)
            ))
        }
        
        // Last week
        if let lastWeek = calendar.date(byAdding: .day, value: -8, to: now) {
            conversations.append(Conversation(
                aiModel: randomAI(),
                topic: "I'll send the invoice by Friday for the consulting work",
                timestamp: lastWeek,
                messages: generateSampleMessages(count: 9)
            ))
            
            conversations.append(Conversation(
                aiModel: randomAI(),
                topic: "Can you help me with the presentation for next week's meeting?",
                timestamp: lastWeek.addingTimeInterval(-172800), // 2 days after last week started
                messages: generateSampleMessages(count: 6)
            ))
        }
        
        // Older
        if let twoWeeksAgo = calendar.date(byAdding: .day, value: -15, to: now) {
            conversations.append(Conversation(
                aiModel: randomAI(),
                topic: "Let's catch up soon! I'd love to hear about your new projects",
                timestamp: twoWeeksAgo,
                messages: generateSampleMessages(count: 10)
            ))
        }
        
        if let threeWeeksAgo = calendar.date(byAdding: .day, value: -22, to: now) {
            conversations.append(Conversation(
                aiModel: randomAI(),
                topic: "Happy birthday! Hope you had a great celebration",
                timestamp: threeWeeksAgo,
                messages: generateSampleMessages(count: 4)
            ))
        }
        
    }
    
}

// Generate sample messages for a conversation
private func generateSampleMessages(count: Int) -> [Message] {
    let now = Date()
    var messages: [Message] = []
    
    let sampleTexts = [
        "Hey, how are you?",
        "Did you get a chance to look at that document?",
        "I was thinking we should meet up sometime next week.",
        "That sounds great!",
        "Can you send me the details?",
        "Just checking in to see how things are going.",
        "I'll get back to you on that tomorrow.",
        "Have you heard about the new project?",
        "Thanks for your help with this!",
        "Let me know if you need anything else.",
        "I'm not sure I understand what you're asking.",
        "Could you elaborate a bit more?",
        "I've attached the files you requested.",
        "Looking forward to seeing you soon!",
        "Sorry for the late reply."
    ]
    
    for i in 0..<count {
        let isFromMe = i % 2 == 1
        let timeOffset = Double(-(i + 1)) * 3600 // Hours back in time
        let messageTime = now.addingTimeInterval(timeOffset)
        let messageText = sampleTexts[i % sampleTexts.count]
        
        messages.append(Message(
            role: isFromMe ? .user : .assistant,
            content: messageText,
            timestamp: messageTime,
        ))
    }
    
    return messages.reversed() // Most recent last
}

let mokeConversationModel = AIChartVeiwModel()

let mokeConversation = Conversation(
    aiModel: theDefaultModel,
    topic: "No topic",
    timestamp: Date.now,
    messages: generateSampleMessages(count: 4)
)
