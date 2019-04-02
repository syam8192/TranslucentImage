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

    @IBOutlet weak var menuItem_x0_5: NSMenuItem!
    @IBOutlet weak var menuItem_x1_0: NSMenuItem!
    @IBOutlet weak var menuItem_x2_0: NSMenuItem!

    enum KeyCode: UInt16 {
        case left = 0x7b
        case right = 0x7c
        case down = 0x7d
        case up = 0x7e
    }

    var image: NSImage?
    var originalSize: CGSize?
    var alpha: CGFloat = 0.5
    var scale: CGFloat = 1.0
    var eraser: DispatchWorkItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        initializeWindow()
        window.delegate = self
        dropView.setDropDelegate(delegate: self)
    }

    func initializeWindow()    {
        window.setContentSize(NSSize(width: 320, height: 320))
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 16
        shadow.shadowColor = NSColor.black
        label.shadow = shadow
        window.makeFirstResponder(dropView)
        
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(self)
    }

    func update() -> Bool {
        guard
            let image = image,
            let originalSize = originalSize
            else { return false }

        if image.isValid {
            let size = CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
            let x = window.frame.minX
            let y = window.frame.maxY
            window.setContentSize(size)
            imageView.image = image
            label.isHidden = true
            window.isOpaque = false
            window.backgroundColor = NSColor.clear
            imageView.alphaValue = CGFloat(alpha)
            window.setFrameOrigin(CGPoint(x: x, y: y - size.height))
            return true
        }
        return false
    }

    func filesDidDrop(path: String) {
        guard
            let img = NSImage(contentsOfFile: path),
            let tiffrep = img.tiffRepresentation,
            let bitmapImageRef = NSBitmapImageRep(data: tiffrep)
            else { return }
        
        image = img
        originalSize = bitmapImageRef.size
        
        if update() {
            let path = NSString(string: path)
            window.title = path.lastPathComponent
        }
    }

    func keyDown(with event: NSEvent, isShiftDown: Bool) {
        var p = window.frame.origin
        let s: CGFloat = isShiftDown ? 8.0 : 1.0
        switch event.keyCode {
        case KeyCode.up.rawValue:
            p.y += s
            break
        case KeyCode.down.rawValue:
            p.y -= s
            break
        case KeyCode.left.rawValue:
            p.x -= s
            break
        case KeyCode.right.rawValue:
            p.x += s
            break
        default: return
        }
        window.setFrameOrigin(p)
    }

    func scrollWheel(with event: NSEvent) {
        alpha = max(min((alpha + event.deltaY / 10.0), 1), 0.1)
        alpha = ceil(alpha * 10) / 10
        imageView.alphaValue = CGFloat(alpha)
        label.stringValue = "\(Int(alpha * 100))%"
        label.isHidden = false
        if eraser != nil {
            eraser?.cancel()
        }
        eraser = DispatchWorkItem() {
            self.label.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: eraser!)
    }

    @IBAction
    func onSelectAlwaysOnTop(_ sender: NSMenuItem) {
        if (sender.state == NSControl.StateValue.on) {
            sender.state = NSControl.StateValue.off
            window.level = NSWindow.Level.normal
        }
        else {
            sender.state = NSControl.StateValue.on
            window.level = NSWindow.Level.floating
        }
    }

    @IBAction
    func onSelectScale(_ sender: NSMenuItem) {
        switch sender.tag {
        case 0:
            scale = 0.5
            break;
        case 1:
            scale = 1.0
            break;
        case 2:
            scale = 2.0
            break;
        default: return
        }
        menuItem_x0_5.state = scale == 0.5 ? NSControl.StateValue.on : NSControl.StateValue.off
        menuItem_x1_0.state = scale == 1.0 ? NSControl.StateValue.on : NSControl.StateValue.off
        menuItem_x2_0.state = scale == 2.0 ? NSControl.StateValue.on : NSControl.StateValue.off
        let _ = update()
    }

}
