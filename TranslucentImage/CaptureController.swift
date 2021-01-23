//
//  CaptureController.swift
//  TranslucentImage
//
//  Created by 山上 忍 on 2021/01/21.
//  Copyright © 2021 山上 忍. All rights reserved.
//

import Foundation
import Cocoa

protocol CaptureControllerDelegate {
    func choosedRect(_ : CGRect?)
}

class CaptureController: NSWindowController, NSWindowDelegate, DragRectViewDelegate {
    
    var delegate: CaptureControllerDelegate?
    override var acceptsFirstResponder: Bool { return true }
    override var windowNibName: NSNib.Name? { "CaptureWindow" }
    
    @IBOutlet weak var backgroundView: DragRectView! {
        didSet {
            backgroundView?.rectDelegate = self
        }
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        window?.isOpaque = false
        window?.backgroundColor = NSColor.black.withAlphaComponent(0.1)
        window?.level = NSWindow.Level.floating
        configureUI()
    }
    
    private func configureUI() {
        window?.setFrameOrigin(NSPoint.zero)
    }
    
    func dragRectView(_ view: DragRectView, choosed: CGRect?) {
        delegate?.choosedRect(choosed)
    }
    
}
