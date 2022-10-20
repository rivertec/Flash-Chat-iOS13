//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
    ]
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "ChatChatChat"
        navigationItem.hidesBackButton = true
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        loadMessages()
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
    }
    
    func loadMessages() {
        
        db.collection(K.FStore.collectionName)
            .order(by: "date", descending: false)
            .addSnapshotListener { [self] querySnapshot, error in
                
            if let e = error {
                print("error while retrieving data \(e)")
                
            } else {
                messages = []
            
                if let snapshotDocuments = querySnapshot?.documents {

                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let messageSender = data[K.FStore.senderField] as! String
                        let messageBody = data[K.FStore.bodyField] as! String
                        let messageTime = Date().timeIntervalSince1970
                        
                        let newMessage = Message(sender: messageSender, body: messageBody, time: messageTime)
                        messages.append(newMessage)
                        
                        // need to search DispatchQueue
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        let currentTime = Date()
        let messageDate = currentTime.timeIntervalSinceReferenceDate
        
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email { db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.bodyField: messageBody, K.FStore.senderField: messageSender, K.FStore.dateField: messageDate]) { error in
                if let e = error {
                    print("there was an issue while saving data to FireStore \(e)")
                } else {
                    print("Data Saved. \(messageBody)")

                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                    //                    self.loadMessages()
                }
            }
        }
    }
    
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        
        do {
            try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        cell.messageLabel.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        
        
        
        return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    
}
