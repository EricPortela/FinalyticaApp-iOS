//
//  SecondViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-07-08.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import UserNotifications

class SecondViewController: UIViewController {
    
    var imageArray = [UIImage]()
    var screeningResults = [screenerFeed]()
    var orderedScreeningResults = [String]()
    
    
    @IBOutlet weak var stockScreenerCollectionView: UICollectionView!
    
    
    func getScreeningURL(companySelected : String) -> String {
        var ratioLink = ""
        ratioLink = "https://financialmodelingprep.com/api/v3/stock-screener?marketCapHigherThan=\(100000)&dividendMoreThan=\(0)&betaMoreThan=\(1)&volumeMoreThan=\(100)&exchange=NYSE,NASDAQ&apikey=\(apiKey)"
        return ratioLink
    }
    
    func getScreeningResults(urlString: String){
        self.screeningResults.removeAll()
        
        let url = URL(string: urlString)
        
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let ratioFeed = try decoder.decode([screenerFeed].self, from: data!)
                    
                    for periodRatios in ratioFeed {
                        self.screeningResults.append(periodRatios)
                        //self.createRatioArrayAndDict(val: periodRatios)
                    }
                    
                    DispatchQueue.main.async { [self] in
                        for companyData in self.screeningResults {
                            if let symbol = companyData.symbol, let marketCap = companyData.marketCap, let price = companyData.price, let dividend = companyData.lastAnnualDividend, let beta = companyData.beta {
                                self.orderedScreeningResults.append(symbol)
                                self.orderedScreeningResults.append(String(marketCap.abbreviateLargeNumbers(format: "%.0f")))
                                self.orderedScreeningResults.append(String(format: "%.2f", price) + "$")
                                self.orderedScreeningResults.append(String(format: "%.2f", dividend) + "$")
                                self.orderedScreeningResults.append(String(format: "%.2f", beta))
                            }
                        }
                        
                        self.stockScreenerCollectionView.reloadData()
                    }
                }
                catch {
                    print("Error in JSON parsing")
                }
            }
        }
        dataTask.resume()
    }
    
    
    func favoriteStockNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            
            let content = UNMutableNotificationContent()
            content.title = "Notification Finalytica"
            content.body = "Body"
            
            let date = Date().addingTimeInterval(5)
            
            let dateComponenets = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponenets, repeats: true)
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            center.add(request) { (error) in
            }
        }
    }
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = stockScreenerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true //makes header "sticky"
        stockScreenerCollectionView.register(StockScreenerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        let ticker = SearchViewController.GlobalVariable.myString
        let urlString = getScreeningURL(companySelected: ticker)
        
        getScreeningResults(urlString: urlString)
        
        favoriteStockNotifications()
    }
    
}

extension SecondViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (orderedScreeningResults.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = stockScreenerCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? StockScreenerCollectionViewCell
        
        cell?.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        
        if orderedScreeningResults.count != 0 {
            cell?.label.text = orderedScreeningResults[indexPath.row]
        }
                
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat
        let height: CGFloat
        
        width = (UIScreen.main.bounds.size.width)/5
        height = 40
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat
        let height: CGFloat
        
        width = (UIScreen.main.bounds.size.width) - 40
        height = 50
        
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = stockScreenerCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? ScreenerCollectionReusableView
        
        headerView?.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        
        return headerView!
    }
}
