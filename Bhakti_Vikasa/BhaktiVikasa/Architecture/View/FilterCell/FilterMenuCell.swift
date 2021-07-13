//
//  FilterCell.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 10/09/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit

class FilterMenuCell: UITableViewCell {
    @IBOutlet private  weak var lblCatgoryName: UILabel!
    @IBOutlet private weak var viewCounter: UIView!
    @IBOutlet private weak var lblCount: UILabel!
    var filterCat:Filter?  {
        didSet{
            lblCatgoryName.text = filterCat?.name ?? ""
            if let selectedFilte = filterCat?.selected?.count , selectedFilte > 0{
                viewCounter.isHidden = false
                lblCount.text = "\(selectedFilte)"
            }else{
                viewCounter.isHidden = true
                lblCount.text = ""
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedBackgroundView?.borderColor = UIColor.purple

        // Configure the view for the selected state
    }

}

class FilterOptionsCell: UITableViewCell {
    @IBOutlet weak var lblFiletrOption: UILabel!
    @IBOutlet weak var imgSelecter: UIImageView!
    var filterCat:Filter?  {
        didSet{
            let option = filterCat?.options?[self.tag] ?? ""
            if filterCat?.name == "Month"{
                if let intMonth = Int(option), intMonth != 0,intMonth <= 12{
                    lblFiletrOption.text = DateFormatter().monthSymbols[intMonth-1].capitalized

                }else{
                    lblFiletrOption.text = "unknown"

                }

            }else{
                lblFiletrOption.text = option
            }
            if filterCat?.selected?.contains(option) ?? false {
                imgSelecter.image = #imageLiteral(resourceName: "check-box (1)")
            }else{
                imgSelecter.image = #imageLiteral(resourceName: "check-box")

            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
