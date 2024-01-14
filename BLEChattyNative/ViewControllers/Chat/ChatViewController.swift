//
//  ChatViewController.swift
//  BLEChattyNative
//
//  Created by Shane Whitehead on 21/8/18.
//  Copyright © 2018 Beam Communications. All rights reserved.
//

import UIKit
import Cadmus
import Hermes

protocol MessageDelegate {
    func send(message: String)
}

class ChatViewController: UIViewController {
    
    var messageViewController: MessageViewController!
    var chatTableViewController: ChatTableViewController!
    
    var keyboardHelper: KeyboardHelper = KeyboardHelper()
    
    var currentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    var client: ChatClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "\(client.avatar) \(client.displayName)"
        
        dismissKeyboardOnTap = false
        displaceOnKeyboard = true
        
        keyboardHelper.delegate = self
        keyboardHelper.isInstalled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageWasRecieved), name: ChatServiceManager.MessageRecieved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageWasDelivered), name: ChatServiceManager.MessageDelivered, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissKeyboardOnTap = false
        displaceOnKeyboard = false
        
        keyboardHelper.isInstalled = false
        keyboardHelper.delegate = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private var isFirstLayout = true
    private var layoutPass = 0;
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 😓 Okay, so, apparently, the "safe" areas aren't populated till
        // the layout pass, but the size of the messaging area doesn't seem
        // to be set (properly) until the second layout pass
        // So we can't use willAppear to offset the table view and viewDidAppear
        // causes a visual change which is not pleasent, so we jump through some
        // hoops to make this work
        guard isFirstLayout else {
            return
        }
        layoutPass += 1
        guard layoutPass > 1 else {
            return
        }
        // Not sure this is really needed, but...
        isFirstLayout = false;
        let bounds = messageViewController.view.bounds
        let leftOver = bounds.height - currentInsets.bottom
        
        chatTableViewController.tableView.contentInset.top = leftOver
        chatTableViewController.scrollToTop(animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if segue.identifier == "Segue.message" {
            destination.view.translatesAutoresizingMaskIntoConstraints = false
            guard let controller = destination as? MessageViewController else {
                return
            }
            messageViewController = controller
            messageViewController.currentInsets = currentInsets
            messageViewController.delegate = self
        } else if segue.identifier == "Segue.conversation" {
            guard let controller = destination as? ChatTableViewController else {
                return
            }
            chatTableViewController = controller
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension ChatViewController: KeyboardHelperDelegate {
    
    func changeTableViewContentInset(_ inset: CGFloat, offset: CGFloat, with event: KeyboardEvent) {
        guard let duration = event.duration, let curve = event.curve else {
            chatTableViewController.tableView.contentInset.top += inset
            return
        }
        chatTableViewController.tableView.contentInset.top += inset
        self.chatTableViewController.tableView.contentOffset.y += offset
        UIView.animate(withDuration: duration, delay: 0, options: [curve], animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
        }
    }
    
    func keyboardWillShow(with event: KeyboardEvent) {
        let safeInsets = view.safeAreaInsets
        // Life is hard when you're inverted :/
        let offset = chatTableViewController.isAtTop ? -safeInsets.bottom : safeInsets.bottom
        changeTableViewContentInset(-safeInsets.bottom,
                                     offset: offset,
                                     with: event)
    }
    
    func keyboardWillHide(with event: KeyboardEvent) {
        let safeInsets = view.safeAreaInsets
        // Don't ask, I don't care
        // To many issues around trying to get this to work in a sane way
        changeTableViewContentInset(safeInsets.bottom,
                                    offset: -safeInsets.bottom,
                                    with: event)
    }
    
    // MARK: - Notification
    
    @objc func messageWasRecieved(_ notification: Notification) {
        log(debug: "")
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.messageWasRecieved(notification)
            }
            return
        }
        guard let userInfo = notification.userInfo else {
            log(debug: "didReceiveWrite notification without userInfo")
            return
        }
        guard let message = userInfo[ChatServiceManager.MessageKeys.message] as? IncomingMessage else {
            log(debug: "didReceiveWrite notification without device")
            return
        }
        
        if message.client == client {
            chatTableViewController.add(message)
        } else {
            let name = message.client.displayName
            let text = message.text
            
            log(debug: "Message = \(text);\n\tfrom: \(name)")
            
            NotificationServiceManager.shared.add(
                identifier: UUID().uuidString,
                title: "\(name) said", body: text
            )
            .catch { (error) -> (Void) in
                log(debug: "Failed to deliver notification \(error)")
            }
        }
    }
    
    @objc func messageWasDelivered(_ notification: Notification) {
        log(debug: "")
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.messageWasRecieved(notification)
            }
            return
        }
        guard let userInfo = notification.userInfo else {
            log(debug: "didReceiveWrite notification without userInfo")
            return
        }
        guard let message = userInfo[ChatServiceManager.MessageKeys.message] as? Message else {
            log(debug: "didReceiveWrite notification without device")
            return
        }
        chatTableViewController.update(message)
    }
    
}

extension ChatViewController: MessageDelegate {
    func send(message: String) {
        var msg = DefaultMessage(text: message, direction: .outgoing, status: .sending)
        chatTableViewController.add(msg)
        do {
            try client.write(message: message)
        } catch (let error) {
            log(error: "Failed to write message: \(error)")
            msg = DefaultMessage(text: message, direction: .outgoing, status: .failed)
            chatTableViewController.update(msg)
        }
    }
}
