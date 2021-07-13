//
//  UITableView+Ex.swift
//  Doctalkgo
//
//  Created by Jitendra Kumar on 04/08/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

extension UITableView{
    
    /// Update HeaderView Height based on Content Size.height
    func updateHeaderHeight(){
        guard let headerView = self.tableHeaderView else {return}
        // The table view header is created with the frame size set in
        // the Storyboard. Calculate the new size and reset the header
        // view to trigger the layout.
        // Calculate the minimum height of the header view that allows
        // the text label to fit its preferred width.
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            
            // Need to set the header view property of the table view
            // to trigger the new layout. Be careful to only do this
            // once when the height changes or we get stuck in a layout loop.
            self.tableHeaderView = headerView
            
            // Now that the table view header is sized correctly have
            // the table view redo its layout so that the cells are
            // correcly positioned for the new header size.
            // This only seems to be necessary on iOS 9.
            self.layoutIfNeeded()
        }
        
    }
    /// Update FooterView Height based on Content Size.height
    func updateFooterHeight(){
        guard let footerView = self.tableFooterView else {return}
        // The table view footer is created with the frame size set in
        // the Storyboard. Calculate the new size and reset the header
        // view to trigger the layout.
        // Calculate the minimum height of the header view that allows
        // the text label to fit its preferred width.
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            
            // Need to set the footer view property of the table view
            // to trigger the new layout. Be careful to only do this
            // once when the height changes or we get stuck in a layout loop.
            self.tableFooterView = footerView
            
            // Now that the table view footer is sized correctly have
            // the table view redo its layout so that the cells are
            // correcly positioned for the new header size.
            // This only seems to be necessary on iOS 9.
            self.layoutIfNeeded()
        }
        
    }
    
    /// The custom distance that the content view is inset from the safe area or scroll view edges.
    /// - Parameter insets: inset from the safe area or scroll view edges.
    func setContentInset(_ insets:UIEdgeInsets = .zero){
        self.contentInset = insets
    }
    /// The distance the scroll indicators are inset from the edge of the scroll view.
    /// - Parameter insets: inset from the edge of the scroll view.
    func setScrollIndicatorInsets(_ insets:UIEdgeInsets = .zero){
        self.scrollIndicatorInsets = insets
    }
    ///  last indexPath  that together represent the path to a last location in a tree of nested arrays.
    var indexPathForLastRow:IndexPath?{
        let section = max(numberOfSections - 1, 0)
        let row = max(numberOfRows(inSection: section) - 1, 0)
        if row>0{
            return IndexPath(row: row, section: section)
        }else{
            return nil
        }
        
        
    }
    /// Registers a class for use in creating new table  Generic cells.
    /// - Parameters:
    ///   - genericCellClass: The class of a cell that you want to use in the table (must be a UITableViewCell subclass).
    ///   - reuseIdentifier: The reuse identifier for the cell. This parameter must not be nil and must not be an empty string.
    func register<T: UITableViewCell>(_ : T.Type, reuseIdentifier: String? = nil) {
        self.register(T.self, forCellReuseIdentifier: reuseIdentifier ?? String(describing: T.self))
    }
    /// Returns a reusable table-view Generic cell object for the specified reuse identifier and adds it to the table.
    /// - Parameters:
    ///   - identifier: A string identifying the cell object to be reused. This parameter can  be nil.
    ///   - indexPath: The index path specifying the location of the cell. Always specify the index path provided to you by your data source object.
    ///   This method uses the index path to perform additional configuration based on the cell’s position in the table view.
    /// - Returns: A  Geneirc UITableViewCell object with the associated reuse identifier. This method always returns a valid cell.
    func dequeue<T: UITableViewCell>(_: T.Type,reuseIdentifier: String? = nil, for indexPath: IndexPath) -> T {
        guard let cell = dequeueCell(reuseIdentifier:reuseIdentifier ?? String(describing: T.self),for: indexPath) as? T
            else { fatalError("Could not deque cell with type \(T.self)") }
        
        return cell
    }
    /// Returns a reusable table-view cell object located by its identifier.
    /// - Parameter identifier: A string identifying the cell object to be reused. This parameter must not be nil
    /// - Returns: A Generic UITableViewCell object with the associated identifier or nil if no such object exists in the reusable-cell queue.
    func dequeue<T: UITableViewCell>(_: T.Type,reuseIdentifier: String? = nil) -> T? {
        guard let cell = dequeueCell(reuseIdentifier:reuseIdentifier ?? String(describing: T.self)) as? T
            else { fatalError("Could not deque cell with type \(T.self)") }
        
        return cell
    }
    /// Returns a reusable table-view cell object located by its identifier.
    /// - Parameter identifier: A string identifying the cell object to be reused. This parameter must not be nil
    /// - Returns: A UITableViewCell object with the associated identifier or nil if no such object exists in the reusable-cell queue.
    func dequeueCell(reuseIdentifier identifier: String) -> UITableViewCell? {
        return dequeueReusableCell(withIdentifier: identifier)
    }
    /// Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table.
    /// - Parameters:
    ///   - identifier: A string identifying the cell object to be reused. This parameter must not be nil.
    ///   - indexPath: The index path specifying the location of the cell. Always specify the index path provided to you by your data source object. This method uses the index path to perform additional configuration based on the cell’s position in the table view.
    /// - Returns: A UITableViewCell object with the associated reuse identifier. This method always returns a valid cell.
    func dequeueCell(reuseIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(
            withIdentifier: identifier,
            for: indexPath
        )
    }
    func multilineCell<T:UITableViewCell>(cell:T, for height:CGFloat,minHeight:CGFloat = 60){
        
        if height>0, minHeight>0, height != minHeight {
            UIView.setAnimationsEnabled(false)
            self.beginUpdates()
            self.endUpdates()
            UIView.setAnimationsEnabled(true)
            if let thisIndexPath = self.indexPath(for: cell) {
                self.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
    /// Reloads the specified sections using a given animation effect.
    /// - Parameters:
    ///   - sections: An index set identifying the sections to reload.
    ///   - animation: A constant that indicates how the reloading is to be animated, for example, fade out or slide out from the bottom. See UITableView.RowAnimation for descriptions of these constants.
    ///   The animation constant affects the direction in which both the old and the new section rows slide. For example, if the animation constant is UITableView.RowAnimation.right, the old rows slide out to the right and the new cells slide in from the right.
    ///   - completion: A completion handler block to execute when all of the operations are finished. This block has no return value and takes the following
    ///   parameter:finished A Boolean value indicating whether the animations completed successfully. The value of this parameter is false if the animations were interrupted for any reason.
    func reload(sections: IndexSet,with animation: UITableView.RowAnimation = .automatic,completion: ((Bool) -> Void)? = nil){
        self.performBatchUpdates({self.reloadSections(sections, with: .automatic)}, completion:completion)
    }
}
extension UITableViewCell{
    var identifier:String{String(describing: self)}
}

extension UITableViewCell {
    
//    var tableView: UITableView? {
//         let currentController = UIApplication.getTopViewController()
//          
//        if let currentController = currentController, currentController.isKind(of: UITableViewController.self) {
//            return (currentController as! UITableViewController).tableView
//        }else if let currentController = currentController{
//            let subviews = currentController.view.subviews
//            var table:UITableView? = nil
//            subviews.forEach { v in
//                if let tb = v as? UITableView{
//                    table = tb
//                    return
//                }
//            }
//            return table
//        }
//        return parentView(of: UITableView.self)
//        
//    }
    
//    var indexPath: IndexPath? {
//        return tableView?.indexPath(for: self)
//    }
}


