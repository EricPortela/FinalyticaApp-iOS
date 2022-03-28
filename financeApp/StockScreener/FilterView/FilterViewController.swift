//
//  FilterViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-04-25.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

protocol filterSelectionDelegate {
    func didSelectFilters(type: String, limit: String, value: String)
}

class FilterViewController: UIViewController {
    
    var selectionDelegate: filterSelectionDelegate!
    var typeArray = [String]()
    var limitArray = [String]()
    var valueArray = [String]()
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBAction func applyFilterButton(_ sender: Any) {
        //selectionDelegate.didSelectFilters(type: <#T##String#>, limit: <#T##String#>, value: <#T##String#>)
    }
    

    let filterChoices = ["marketCap", "price", "dividend", "beta", "volume"]


    override func viewDidLoad() {
        super.viewDidLoad()
        filterCollectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "filterCell")


    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filterChoices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        width = (UIScreen.main.bounds.size.width - 40)/3
        height = 50
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as? FilterCollectionViewCell
        
        if indexPath.row == 0{
            cell?.textField.inputView = cell?.pickerViewType
        } else if indexPath.row == 1{
            cell?.textField.inputView = cell?.pickerViewLimit
        } else {
            cell?.textField.keyboardType = .numberPad
        }
        
        cell?.layer.backgroundColor = UIColor.red.cgColor //label.text = filterChoices[indexPath.section]
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print()
    }
}

