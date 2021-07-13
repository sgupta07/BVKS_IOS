//
//  CreatePaylistVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 07/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit
import Toaster
import DropDown

class CreatePaylistVC: UIViewController {
    var opratedlecture: Lecture? = nil
    var listType: PlayList.listType? = .privateList {
        didSet{
            self.lblTitle.text = "Playlist : \(String(describing: listType!.str))"
        }
        
    }
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var txtTitle:UITextField!
    @IBOutlet weak var txtCetgory:UITextField!
    @IBOutlet weak var txtDiscription:UITextView!
    @IBOutlet weak var btnPublic:UIButton!
    @IBOutlet weak var btnPrivate:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func dismissAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    

     @IBAction func selectePublicType(_ sender:UIButton){
        self.listType = .publicList
        self.btnPublic.setImage(#imageLiteral(resourceName: "selectedRadio"), for: .normal)
        self.btnPrivate.setImage(#imageLiteral(resourceName: "unSelectedRadio"), for: .normal)


    }
    @IBAction func selectePrivateType(_ sender:UIButton){
        self.listType = .privateList
        self.btnPrivate.setImage(#imageLiteral(resourceName: "selectedRadio"), for: .normal)
        self.btnPublic.setImage(#imageLiteral(resourceName: "unSelectedRadio"), for: .normal)


    }
    
    @IBAction func createPlayList(_ sender:UIButton){
        if txtTitle.text?.isEmpty ?? true || txtCetgory.text?.isEmpty ?? true || txtDiscription.text.isEmpty{
            Toast(text:"Please enter all fields",duration: Delay.long).show()

        }else{
            let newDocumentID = UUID().uuidString
            let playList  = PlayList(name: txtTitle.text,
                                     thumbnail:opratedlecture?.thumbnail,
                                           listID: newDocumentID,
                                           lecturesCategory: txtCetgory.text,
                                           listType: listType?.str,
                                           creationTime: Double(c_Time),
                                           lastUpdate: Double(c_Time),
                                           lectureCount: 1,
                                           lectureIds: [(opratedlecture?.id! ?? 0)],
                                           docPath : "",
                                           discription: txtDiscription.text!,
                                           email:GlobleVAR.appUser.email)
            if listType == .privateList{
                PlayList.createPrivatePlayList(with: playList)
            }else{
                PlayList.createPublicPlayList(with: playList)
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }


}
