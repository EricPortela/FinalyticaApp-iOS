//
//  FundPopUpViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-09-12.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FundPopUpViewController: UIViewController {

    @IBOutlet weak var closePopUp: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fundsCollection: UICollectionView!
    @IBOutlet weak var fundName: UILabel!
    var ref: DatabaseReference!
    
    var company = String()
    var fundsArray = [String]()

    
    
    @IBAction func closePopUpView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 5
        closePopUp.layer.cornerRadius = 5
        fundName.text = company
        
        ref = Database.database().reference()
        
        //Listen for types of funds each company has
        ref.child("Fondinnehav/\(yearAndQuarter)/1Companies/\(company)").observe(.value) { (snapshot) in
            let dataFund = snapshot.value as? [String:Any]
            if let actualDataFund = dataFund {
                for (k,_) in actualDataFund {
                    self.fundsArray.append(k)
                    }
                self.fundsCollection.reloadData()
                }
            }
        }
    }


extension FundPopUpViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fundsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (fundsCollection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? FundPopUpCollectionViewCell)
        
        let sortedFundsArray = fundsArray.sorted()

        cell?.contentView.layer.cornerRadius = 20
        cell?.fundLbl.text = sortedFundsArray[indexPath.row]
        cell?.numberFund.text = String(indexPath.row + 1)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let details = storyboard.instantiateViewController(withIdentifier: "showFundData") as! AboutFundScreener
        let sortedFundsArray = fundsArray.sorted()
        print(sortedFundsArray[indexPath.row])
        details.fund = sortedFundsArray[indexPath.row]
        details.company = company
        self.present(details, animated: true, completion: nil)
    }
}
