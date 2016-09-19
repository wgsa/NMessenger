//
//  ChatBubbleConfiguration.swift
//  WGSA
//
//  Created by Gustav Sundin on 06/09/16.
//  Copyright © 2016 WGSA. All rights reserved.
//

import UIKit

open class ImageBubbleConfiguration: StandardBubbleConfiguration {
    open func getBubbleBorderColor() -> UIColor {
    	return .black
    }
    
    override open func getIncomingColor() -> UIColor {
        return .clear
    }
    
    override open func getOutgoingColor() -> UIColor {
        return .clear
    }
    
    override open func getIncomingTextColor() -> UIColor {
        return .black
    }
    
    override open func getOutgoingTextColor() -> UIColor {
        return .black
    }
    
    override open func getBubble() -> Bubble {
        let newBubble = MessageBubble()
        newBubble.hasLayerMask = isMasked
        newBubble.borderWidth = 4
        newBubble.bubbleBorderColor = getBubbleBorderColor()
        return newBubble
    }
    
    override open func getSecondaryBubble() -> Bubble {
        return getBubble()
    }
}
