//
//  UIHelper.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI
import AppKit
import Cocoa
import libwebp

func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

import Foundation
import SDWebImageWebPCoder

func encodeWebP(pixelData: Data, width: Int, height: Int) -> Data? {
    var outputData: Data? = nil
    
    pixelData.withUnsafeBytes { rawBufferPointer in
        if let rawPointer = rawBufferPointer.baseAddress {
            var webPData: UnsafeMutablePointer<UInt8>? = nil
            let webPSize = WebPEncodeLosslessBGRA(rawPointer.assumingMemoryBound(to: UInt8.self), Int32(width), Int32(height), Int32(width * 4), &webPData)
            
            if webPSize > 0, let webPData = webPData {
                outputData = Data(bytes: webPData, count: Int(webPSize))
                free(webPData)
            }
        }
    }
    
    return outputData
}


func convertImageToWebPBase64(image: NSImage) -> String? {
    
    guard let webpData = SDImageWebPCoder.shared.encodedData(with: image, format: .webP, options: nil) else {
        print("Error: Could not encode UIImage to WebP data.")
        return nil
    }

    let base64String = webpData.base64EncodedString()
    return "data:image/webp;base64,\(base64String)"
}


func setPasteboardString(_ string: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(string, forType: .string)
}
