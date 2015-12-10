//
//  CustomizableTextField.swift
//  FamilyPlanner
//
//  Created by Julia Will on 10.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import UIKit

@IBDesignable class CustomizableTextField: UITextField {

    @IBInspectable var placeholderColor: UIColor = UIColor.lightGrayColor()
    
    @IBInspectable var borderTopWidth: CGFloat = 0
    @IBInspectable var borderRightWidth: CGFloat = 0
    @IBInspectable var borderBottomWidth: CGFloat = 0
    @IBInspectable var borderLeftWidth: CGFloat = 0
    
    @IBInspectable var borderColor: UIColor = UIColor.blackColor()
    
    #if !TARGET_INTERFACE_BUILDER
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    #endif
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if placeholder != nil {
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName: placeholderColor])
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 0.0)
        
        // Border Top
        if (borderTopWidth > 0) {
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextSetLineWidth(context, borderTopWidth)
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect))
            CGContextStrokePath(context)
        }
        
        // Border Right
        if (borderRightWidth > 0) {
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextSetLineWidth(context, borderRightWidth)
            CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect))
            CGContextStrokePath(context)
        }
        
        // Border Bottom
        if (borderBottomWidth > 0) {
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextSetLineWidth(context, borderBottomWidth)
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect))
            CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect))
            CGContextStrokePath(context)
        }
        
        // Border Left
        if (borderLeftWidth > 0) {
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            CGContextSetLineWidth(context, borderLeftWidth)
            CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect))
            CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect))
            CGContextStrokePath(context)
        }
    }
    
}
