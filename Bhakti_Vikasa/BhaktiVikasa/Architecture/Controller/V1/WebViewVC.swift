//
//  WebViewVC.swift
//  Bhakti_Vikasa
//
//  Created by MAC on 11/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC: UIViewController, WKUIDelegate {
    @IBOutlet weak var webView: WKWebView!
    
    var webV:WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back_action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
