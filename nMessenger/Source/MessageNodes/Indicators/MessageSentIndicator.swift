//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AsyncDisplayKit
import UIKit

//MARK: HeadLoadingIndicator class
/**
 Spinning loading indicator class. Used by the NMessenger prefetch.
 */
open class MessageSentIndicator: GeneralMessengerCell {
    /** Horizontal spacing between text and spinner. Defaults to 20.*/
    open var contentPadding: CGFloat = 20 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /** Loading text node*/
    public let text = ASTextNode()
    
    /** Sets the loading attributed text for the spinner. Defaults to *"Loading..."* */
    open var messageSentAttributedText: NSAttributedString? {
        set {
            text.attributedString = newValue
            self.setNeedsLayout()
        } get {
            return text.attributedText
        }
    }
    
    open var textColor = UIColor.lightGray {
        didSet {
            updateAttributedText()
        }
    }
    
    open var font = UIFont.systemFont(ofSize: 14) {
        didSet {
            updateAttributedText()
        }
    }
    
    open var messageSentText: String? {
        set {
            text.attributedString = NSAttributedString(
                string: newValue != nil ? newValue! : "",
                attributes: convertToOptionalNSAttributedStringKeyDictionary([
                    convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
                    convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor,
                    convertFromNSAttributedStringKey(NSAttributedString.Key.kern): -0.3
                ]))
            self.setNeedsLayout()
        } get {
            return text.attributedString?.string
        }
    }
    
    fileprivate func updateAttributedText() {
        let tmpString = NSMutableAttributedString(string: self.messageSentText ?? "")
        tmpString.addAttributes(convertToNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor,
            convertFromNSAttributedStringKey(NSAttributedString.Key.kern): -0.3
            ]), range: NSMakeRange(0, tmpString.length))
        text.attributedString = tmpString
        
        setNeedsLayout()
    }
    
    public override init() {
        super.init()
        addSubnode(text)
    }
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackLayout = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: contentPadding,
            justifyContent: .center,
            alignItems: .center,
            children: [ text ])
        let paddingLayout = ASInsetLayoutSpec(insets: cellPadding, child: stackLayout)
        return paddingLayout
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
