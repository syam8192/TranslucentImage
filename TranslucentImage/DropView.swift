//
//  DropView.swift
//  TranslucentImage
//
//  Created by 山上 忍 on 2019/03/18.
//  Copyright © 2019年 山上 忍. All rights reserved.
//

import Cocoa

class DropView: NSImageView {

    required init?(coder : NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        NSLog("draggingEntered");
        return NSDragOperation.generic
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let paths: [String] = sender.draggingPasteboard.propertyList(forType:
            NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? [String] else {
            return false
        }

        return true;
        
    }
    
}
