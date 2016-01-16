//
//  MessageDetailViewController.swift
//  FamilyPlanner
//
//  Created by Julia Will on 16.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit

class MessageDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var sendAnswerButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var message : Message!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: show Messages
        //TODO: set Title to subject
        //TODO: slide view up with Keyboard
    }

    @IBAction func sendAnswerButtonTouch(sender: AnyObject) {
        print("New Answer to message")
    }
    
    //MARK: CollectionView
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("messageCell", forIndexPath: indexPath) as! MessageCollectionViewCell
        if indexPath.row == 0 {
            cell.messageText.text = message.message
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
}
