//
//  ContentView.swift
//  claudi_integration
//
//  Created by admin on 01.05.2025.
//

import SwiftUI

let openRouterApiKey = "<YOU API KEY HERE>"

struct ModelOption: Identifiable, Hashable {
    var id: String
    var supportImage: Bool
}

let availableModels: [String: ModelOption] = [
    "$ Claude 3.7 Sonnet": ModelOption(id: "anthropic/claude-3.7-sonnet", supportImage: true),
    "Qwen3-235B": ModelOption(id: "qwen/qwen3-235b-a22b", supportImage: false),
    "Qwen2.5-vl-72b-instruct": ModelOption(id: "qwen/qwen2.5-vl-72b-instruct:free", supportImage: true),
    "Mistral-small-3.1-24b-instruct": ModelOption(id: "mistralai/mistral-small-3.1-24b-instruct:free", supportImage: true),
    "Llama-3.2-11b-vision-instruct": ModelOption(id: "meta-llama/llama-3.2-11b-vision-instruct:free", supportImage: true),
    "Llama-4-maverick": ModelOption(id: "meta-llama/llama-4-maverick:free", supportImage: true),
    "google/gemini-2.0-flash": ModelOption(id: "google/gemini-2.0-flash-exp:free", supportImage: true),
    "google/gemma-3-4b": ModelOption(id: "google/gemma-3-4b-it:free", supportImage: true),
    "$ google/gemini-2.5-pro-exp": ModelOption(id: "google/gemini-2.5-pro-exp-03-25", supportImage: true),
    "$ GPT-4.1": ModelOption(id: "openai/gpt-4.1", supportImage: true),
]

struct ContentView: View {
    @State private var question: String = "Say something good about me"
    @State private var showingImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var imageUrl: String = ""
    @State private var response: String = ""
    @State private var isLoading: Bool = false
    @State private var showingImageSourceOptions: Bool = false
    @State private var activeImageSource: ImageSource? = nil
    @State private var selectedModel: String = "Llama-4-maverick" // Default model
    @State private var showCopyPopup = false
    @State private var copyText : String = ""
    enum ImageSource: Identifiable {
        case gallery
        case url
        var id: Self { self }
    }
    
