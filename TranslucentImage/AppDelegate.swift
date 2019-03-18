//
//  AppDelegate.swift
//  TranslucentImage
//
//  Created by 山上 忍 on 2019/03/18.
//  Copyright © 2019年 山上 忍. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, DropViewDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var dropView: DropView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    var alpha: CGFloat = 0.5
    var eraser: DispatchWorkItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        initializeWindow()
        window.delegate = self
        dropView.setDropDelegate(delegate: self)
    }
    
    func initializeWindow()    {
        window.setContentSize(NSSize(width: 320, height: 320))
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(self)
    }

    func filesDidDrop(path: String) {
        update(with: path)
    }
    
    func scrollWheel(with event: NSEvent) {
        alpha = max(min((alpha + event.deltaY / 10.0), 1), 0.1)
        alpha = ceil(alpha * 10) / 10
        
        imageView.alphaValue = CGFloat(alpha)
        label.stringValue = "\(alpha * 100)%"
        label.isHidden = false
        if eraser != nil {
            eraser?.cancel()
        }
        eraser = DispatchWorkItem() {
            self.label.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: eraser!)
    }

    func update(with imagePath: String) {
        guard
            let image = NSImage(contentsOfFile: imagePath),
            let tiffrep = image.tiffRepresentation,
            let bitmapImageRef = NSBitmapImageRep(data: tiffrep)
            else { return }
        let imageSize = (bitmapImageRef.size)

        window.setContentSize(imageSize)

        if image.isValid {
            imageView.image = image
        }

        label.isHidden = true
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        imageView.alphaValue = CGFloat(alpha)

    }
  
}
