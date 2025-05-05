//
//  UIHelper.swift
//  AI View Test
//
//  Created by admin on 02.05.2025.
//

import SwiftUI
import AppKit

func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

extension Image {
    func asNSImage() -> NSImage? {
        let hostingView = NSHostingView(rootView: self.resizable().aspectRatio(contentMode: .fit).frame(width: 400, height: 400))
        hostingView.setFrameSize(NSSize(width: 400, height: 400))
        
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(hostingView.frame.width),
            pixelsHigh: Int(hostingView.frame.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else { return nil }
        
        hostingView.layer?.render(in: NSGraphicsContext(bitmapImageRep: bitmap)! as! CGContext)
        
        let image = NSImage(size: hostingView.frame.size)
        image.addRepresentation(bitmap)
        
        return image
    }
}

// A more universal approach
func getImageData(from swiftUIImage: Image?) -> Data? {
    if let nsImage = swiftUIImage?.asNSImage(),
       let tiffData = nsImage.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) {
        return jpegData
    }
    return nil
}
