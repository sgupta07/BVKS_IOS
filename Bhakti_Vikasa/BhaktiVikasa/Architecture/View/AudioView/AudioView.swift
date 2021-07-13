//
//  AudioView.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 26/11/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit
import MarqueeLabel
class AudioView:UIView{
    
    @IBOutlet var contentView: UIView!
    //player outlet
    @IBOutlet weak var lblplayerSubTitle:UILabel!
    @IBOutlet weak var lblPlayerTitle:MarqueeLabel!
    @IBOutlet weak var imgPlayerThumb:UIImageView!
    @IBOutlet weak var btnPlay:UIButton!
    
    let kCONTENT_XIB_NAME = "AudioView"
/*
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
     }
     required init?(coder aDecoder: NSCoder) {
             super.init(coder: aDecoder)
     }
  */
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        addActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        addActions()
    }
    func addActions(){
        self.contentView.addShadow()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openPlayer(_:)))
                    self.contentView.addGestureRecognizer(tap)
    }
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        btnPlay.tintColor = AppColors.primaryOring
    }
     
      @objc func openPlayer(_ sender: UITapGestureRecognizer? = nil) {
          // handling code
          let vc = AppStorybords.home.instantiateViewController(withIdentifier: "PlayerVC")as! PlayerVC
        UIApplication.getTopViewController()?.present(vc, animated: true, completion: nil)
          vc.onDoneBlock = {
              if CommonPlayerFunc.shared.isPlaying{
                         
                  self.btnPlay.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                     }else{
                  self.btnPlay.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                         
                     }
          }
      }
    @IBAction func playAndPause(_ sender: UIButton)-> Void{
        NotificationCenter.default.post(name: Notification.Name(AppNotification.setPlayerState), object: nil)
        //           if sender.currentImage ==  #imageLiteral(resourceName: "pause") {
        //               CommonPlayerFunc.shared.pause()
        //               sender.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        //           }else{
        //                CommonPlayerFunc.shared.play()
        //               sender.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        //           }
        
        if CommonPlayerFunc.shared.isPlaying{
            CommonPlayerFunc.shared.pause()
            self.btnPlay.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }else{
            
            CommonPlayerFunc.shared.play()
            self.btnPlay.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            
            
        }
        
    }

}
//PUBLIC FUNCTION
extension AudioView{
    func detailForAudioPlay(lect:Lecture){

        lblPlayerTitle.text = lect.title?.joined(separator: " ")
        lblplayerSubTitle.text = lect.category?.randomElement()
        if GlobleVAR.isFirstPlay{
            btnPlay.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            
        }else{
            btnPlay.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        }
        imgPlayerThumb.kf.setImage(with: URL(string: lect.thumbnail ?? ""), placeholder:  #imageLiteral(resourceName: "bvks_thumbnail"))
    }
}
