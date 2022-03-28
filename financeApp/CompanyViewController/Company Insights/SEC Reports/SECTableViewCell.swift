//
//  SECTableViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-01-29.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class SECTableViewCell: UITableViewCell {
    
    @IBOutlet weak var symbolLabel : UILabel!
    @IBOutlet weak var fillingDate : UILabel!
    @IBOutlet weak var more: UILabel!
    @IBOutlet weak var typeImage : UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        typeImage.tintColor = .label
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
