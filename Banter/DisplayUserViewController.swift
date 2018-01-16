//
//  SignInViewController.swift
//  Banter
//
//  Created by e-carlin on 1/2/18.
//  Copyright © 2018 Banter. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class DisplayUserViewController: UITableViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    
    var pool: AWSCognitoIdentityUserPool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.resetAttributeValues()
        self.fetchUserAttributes()
    }
    
    func fetchUserAttributes() {
        self.resetAttributeValues()
        user = self.pool!.currentUser()
        user?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                return nil
            }
            self.userAttributes = task.result?.userAttributes
            self.userAttributes?.forEach({ (attribute) in
                print("Name: " + attribute.name!)
            })
            DispatchQueue.main.async {
                self.setAttributeValues()
            }
            return nil
        })
    }
    
    func resetAttributeValues() {
        self.emailLabel.text = ""
    }
    
    func setAttributeValues() {
        self.emailLabel.text = valueForAttribute(name: "email")
    }
    
    func valueForAttribute(name:String) -> String? {
        let values = self.userAttributes?.filter { $0.name == name }
        return values?.first?.value
    }
    
    @IBAction func logoutButtonPressed(_ sender:AnyObject) {
        user?.signOut()
        self.fetchUserAttributes()
    }
    
    @IBAction func addAccountButtonPressed(_ sender:AnyObject) {
        self.shouldPerformSegue(withIdentifier: "addAccountSegue", sender: self)
    }
    
}
