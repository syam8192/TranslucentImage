//
//  DropView.swift
//  TranslucentImage
//
//  Created by 山上 忍 on 2019/03/18.
//  Copyright © 2019年 山上 忍. All rights reserved.
//

import Cocoa


protocol DropViewDelegate {
    func filesDidDrop(path: String)
    func scrollWheel(with event: NSEvent)
    func keyDown(with event: NSEvent, isShiftDown: Bool)
}

class DropView: NSImageView {

    var dropDelegate: DropViewDelegate?
    var isShiftDown = false
    
    required init?(coder : NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.generic
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let paths: [String] = sender.draggingPasteboard.propertyList(forType:
            NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String] else {
            return false
        }
        dropDelegate?.filesDidDrop(path: paths[0])
        return true;
    }
    
    func setDropDelegate(delegate: DropViewDelegate) {
        dropDelegate = delegate
    }
    
    override func scrollWheel(with event: NSEvent) {
        dropDelegate?.scrollWheel(with: event)
    }

    override var acceptsFirstResponder: Bool { return true }
    
    override func flagsChanged(with event: NSEvent) {
        isShiftDown = event.modifierFlags.contains([.shift])
    }
    
    override func keyDown(with event: NSEvent) {
        dropDelegate?.keyDown(with: event, isShiftDown: isShiftDown)
    }
    
}


