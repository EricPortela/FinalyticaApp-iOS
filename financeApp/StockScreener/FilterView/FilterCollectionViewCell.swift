//
//  FilterCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-04-25.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    var cellWidth = Int(UIScreen.main.bounds.size.width - 40)/3
    let cellHeight = 40
    
    let pickerViewType = UIPickerView()
    let pickerViewLimit = UIPickerView()
    let filterChoices = ["marketCap", "price", "dividend", "beta", "volume"]
    let limitChoices = [">", "<", "="]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.textAlignment = .center
        label.text = "n/A"
        return label
    }()
    
    let textField: UITextField = {
        let txtField = UITextField()
        txtField.textAlignment = .center
        txtField.text = ""
        return txtField
    }()
    
    func positionTextField(txtField: UITextField) {
        txtField.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
        self.addSubview(txtField)
    }
    
    func setUpViews() {
        positionTextField(txtField: textField)
        
        pickerViewType.delegate = self
        pickerViewType.dataSource = self
        
        pickerViewLimit.delegate = self
        pickerViewLimit.dataSource = self
    }
}

extension FilterCollectionViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewLimit {
            return limitChoices.count
        }
        
        return filterChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerViewLimit {
            return limitChoices[row]
        }
        return filterChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewType {
            textField.text = filterChoices[row]
        }
        else if pickerView == pickerViewLimit{
            textField.text = limitChoices[row]
        }
        
        textField.resignFirstResponder()
    }
}

