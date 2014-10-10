//
//  BezierView.swift
//  LiveLine
//
//  Created by Rhys Powell on 10/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit

class BezierView: UIView {
    
    var path: UIBezierPath? = nil

    override func drawRect(rect: CGRect)
    {
        UIColor.liveLineRedColor().setStroke()
        path?.stroke()
    }

}
