//
//  HorizontalAnalysisHeaderCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-10-11.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class HorizontalAnalysisHeaderCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    let cellWidth = UIScreen.main.bounds.size.width - 40
    let cellHeight = 25
    
    let headerLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        return lbl
    }()
    
    let periodDropDown: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "Dropdown_2.png")
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    let periodDropDownLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "x Years"
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        return lbl
    }()
    
    let typeDropDown: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "Dropdown_2.png")
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    let typeDropDownLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Income Statement"
        lbl.font = UIFont(name: "HelveticaNeue", size: 12)
        return lbl
    }()
    
    func setUpView() {
        
        //Header Label
        headerLbl.frame = CGRect(x: 20, y: 10, width: cellWidth, height: 20)
        self.addSubview(headerLbl)
        
        //General drop down menu sizes
        let dropDownWidth = (cellWidth-40)/2
        let dropDownHeight = CGFloat(34)
        let yPosMenu = CGFloat(40)
        
        //General size for drop down menu button
        let lblWidthDropDown = dropDownWidth - 20
        let lblHeightDropDown = CGFloat(26)
        let xPosLblDropDown = CGFloat(10)
        let yPosLblDropDown = CGFloat(dropDownHeight - lblHeightDropDown)/2
        
        //Drop Down menu button (period)
        let xPosMenuPeriod = CGFloat(20)
        periodDropDown.frame = CGRect(x: xPosMenuPeriod, y: yPosMenu, width: dropDownWidth, height: dropDownHeight)
        self.addSubview(periodDropDown)
        
        //Drop down label (period)
        periodDropDownLabel.frame = CGRect(x: xPosLblDropDown, y: yPosLblDropDown, width: lblWidthDropDown, height: lblHeightDropDown)
        periodDropDown.addSubview(periodDropDownLabel)
        
        //Drop Down menu button (type)
        let xPosMenuType = 20 + dropDownWidth + 40
        typeDropDown.frame = CGRect(x: xPosMenuType, y: yPosMenu, width: dropDownWidth, height: dropDownHeight)
        self.addSubview(typeDropDown)
        
        //Drop down label (type)
        typeDropDownLabel.frame = CGRect(x: xPosLblDropDown, y: yPosLblDropDown, width: lblWidthDropDown, height: lblHeightDropDown)
        typeDropDown.addSubview(typeDropDownLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
