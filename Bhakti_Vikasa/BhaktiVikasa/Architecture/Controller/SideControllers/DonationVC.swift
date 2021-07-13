//
//  PaymentVC.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 22/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

/*
 import UIKit
 class PaymentVC: UIViewController {
 }
 */
import UIKit
import Razorpay
class DonationVC: UIViewController,UISearchResultsUpdating {
    
    
    
    // typealias Razorpay = RazorpayCheckout
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtDonateFor: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtCurrency: UITextField!
    @IBOutlet weak var txtoptionMessage: UITextField!
    
    private var currency_code = "IND"
    private var countryCodeBtn:UIButton = .init(type: .custom)
    private  var razorpay: RazorpayCheckout!
    private var search:String=""
    private  var searcTime : Timer? = nil
 
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.hideKeyboardWhenTappedAround()
        initialSetup()
       // razorpay = RazorpayCheckout.initWithKey("rzp_test_IjSKkxoWWZyC1b", andDelegate: self) //TEST KEY
        razorpay = RazorpayCheckout.initWithKey("rzp_live_9vXnIK1pCzdgN3", andDelegate: self) //LIVE KEY
        addSearch()
        
        
    }
    func addSearch(){
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    @IBAction func moveToBack(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.resignFirstResponder()
            
            var errorMsg = ""
            if self.txtCurrency.text?.isEmpty ?? true{
                errorMsg = "Please provide a valid currency"
            }else if self.txtAmount.text?.isEmpty ?? true{
                errorMsg = "Please provide valid amount"
            }else if self.txtDonateFor.text?.isEmpty ?? true{
                errorMsg = "Please Donation option"
            }else{
                self.genrateRazorPayOrderID()
                return
            }
            self.popupAlert(title: "Dontion faild", message:errorMsg , actionTitles: ["Ok"], actions: [nil])
        }
        
    }
    
    func initialSetup(){
      //  txtName.text = GlobleVAR.appUser.name
        txtEmail.text = GlobleVAR.appUser.email
        txtDonateFor.delegate = self
        txtCurrency.delegate = self
        setupCountryTextField(textfield: txtPhoneNumber)
    }
    
    func setupCountryTextField(textfield: UITextField){
       
        let countrie = JKCountry(countryCode: "IN", countryName: "India", dialCode: "+91")
        //Bundle.decode([JKCountry].self, forResource: "CountryCodes", extension: "json").randomElement()
        countryCodeBtn = UIButton(type: .custom)
        self.countryCodeBtn.setTitleColor(.lightGray, for: .normal)
        self.countryCodeBtn.setTitle("    \(countrie.flag ?? "") \(countrie.dialCode ?? "")    ", for: .normal)
        
        countryCodeBtn.addTarget(self, action: #selector(self.refresh(_:)), for: .touchUpInside)
     //   countryCodeBtn.frame = CGRect(origin: self.txtPhoneNumber.frame.origin, size: CGSize(width: 100, height: 40))
        countryCodeBtn.frame = CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: 100.0, height:30.0))
        let leftView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0) , size: CGSize(width: 100.0, height:30.0)))
        
        leftView.addSubview(countryCodeBtn)
       // self.view.bringSubviewToFront(countryCodeBtn)
      
        textfield.leftView = leftView//countryCodeBtn
        textfield.leftViewMode = .always
       //   textfield.leftView?.sizeToFit()
    }
    
    @objc func refresh(_ sender: UITextField){
        self.showDataPicker(with: sender)
    }
    private func showDataPicker(with type:UITextField){
        let vc = AppStorybords.home.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        if type == self.txtCurrency{
            let currancyModel = Bundle.decode([RazorPayCurrancy].self, forResource: "currencyCodeRazorPay", extension: "json")
            vc.currancyModel = currancyModel
            vc.countryCode = nil
        }else{
            let object = JKCountryViewModel.shared
            object.getCountry()
            vc.currancyModel = nil
            vc.countryCode = object.countries
        }
        vc.getSelectionCallBack = { (sCountry,sCurrancy) in
            if sCountry != nil{
                let displayText = sCountry!.flag!+" "+sCountry!.dialCode
                self.countryCodeBtn.setTitle(displayText, for: .normal)
                
            }else{
                let displayText = "' "+sCurrancy!.currencyCode+" '"+" "+sCurrancy!.countryName
                self.txtCurrency.text = displayText
                self.currency_code = sCurrancy!.currencyCode
                print(sCurrancy!.currencyCode)
            }
            
        }
        let navVC =  UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true, completion: nil)
    }
    

}
import Alamofire
extension DonationVC:RazorpayPaymentCompletionProtocol{
    func genrateRazorPayOrderID(){
        
        guard let ammount = Float(self.txtAmount.text ?? "0") else{return}
        
        let receipt = String.random()+"_#\(self.txtDonateFor.text ?? "")"
        let orderId_Params = ["amount":ammount*100,"currency":currency_code,"receipt":receipt] as [String : Any]
       // let headers_Params = ["Authorization":"Basic cnpwX3Rlc3RfSWpTS2t4b1dXWnlDMWI6dkR5Ukk4NFl4V3ptNk5pOEhYZDJYd3g5"] //RAZOR_PAY TEST KEY
        let headers_Params = ["Authorization":"Basic cnpwX2xpdmVfOXZYbklLMXBDemRnTjM6RTZLTGxkckhpWkUxaXlWcldXU1NTZ1pU"] //RAZOR_PAY LIVE KEY
        CommonFunc.shared.switchAppLoader(value: true)
        let headers = HTTPHeaders(headers_Params)
        Webservices.instance.post(url: raZorPay_OrderUrl, params: orderId_Params, headers: headers){ (order:RazorPayOrder?, error:RazorPayError_Ordar?, errorStr) in
            CommonFunc.shared.switchAppLoader(value: false)
            if let orderDetail  = order{
                self.showPaymentForm(order: orderDetail)
            }else{
                self.popupAlert(title: error?.error.code, message: error?.error.errorDescription, actionTitles: ["Ok"], actions: [nil])
            }
        }
        
    }
    
