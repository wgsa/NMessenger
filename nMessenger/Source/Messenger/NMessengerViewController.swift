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
import AVFoundation
import Photos
import AsyncDisplayKit
import ImageViewer

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}


open class NMessengerViewController: UIViewController, UITextViewDelegate, NMessengerDelegate, UIGestureRecognizerDelegate, ImageTapDelegate {
    
    //MARK: Views
    open var messengerView: NMessenger!
    
    open var inputBarView: InputBarView!
    
    //MARK: Private Variables
    open fileprivate(set) var isKeyboardIsShown: Bool = false
    
    //NSLayoutConstraint for the input bar spacing from the bottom
    fileprivate var inputBarBottomSpacing: NSLayoutConstraint = NSLayoutConstraint()
    
    //MARK: Public Variables
    //UIEdgeInsets for padding for each message
    open var messagePadding: UIEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    
    open var sharedBubbleConfiguration: BubbleConfigurationProtocol = StandardBubbleConfiguration()
    
    open var imageBubbleConfiguration: BubbleConfigurationProtocol = StandardBubbleConfiguration()
    
    // MARK: Initialisers
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        addObservers()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        addObservers()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: Initialisers helper methods
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(NMessengerViewController.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Controller LifeCycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        loadMessengerView()
        loadInputView()
        setUpConstraintsForViews()
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(NMessengerViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        inputBarView.textInputAreaView.addGestureRecognizer(swipeDown)
    }
    
    //MARK: Controller LifeCycle helper methods
    
    fileprivate func loadMessengerView() {
        messengerView = NMessenger(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 63))
        messengerView.delegate = self
        view.addSubview(messengerView)
    }
    
    fileprivate func loadInputView() {
        inputBarView = getInputBar()
        view.addSubview(inputBarView)
    }
    
    open func setBackgroundImage(_ image: UIImage) {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = image
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        messengerView.messengerNode?.isOpaque = false
        view.addSubview(imageViewBackground)
        view.sendSubview(toBack: imageViewBackground)
    }
    
    /**
     Override this method to create your own custom InputBarView
     - Returns: A view that extends InputBarView
     */
    open func getInputBar() -> InputBarView {
        return InputBarView(controller: self)
    }
    
