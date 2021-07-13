//
//  FilterVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 10/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit

class FilterVC: UIViewController {
    var homeDeligate:FilterApplyProtocoal?
    @IBOutlet private weak var tblMAin: UITableView!
    @IBOutlet private weak var tblSub: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func selectedCategoryIndex()->Int{
        return self.tblMAin.indexPathForSelectedRow?.row ?? 0
    }


    @IBAction func back(_ sender: UIButton)-> Void{
               self.dismiss(animated: true, completion: nil)
           }
    @IBAction func clearAllFilte(_ sender: UIButton)-> Void{
        for (index,value) in GlobleVAR.filterModel.enumerated(){
            guard value.selected?.count ?? 0 > 0 else {
                continue
            }
            GlobleVAR.filterModel[index].selected?.removeAll()
            
        }
        homeDeligate?.filterApply(with: 0, filters: GlobleVAR.filterModel)
        GlobleVAR.filterDeligate?.filterApply(with: 0, filters: GlobleVAR.filterModel)
        self.tblMAin.reloadData()
        self.tblSub.reloadData()
        
    }
    @IBAction func applyFilters(_ sender: UIButton)-> Void{
        var filterAdded = 0
        for filter in GlobleVAR.filterModel{
            let fCount = filter.selected?.count ?? 0
            filterAdded += fCount
        }
        homeDeligate?.filterApply(with: filterAdded, filters: GlobleVAR.filterModel)
        GlobleVAR.filterDeligate?.filterApply(with: filterAdded, filters: GlobleVAR.filterModel)
        self.dismiss(animated: true, completion: nil)
           }
}

extension FilterVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblMAin{
            return GlobleVAR.filterModel.count
        }else{
            return GlobleVAR.filterModel[selectedCategoryIndex()].options?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblMAin{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterMenuCell")as! FilterMenuCell
            cell.filterCat = GlobleVAR.filterModel[indexPath.row]
            return cell

        }else{
           let cell = tableView.dequeueReusableCell(withIdentifier: "FilterOptionsCell")as! FilterOptionsCell
            cell.tag = indexPath.row
            cell.filterCat = GlobleVAR.filterModel[selectedCategoryIndex()]

            return cell

        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tblMAin{
            self.tblSub.reloadData()
        }else{
            let selectedOption = GlobleVAR.filterModel[selectedCategoryIndex()].options?[indexPath.row] ?? ""
            if GlobleVAR.filterModel[selectedCategoryIndex()].selected?.contains(selectedOption) ?? false{
                GlobleVAR.filterModel[selectedCategoryIndex()].selected?.removeAll(where: {$0 == selectedOption})

            }else{
                GlobleVAR.filterModel[selectedCategoryIndex()].selected?.append(selectedOption)

            }
            let cell = self.tblMAin.cellForRow(at: IndexPath(row: selectedCategoryIndex(), section: 0)) as! FilterMenuCell
            cell.filterCat = GlobleVAR.filterModel[selectedCategoryIndex()]
            self.tblMAin.beginUpdates()
            self.tblMAin.endUpdates()

            self.tblSub.reloadRows(at: [indexPath], with: .none)
           
        }
    }
}

