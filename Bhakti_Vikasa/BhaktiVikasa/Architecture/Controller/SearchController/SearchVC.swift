//
//  SearchVC.swift
//  Bhakti_Vikasa
//
//  Created by harishkumar on 23/02/21.
//  Copyright © 2021 Harsh Rajput. All rights reserved.
//

import UIKit

class SearchVC: UIViewController ,UISearchResultsUpdating{
    var countryCode : [JKCountry]? = nil
    var currancyModel: [RazorPayCurrancy]? = nil
    var getSelectionCallBack:((JKCountry?,RazorPayCurrancy?) -> ())?
    
    private var rawCountryCode:[JKCountry] = []
    private var rawCurrancyModel:[RazorPayCurrancy] = []
    @IBOutlet private weak var tableList : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rawCountryCode = countryCode ?? []
        rawCurrancyModel = currancyModel ?? []
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type here to search"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchController.searchBar.text else { return }
        
        print("real------>\(search)")
        if rawCurrancyModel.isEmpty{
            if !search.isEmpty{
                let filter1 = rawCountryCode.filter({$0.countryName.range(of: search, options: .caseInsensitive) != nil})
                let filter2 = rawCountryCode.filter({$0.countryCode.range(of: search, options: .caseInsensitive) != nil})
                let filter3 = rawCountryCode.filter({$0.dialCode.range(of: search, options: .caseInsensitive) != nil})
                countryCode = (filter1+filter2+filter3).removeDuplicates()
                print("countryCode=====",countryCode?.count)
            }else{
                self.countryCode = rawCountryCode
                
            }
        }else{
            if !search.isEmpty{
                let filter1 = rawCurrancyModel.filter({$0.countryName.range(of: search, options: .caseInsensitive) != nil})
                let filter2 = rawCurrancyModel.filter({$0.countryCode.range(of: search, options: .caseInsensitive) != nil})
                let filter3 = rawCurrancyModel.filter({$0.currencyCode.range(of: search, options: .caseInsensitive) != nil})
                currancyModel = (filter1+filter2+filter3).removeDuplicates()
                print("currancyModel=====",currancyModel?.count)
                
            }else{
                currancyModel = rawCurrancyModel
            }
        }
        self.tableList.reloadData()
        
        
        
        
    }
}
extension SearchVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rawCountryCode.isEmpty{
            return currancyModel?.count ?? 0
        }else{
            return countryCode?.count ?? 0
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(reuseIdentifier: "codeCell")!
        
        if rawCountryCode.isEmpty{
            let item = currancyModel![indexPath.row]
            cell.textLabel?.text = "'\(item.currencyCode)' \(item.countryName)"
        }else{
            let item = countryCode![indexPath.row]
            cell.textLabel?.text = "\(item.flag ?? "") \(item.dialCode) \(item.countryName)"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var text = ""
        var country : JKCountry? = nil
        var currancy : RazorPayCurrancy? = nil
        if rawCountryCode.isEmpty{
            let item = currancyModel![indexPath.row]
            text = "'\(item.currencyCode)' \(item.countryName)"
            currancy = item
        }else{
            let item = countryCode![indexPath.row]
            text = "\(item.flag ?? "") \(item.dialCode) \(item.countryName)"
            country = item
        }
        print("-------->",text)
        navigationItem.searchController?.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion:
                        {
            self.getSelectionCallBack?(country,currancy)
        })
    }
}
