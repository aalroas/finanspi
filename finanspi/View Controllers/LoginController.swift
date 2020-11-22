//
//  LoginController.swift
//  finanspi
//
//  Created by Abdulsalam Alroas on 9/14/20.
//  Copyright © 2020 Abdulsalam Alroas. All rights reserved.
//

import UIKit
import WebKit
import Foundation
import SVProgressHUD
import SafariServices

class LoginController: UIViewController,UITextFieldDelegate,SFSafariViewControllerDelegate {
    
     
    @IBOutlet weak var termsButtonOutlet: UIButton!
    
    @IBOutlet weak var privacyPolicyButtonOutlet: UIButton!
    
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func LoginButton(_ sender: Any) {
        guard let url = URL(string: "https://www.pi.finanspi.com/api/auth") else {
                    return
                }
        SVProgressHUD.show()
        if(username.text!.isEmpty){
            SVProgressHUD.dismiss()
            Helper.app.showAlert(title: "Hata", message: "kullanıcı adı alanı boş", vc: self)
         return
        }
        if(password.text!.isEmpty){
          SVProgressHUD.dismiss()
          Helper.app.showAlert(title: "Hata", message: "Şifre alanı boş", vc: self)
          return
        }
        
        
        
        let data : Data =  "username=\(username.text!)&password=\(password.text!)&server_key=56ef57705487e1954a2fbd0a1882404e4bb3a0c3-fc12b2efb86e258aa228832a71d465fd-79130275".data(using: .utf8)!
                var request : URLRequest = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
                request.setValue(NSLocalizedString("lang", comment: ""), forHTTPHeaderField:"Accept-Language");
                request.httpBody = data
                print("one called")
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                let task = session.dataTask(with: request, completionHandler: {
                    (data, response, error) in

                     if let error = error
                    {
                        print(error)
                    }
                     else if response != nil {
                        print("her in resposne")
                    }

                    DispatchQueue.main.async { // Correct
                        guard let responseData = data else {
                            print("Error: did not receive data")
                            return
                        }
                     let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                    
                     if(json!["access_token"] != nil ){
                        UserDefaults.standard.accessToken = json!["access_token"] as? String
                        UserDefaults.standard.username = self.username.text
                        UserDefaults.standard.password = self.password.text
                        UserDefaults.standard.serverKey = "56ef57705487e1954a2fbd0a1882404e4bb3a0c3-fc12b2efb86e258aa228832a71d465fd-79130275"
                        UserDefaults.standard.nightMode = false
                        if UserDefaults.standard.isNotificationPermissionGranted {
                            let sendDeviceToken = HomeViewController()
                            sendDeviceToken.sendDeviceToken(uAccessToken: UserDefaults.standard.accessToken ?? "" , UdeviceToken: UserDefaults.standard.DeviceToken ?? "")
                        }
                        SVProgressHUD.dismiss()
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeController = storyboard.instantiateViewController(withIdentifier: "home")
                        if #available(iOS 13.0, *) {
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(homeController)
                        } else {
                            (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(homeController)
                        }
                     }else{
                         SVProgressHUD.dismiss()
                         Helper.app.showAlert(title: "Hata", message: "kullanıcı adı veya şifre yanlış", vc: self)
                        }
                    }
                })
                task.resume()
    }
 
    @IBAction func RegisterButton(_ sender: Any) {
        let urlString = "https://www.pi.finanspi.com/register"

        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true)
        }
       
    }
    
    
    
    
    @IBAction func termsButton(_ sender: Any) {
        
        let urlString = "https://www.pi.finanspi.com/terms/terms"

        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true)
        }
        
        
    }
    
    
    @IBAction func privacyPolicyButton(_ sender: Any) {
        
        let urlString = "https://www.pi.finanspi.com/terms/privacy-policy"

        if let url = URL(string: urlString) {
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            present(vc, animated: true)
        }
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        username.delegate = self
        password.delegate = self
        termsButtonOutlet.underline()
        privacyPolicyButtonOutlet.underline()
        makeTextFieldBorderstyle()
     }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    
    
    func makeTextFieldBorderstyle(){
    if #available(iOS 14.0, *) {
        self.username.borderStyle = .line
        self.password.borderStyle = .line
      }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    
}

     extension LoginController {
        
        
     func initializeHideKeyboard(){
     //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
     let tap: UITapGestureRecognizer = UITapGestureRecognizer(
     target: self,
     action: #selector(dismissMyKeyboard))
     //Add this tap gesture recognizer to the parent view
     view.addGestureRecognizer(tap)
        
     }
       
        
        
        
    
        
     @objc func dismissMyKeyboard(){
     //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
     //In short- Dismiss the active keyboard.
     view.endEditing(true)
     }
        
     
    }
