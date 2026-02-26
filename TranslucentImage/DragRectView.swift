//
//  DragRectView.swift
//  TranslucentImage
//
//  Created by 山上 忍 on 2021/01/21.
//  Copyright © 2021 山上 忍. All rights reserved.
//

import Foundation
import Cocoa


protocol DragRectViewDelegate {
    func dragRectView(_ view: DragRectView, choosed: CGRect?)
}

class DragRectView: NSView {
    
    var rectDelegate: DragRectViewDelegate?
    var clickedOrigin: CGPoint = CGPoint.zero
    var checkerHolder: Any?
    
    lazy var checker: ((NSEvent) -> NSEvent?) = { [weak self] event in
        guard let self = self else { return event }
        
        switch event.type {
        case .mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown:
            if !self.bounds.contains(event.locationInWindow) {
                self.finish(rect: nil)
            }
        default:
            break
        }
        return event
    }
    
    var rectView: NSView? {
        didSet {
            guard let view = rectView else { return }
            view.wantsLayer = true
            view.layer?.borderWidth = 1.0
            view.layer?.borderColor = NSColor.white.withAlphaComponent(0.85).cgColor
            view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.15).cgColor
            view.needsDisplay = true
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        rectView?.removeFromSuperview()
        clickedOrigin = CGPoint.with(event)
        let view = NSView(frame: CGRect(origin: clickedOrigin, size: CGSize.zero))
        addSubview(view)
        rectView = view
    }
    
    override func mouseUp(with event: NSEvent) {
        rectView?.removeFromSuperview()
        rectView = nil
        
        let rect = clickedOrigin.rect(with: event.locationInWindow)
        finish(rect: rect)
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let view = rectView else { return }
        view.frame = clickedOrigin.rect(with: event.locationInWindow)
    }
    
    override func rightMouseDown(with : NSEvent) {
        finish(rect: nil)
    }
    
    private func finish(rect: CGRect?) {
        if let checkerHolder = checkerHolder {
            NSEvent.removeMonitor(checkerHolder)
        }
        checkerHolder = nil
        rectDelegate?.dragRectView(self, choosed: rect)
    }
    
}


extension CGPoint {
    static func with(_ event: NSEvent) -> CGPoint {
        return CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y)
    }
    func rect(with other: CGPoint) -> CGRect {
        CGRect(
            x: min(x, other.x),
            y: min(y, other.y),
            width: abs(x - other.x),
            height: abs(y - other.y)
        )
    }
}
