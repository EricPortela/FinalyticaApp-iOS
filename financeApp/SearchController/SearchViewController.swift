//
//  SearchViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-03-27.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit

var myIndex = 0
var searchTask : DispatchWorkItem?

class SearchViewController: UIViewController {
    
    struct GlobalVariable{
        static var myString = String()
    }
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    struct nameSymbol: Codable {
        var name: String?
        var symbol: String?
    }
    
    var searchResults: [nameSymbol] = []
    var searching = false
    var label = UILabel()
    
    var pendingRequestWorkItem : DispatchWorkItem?
    let dispatchGroup = DispatchGroup()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        scrollViewWillBeginDragging(UIScrollView())
        
        searchBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchBar.becomeFirstResponder() //make keyboard show up directly when searchViewController is presented
    }

       
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func updateSearchResults(){
        dispatchGroup.notify(queue: .main) {
            
            UIView.transition(with: self.tableView, duration: 1, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        }
    }
    
    func getStocks(insertedCharacters: String, url: String) {
        dispatchGroup.enter()
        searchResults.removeAll()
        
        let url = URL(string: url)
        guard  url != nil else {
           return
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
           if error == nil && data != nil {
               let decoder = JSONDecoder()
               
               do {
                   let searchContent = try decoder.decode([searchFeed].self, from: data!)
                
                for companyInfo in searchContent {
                    if let ticker = companyInfo.symbol {
                        if let name = companyInfo.name {
                            let company = nameSymbol(name: name, symbol: ticker)
                            self.searchResults.append(company)
                        }
                    }
                }
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
    
    
    func getNYSE(company: String) {
        let NYSE = "https://financialmodelingprep.com/api/v3/search?query=\(company)&limit=50&exchange=NYSE&apikey=\(apiKey)"
        getStocks(insertedCharacters: company, url: NYSE)
    }
    
    
    func getNASDAQ(company: String) {
        let NASDAQ = "https://financialmodelingprep.com/api/v3/search?query=\(company)&limit=50&exchange=NASDAQ&apikey=\(apiKey)"
        getStocks(insertedCharacters: company, url: NASDAQ)
    }
    
    private func animateTableView() {
        UIView.transition(with: self.tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        
        searchTask?.cancel()
        
        let modifiedText = searchText.replacingOccurrences(of: " ", with: "_")
        
        if searchText.count > 1 {
            let endpoints = ["https://financialmodelingprep.com/api/v3/search?query=\(modifiedText.uppercased())&limit=50&exchange=NYSE&apikey=\(apiKey)", "https://financialmodelingprep.com/api/v3/search?query=\(modifiedText.uppercased())&limit=50&exchange=NASDAQ&apikey=\(apiKey)"]
            
            let task = DispatchWorkItem {[weak self] in
                
                for endpoint in endpoints {
                    self?.getStocks(insertedCharacters: modifiedText.uppercased(), url: endpoint)
                }
                
                self!.dispatchGroup.notify(queue: .main) {
                    self?.animateTableView()
                }
            }
            
            searchTask = task
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
            
        }
        
        else if searchText.count == 0 {
            self.searchResults.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        self.navigationItem.title = "Overview"
        //searchBar.text = "Search company by ticker or name"
        self.view.removeFromSuperview() //Removes the current viewcontroller (that this code controls) and returns to "first itembar"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchResults.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
                
        if searching && searchResults.count != 0 {
            cell?.textLabel?.text = searchResults[indexPath.row].name
            cell?.detailTextLabel?.text = searchResults[indexPath.row].symbol
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
                        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let details = storyboard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        
        if let ticker = searchResults[indexPath.row].symbol {
            details.ticker = ticker
            self.navigationController?.pushViewController(details, animated: true)
        }
    }
}