    @ViewBuilder
    var QuestionSection: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Ask:")
                .font(.system(size: 18)) // Adjust the size value
            Picker("Choose Model", selection: $selectedModel) {
                ForEach(availableModels.sorted(by: { $0.key < $1.key }), id: \.value) { name, _ in
                    Text(name)
                        .tag(name)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 5.0)
                    .stroke(Color.gray, lineWidth: 1)
                TextEditor(text: $question)
                    .padding(2) // Add some internal padding so text doesn't touch the border
                    .background(Color.clear) // Make the TextEditor's background clear to see the border
                
            }
            .frame(maxHeight: 60)
            .animation(.easeInOut, value: showCopyPopup)
            .onTapGesture(count: 2) {
                UIPasteboard.general.string = question
                copyText = "Question copied to clipboard!"
                showCopyPopup = true
                
                // Auto-hide popup after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCopyPopup = false
                }
            }

            if !question.isEmpty {
                Button {
                    question = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle()) // To remove default button styling
            }
        }
    }
    
    @ViewBuilder
    var AnswerSection: some View {
        HStack {
            let isAnswered = !response.isEmpty
            Button(isAnswered ? "Ask again" : "Ask") {
                UIApplication.shared.endEditing()
                Task {
                    await analyzeImage()
                }
            }
            .disabled(isLoading || question.isEmpty)
            if isAnswered {
                Button("Clear") {
                    response = ""
                }
            }
        }
        
        if isLoading {
            ProgressView("Thinking...")
        } else {
            ScrollView {
                Text(response)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .onTapGesture(count: 2) {
                        UIPasteboard.general.string = response
                        showCopyPopup = true
                        copyText = "Response copied to clipboard!"
                        
                        // Auto-hide popup after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopyPopup = false
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    var ImageSection: some View {
        let isCancel = activeImageSource != nil
        Button(isCancel ? "Clear image" : "Add Image") {
            if isCancel {
                selectedImage = nil
                activeImageSource = nil
                imageUrl = ""
            } else {
                UIApplication.shared.endEditing()
                showingImageSourceOptions = true
            }
        }
        .padding(.top, 8)

        VStack {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 150)
            } else if !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 150)
                } placeholder: {
                    ProgressView()
                        .frame(width: 200, height: 150)
                }
            }
            
            if activeImageSource == .url {
                TextField("Image URL", text: $imageUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onTapGesture(count: 2) {
                        UIPasteboard.general.string = imageUrl
                        showCopyPopup = true
                        copyText = "Image URL copied to clipboard!"
                        
                        // Auto-hide popup after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopyPopup = false
                        }
                    }
            }
        }
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack (alignment: .leading) {
                    Text("openrouter.ai apis:")
                        .font(.title)
                    QuestionSection
                        .padding(.bottom, 8)
                    
                    if availableModels[selectedModel]!.supportImage {
                        ImageSection
                            .padding(.bottom, 8)
                    }
                    
                    AnswerSection
                    
                    Spacer()
                }
                if showCopyPopup {
                    Text(copyText)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .transition(.opacity)
                }
            }
            .scrollDismissesKeyboard(.automatic)
            .padding()
            .actionSheet(isPresented: $showingImageSourceOptions) {
                ActionSheet(title: Text("Choose Image Source"), buttons: [
                    .default(Text("Photo Gallery")) {
                        activeImageSource = .gallery
                    },
                    .default(Text("Enter Image URL")) {
                        activeImageSource = .url
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onChange(of: activeImageSource) { olsValue, newValue in // New onChange syntax
                if newValue == .gallery {
                    showingImagePicker = true
                }
            }
            .onChange(of: selectedImage) {  // New onChange syntax with no explicit oldValue
                imageUrl = ""
            }
        }
    }
    
    func analyzeImage() async {
        isLoading = true
        response = ""
        
        guard let endpoint = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            DispatchQueue.main.async {
                response = "Error: Invalid endpoint URL"
                isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openRouterApiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("Your-App-Name", forHTTPHeaderField: "HTTP-Referer") // Required by OpenRouter
        
        var contentArray: [[String: Any]] = [["type": "text", "text": question]]
        
        // Handle image inclusion if the model supports it
        if availableModels[selectedModel]?.supportImage == true {
            if let selectedImage {
                if let imageCoded = convertImageToWebPBase64(image: selectedImage) {
                    let imageUrlDict: [String: Any] = [
                        "url": imageCoded,
                        "detail": "auto"
                    ]
                    contentArray.append([
                        "type": "image_url",
                        "image_url": imageUrlDict
                    ])
                } else {
                    DispatchQueue.main.async {
                        response = "Error: Failed to encode selected image."
                        isLoading = false
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
            "model": availableModels[selectedModel]?.id ?? "",
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
                DispatchQueue.main.async {
                    self.response = "Error: HTTP \(httpResponse.statusCode)"
                    isLoading = false
                }
                return
            }
            
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            if let choices = jsonResponse?["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any] {
                let content = message["content"] as? String ?? ""
                let reasoning = message["reasoning"] as? String ?? ""
                DispatchQueue.main.async {
                    self.response = content + reasoning
                    isLoading = false
                }
            } else if let error = jsonResponse?["error"] as? [String: Any],
                      let message = error["message"] as? String {
                DispatchQueue.main.async {
                    self.response = "Error: \(message)"
                    isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.response = "Failed to process the response."
                    isLoading = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.response = "Error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func mokeAnsver() {
        let answers = ["The image shows a stylized logo or emblem of what appears to be a cat or feline head in profile. It features blue outlines for the top portion of the head and yellow/gold elements representing facial features or markings, possibly whiskers or a muzzle area. The design is set against a black background, creating strong contrast with the blue and yellow colors. This looks like it could be a sports team mascot, gaming logo, or brand identity for a company or organization.",
           "You're curious enough to engage with an AI and seek positive feedback, which shows emotional intelligence and openness. That willingness to connect and seek different perspectives is a genuinely admirable quality that helps people grow and learn throughout life.",
           "This image shows a beautiful nature landscape featuring a wooden boardwalk or path cutting through a lush green wetland or grassland area. The boardwalk stretches into the distance, creating a perfect perspective. On either side are tall green grasses or reeds typical of a marsh or wetland ecosystem. In the background, you can see trees and shrubs lining the horizon. Above is a stunning blue sky with wispy white clouds stretching across it. The scene has a serene, peaceful quality with vibrant natural colors - the rich greens of the vegetation contrasting beautifully with the blue sky and wooden boardwalk. This appears to be taken in a nature preserve or protected wetland area during spring or summer.",
        ]
        DispatchQueue.main.async {
            response = answers[Int.random(in: 0..<answers.count)]
            isLoading = false
        }

    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
