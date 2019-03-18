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

        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.alphaValue = CGFloat(0.5)

        label.isHidden = true
    }
  
}
