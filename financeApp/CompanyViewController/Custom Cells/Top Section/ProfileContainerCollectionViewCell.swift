//
//  ProfileContainerCollectionViewCell.swift
//  financeApp
//
//  Created by Eric Portela on 2021-06-18.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class ProfileContainerCollectionViewCell: UICollectionViewCell {
    
    let categories = ["Beta", "Vol. Avg.", "Country", "Symbol", "Industry", "Sector", "Website"]
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var companyProfileArray: [String] = []
    var dataArray: [CompanyProfileFeed] = []
    var ticker = ""
    
    override init(frame: CGRect) {
           super.init(frame: frame)
           setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    let horizontalCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    
    func setUpView() {
        //Delegate and DataSource
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.delegate = self
        
        //Register cell
        horizontalCollectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: "profileCell")
        
        //Layout
        layout.sectionInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        layout.itemSize = CGSize(width: 110, height: 60)
        layout.scrollDirection = .horizontal
        horizontalCollectionView.collectionViewLayout = layout
        
        //Frame
        let collectionViewWidth = UIScreen.main.bounds.size.width
        let collectionViewHeight = CGFloat(70)
        horizontalCollectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewHeight)
        self.addSubview(horizontalCollectionView)
    }
    
    func flag(country: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        
        for character in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + character.value)!)
        }
        return String(s)
    }
    
    func getCompanyProfile(urlString : String) {
        companyProfileArray.removeAll()
        let url = URL(string: urlString)
        
        guard url != nil else {
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url!) {(data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                do {
                    let profileFeed = try decoder.decode([CompanyProfileFeed].self, from: data!)
                    
                    self.dataArray = profileFeed
                    
                    var profile = [String]()
                    for data in profileFeed {
                        
                        if let beta = data.beta, let volAvg = data.volAvg, let country = data.country, let sym = data.symbol, let ind = data.industry, let sec = data.sector {
                            profile.append(String(beta))
                            profile.append(String(volAvg))
                            profile.append(self.flag(country: country))
                            profile.append(String(sym))
                            profile.append(String(ind))
                            profile.append(String(sec))
                        }
                    }
                    self.companyProfileArray = profile

                    DispatchQueue.main.async {
                        self.horizontalCollectionView.reloadData()
                    }
                }
                
                catch {
                    print("Error in JSON parsing")
                }
            }
        }
        dataTask.resume()
    }
}

extension ProfileContainerCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = horizontalCollectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as? ProfileCollectionViewCell
        cell?.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00) //.tertiarySystemBackground
        cell?.layer.cornerRadius = 5
        cell?.layer.borderWidth = 0
        cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell?.layer.shadowColor = UIColor.darkGray.cgColor
        cell?.layer.shadowRadius = 2
        cell?.layer.shadowOpacity = 0.2
        cell?.layer.masksToBounds = false
        
        cell?.categoryLabel.text = categories[indexPath.row]
        //cell?.valueLabel.text = companyProfileArray[indexPath.row]
        
        if dataArray.count != 0 {
            if indexPath.row == 0 {
                if let beta = dataArray[0].beta {
                    cell?.valueLabel.text = String(format: "%.2f", beta)
                }
            } else if indexPath.row == 1 {
                if let vol = dataArray[0].volAvg {
                    cell?.valueLabel.text = String(format: "%.2f", vol)
                }
            } else if indexPath.row == 2 {
                if let country = dataArray[0].country {
                    cell?.valueLabel.text = flag(country: country)
                }
            } else if indexPath.row == 3 {
                if let symbol = dataArray[0].symbol {
                    cell?.valueLabel.text = symbol
                }
            } else if indexPath.row == 4 {
                if let industry = dataArray[0].industry {
                    cell?.valueLabel.text = industry
                }
            } else if indexPath.row == 5 {
                if let sector = dataArray[0].sector {
                    cell?.valueLabel.text = sector
                }
            } else if indexPath.row == 6 {
                if let website = dataArray[0].website {
                    cell?.valueLabel.text = website
                }
            }
        }
        return cell!
    }
}

