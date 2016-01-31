//
//  MessageCollectionViewCell.swift
//  FamilyPlanner
//
//  Created by Julia Will on 16.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var metaInfoText: UILabel!
    
    var own:Bool = true
    
    override func drawRect(rect: CGRect) {
        messageText.sizeToFit()
    }
}
