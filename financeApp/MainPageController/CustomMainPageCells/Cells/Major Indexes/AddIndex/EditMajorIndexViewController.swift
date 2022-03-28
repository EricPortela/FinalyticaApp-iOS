//
//  EditMajorIndexViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-08-31.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class EditMajorIndexViewController: UIViewController {
    
    var joinedIndexSymbols: String = ""
    var batchPriceData: [majorIndexBatchFeed] = []
    
    struct majorIndex {
        var symbol: String?
        var name: String?
        var close: Double?
        var yearHigh: Double?
        var yearLow: Double?
        var change: Double?
        var pctChange: Double?
        var isSelected: Bool
    }

    @IBOutlet weak var indexCollectionView: UICollectionView!
    
    var completeIndexData: [majorIndex] = []
    var indexSearchResult: [majorIndex] = []
    var indexData: [majorIndexFeed] = []
    var searching = false
    
    let searchBar = UISearchBar()
    
    let dispatchGroup = DispatchGroup()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        setUpSearchBar()
        
        //let url = "https://financialmodelingprep.com/api/v3/quotes/index?apikey=\(apiKey)"
        //getAvailableIndexes(url: url)
        concurrentApiCalls()
    }
    
    func setUpCollectionView() {
        indexCollectionView.delegate = self
        indexCollectionView.dataSource = self
        //indexCollectionView.register(MajorIndexCollectionViewCell.self, forCellWithReuseIdentifier: "indexCell")
        indexCollectionView.register(SearchIndexCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "searchIndexHeader")
        indexCollectionView.register(AddIndexCollectionViewCell.self, forCellWithReuseIdentifier: "indexCell")
        indexCollectionView.register(FavoriteStocksTopCollectionViewCell.self, forCellWithReuseIdentifier: "descriptionCell")
        
        let layout = indexCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumInteritemSpacing = 10
        layout?.sectionHeadersPinToVisibleBounds = true
    }
    
    func setUpSearchBar() -> Void {
        searchBar.delegate = self
        searchBar.placeholder = "Search by name or symbol"
        searchBar.backgroundImage = UIImage()
    }
    
    func concurrentApiCalls() {
        
        let majorIndexURL = "https://financialmodelingprep.com/api/v3/quotes/index?apikey=\(apiKey)"
        getAvailableIndexes(url: majorIndexURL)
        
        dispatchGroup.notify(queue: .main) {
            print("All requests have been made")
            self.sortData()
            self.indexSearchResult = self.completeIndexData
            self.indexCollectionView.reloadData()
        }
    }
    
    func sortData() {
        completeIndexData.sort {
            let first = $0.name ?? "z" //$0.symbol?.replacingOccurrences(of: "^", with: "") ?? "z"
            let second = $1.name ?? "z" //$1.symbol?.replacingOccurrences(of: "^", with: "") ?? "z"
            return first < second
        }
    }
        
    func getAvailableIndexes(url: String) {
        completeIndexData.removeAll()
        
        dispatchGroup.enter()
        let url = URL(string: url)
        
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let dataFeed = try decoder.decode([majorIndexFeed].self, from: data!)
                    
                    DispatchQueue.main.async {
                        for idxData in dataFeed {
                            if let symbol = idxData.symbol, let name = idxData.name, let close = idxData.price, let yearHigh = idxData.yearHigh, let yearLow = idxData.yearLow, let change = idxData.change, let pctChange = idxData.changesPercentage {
                                let majorIndexData = majorIndex(symbol: symbol, name: name, close: close, yearHigh: yearHigh, yearLow: yearLow, change: change, pctChange: pctChange, isSelected: false)
                                self.completeIndexData.append(majorIndexData)
                            }
                        }
                    }
                    
                    
                    /*
                    DispatchQueue.main.async {
                        var count = 0
                        for index in dataFeed {
                            count += 1
                            if let symbol = index.symbol {
                                let modifiedSymbol = symbol.replacingOccurrences(of: "^", with: "")
                                self.joinedIndexSymbols += "%5E\(modifiedSymbol),"
                            }
                            
                            if count % 5 == 0{
                                let url = "https://financialmodelingprep.com/api/v3/historical-price-full/\(self.joinedIndexSymbols)?apikey=\(apiKey)"
                                print(url)
                                self.getBatchPriceData(url: url)
                                self.joinedIndexSymbols = ""
                            }
                        }
                        print(self.batchPriceData)
                    }
                    */
                    
                    self.dispatchGroup.leave()
                }
                catch {
                    print("Error in JSON parsing")
                    self.dispatchGroup.leave()
                }
            }
        }
        dataTask.resume()
    }
    
    private func getBatchPriceData(url: String){
        dispatchGroup.enter()
        
        let url = URL(string: url)
        
        guard  url != nil else {
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let dataFeed = try decoder.decode(majorIndexBatchFeed.self, from: data!)
                    //self.batchPriceData.append(dataFeed)
                    
                    self.dispatchGroup.leave()
                }
                catch {
                    print("Error in JSON parsing")
                    print(error.localizedDescription)
                    self.dispatchGroup.leave()
                }
            }
        }
        dataTask.resume()
    }
}


