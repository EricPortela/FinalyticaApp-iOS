//
//  DatePopUpViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-09-13.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import FirebaseDatabase


protocol yearQuarterSelection {
    func updateCompanyTable(yearQuarter : String)
}

var yearAndQuarter = "2018Q4"

class DatePopUpViewController: UIViewController {
    
    var selectionDelegate : yearQuarterSelection!
    var yearForFundData = "2018Q4"
    
    @IBOutlet weak var yearPicker: UIPickerView!
    @IBOutlet var datePopUp: UIView!
    var ref: DatabaseReference!
    var pickerDates = [String]()
    
    @IBAction func closePopUp(_ sender: Any) {
        selectionDelegate.updateCompanyTable(yearQuarter: yearForFundData)
        
        yearAndQuarter = yearForFundData
        
        //MutualFundsController().updateFundData(yearQuarter: yearForFundData)
        //self.navigationController?.pushViewController(back, animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        ref = Database.database().reference()
        
        //Retrieve company names data and listen for changes
        ref.child("Fondinnehav/PickerYears").observe(.childAdded, with: { (snapshot) in
            
            //Code to execute when a new child in the database is added
            //Extract value from snapshot and add to array
            
            let year = snapshot.value as? String
            
            if let actualYear = year {
                self.pickerDates.append(actualYear)
            }
            self.yearPicker.reloadAllComponents()
        })
    }
}


extension DatePopUpViewController : UIPickerViewDataSource, UIPickerViewDelegate{
    
    func pickerView (_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDates[row]
     }

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDates.count
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        yearForFundData = pickerDates[row]
    }
}
