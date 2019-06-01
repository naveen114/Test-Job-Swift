//
//  UpdateVC.swift
//  CoreDatademo
//


import UIKit
import CoreData
import Firebase
import FirebaseDatabase

var getrecord = NSManagedObject()


class UpdateVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var email = ""
    var password = ""
    var key = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        txtEmail.text = getrecord.value(forKey: "email") as? String
//        txtPassword.text = getrecord.value(forKey: "password") as? String
        
        txtEmail.text = self.email
        txtPassword.text = self.password
        let leftButton = UIBarButtonItem.init(title: "Back", style: .plain, target: self, action: #selector(handleLeftBtnClick))
        leftButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = leftButton
    }

    //MARK:- HANDLE LEFT BUTTON ACTION
    @objc func handleLeftBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func update(_ sender: UIButton) {
        if self.txtEmail.text?.isEmpty == true {
            
        } else if self.txtPassword.text?.isEmpty == true {
            
        } else {
            self.updateDataToFirebase()
        }
    }
    
    @IBAction func btn_back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//MARK:- TEXTFIELD DELEGATE
extension UpdateVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtEmail {
            self.txtPassword.becomeFirstResponder()
        } else if txtEmail == self.txtPassword {
            self.txtPassword.resignFirstResponder()
        }
        return true
    }
}

extension UpdateVC {
    func updateData() {
        let context = appDelegate.persistentContainer.viewContext
        let entitidec = NSEntityDescription.entity(forEntityName: "Login", in: context)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Login")
        request.entity = entitidec
        let pred = NSPredicate(format: "email =%@", txtEmail.text!)
        request.predicate = pred
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                let manage = result[0] as! NSManagedObject
                manage.setValue(txtEmail.text!, forKey: "email")
                manage.setValue(txtPassword.text!, forKey: "password")
                
                try context.save()
                self.dismiss(animated: true, completion: nil)
                
            } else {
                print("Record Not Found")
            }
        } catch {
        }
    }
    
    
    func updateDataToFirebase() {
      if Helper.isConnectedToInternet() {
        self.ref = Database.database().reference()
        let parameters:[String:AnyObject] = ["email" : self.txtEmail.text as AnyObject,
                                             "password": self.txtPassword.text as AnyObject]
        self.ref.child("Login").child(self.key).updateChildValues(parameters) { (error, databaseRef) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
            } else {
                print("Data updated")
                reloadTableViewDelegate?.reloadTableView()
                self.dismiss(animated: true, completion: nil)
            }
        }
        }
        
    }
}
