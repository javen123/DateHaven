//
//  SwipeView.swift
//  DateHaven
//
//  Created by Jim Aven on 5/11/15.
//  Copyright (c) 2015 Jim Aven. All rights reserved.
//

import Foundation
import UIKit

protocol SwipeViewDelegate: class {
    func swipedLeft()
    func swipedRight()
}

class SwipeView: UIView {
    
    enum Direction {
        case None
        case Left
        case Right
    }
    
    weak var delegate:SwipeViewDelegate?
    
    let overlay: UIImageView = UIImageView()
    
    var direction:Direction?
    
    var innerView: UIView? {
        didSet {
            if let v = innerView {
                insertSubview(v, belowSubview: overlay)
                addSubview(v)
                v.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            }
        }
    }
    
    
    
    private var originalPoint: CGPoint?
    private let card: CardView = CardView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init(){
        self.init(frame:CGRectZero)
        initialize()
    }

    private func initialize() {
        self.backgroundColor = UIColor.clearColor()
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "dragged:"))
        overlay.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(overlay)
    }

    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        let distance = gestureRecognizer.translationInView(self)
        
        switch gestureRecognizer.state{
        case UIGestureRecognizerState.Began:
            originalPoint = center
        case UIGestureRecognizerState.Changed:
            
            let rotationPercent = min(distance.x/(self.superview!.frame.width/2), 1)
            let rotationAngle = (CGFloat(2*M_PI/16)*rotationPercent)
            transform = CGAffineTransformMakeRotation(rotationAngle)
            center = CGPointMake(originalPoint!.x + distance.x, originalPoint!.y + distance.y)
            updateOverlay(distance.x)
            
        case UIGestureRecognizerState.Ended:
            
            if abs(distance.x) < frame.width/4 {
                resetViewPositionAndTransformations()
            }
            else {
                swipe(distance.x > 0 ? .Right : .Left)
            }
        
        default:
            println("Default trigged for GestureRecognizer")
            break
        }
    }
    
    func swipe(s: Direction) {
        
        if s == .None {
            return
        }
        var parentWidth = superview!.frame.size.width
        if s == .Left {
            parentWidth *= -1
        }
        
        UIView.animateWithDuration(0.2, animations: {
            self.center.x = self.frame.origin.x + parentWidth
            }, completion: {
                
                success in
                if let d = self.delegate {
                    s == .Right ? d.swipedRight() : d.swipedLeft()
                }
        })
        
    }
    
    private func updateOverlay(distance:CGFloat){
        
        var newDirection: Direction
        newDirection = distance < 0 ? .Left : .Right
        
        if newDirection != direction {
            direction = newDirection
            overlay.image = direction == .Right ? UIImage(named: "yeah-stamp") : UIImage(named: "nah-stamp")
        }
        overlay.alpha = abs(distance) / (superview!.frame.width)
        
    }

    
    private func resetViewPositionAndTransformations() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.center = self.originalPoint!
            self.transform = CGAffineTransformMakeRotation(0)
            self.overlay.alpha = 0
        })
    }
}
