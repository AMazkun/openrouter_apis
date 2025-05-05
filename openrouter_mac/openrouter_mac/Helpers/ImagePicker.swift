//
//  ImagePicker.swift
//  AI View Test
//
//  Created by admin on 04.05.2025.
//

import SwiftUI
import AppKit

struct ImagePickerView: View {
    @State var selectedImage: NSImage?
    let completion: (NSImage?) -> Void

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .border(Color.gray, width: 1)
            } else {
                Text("No image selected")
                    .padding()
            }

            Button("Select Image") {
                pickImage()
            }
            .padding()
        }
    }

    func pickImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.urls.first, let nsImage = NSImage(contentsOf: url) {
            selectedImage = nsImage
            completion(nsImage)
        }
    }
}
