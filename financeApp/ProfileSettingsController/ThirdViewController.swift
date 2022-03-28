//
//  ThirdViewController.swift
//  financeApp
//
//  Created by Eric Portela on 2020-04-07.
//  Copyright © 2020 Eric Portela. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ThirdViewController: UIViewController {

    
    @IBAction func logOut(_ sender: Any) {
        do {
            try! Auth.auth().signOut()
            //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            //self.navigationController?.popToRootViewController(animated: true)
            performSegue(withIdentifier: "unwindToViewController1", sender: self)
        } catch {
            print(error)
        }
   
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Profile"
        
    }
    
    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