    /**
     Adds auto layout constraints for NMessenger and InputBarView
     */
    fileprivate func setUpConstraintsForViews() {
        inputBarView.translatesAutoresizingMaskIntoConstraints = false
        inputBarBottomSpacing = NSLayoutConstraint(item: inputBarView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(inputBarBottomSpacing)
        view.addConstraint(NSLayoutConstraint(item: inputBarView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputBarView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputBarView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: inputBarView.frame.size.height))
        view.addConstraint(NSLayoutConstraint(item: inputBarView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 46))
        
        messengerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: messengerView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: messengerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: messengerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: messengerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: view.frame.size.height-100))
    }
    
    override open var shouldAutorotate: Bool {
        return UIDevice.current.orientation != .landscapeLeft
            && UIDevice.current.orientation != .landscapeRight
            && UIDevice.current.orientation != .unknown
    }
    
    //MARK: UIKeyboardWillChangeFrameNotification Selector
    /**
     Moves InputBarView up and down accoridng to the location of the keyboard
     */
    func keyboardNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if endFrame?.origin.y >= UIScreen.main.bounds.size.height {
                self.inputBarBottomSpacing.constant = 0
                self.messengerView.messengerNode?.view.contentInset = UIEdgeInsets.zero
                self.isKeyboardIsShown = false
            } else {
                self.inputBarBottomSpacing.constant = 0
                self.inputBarBottomSpacing.constant -= endFrame?.size.height ?? 0.0
                self.messengerView.messengerNode?.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame?.size.height ?? 0.0, right: 0)
                self.isKeyboardIsShown = true
            }
            
            if let contentInset = self.messengerView.messengerNode?.view.contentInset {
                self.messengerView.messengerNode?.view.scrollIndicatorInsets = contentInset
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            
                            self.view.layoutIfNeeded()
                            
                            if self.isKeyboardIsShown {
                                self.messengerView.scrollToLastMessage(true)
                            }
                            
            }, completion: nil
            )
        }
    }
    
    //MARK: Gesture Recognizers Selector
    
    /**
     Closes the messenger on swipe on InputBarView
     */
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        inputBarView.textInputView.resignFirstResponder()
    }
    
    //MARK: NMessengerViewController - override to create custom behavior
    /**
     Called when adding a text to the messenger. Override this function to add your message to the VC
     */
    open func sendText(_ text: String, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return postText(text, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called  when adding an image to the messenger. Override this function to add your message to the VC
     */
    open func sendImage(_ image: UIImage, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return postImage(image, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a network image to the messenger. Override this function to add your message to the VC
     */
    open func sendNetworkImage(_ imageURL: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return postNetworkImage(imageURL, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a collection view with views to the messenger. Override this function to add your message to the VC
     */
    open func sendCollectionViewWithViews(_ views: [UIView], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return postCollectionView(views, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a collection view with nodes to the messenger. Override this function to add your message to the VC
     */
    open func sendCollectionViewWithNodes(_ nodes: [ASDisplayNode], numberOfRows:CGFloat, isIncomingMessage:Bool) -> GeneralMessengerCell {
        return postCollectionView(nodes, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
    }
    
    
    /**
     Called when adding a a custom view to the messenger. Override this function to add your message to the VC
     */
    open func sendCustomView(_ view: UIView, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return postCustomContent(view, isIncomingMessage: isIncomingMessage)
    }
    
    /**
     Called when adding a a custom node to the messenger. Override this function to add your message to the VC
     */
    open func sendCustomNode(_ node: ASDisplayNode, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return postCustomContent(node, isIncomingMessage: isIncomingMessage)
    }
    
    //MARK: NMessengerViewController - Add message methods - DO NOT OVERRIDE
    /**
     DO NOT OVERRIDE
     Adds a message to the messenger
     - parameter message: GeneralMessageCell
     */
    open func addMessageToMessenger(_ message: GeneralMessengerCell) {
        message.currentViewController = self
        if message.isIncomingMessage == false {
            messengerView.addMessage(message, scrollsToMessage: true, withAnimation: .right)
        } else {
            messengerView.addMessage(message, scrollsToMessage: true, withAnimation: .left)
        }
    }
    
    /**
     Adds a general message to the messenger. Default animation is fade.
     */
    open func addGeneralMessageToMessenger(_ message: GeneralMessengerCell) {
        message.currentViewController = self
        messengerView.addMessage(message, scrollsToMessage: false, withAnimation: .fade)
    }
    
    /**
     Creates an incoming typing indicator
     - parameter avatar: an avatar to add to the typing indicator message
     */
    open func createTypingIndicator(_ avatar: ASDisplayNode?) -> GeneralMessengerCell {
        let typing = TypingIndicatorContent(bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: typing)
        newMessage.avatarNode = avatar
        
        return newMessage
    }
    
    /**
     Adds an incoming typing indicator to the messenger
     - parameter avatar: an avatar to add to the typing indicator message
     */
    open func showTypingIndicator(_ avatar: ASDisplayNode?) -> GeneralMessengerCell {
        let newMessage = createTypingIndicator(avatar)
        messengerView.addTypingIndicator(newMessage, scrollsToLast: false, animated: true, completion: nil)
        return newMessage
    }
    
    open func removeTypingIndicator(_ indicator: GeneralMessengerCell) {
        messengerView.removeTypingIndicator(indicator, scrollsToLast: false, animated: true)
    }
    
    //MARK: NMessengerViewController Helper methods
    
    open func createTextMessage(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: textContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    fileprivate func postText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let newMessage = createTextMessage(text, isIncomingMessage: isIncomingMessage)
        addMessageToMessenger(newMessage)
        return newMessage
    }
    
    open func createImageMessage(_ image: UIImage, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let imageContent = ImageContentNode(image: image, bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: imageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    fileprivate func postImage(_ image: UIImage, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let newMessage = createImageMessage(image, isIncomingMessage: isIncomingMessage)
        addMessageToMessenger(newMessage)
        return newMessage
    }
    
    open func createNetworkImageMessage(_ url: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let networkImageContent = NetworkImageContentNode(imageURL: url, bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: networkImageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    fileprivate func postNetworkImage(_ url: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let newMessage = createNetworkImageMessage(url, isIncomingMessage: isIncomingMessage)
        addMessageToMessenger(newMessage)
        
        return newMessage
    }
    
    open func createCollectionViewMessage(_ views: [UIView], numberOfRows: CGFloat, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let collectionViewContent = CollectionViewContentNode(withCustomViews: views, andNumberOfRows: numberOfRows, bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: collectionViewContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    fileprivate func postCollectionView(_ views: [UIView], numberOfRows: CGFloat, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let newMessage = createCollectionViewMessage(views, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
        addMessageToMessenger(newMessage)
        
        return newMessage
    }
    
    open func createCollectionNodeMessage(_ nodes: [ASDisplayNode], numberOfRows: CGFloat, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let collectionViewContent = CollectionViewContentNode(withCustomNodes: nodes, andNumberOfRows: numberOfRows, bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: collectionViewContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    fileprivate func postCollectionView(_ nodes: [ASDisplayNode], numberOfRows: CGFloat, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let newMessage = createCollectionNodeMessage(nodes, numberOfRows: numberOfRows, isIncomingMessage: isIncomingMessage)
        addMessageToMessenger(newMessage)
        
        return newMessage
    }
    
    open func createCustomContentViewMessage(_ view: UIView, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let customView = CustomContentNode(withCustomView: view, bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: customView)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    fileprivate func postCustomContent(_ view: UIView, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let newMessage = createCustomContentViewMessage(view, isIncomingMessage: isIncomingMessage)
        addMessageToMessenger(newMessage)
        
        return newMessage
    }
    
    open func createCustomContentNodeMessage(_ node: ASDisplayNode, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let customView = CustomContentNode(withCustomNode: node, bubbleConfiguration: sharedBubbleConfiguration)
        let newMessage = MessageNode(content: customView)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    fileprivate func postCustomContent(_ node: ASDisplayNode, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let newMessage = createCustomContentNodeMessage(node, isIncomingMessage: isIncomingMessage)
        addMessageToMessenger(newMessage)
        
        return newMessage
    }
    
    open func newMessageGroup(isIncoming: Bool) -> MessageGroup {
        let messageGroup = MessageGroup()
        messageGroup.isIncomingMessage = isIncoming
        messageGroup.cellPadding = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 7.0, right: 0.0)
        
        for n in messageGroup.subnodes {
            n.view.backgroundColor = .clear
        }
        
        return messageGroup
    }
    
    open func createTitleCell(_ title: String, textColor: UIColor) -> GeneralMessengerCell {
        let titleCell = MessageSentIndicator()
        titleCell.messageSentText = title
        titleCell.textColor = textColor
        
        return titleCell
    }
    
    open func createPlaceholderMessage(width: CGFloat?, height: CGFloat?, isIncomingMessage: Bool) -> GeneralMessengerCell {
        return createPlaceholderMessage(withImage: UIImage(named: "icPlaceholder"), width: width, height: height, isIncomingMessage: isIncomingMessage)
    }
    
    open func createPlaceholderMessage(withImage image: UIImage?, width: CGFloat?, height: CGFloat?, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let placeholder = image ?? UIImage()
        
        let imageContent = ImageContentNode(image: placeholder, bubbleConfiguration: imageBubbleConfiguration)
        imageContent.height = height
        imageContent.width = width
        imageContent.placeholderEnabled = false
        
        let newMessage = MessageNode(content: imageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    open func createLocalImageMessage(_ image: UIImage, isIncomingMessage: Bool) -> GeneralMessengerCell {
        let imageContent = ImageContentNode(image: image, bubbleConfiguration: imageBubbleConfiguration, contentMode: .scaleAspectFill)
        imageContent.imageTapDelegate = self
        
        let newMessage = MessageNode(content: imageContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = isIncomingMessage
        
        return newMessage
    }
    
    open func swapImageInMessage(_ messageNode: MessageNode, image: UIImage) {
        swapImageInMessage(messageNode, image: image, tapDelegate: self)
    }
    
    open func swapImageInMessage(_ messageNode: MessageNode, image: UIImage, tapDelegate: ImageTapDelegate) {
        let imageContentNode = ImageContentNode(image: image, bubbleConfiguration: imageBubbleConfiguration, contentMode: .scaleAspectFill)
        imageContentNode.imageTapDelegate = tapDelegate
        imageContentNode.view.alpha = 0.1
        
        UIView.animate(withDuration: 0.2, animations: {
            messageNode.contentNode?.view.alpha = 0
        }, completion: { success in
            UIView.animate(withDuration: 0.6) {
                imageContentNode.view.alpha = 1.0
            }
            messageNode.contentNode = imageContentNode
        })
    }
    
    open func imageTapped(_ image: UIImage, sender source: UIView) {
        let imageWrapper = FullScreenImageWrapper(image)
        let closeIcon = UIImage() // If close button is wanted replace with UIImage(named:"icClose")
        let buttonAssets = CloseButtonAssets(normal: closeIcon, highlighted: closeIcon)
        let configuration = ImageViewerConfiguration(imageSize: CGSize(width: image.size.width, height: image.size.height), closeButtonAssets: buttonAssets)
        
        let imageViewer = ImageViewerController(imageProvider: imageWrapper, configuration: configuration, displacedView: source)
        presentImageViewer(imageViewer)
    }
}
