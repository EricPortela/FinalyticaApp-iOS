//
//  DashboardCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-25.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class DashboardCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!
    
    let cellWidth = (UIScreen.main.bounds.size.width - 40.0)
    let cellHeight = 70
    
    override func layoutSubviews() {
        positionSegmentedControl(segmentedControl: segmentedControl)
        positionFilterButton(button: filterButton)
    }
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Income", "Balance", "Cash Flow"]
        let segControl = UISegmentedControl(items: items)
        segControl.selectedSegmentIndex = 0
        return segControl
    }()
    
    let filterButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .tertiarySystemBackground
        return btn
    }()
    
    func positionSegmentedControl(segmentedControl: UISegmentedControl){
        let width = Int(cellWidth)
        let height = 32
        segmentedControl.frame = CGRect(x: 0, y: 55, width: width, height: height)
        self.addSubview(segmentedControl)
    }
    
    func positionFilterButton(button: UIButton) {
        let width = Int(cellWidth*0.08)
        let height = width
        button.frame = CGRect(x: (Int(cellWidth) - (width)), y: 20, width: width, height: height)
        self.addSubview(button)
    }
}
