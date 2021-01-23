//
//  AppDelegate.swift
//  TranslucentImage
//
//  Created by 山上 忍 on 2019/03/18.
//  Copyright © 2019年 山上 忍. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, DropViewDelegate, CaptureControllerDelegate {
    
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
        case esc = 0x35
    }
    
    var image: NSImage?
    var originalSize: CGSize?
    var alpha: CGFloat = 0.5
    var scale: CGFloat = 1.0
    var eraser: DispatchWorkItem?
    
    var captureController: CaptureController?
    
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
    
    func keyDown(with event: NSEvent) {
        changeWindowPosition(with: event)
    }
    
    func scrollWheel(with event: NSEvent) {
        if NSEvent.modifierFlags == .control {
            changeScale(with: event)
        } else {
            changeTranslucent(with: event)
        }
    }
    
    @IBAction
    func onSelectScreenCapture(_ sender: NSMenuItem) {
        let controller = CaptureController(window: nil)
        controller.delegate = self
        guard let captureWindow = controller.window,
              let wFrame = window.screen?.frame else { return }
        controller.showWindow(nil)
        captureWindow.becomeFirstResponder()
        captureWindow.setFrame(wFrame, display: true)
        captureController = controller
        let _ = NSApp.runModal(for: captureWindow)
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
        updateScale()
    }
    
    private func changeScale(with event: NSEvent) {
        let delta: CGFloat = (event.deltaY > 0) ? 0.5 : -0.5
        scale = max(min(scale + delta, 2), 0.5)
        updateScale()
    }
    
    private func changeTranslucent(with event: NSEvent) {
        let iAlpha: Int = max(min(Int(alpha * 10) + ((event.deltaY > 0) ? 1 : -1), 10), 1)
        alpha = CGFloat(iAlpha) / 10.0
        imageView.alphaValue = alpha
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
    
    private func changeWindowPosition(with event: NSEvent) {
        var p = window.frame.origin
        let s: CGFloat = NSEvent.modifierFlags.contains(.shift) ? 8.0 : 1.0
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
        case KeyCode.esc.rawValue:
            NSApp.stopModal(withCode: .OK)
            captureController?.close()
            break
        default: return
        }
        window.setFrameOrigin(p)
    }
    
    private func updateScale() {
        menuItem_x0_5.state = scale == 0.5 ? NSControl.StateValue.on : NSControl.StateValue.off
        menuItem_x1_0.state = scale == 1.0 ? NSControl.StateValue.on : NSControl.StateValue.off
        menuItem_x2_0.state = scale == 2.0 ? NSControl.StateValue.on : NSControl.StateValue.off
        let oldCenter = window.center
        let _ = update()
        window.center = oldCenter
    }
    
    func choosedRect(_ rect: CGRect?) {
        NSApp.stopModal(withCode: .OK)
        captureController?.close()
        if let rect = rect, rect.width > 64.0, rect.height > 64.0 {
            DispatchQueue.main.async { [weak self] in
                self?.capture(rect: rect)
            }
        }
    }
    
    private func capture(rect: CGRect) {
        guard let screen = window.screen else { return }
        let option: CGWindowListOption = CGWindowListOption.optionOnScreenOnly
        let relativeToWindow: CGWindowID = (CGWindowID(0))
        let capRect = CGRect(
            x: rect.minX + screen.visibleFrame.minX,
            y: screen.frame.height - rect.maxY + screen.visibleFrame.minY,
            width: rect.width,
            height: rect.height
        )
        let cgImage: CGImage = CGWindowListCreateImage(
            capRect,
            option,
            relativeToWindow,
            [.boundsIgnoreFraming, .nominalResolution])!
        
        originalSize = CGSize(width: cgImage.width, height: cgImage.height)
        image = NSImage(cgImage: cgImage, size: originalSize!)
        
        if update() {
            window.title = "Captured"
        }
    }
    
}

extension NSWindow {
    var center: CGPoint {
        get { CGPoint(x: frame.midX, y: frame.midY) }
        set {
            self.setFrameOrigin(CGPoint(x: newValue.x - frame.width / 2.0, y: newValue.y - frame.height / 2.0))
        }
    }
}

extension CGRect {
    func reverseY(with height: CGFloat) -> CGRect {
        return CGRect(
            x: self.minX,
            y: height - self.maxY,
            width: self.width,
            height: self.height)
    }
}
