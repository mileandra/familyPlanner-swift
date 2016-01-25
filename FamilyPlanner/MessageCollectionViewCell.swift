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
    var own:Bool = true
    
    override func drawRect(rect: CGRect) {
        messageText.sizeToFit()
        let frame = messageText.frame
        let padding:CGFloat = 5.0
        
        //TODO: switch sides and color by user
        if own == true {
            //// Color Declarations
            let color = UIColor(red: 0.926, green: 0.971, blue: 0.965, alpha: 1.000)
            
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath(roundedRect: CGRectMake(frame.minX-padding, frame.minY-padding, frame.maxX+padding, frame.maxY+padding), cornerRadius: 5)
            color.setFill()
            rectanglePath.fill()
        }
    }
}
