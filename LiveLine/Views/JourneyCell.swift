//
//  JourneyCell.swift
//  LiveLine
//
//  Created by Rhys Powell on 10/10/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

import UIKit

class JourneyCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel! = nil
    @IBOutlet weak var dateLabel: UILabel! = nil
    @IBOutlet weak var distanceLabel: UILabel! = nil
    @IBOutlet weak var bezierView: BezierView! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
