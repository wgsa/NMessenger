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

//MARK: InputBarView
/**
 InputBarView class for NMessenger.
 Define the input bar for NMessenger. This is where the user would type text and open the camera or photo library.
 */
open class InputBarView: UIView, UITextViewDelegate {
    
    //MARK: IBOutlets
    @IBOutlet open weak var textInputAreaView: UIView!
    @IBOutlet open weak var textInputView: UITextView!
    @IBOutlet open var inputBarView: UIView!
    @IBOutlet open weak var sendButton: UIButton!
    @IBOutlet open weak var cameraButton: UIButton!
    @IBOutlet open weak var textInputAreaViewHeight: NSLayoutConstraint!
    @IBOutlet open weak var textInputViewHeight: NSLayoutConstraint!
    
    //MARK: Public Parameters
    
    open var nibName = "InputBarView"
    
    open var buttonTintColor = UIColor.n1ActionBlueColor()
    open var inputAreaBackgroundColor = UIColor.white
    
    open var placeholderTextColor = UIColor.lightGray
    open var textColor = UIColor.n1DarkestGreyColor()
    
    //CGFloat to the fine the number of rows a user can type
    open var numberOfRows: CGFloat = 7
    
    open var sendButtonTitle = "Send"
    
    //String as placeholder text in input view
    open var inputPlaceholderText: String = "Write a message" {
        willSet(newVal) {
            self.textInputView?.text = newVal
        }
    }
    
    //NMessengerViewController where to input is sent to
    open var controller: NMessengerViewController!
    
    //MARK: Private Parameters
    
    //CGFloat as defualt height for input view
    fileprivate let textInputViewHeightConst: CGFloat = 30
    
    // MARK: Initialisers
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     Calls helper methond to setup the view
     */
    public required init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        commonInit()
    }
    
    public required init(controller: NMessengerViewController) {
        super.init(frame: CGRect.zero)
        
        self.controller = controller
        commonInit()
    }
    
    /**
     Initialiser the view.
     - parameter controller: Must be NMessengerViewController. Sets controller for the view.
     - parameter controller: Must be CGRect. Sets frame for the view.
     Calls helper methond to setup the view
     */
    public required init(controller: NMessengerViewController, frame: CGRect) {
        super.init(frame: frame)
        
        self.controller = controller
        commonInit()
    }
    
    /**
     - parameter aDecoder: Must be NSCoder
     Calls helper methond to setup the view
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    open func commonInit() {
        loadFromBundle()
        
        addInputPlaceholder()
    }
    
    // MARK: Initialiser helper methods
    
    fileprivate func loadFromBundle() {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        
        self.addSubview(inputBarView)
        inputBarView?.frame = self.bounds
        textInputView?.delegate = self
        
        textInputAreaView?.backgroundColor = inputAreaBackgroundColor
        
        sendButton.setTitleColor(buttonTintColor, for: .normal)
        sendButton?.setTitle(sendButtonTitle, for: .normal)
        
        cameraButton?.tintColor = buttonTintColor
        cameraButton?.adjustsImageWhenHighlighted = true
    }
    
    override open func becomeFirstResponder() -> Bool {
        textInputView.becomeFirstResponder()
        return true
    }
    
    // MARK: Text input behaviour
    
    open func getText() -> String {
        return placeholderVisible() ? "" : textInputView.text
    }
    
    open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if placeholderVisible() {
            removeInputPlaceholder()
        }
        
        return true
    }
    
    open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if self.textInputView.text.isEmpty {
            self.addInputPlaceholder()
        }
        
        self.textInputView.resignFirstResponder()
        return true
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        textInputViewHeight.constant = newFrame.size.height
        textInputAreaViewHeight.constant = newFrame.size.height + 10
        
        UIView.animate(withDuration: 0.1) {
            self.sendButton.isHidden = textView.text.isEmpty
        }
    }
    
    open func addInputPlaceholder() {
        textInputView.text = inputPlaceholderText
        textInputView.textColor = placeholderTextColor
        sendButton.isHidden = true
    }
    
    open func removeInputPlaceholder() {
        textInputView.text = ""
        textInputView.textColor = textColor
        textInputView.selectedRange = NSRange(location: 0, length: 0)
    }
    
    private func placeholderVisible() -> Bool {
        return textInputView.textColor == placeholderTextColor
    }
    
    //MARK: @IBAction selectors
    
    /**
     Send button selector
     Sends the text in textInputView to the controller
     */
    @IBAction open func sendButtonClicked(_ sender: AnyObject) {
        textInputViewHeight.constant = textInputViewHeightConst
        textInputAreaViewHeight.constant = textInputViewHeightConst + 10
        if self.textInputView.text != "" {
            let _ = controller.sendText(textInputView.text, isIncomingMessage: false)
            textInputView.text = ""
            sendButton.isHidden = true
        }
    }
    
    /**
     Requests camera and photo library permission if needed
     Open camera and/or photo library to take/select a photo
     */
    @IBAction open func plusClicked(_ sender: AnyObject?) {
        
    }
}