    internal func showPaymentForm(order:RazorPayOrder){
        let options: [String:Any] = [
            "amount": order.amountPaid, //This is in currency subunits. 100 = 100 paise= INR 1.
            "currency": order.currency,//We support more that 92 international currencies.
            "description":"Donation",// order.receipt,//"purchase description",
            "order_id": order.id,//"order_DBJOWzybf0sJbb",
            "image": "https://bvks-d1ac.kxcdn.com/wp-content/uploads/2018/05/20151354/4-3.jpg",
            "name": "Bhakti Vikasa Trust",//"BVKS DONATION FROM \(self.txtName.text)",
            "prefill": [
                "contact": self.txtPhoneNumber.text,
                "email": self.txtEmail.text
            ],
            "theme": [
                "color": "#Fd7e14"//"#F37254"
            ]
        ]
        // razorpay.open(options)
        razorpay.open(options, displayController: self)
    }
    func onPaymentError(_ code: Int32, description str: String) {
        print("CODE: ",code)
        print("description str: ",str)
        self.popupAlert(title: "FAILED", message: str, actionTitles: ["BACK"], actions: [
            {action in
                self.navigationController?.popViewController(animated: true)
            }
        ])
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        
        print("payment_id String : ",payment_id)
        self.popupAlert(title: "Thankyou!", message: "We have received your donation.", actionTitles: ["BACK"], actions: [
            {action in
                self.navigationController?.popViewController(animated: true)
            }
        ])
    }
}

extension DonationVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.resignFirstResponder()
            self.view.endEditing(true)
            self.resignFirstResponder()
            if textField == self.txtCurrency {
                self.showDataPicker(with: textField)
                
            }else if textField == self.txtDonateFor{
                let otherOptions = ["Village Development","Gurukula Schools","Website Maintenance","Book Printing","Media services","Others"]
                self.showDropdown(items: otherOptions, sender: textField, configure: {(cell, item) in
                    cell.textLabel?.text = item
                    
                }, didSelect: {item  in
                    self.txtDonateFor.text = item
                    if item == "Others"{
                        self.txtoptionMessage.isHidden = false
                    }else{
                        self.txtoptionMessage.isHidden = true
                    }
                    self.txtoptionMessage.text = ""
                })
            }
        }
    }
    
    
}