extension EditMajorIndexViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return indexSearchResult.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row != 0 {
            if indexSearchResult.count != 0 {
                let currentIndex = indexPath.row-1
                let cell = indexCollectionView.dequeueReusableCell(withReuseIdentifier: "indexCell", for: indexPath) as? AddIndexCollectionViewCell
                /*
                 cell?.layer.cornerRadius = 10
                 cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
                 cell?.layer.shadowColor = UIColor.darkGray.cgColor
                 cell?.layer.shadowRadius = 2
                 cell?.layer.shadowOpacity = 0.2
                 cell?.layer.masksToBounds = false
                 cell?.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
                 */
                
                if indexSearchResult[currentIndex].isSelected == true {
                    //cell?.layer.borderColor = UIColor(red: 0.31, green: 0.25, blue: 0.60, alpha: 1.00).cgColor
                    cell?.layer.shadowColor = UIColor.lightGray.cgColor
                    cell?.layer.backgroundColor = UIColor(red: 0.31, green: 0.25, blue: 0.60, alpha: 1.00).cgColor
                } else {
                    cell?.layer.shadowColor = UIColor.clear.cgColor
                    cell?.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
                }
                
                if let name = indexSearchResult[currentIndex].name {
                    cell?.indexName.text = name
                }
                
                if let ticker = indexSearchResult[currentIndex].symbol {
                    let editedTicker = ticker.replacingOccurrences(of: "^", with: "")
                    cell?.indexsymbol.text = editedTicker
                }
                
                if let high = indexSearchResult[currentIndex].yearHigh {
                    cell?.highLabel.text = "High (y)\n" + String(format: "%.2f", high)
                }
                
                if let low = indexSearchResult[currentIndex].yearLow {
                    
                    //let attributedStr = NSMutableAttributedString(string: "Low (Y)\n", attributes: [NSMutableAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 12), NSMutableAttributedString.Key.foregroundColor: UIColor.gray])
                                
                    //cell?.lowLabel.attributedText = attributedStr // + attributedVal
                    cell?.lowLabel.text = "Low (y)\n" + String(format: "%.2f", low)
                    
                    
                    
                    //attributedStr.string + String(format: "%.2f", low)
                }
                
                if let pctChange = indexSearchResult[currentIndex].pctChange, let change = indexSearchResult[currentIndex].change, let close = indexSearchResult[currentIndex].close{
                    
                    let pctChangeString = String(format: "%.2f", pctChange)
                    let changeString = String(format: "%.2f", change)
                    let completeChange = "\n" + changeString + " (\(pctChangeString))"
                    
                    let closeString = String(format: "%.2f", close)
                    
                    let completeString = closeString + completeChange

                    
                    //let range = (completeString as NSString).range(of: completeChange)
                    //let attributedString = NSMutableAttributedString.init(string: closeString)
                    //attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
                                
                    cell?.changeLabel.text = completeString//attributedString
                    
                    //cell?.changeLabel.layer.backgroundColor = UIColor.red.cgColor
                }
                
                return cell!
            }
        }
        
        let cell = indexCollectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as? FavoriteStocksTopCollectionViewCell
        
        cell?.label.text = "Select your favorite indexes"
        cell?.descLabel.text = "You can choose up to 15 different indexes to be displayed in the home menu. The indexes are sorted by price in descending order."
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = UIScreen.main.bounds.size.width - 40
        
        if indexPath.row == 0 {
            return CGSize(width: width, height: 100)
        } else {
            return (CGSize(width: width, height: 75))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexSearchResult[indexPath.row].isSelected != true {
            indexSearchResult[indexPath.row].isSelected = true
            //self.indexCollectionView.reloadData()
        } else {
            indexSearchResult[indexPath.row].isSelected = false
            //self.indexCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat
        var width: CGFloat
        
        if section == 0 {
            height = 56
            width = UIScreen.main.bounds.size.width
            
            return CGSize(width: width, height: height)
        } else {
            height = 0
            width = 0
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader && indexPath.section == 0) {
            let view = indexCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "searchIndexHeader", for: indexPath) as! SearchIndexCollectionReusableView
            view.searchBar = searchBar
            return view
        } else {
            return IndexCollectionReusableView()
        }
    }
}

extension EditMajorIndexViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                
        var indexDelete: [IndexPath] = []
        var indexReload: [IndexPath] = []
        var helpArray: [majorIndex] = []
        var count = 1
        
        if searchText.count > 1 && indexSearchResult.count != 0 {
            let task = DispatchWorkItem {[weak self] in
                            
                for i in self!.indexSearchResult {
                    if let name = i.name, let symbol = i.symbol {
                        let indexPath = IndexPath(row: count, section: 0)
                        if name.uppercased().contains(searchText.uppercased()) == false && symbol.uppercased().contains(searchText.uppercased()) == false {
                            indexDelete.append(indexPath)
                        } else {
                            helpArray.append(i)
                            indexReload.append(indexPath)
                        }
                    }
                    count += 1
                }
                
                self?.indexCollectionView.performBatchUpdates({
                    self?.indexCollectionView.deleteItems(at: indexDelete)
                    self?.indexSearchResult = helpArray
                }, completion: { Bool in
                    self?.indexCollectionView.reloadItems(at: indexReload)
                })
            }
                    
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
        } else if searchText == "" {
            count = 1
            for _ in completeIndexData {
                let indexPath = IndexPath(row: count, section: 0)
                indexReload.append(indexPath)
            }
            
            let task = DispatchWorkItem {[weak self] in
                
                self?.indexCollectionView.performBatchUpdates({
                    self?.indexCollectionView.insertItems(at: indexReload)
                    self?.indexSearchResult = self!.completeIndexData
                }, completion: { Bool in
                    self?.indexCollectionView.reloadItems(at: indexReload)
                })
            }
                    
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        indexCollectionView.keyboardDismissMode = .onDrag
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}
