//
//  PressReleaseViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-06-25.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class PressReleaseViewController: UIViewController {
    
    @IBOutlet weak var pressReleaseTableView: UITableView!
    
    var pressReleaseArray = [pressReleaseFeed]()
    var cleanTableViewData = [ExpandableCellSection(isExpanded: true, content: [[String:Any]()])]
    
    //let kpiSectionOne = ExpandableCellSection(isExpanded: true, content: [["Valuation": 1], ["Leverage": 1], ["Liquidity": 1], ["Profitability": 1]])
    
    let dateFormatter1 = DateFormatter()
    let dateFormatter2 = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        
        //Ticker
        let tickerName = (SearchViewController.GlobalVariable.myString)
        let ticker = getTicker(companySelected: tickerName)
        
        let pressReleaseLink = "https://financialmodelingprep.com/api/v3/press-releases/\(ticker)?limit=100&apikey=\(apiKey)"
        getPressRelease(urlString: pressReleaseLink)
        //pressReleaseView
    }
    
    func setUpTableView() {
        pressReleaseTableView.delegate = self
        pressReleaseTableView.dataSource = self
        
        pressReleaseTableView.register(PressReleaseTableViewCell.self, forCellReuseIdentifier: "pressReleaseCell")
        pressReleaseTableView.layer.cornerRadius = 5
        pressReleaseTableView.backgroundColor = .clear
        
        /*
         pressReleaseTableView.register(KPICellOne.self, forCellReuseIdentifier: "kpiOne")
         pressReleaseTableView.register(KPICellTwo.self, forCellReuseIdentifier: "kpiTwo")
         */
    }
    
    func getPressRelease(urlString: String){
        self.pressReleaseArray.removeAll()
        self.cleanTableViewData.removeAll()
        
        let url = URL(string: urlString)
        
        guard url != nil else {
            return
        }
        
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                
                do {
                    let ratioFeed = try decoder.decode([pressReleaseFeed].self, from: data!)
                    
                    var data = [[String:Any]()]
                    data.removeAll()
                    
                    for pressRelease in ratioFeed {
                        var onePressRelease = [String:Any]()
                        onePressRelease.removeAll()
                        onePressRelease["date"] = pressRelease.date
                        onePressRelease["title"] = pressRelease.title
                        
                        //Add data
                        data.append(onePressRelease)
                    }
                    
                    DispatchQueue.main.async {
                        self.cleanTableViewData.append(ExpandableCellSection(isExpanded: true, content: data))
                        //self.cleanTableViewData.append(self.kpiSectionOne)
                        self.pressReleaseTableView.reloadData()
                        
                        /*
                         //Fix with view height
                             let preferedViewHeight = (self.overviewCollectionView.contentSize.height + self.pressReleaseTableView.contentSize.height)
                              
                             self.viewHeight.constant = CGFloat(preferedViewHeight + 78 + 80)
                             self.pressReleaseTableViewHeight.constant = CGFloat(self.pressReleaseTableView.contentSize.height)
                             self.overviewCollectionViewHeight.constant = CGFloat(self.overviewCollectionView.contentSize.height)
                         }
                         */
                    }
                }
                
                catch {
                    print("Error in JSON parsing")
                }
            }
        }
        dataTask.resume()
    }
    
    func drawLine(start: CGPoint, end: CGPoint, view: UIView) {
        //path design
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor(red: 0.49, green: 0.47, blue: 0.82, alpha: 1.00).cgColor
        shape.lineWidth = 2.0
        
        view.layer.addSublayer(shape)
    }
}

extension PressReleaseViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cleanTableViewData.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !cleanTableViewData[section].isExpanded {
            return 0
        }
        return cleanTableViewData[section].content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = pressReleaseTableView.dequeueReusableCell(withIdentifier: "pressReleaseCell") as? PressReleaseTableViewCell //as? PressReleaseTableViewCell
        cell?.backgroundColor = UIColor.secondarySystemBackground
        
        if cleanTableViewData.count != 0 && indexPath.section == 0 {
            
            let content = cleanTableViewData[indexPath.section].content
                
            //Create two dateFormatter to convert constant "date" (string) to type date and further convert to string in order to obtain format: "Time Day, date month year"
            self.dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.dateFormatter2.dateFormat = "HH:mm E, d MMM y"
            
            if let title = content[indexPath.row]["title"] as? String {
                cell?.titleLabel.text = title
            }
            
            if let date = content[indexPath.row]["date"] as? String {
                cell?.subTitleLabel.text = date
            }
            
        }
        
        return cell!
    }
    
    
    //For header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 12, y: 0, width: tableView.frame.size.width, height: 80))
        view.backgroundColor = UIColor.tertiarySystemBackground
        view.layer.cornerRadius = 5
        
        //Purple line
        //Vertical, to the left
        let start = CGPoint(x:1, y:10)
        let end = CGPoint(x: 1, y: 80)
        drawLine(start: start, end: end, view: view)
        
        //Image view
        let imgView = UIImageView(frame: CGRect(x: 15, y: ((80-25)/2), width: 26, height: 26))
        
        //Labels
        let labelWidth = tableView.frame.size.width - ((15*3) + 26)
        
        //Title
        let title = UILabel(frame: CGRect(x: ((15*2) + 26) , y: (22), width: labelWidth, height: 20.5))
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        
        
        //Subtitle
        let subTitle = UILabel(frame: CGRect(x: ((15*2) + 26) , y: (22 + title.frame.size.height + 2), width: labelWidth, height: 14))
        subTitle.font = UIFont(name: "HelveticaNeue", size: 12)
        
        
        if section == 0 {
            let icon = UIImage(named: "press.png")
            imgView.image = icon
            title.text = "Press Releases"
            subTitle.text = "Check out the latest press releases!"
        }
   
        //Button
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: tableView.contentSize.width, height: 80)
        button.setTitle("", for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        button.tag = section
        
        //Add icon + labels + button to the header
        view.addSubview(imgView)
        view.addSubview(title)
        view.addSubview(subTitle)
        view.addSubview(button)
        
        return view
    }
    
    @objc func handleExpandClose(button: UIButton) {
        
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        
        for row in 0..<cleanTableViewData[section].content.count {
            //print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = cleanTableViewData[section].isExpanded
        cleanTableViewData[section].isExpanded = !isExpanded
        
        if isExpanded {
            self.pressReleaseTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            pressReleaseTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    
    //For footer
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        
        footerView.layer.backgroundColor = UIColor.clear.cgColor

        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("poo")
    }
}
