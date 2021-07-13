//
//  DKDropdownController.swift
//  Doctalkgo
//
//  Created by Jitendra Kumar on 04/08/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

class DKDropdownController<Item, Cell: UITableViewCell>:UITableViewController{
    var items: [Item] = []
    let reuseIdentifier = "Cell"
    var configure: (Cell, Item) -> ()
    var didSelect: (Item)->()
    
    /// Initializes a table-view controller to manage a table view of a given style.
    /// - Parameters:
    ///   - style: A constant that specifies the style of table view that the controller object is to manage (UITableView.Style.plain or UITableView.Style.grouped).
    ///   - items: Generic Item Array
    ///   - configure: Cell Configuration CallBack(imageView/titleLabel/DetailLabel) and Item genaric Value to presrenttion of Cell Data
    ///   - didSelect: Selected Item Callback
    init(style:UITableView.Style = .plain,items:[Item],configure:@escaping(Cell,Item)->Void,didSelect:@escaping(Item)->Void) {
        self.items = items
        self.configure = configure
        self.didSelect = didSelect
        super.init(style: style)
        //self.tableView.register(Cell.self, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didUpdatePreferredContentHieght()
    }
    private func didUpdatePreferredContentHieght(){
        self.tableView.performBatchUpdates({self.tableView.reloadSections(.init(arrayLiteral: 0), with: .automatic)}, completion: {_ in   self.preferredContentSize.height = self.tableView.contentSize.height
            self.tableView.isScrollEnabled =  self.view.bounds.height<self.tableView.contentSize.height ? true:false
        })
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(Cell.self, reuseIdentifier: reuseIdentifier, for: indexPath)
        let item = items[indexPath.row]
        configure(cell, item)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let item = self.items[indexPath.row]
            self.didSelect(item)
        }
    }
    
}




extension UIViewController:UIPopoverPresentationControllerDelegate{
    
    /// a UITableViewController present in Dropdown Style
    /// - Parameters:
    ///   - style: A constant that specifies the style of table view that the controller object is to manage (UITableView.Style.plain or UITableView.Style.grouped).
    ///   - items: Generic Item Array
    ///   - sender: Show View in popoverPresentationController Mode from Any type sender(UIControl/UIIVew/UIBarButtonItem)
    ///   - configure: Cell Configuration CallBack(imageView/titleLabel/DetailLabel/Custom) and Item genaric Value to presrenttion of Cell Data
    ///   - didSelect:  Selected Item Callback
    func showDropdown<Item, Cell: UITableViewCell>(style:UITableView.Style = .plain,items:[Item],sender:Any,size:CGSize? = nil,configure:@escaping(Cell,Item)->Void,didSelect:@escaping(Item)->Void){
        let pickerController =  DKDropdownController(style: style, items: items, configure: configure, didSelect: didSelect)
        pickerController.modalTransitionStyle  = .crossDissolve
        pickerController.modalPresentationStyle = .popover
        if let popoverController = pickerController.popoverPresentationController {
            popoverController.permittedArrowDirections = .any
            if let sourceView = sender as? UIBarButtonItem {
                popoverController.barButtonItem = sourceView
            }else if let source = sender as? UIView{
                popoverController.sourceView = source
                popoverController.sourceRect = source.bounds
                var preferredContentSize:CGSize =  size == nil ? source.bounds.size : size!
                preferredContentSize.width  = Platform.isPad ? (size == nil ? source.bounds.width*0.65 : size!.width):(size == nil ?  source.bounds.width*0.9 : size!.width)
                pickerController.preferredContentSize = preferredContentSize
            }
            popoverController.delegate = self
            
        }
        self.present(pickerController, animated: true, completion: nil)
        
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if Platform.isPhone {
            return .none
        }else{
            return .popover
        }
    }
}

