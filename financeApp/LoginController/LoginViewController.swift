//
//  LoginViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-04-07.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //Outlets for register view
    @IBOutlet weak var emailInputOne: UITextField!
    @IBOutlet weak var usernameInputOne: UITextField!
    @IBOutlet weak var passwordInputOne: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    //Outlets for login view
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var startLabel: UILabel!

    //Main boards
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var registerView: UIView!
    
    //Register
    @IBOutlet weak var registerBoard: UIView!
    @IBOutlet weak var registerBtn: UIButton!
    
    //Login
    @IBOutlet weak var loginBoard: UIView!
    @IBOutlet weak var loginBtn: UIButton!

    @IBOutlet weak var finalyticaLogo: UIImageView!
    //Unwind segue preparation to access this view when pressing log out in third tab item in tab bar
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finalyticaLogo.isHidden = true
        
        continueButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        registerBtn.addTarget(self, action: #selector(switchToRegister), for: .touchUpInside)
        loginBtn.addTarget(self, action: #selector(switchToLogin), for: .touchUpInside)
        
        boardAppearance()
        
        //Pre-fixing the login page (e.g. the buttons, boards, views, etc)
        let screenBounds = UIScreen.main.bounds
        let screen_width = screenBounds.width
        
        self.registerView.center.x = screen_width - screen_width - ((self.registerView.bounds.width)/2) - 40
        self.loginBoard.center.x = screen_width - screen_width - ((self.loginBoard.bounds.width)/2) - 40
        
        emailInput.placeholder = "E-mail"
        passwordInput.placeholder = "Password"
        passwordInput.isSecureTextEntry = true
        emailInputOne.placeholder = "E-mail"
        usernameInputOne.placeholder = "Username"
        passwordInputOne.placeholder = "Password"
        passwordInputOne.isSecureTextEntry = true
        
        
        if Auth.auth().currentUser != nil {
            loginView.isHidden = true
            registerBtn.isHidden = true
            startLabel.isHidden = true
            registerBoard.isHidden = true
            finalyticaLogo.isHidden = false
            
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //let vc = storyboard.instantiateViewController(withIdentifier: "toHomeScreen") as? ViewController
            
            //view.window?.rootViewController = vc
            //view.window?.makeKeyAndVisible()
            //vc.modalPresentationStyle = .overFullScreen
            //present(vc, animated: true)
            performSegue(withIdentifier: "toHomeScreen", sender: self)
        }
    }
    
    //private func prepare
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @objc func handleSignIn() {
        guard let email = emailInput.text else { return }
        guard let password = passwordInput.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) {user, error in
            if error == nil && user != nil {
                self.performSegue(withIdentifier: "toHomeScreen", sender: nil)
                self.emailInput.text = ""
                self.passwordInput.text = ""
                //self.navigationController?.popViewController(animated: true)
            } else {
                print("Error loging in: \(error!.localizedDescription )")
            }
        }
    }
    
    @objc func handleSignUp() {
        guard let username = usernameInputOne.text else { return }
        guard let email = emailInputOne.text else { return }
        guard let password = passwordInputOne.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil && user != nil {
                print("User created!")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        //self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                if let errorLocDesc = error?.localizedDescription {
                    print("Error creating user: \(errorLocDesc)")
                }
            }
        }
    }
    
    @objc func switchToRegister() {
        startLabel.text = "Register"

        let screenBounds = UIScreen.main.bounds
        let screen_width = screenBounds.width
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.registerBoard.center.x = screen_width + ((self.registerBoard.bounds.width)/2) + 40})
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.loginView.center.x = screen_width - screen_width - ((self.loginView.bounds.width)/2) - 40})

        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.registerView.center.x = screen_width - screen_width + ((self.registerView.bounds.width)/2)})
        
        loginBoard.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.loginBoard.center.x = screen_width - screen_width + ((self.loginBoard.bounds.width)/2)})
    }
    
    @objc func switchToLogin() {
        startLabel.text = "Log in"
        
        let screenBounds = UIScreen.main.bounds
        let screen_width = screenBounds.width
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.loginBoard.center.x = screen_width - screen_width - ((self.loginBoard.bounds.width)/2)})
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.loginView.center.x = screen_width - screen_width + ((self.loginView.bounds.width)/2)})
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.registerView.center.x = screen_width - screen_width - ((self.registerView.bounds.width)/2) - 40})

        loginBoard.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: {self.registerBoard.center.x = screen_width - ((self.registerBoard.bounds.width)/2)})

    }
    
    func boardAppearance() {
        let switches = ["register": [loginView, registerBoard, registerBtn], "login": [registerView, loginBoard, loginBtn]] //ad the main view for sign up
        
        for (_,v) in switches {
            for i in v {
                if i == loginView || i == registerView{
                    i?.layer.cornerRadius = 70
                    i?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                    i?.layer.shadowColor = UIColor.black.cgColor
                    i?.layer.shadowOpacity = 1
                    i?.layer.shadowOffset = .zero
                    i?.layer.shouldRasterize = true
                    i?.layer.rasterizationScale = UIScreen.main.scale
                }
                    
                else if i == registerBoard || i == loginBoard {
                    if i == registerBoard {
                        i?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
                    }
                    else {
                        i?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                    }
                    
                    i?.layer.cornerRadius = 25
                    i?.layer.shadowColor = UIColor.black.cgColor
                    i?.layer.shadowOpacity = 1
                    i?.layer.shadowOffset = .zero
                    i?.layer.shouldRasterize = true
                    i?.layer.rasterizationScale = UIScreen.main.scale
                }
                
                else if i == registerBtn || i == loginBtn {
                    if i == registerBtn {
                        i?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
                    }
                    else {
                        i?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                    }
                    i?.layer.cornerRadius = 30
                }
            }
        }
    }
}


class DrawOnView: UIView {
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let color = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.5)
        context?.setLineWidth(1.0)
        context?.setStrokeColor(color.cgColor)
        context?.move(to: CGPoint(x:0, y: 5.5))
        context?.addLine(to: CGPoint(x: 310 , y: 5.5))
        context?.strokePath()
    }
}
