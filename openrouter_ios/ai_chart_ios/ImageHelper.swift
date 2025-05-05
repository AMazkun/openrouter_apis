//
//  ImageHelper.swift
//  openrouter_ios
//
//  Created by admin on 06.05.2025.
//

import SwiftUI
import UIKit
import SDWebImageWebPCoder


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}


func convertImageToWebPBase64(image: UIImage) -> String? {
    guard let cgImage = image.cgImage else { return nil }
    
    guard let webpData = SDImageWebPCoder.shared.encodedData(with: image, format: .webP, options: nil) else {
        print("Error: Could not encode UIImage to WebP data.")
        return nil
    }

    let base64String = webpData.base64EncodedString()
    return "data:image/webp;base64,\(base64String)"
}
