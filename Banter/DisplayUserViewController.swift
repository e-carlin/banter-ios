//
//  SignInViewController.swift
//  Banter
//
//  Created by e-carlin on 1/2/18.
//  Copyright © 2018 Banter. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import LinkKit

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
        
        //TODO: Move somewhere else. READ: https://github.com/plaid/link/tree/master/ios#setup-plaid-link
        PLKPlaidLink.setup { (success, error) in
            if (success) {
                // Handle success here, e.g. by posting a notification
                NSLog("Plaid Link setup was successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PLDPlaidLinkSetupFinished"), object: self)
            }
            else if let error = error {
                NSLog("Unable to setup Plaid Link due to: \(error.localizedDescription)")
            }
            else {
                NSLog("Unable to setup Plaid Link")
            }
        }
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
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
    }
}

extension DisplayUserViewController : PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            NSLog("Successfully got public token!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
//            self.handleSuccessWithToken(publicToken, metadata: metadata)
            NSLog("About to exchange public key...")
            PlaidHelper.exchangePublicKey(publicToken: publicToken);
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
//                self.handleError(error, metadata: metadata)
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
//                self.handleExitWithMetadata(metadata)
            }
        }
    }
}
