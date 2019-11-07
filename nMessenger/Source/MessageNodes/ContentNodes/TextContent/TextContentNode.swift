//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit

open class TextContentNode: ContentNode {
    
    // MARK: Public Variables
    
    open var insets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 5) {
        didSet {
            setNeedsLayout()
        }
    }
    
    open var incomingTextFont = UIFont.n1B1Font() {
        didSet {
            updateAttributedText()
        }
    }
    
    open var outgoingTextFont = UIFont.n1B1Font() {
        didSet {
            updateAttributedText()
        }
    }
    
    open var incomingTextColor = UIColor.n1DarkestGreyColor() {
        didSet {
            updateAttributedText()
        }
    }
    
    open var outgoingTextColor = UIColor.n1WhiteColor() {
        didSet {
            updateAttributedText()
        }
    }
    
    open var textMessageString: NSAttributedString? {
        get {
            return textMessageNode.attributedString
        } set {
            textMessageNode.attributedString = newValue
        }
    }
    
    open override var isIncomingMessage: Bool {
        didSet {
            if isIncomingMessage {
                backgroundBubble?.bubbleColor = bubbleConfiguration.getIncomingColor()
                incomingTextColor = bubbleConfiguration.getIncomingTextColor()
                incomingTextFont = bubbleConfiguration.getIncomingTextFont()
                updateAttributedText()
            } else {
                backgroundBubble?.bubbleColor = bubbleConfiguration.getOutgoingColor()
                outgoingTextColor = bubbleConfiguration.getOutgoingTextColor()
                outgoingTextFont = bubbleConfiguration.getOutgoingTextFont()
                updateAttributedText()
            }
        }
    }
    
    // MARK: Private Variables
    
    open fileprivate(set) var textMessageNode: ASTextNode = ASTextNode()
    
    /** Bool as mutex for handling attributed link long presses */
    fileprivate var lockKey: Bool = false
    
    // MARK: Initialisers
    
    public init(textMessageString: String, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        
        setupTextNode(textMessageString)
    }
    
    public init(textMessageString: String, currentViewController: UIViewController, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        
        self.currentViewController = currentViewController
        setupTextNode(textMessageString)
    }
    
    // MARK: Initialiser helper method
    
    
    /** Creates the text to be display in the cell. Finds links and phone number in the string and creates atrributed string. */
    fileprivate func setupTextNode(_ textMessageString: String) {
        backgroundBubble = bubbleConfiguration.getBubble()
        textMessageNode.isUserInteractionEnabled = true
        textMessageNode.linkAttributeNames = ["LinkAttribute", "PhoneNumberAttribute"]
        let fontAndSizeAndTextColor = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): isIncomingMessage ? incomingTextFont : outgoingTextFont,
                                       convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): isIncomingMessage ? incomingTextColor : outgoingTextColor]
        
        let originalString = NSMutableAttributedString(string: textMessageString, attributes: convertToOptionalNSAttributedStringKeyDictionary(fontAndSizeAndTextColor))
        let stringAppendix = NSMutableAttributedString(string: " ", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 1)])) // This workaround prevents emojis from being clipped
        
        let outputString = NSMutableAttributedString()
        outputString.append(originalString)
        outputString.append(stringAppendix)
        
        let types: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        let detector = try! NSDataDetector(types: types.rawValue)
        
        let matches = detector.matches(in: textMessageString, options: [], range: NSMakeRange(0, textMessageString.count))
        
        for match in matches {
            if let url = match.url {
                outputString.addAttribute(convertToNSAttributedStringKey("LinkAttribute"), value: url, range: match.range)
                outputString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
                outputString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: match.range)
            }
            if let phoneNumber = match.phoneNumber {
                outputString.addAttribute(convertToNSAttributedStringKey("PhoneNumberAttribute"), value: phoneNumber, range: match.range)
                outputString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
                outputString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: match.range)
            }
        }
        
        textMessageNode.attributedString = outputString
        textMessageNode.accessibilityIdentifier = "labelMessage"
        textMessageNode.isAccessibilityElement = true
        addSubnode(textMessageNode)
    }
    
    //MARK: Helper Methods
    
    /** Updates the attributed string to the correct incoming/outgoing settings and lays out the component again*/
    fileprivate func updateAttributedText() {
        let tmpString = NSMutableAttributedString(attributedString: textMessageNode.attributedString!)
        tmpString.addAttributes(convertToNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): isIncomingMessage ? incomingTextColor : outgoingTextColor,
                                 convertFromNSAttributedStringKey(NSAttributedString.Key.font): isIncomingMessage ? incomingTextFont : outgoingTextFont]),
                                range: NSMakeRange(0, tmpString.length))
        textMessageNode.attributedString = tmpString
        
        setNeedsLayout()
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width * 0.90 - insets.left - insets.right
        
        let tmp = ASRelativeSizeRangeMake(ASRelativeSizeMakeWithCGSize(CGSize.zero), ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(width), ASRelativeDimensionMakeWithPercent(1)))
        textMessageNode.sizeRange = tmp
        let textMessageSize = ASStaticLayoutSpec(children: [textMessageNode])
        
        return  ASInsetLayoutSpec(insets: insets, child: textMessageSize)
    }
    
    // MARK: ASTextNodeDelegate
    
    open func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return attribute == "LinkAttribute" || attribute == "PhoneNumberAttribute"
    }
    
    /** Implementing tappedLinkAttribute - handle tap event on links and phone numbers */
    open func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        if attribute == "LinkAttribute" {
            if !lockKey {
                if let tmpString = textMessageNode.attributedString {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.lightGray, range: textRange)
                    textMessageNode.attributedString = attributedString
                    UIApplication.shared.openURL(value as! URL)
                    delay(0.4) {
                        if let tmpString = self.textMessageNode.attributedString {
                            let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                            attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: textRange)
                            self.textMessageNode.attributedString = attributedString
                        }
                    }
                }
            }
        } else if attribute == "PhoneNumberAttribute" {
            let phoneNumber = value as! String
            UIApplication.shared.openURL(URL(string: "tel://\(phoneNumber)")!)
        }
    }
    
    open func textNode(_ textNode: ASTextNode, shouldLongPressLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return attribute == "LinkAttribute" || attribute == "PhoneNumberAttribute"
    }
    
    open func textNode(_ textNode: ASTextNode, longPressedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        if attribute == "LinkAttribute" {
            lockKey = true
            if let tmpString = textMessageNode.attributedString {
                let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.lightGray, range: textRange)
                textMessageNode.attributedString = attributedString
                
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let openAction = UIAlertAction(title: "Open", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let addToReadingListAction = UIAlertAction(title: "Add to Reading List", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let copyAction = UIAlertAction(title: "Copy", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                optionMenu.addAction(openAction)
                optionMenu.addAction(addToReadingListAction)
                optionMenu.addAction(copyAction)
                optionMenu.addAction(cancelAction)
                
                if let tmpCurrentViewController = currentViewController {
                    DispatchQueue.main.async(execute: { () -> Void in
                        tmpCurrentViewController.present(optionMenu, animated: true, completion: nil)
                    })
                }
            }
            
            delay(0.4) {
                if let tmpString = self.textMessageNode.attributedString {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: textRange)
                    self.textMessageNode.attributedString = attributedString
                }
            }
        } else if attribute == "PhoneNumberAttribute" {
            let phoneNumber = value as! String
            lockKey = true
            if let tmpString = textMessageNode.attributedString {
                let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.lightGray, range: textRange)
                textMessageNode.attributedString = attributedString
                
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let callPhoneNumberAction = UIAlertAction(title: "Call \(phoneNumber)", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let facetimeAudioAction = UIAlertAction(title: "Facetime Audio", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let sendMessageAction = UIAlertAction(title: "Send Message", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let addToContactsAction = UIAlertAction(title: "Add to Contacts", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let copyAction = UIAlertAction(title: "Copy", style: .default, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction) -> Void in
                    self.lockKey = false
                })
                
                optionMenu.addAction(callPhoneNumberAction)
                optionMenu.addAction(facetimeAudioAction)
                optionMenu.addAction(sendMessageAction)
                optionMenu.addAction(addToContactsAction)
                optionMenu.addAction(copyAction)
                optionMenu.addAction(cancelAction)
                
                if let tmpCurrentViewController = currentViewController {
                    DispatchQueue.main.async(execute: { () -> Void in
                        tmpCurrentViewController.present(optionMenu, animated: true, completion: nil)
                    })
                }
            }
            
            delay(0.4) {
                if let tmpString = self.textMessageNode.attributedString {
                    let attributedString =  NSMutableAttributedString(attributedString: tmpString)
                    attributedString.removeAttribute(NSAttributedString.Key.backgroundColor, range: textRange)
                    self.textMessageNode.attributedString = attributedString
                }
            }
        }
    }
    
    // MARK: UILongPressGestureRecognizer Selector Methods
    
    override open func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override open func resignFirstResponder() -> Bool {
        return view.resignFirstResponder()
    }
    
    open override func messageNodeLongPressSelector(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.began {
            let touchLocation = recognizer.location(in: view)
            if textMessageNode.frame.contains(touchLocation) {
                becomeFirstResponder()
                delay(0.1, closure: {
                    let menuController = UIMenuController.shared
                    menuController.menuItems = [UIMenuItem(title: "Copy", action: #selector(TextContentNode.copySelector))]
                    menuController.setTargetRect(self.textMessageNode.frame, in: self.view)
                    menuController.setMenuVisible(true, animated:true)
                })
            }
        }
    }
    
    @objc open func copySelector() {
        UIPasteboard.general.string = textMessageNode.attributedString!.string
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKey(_ input: String) -> NSAttributedString.Key {
	return NSAttributedString.Key(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
