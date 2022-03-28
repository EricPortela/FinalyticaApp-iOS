//
//  HoldingsCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2020-09-13.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import Lottie

class HoldingsCollectionViewCell: UICollectionViewCell {
    
    //These are to be shown when cell is closed
    @IBOutlet weak var holdingsName: UILabel!
    @IBOutlet weak var holdingsISIN: UILabel!
    
    @IBOutlet weak var amountOfInstruments: UILabel!
    
    //These are to be showed when cell is opened
    @IBOutlet weak var marketValueTitle: UILabel!
    @IBOutlet weak var marketValue: UILabel!
    
    @IBOutlet weak var amountTitle: UILabel!
    @IBOutlet weak var amountValue: UILabel!
    
    @IBOutlet weak var fractionTitle: UILabel!
    @IBOutlet weak var fractionValue: UILabel!
    
    @IBOutlet weak var assetTypeTitle: UILabel!
    @IBOutlet weak var assetTypeValue: UILabel!

    
}
