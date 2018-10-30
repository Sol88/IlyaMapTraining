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
    @IBOutlet weak var loginLogoutBarItem: UIBarButtonItem!
    
    //MARK: - Property
    static var storyboardInstance: LoginViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    var pushingVC: UIViewController!
    var isAuthorized = false
    let VK_APP_ID = "6732389"

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginLogoutBarItem.title = "Loading..."
        loginLogoutBarItem.isEnabled = false
        
        let sdkInstance = VKSdk.initialize(withAppId: VK_APP_ID)
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        VKSdk.wakeUpSession(["photos"]) { [weak self] state, error in
            self?.loginLogoutBarItem.isEnabled = true
            
            let authorizationSuccess = (state == .initialized || state == .authorized) && VKSdk.accessToken() != nil
            self?.set(isAuthorized: authorizationSuccess)
            
            if let error = error {
                print(error)
            }
        }
        
    }
    
    //MARK: - Action
    @IBAction func loginLogoutHandler(_ sender: UIBarButtonItem) {
        
        if isAuthorized {
            VKSdk.forceLogout()
            set(isAuthorized: false)
            
        } else {
            VKSdk.authorize([VK_PER_PHOTOS])
        }
    }
    
    @IBAction func loginVKButtonHandler(_ sender: UIButton) {
        let vc = ViewController.storyboardInstance
        vc.fromLibrary = false
        pushingVC = vc
        
        performTransition()
        
    }
    
    @IBAction func enterWithoutLogginHandler(_ sender: UIButton) {
        let vc = ViewController.storyboardInstance
        vc.fromLibrary = true
        pushingVC = vc
        
        performTransition()
    }
    
    @IBAction func goToPhotoCollectionHandler(_ sender: UIButton) {
        let vc = VKImageListViewController.storyboardInstance
        pushingVC = vc
        
        performTransition()
    }
    
    
    //MARK: - Method
    func set(isAuthorized: Bool) {
        
        loginButton.isEnabled = isAuthorized
        goToCollectionViewButton.isEnabled = isAuthorized
        self.isAuthorized = isAuthorized
        
        loginLogoutBarItem.title = isAuthorized ? "Sign out VK" : "Sign in VK"
        
    }
    
    func performTransition() {
        navigationController?.pushViewController(pushingVC, animated: true)
    }
    
}


//MARK: - VK
extension LoginViewController: VKSdkDelegate, VKSdkUIDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        
        if let _ = result.token {
            set(isAuthorized: true)
            
        } else if let error = result.error {
            print(error)
        }
        
    }
    
    func vkSdkUserAuthorizationFailed() {
        set(isAuthorized: false)
        print("Authorization failed")
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        present(controller, animated: true)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("captcha")
    }
    
    
}
