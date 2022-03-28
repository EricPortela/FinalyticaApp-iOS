//
//  KPICollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2020-11-27.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import Charts

class KPICollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var KPILbl: UILabel!
    @IBOutlet weak var KPIValue: UILabel!
    @IBOutlet weak var KPIDate: UILabel!
    @IBOutlet weak var miniBarChart: BarChartView!
}
