//
//  LayoutContainerView.swift
//  DigitalVelocity
//
//  Created by George Webster on 3/19/15.
//  Copyright (c) 2015 Tealium. All rights reserved.
//

import UIKit

protocol LayoutContainerViewDatasource {
    
    func imageDataForLayout(layout:LocationDataLayout) -> NSData?
}

class LayoutContainerView: UIScrollView, UIScrollViewDelegate {

    var imageView:UIImageView
    
    var locationData:LocationDataLayout? {
        
        didSet {
            
            updateView()
        }
    }

    var datasource:LayoutContainerViewDatasource?
    
    override init(frame: CGRect) {

        let ivFrame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))
        self.imageView = UIImageView(frame: ivFrame)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: frame)
        
        self.delegate = self;
        self.scrollEnabled = true
        
        self.addSubview(self.imageView)

//        let viewsDictionary = NSDictionary(object: self.imageView, forKey: "imageView")
        let viewsDictionary = ["imageView":self.imageView]

        let hConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.addConstraints(hConstraint)
        let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.addConstraints(vConstraint)
        

        self.minimumZoomScale = 0.5
        self.maximumZoomScale = 1.0
        
        updateView()
    }
    

    required init?(coder aDecoder: NSCoder) {
        
        self.imageView = UIImageView(frame: CGRectZero)
        
        super.init(coder: aDecoder)
    }
    
    func updateView() {
    
        if let layout:LocationDataLayout = locationData {
            
            if let ds = datasource {
            
                if let data = ds.imageDataForLayout(layout) {
                    if let image = UIImage(data: data) {
                        
                        self.zoomScale = 1
                        
                        contentOffset = CGPointZero
                        
                        imageView.image = image
                        imageView.sizeToFit()
                        
                    }
                }
            }
        }
        
        contentSize = CGSize(width: CGRectGetWidth(imageView.frame), height: CGRectGetHeight(imageView.frame))
        
        let scaleWidth = CGRectGetWidth(self.frame) / CGRectGetWidth(imageView.frame)
        let scaleHeight = CGRectGetHeight(self.frame) / CGRectGetHeight(imageView.frame)
        
        self.minimumZoomScale = min(scaleWidth, scaleHeight)

        let zoomRect = rectForZoomingToScale(scaleHeight)
        self.zoomToRect(zoomRect, animated: false)
    }

    func rectForZoomingToScale(scale:CGFloat) -> CGRect {
        
        let zoomWidth = CGRectGetWidth(self.frame) / scale
        let zoomHeight = CGRectGetHeight(self.frame) / scale
        let zoomX = CGRectGetMidX(self.frame) - (CGRectGetWidth(self.frame) / 2)
        let zoomY = CGRectGetMidY(self.frame) - (CGRectGetHeight(self.frame) / 2)
        
        return CGRect(x: zoomX, y: zoomY, width: zoomWidth, height: zoomHeight)
    }
    
    // MARK: UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}
