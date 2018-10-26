//
//  LoginViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 26/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import VK_ios_sdk
import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var enterWithoutLoginButton: UIButton!
    @IBOutlet weak var goToCollectionViewButton: UIButton!
    
    //MARK: - Property
    static var storyboardInstance: LoginViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    var pushingVC: ViewController!
    
    let VK_APP_ID = "6732389"
    var token: VKAccessToken?

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.isEnabled = false
        
        let sdkInstance = VKSdk.initialize(withAppId: VK_APP_ID)
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        VKSdk.wakeUpSession(["photos"]) { [weak self] state, error in
            if state == .initialized || state == .authorized {
                self?.loginButton.isEnabled = true
                self?.loginButton.isEnabled = true
            } else if let error = error {
                // Error handler
            }
        }
    }
    
    //MARK: - Action
    @IBAction func loginVKButtonHandler(_ sender: UIButton) {
        let vc = ViewController.storyboardInstance
        vc.fromLibrary = false
        pushingVC = vc
        VKSdk.authorize([VK_PER_PHOTOS])
    }
    
    @IBAction func enterWithoutLogginHandler(_ sender: UIButton) {
        let vc = ViewController.storyboardInstance
        vc.fromLibrary = true
        pushingVC = vc
        performTransition()
    }
    
    @IBAction func goToPhotoCollectionHandler(_ sender: UIButton) {
        
    }
    
    
    //MARK: - Method
    func performTransition() {
        navigationController?.pushViewController(pushingVC, animated: true)
    }
    
}


//MARK: - VK
extension LoginViewController: VKSdkDelegate, VKSdkUIDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if let token = result.token {
            self.token = token
            performTransition()
        } else if let error = result.error {
            print(error)
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("fail")
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        present(controller, animated: true)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("captcha")
    }
    
    
}
