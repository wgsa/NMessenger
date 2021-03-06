//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import UIKit

/** Uses a default bubble as primary and a stacked bubble as secondary. Incoming color is pale grey and outgoing is blue */
open class StandardBubbleConfiguration: BubbleConfigurationProtocol {

    open var isMasked = false
    
    public init() {}
    
    open func getIncomingColor() -> UIColor {
        return .n1PaleGreyColor()
    }
    
    open func getOutgoingColor() -> UIColor {
        return .n1ActionBlueColor()
    }
    
    open func getIncomingTextColor() -> UIColor {
        return .n1DarkestGreyColor()
    }
    
    open func getOutgoingTextColor() -> UIColor {
        return .n1WhiteColor()
    }
    
    open func getIncomingTextFont() -> UIFont {
        return .n1B1Font()
    }
    
    open func getOutgoingTextFont() -> UIFont {
        return .n1B1Font()
    }
    
    open func getBubble() -> Bubble {
        let newBubble = MessageBubble()
        newBubble.hasLayerMask = isMasked
        return newBubble
    }
    
    open func getSecondaryBubble() -> Bubble {
        return getBubble()
    }
}
