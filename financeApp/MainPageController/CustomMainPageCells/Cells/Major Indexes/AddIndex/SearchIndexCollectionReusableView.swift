//
//  SearchIndexCollectionReusableView.swift
//  financeApp
//
//  Created by Eric Portela on 2021-12-22.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit

class SearchIndexCollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var searchBar: UISearchBar = {
        let search = UISearchBar()
        return search
    }()
    
    override func layoutSubviews() {
        let width = UIScreen.main.bounds.size.width - 40 - 40
        searchBar.frame = CGRect(x: 10, y: 10, width: width, height: 36)
        self.addSubview(searchBar)
        self.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.00)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
