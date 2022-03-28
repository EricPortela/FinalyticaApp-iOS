//
//  WebViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2021-01-29.
//  Copyright © 2021 Eric Portela. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var webView : WKWebView!
    
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.delegate = self
        loadWebView(url: url)
    }
    
    func loadWebView(url: String) {
        print("jhkgsdghksfdghfsdghhjkgskgh")
        print(url)
        let startURL = URL(string: url)
        let request = URLRequest(url: startURL!)
        webView.load(request)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
      scrollView.pinchGestureRecognizer?.isEnabled = false
    }}

