//
//  TestViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-03-19.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    var showType = "Reports"
    var ticker: String = ""
    
    
    @IBAction func changeTable(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            showType = "Reports"
            let urlString = getSECReportLink(companySelected: ticker)
            apiRequest(urlString: urlString)
            
            //SECReportsTableView.reloadData()

            
        case 1:
            showType = "Insider"
            let urlString = getSECReportLink(companySelected: ticker)
            apiRequest(urlString: urlString)
            
            //SECReportsTableView.reloadData()

            
        default:
            showType = "Reports"
        }
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var SECReportsTableView: UITableView!
    var reportArray = [SECReportFeed]()
    var insiderArray = [SECInsiderFeed]()
    
    func apiRequest(urlString: String) {
        //1. Create URL object
        let url = URL(string: urlString)
        
        //2. Handle optional values/if it is nil
        guard url != nil else {
            return
        }
        
        //3. At this point our URL object has been created since it passed the above guard statement
        let session = URLSession.shared
        
        //5. Create datatask
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            //5.1 Check for errors and data
            if error == nil && data != nil{
                //5.1.1 Parse JSON
                let decoder = JSONDecoder()
                do {
                    if self.showType == "Reports" {
                        self.reportArray.removeAll()
                        
                        let reportFeed = try decoder.decode([SECReportFeed].self, from: data!)
                        
                        for report in reportFeed {
                            self.reportArray.append(report)
                        }
                        DispatchQueue.main.async{
                            self.SECReportsTableView.reloadData()
                        }
                        
                    } else if self.showType == "Insider" {
                        
                        self.insiderArray.removeAll()
                                                
                        let reportFeed = try decoder.decode([SECInsiderFeed].self, from: data!)
                        
                        
                        for insiderReport in reportFeed {
                            self.insiderArray.append(insiderReport)
                        }
                        DispatchQueue.main.async{
                            self.SECReportsTableView.reloadData()
                        }
                    }
                }
                catch {
                    print("Error in JSON parsing")
                    print(error.localizedDescription)
                }
            }
        }
        dataTask.resume()
    }
    
    
    func getSECReportLink(companySelected : String) -> String {
        var ratioLink = ""
        let tick = (companySelected.split(separator: " ")).last
        if showType == "Reports" {
            if let ticker = tick?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "") {
                ratioLink = "https://financialmodelingprep.com/api/v3/sec_filings/\(ticker)?limit=100&apikey=\(apiKey)"
            }
        } else if showType == "Insider" {
            if let ticker = tick?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "") {
                ratioLink = "https://financialmodelingprep.com/api/v4/insider-trading?symbol=\(ticker)&limit=100&apikey=\(apiKey)"
            }
        }
        
        return ratioLink
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        SECReportsTableView.delegate = self
        SECReportsTableView.dataSource = self
                
        let urlString = getSECReportLink(companySelected: ticker)
        apiRequest(urlString: urlString)
    }
}

extension TestViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showType == "Insider" {
            return insiderArray.count
        }
        return reportArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SECReportsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SECTableViewCell

        if showType == "Insider" && insiderArray.count != 0{
            let transaction = insiderArray[indexPath.row].acquistionOrDisposition
            if transaction == "D" {
                cell?.typeImage.image = UIImage(named: "minusIcon.png")
            } else if transaction == "A" {
                cell?.typeImage.image = UIImage(named: "plusIcon.png")
            }
            
            cell?.symbolLabel.text = insiderArray[indexPath.row].reportingName
            let securitiesTransacred = insiderArray[indexPath.row].securitiesTransacted
            
            cell?.fillingDate.text = "Securities Transacted: \(securitiesTransacred)"
            
            let transactionType = insiderArray[indexPath.row].transactionType
            let securityName = insiderArray[indexPath.row].securityName
            cell?.more.text = "\(transactionType)/\(securityName)"
            return cell!
        }
        
        let reportType = reportArray[indexPath.row].type
        
        if reportType != "10-K" && reportType != "10-Q" && reportType != "8-K" {
            cell?.typeImage.image = UIImage(named: "questionMark.png")
        } else {
            cell?.typeImage.image = UIImage(named: "\(reportType).png")
        }
        
        cell?.symbolLabel.text = reportArray[indexPath.row].symbol
        cell?.fillingDate.text = reportArray[indexPath.row].fillingDate
        cell?.more.text = "Type: \(reportArray[indexPath.row].type)"
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sec"{
            if let indexPath = SECReportsTableView.indexPathForSelectedRow {
                let vc = segue.destination as! WebViewController
                if showType == "Reports" {
                    let link = "\(reportArray[indexPath.row].finalLink)"
                    vc.url = link
                } else if showType == "Insider" {
                    let link = "\(insiderArray[indexPath.row].link)"
                    vc.url = link
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "sec", sender: self)
    }
    

}
