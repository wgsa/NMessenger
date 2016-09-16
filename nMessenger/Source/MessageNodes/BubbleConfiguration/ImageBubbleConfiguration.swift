//
//  ChatBubbleConfiguration.swift
//  WGSA
//
//  Created by Gustav Sundin on 06/09/16.
//  Copyright © 2016 WGSA. All rights reserved.
//

import UIKit
import NMessenger

class ImageBubbleConfiguration: StandardBubbleConfiguration {
    open func getBubbleBorderColor() -> UIColor {
    	return .black
    }
    
    override func getIncomingColor() -> UIColor {
        return .clear
    }
    
    override func getOutgoingColor() -> UIColor {
        return .clear
    }
    
    override func getIncomingTextColor() -> UIColor {
        return .black
    }
    
    override func getOutgoingTextColor() -> UIColor {
        return .black
    }
    
    override func getBubble() -> Bubble {
        let newBubble = MessageBubble()
        newBubble.hasLayerMask = isMasked
        newBubble.borderWidth = 4
        newBubble.bubbleBorderColor = getBubbleBorderColor()
        return newBubble
    }
    
    override func getSecondaryBubble() -> Bubble {
        return getBubble()
    }
}
