//
//  MutualFundsController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-09-09.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import FirebaseDatabase


class MutualFundsController: UIViewController {
    
    var ref: DatabaseReference!
    var companyFundName = [String]()
    var companyFunds = [String]()
    var allCompanyFunds = [[String]]()
    var refreshControl = UIRefreshControl()
    
    
    @IBOutlet weak var screenerCollectionView: UICollectionView!
    
    @IBAction func openDatePopUp(_ sender: Any) {
         
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "datePickerPopUp") as! DatePopUpViewController
                 
        popOverVC.selectionDelegate = self
        
        popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        tabBarController?.present(popOverVC, animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshFundData), for: .valueChanged)
        screenerCollectionView.addSubview(refreshControl)

        
        //Set the firebase reference
        ref = Database.database().reference()
         
        //Retrieve company names data and listen for changes
        ref.child("Fondinnehav/2018Q4/1Companies").observe(.childAdded, with: { (snapshot ) in
            
            //Code to execute when a new child in the database is added
            //Extract value from snapshot and add to array
            
            let fund = snapshot.key
            self.companyFundName.append(fund)
            self.screenerCollectionView.reloadData()
            
            
            let data = snapshot.value as? [String:String]
            for (_,v) in data! {
                self.companyFunds.append(v)
            }
            
            self.allCompanyFunds.append(self.companyFunds)
            self.companyFunds = [String]()
            self.screenerCollectionView.reloadData()
        })
    }
    
    
    @objc func refreshFundData() {
        companyFunds = []
        companyFundName = []
        
        var ref: DatabaseReference!

        //Set the firebase reference
        ref = Database.database().reference()

        //Retrieve company names data and listen for changes
        ref.child("Fondinnehav/\(yearAndQuarter)/1Companies").observe(.childAdded, with: { (snapshot ) in

        //Code to execute when a new child in the database is added
        //Extract value from snapshot and add to array
        let fund = snapshot.key
        self.companyFundName.append(fund)
        self.screenerCollectionView.reloadData()

        let data = snapshot.value as? [String:String]
            for (_,v) in data! {
            self.companyFunds.append(v)
        }
            
        self.allCompanyFunds.append(self.companyFunds)
        self.companyFunds = [String]()
        self.screenerCollectionView.reloadData()
        self.refreshControl.endRefreshing()
        })
    }
}


extension MutualFundsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, yearQuarterSelection {
    
    func updateCompanyTable(yearQuarter: String) {
        companyFunds = []
        companyFundName = []
        
        //Set the firebase reference
        ref = Database.database().reference()

        //Retrieve company names data and listen for changes
        ref.child("Fondinnehav/\(yearQuarter)/1Companies").observe(.childAdded, with: { (snapshot ) in

        //Code to execute when a new child in the database is added
        //Extract value from snapshot and add to array

        let fund = snapshot.key
        self.companyFundName.append(fund)
        self.screenerCollectionView.reloadData()
        

        let data = snapshot.value as? [String:String]
        for (_,v) in data! {
            self.companyFunds.append(v)
        }
        
        self.allCompanyFunds.append(self.companyFunds)
        self.companyFunds = [String]()
        self.screenerCollectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        var standardCellSize = CGSize(width: screenWidth - 15, height: 100)
        return standardCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companyFundName.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (screenerCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell)
        
        
        cell?.contentView.layer.cornerRadius = 20
        
        //let correctedCompanyName = String(describing:(companyFundName[indexPath.row]).cString(using: String.Encoding.utf8))
        //print(correctedCompanyName)
                
        cell?.nameFund.text = companyFundName[indexPath.row]
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popUpFund") as! FundPopUpViewController
        
        let company = companyFundName[indexPath.row]
        
        popOverVC.company = (company) //add the current company name to the variable "company" in FundPopUpViewController
        
        popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        tabBarController?.present(popOverVC, animated: true, completion: nil) //This line enables the custom popover to cover the whole area of the underlying "root-view", in this case the tab bar controller, hence tabBarController?.present....
        
        //let details = storyboard.instantiateViewController(withIdentifier: "showFundData") as! AboutFundScreener
        //details.fund = (companyFundName[indexPath.row]) as! String
        //self.navigationController?.present(details, animated: true, completion: nil)
        
        //pushViewController(details, animated: true)
        }
    }

