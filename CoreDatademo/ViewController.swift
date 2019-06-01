//
//  ViewController.swift
//  CoreDatademo


import UIKit
import CoreData
import Firebase
import FirebaseDatabase


class ViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    let nscontext = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    
    var ref: DatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtEmail.endEditing(true)
    }
    
    @IBAction func INsert(_ sender: UIButton) {
        if self.txtEmail.text?.isEmpty == true {
            
        } else if self.txtPassword.text?.isEmpty == true {
            
        } else {
            //self.insertData()
            self.saveDataToFirebase()
        }
    }
    
    @IBAction func btn_back(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK:- TEXTFILED DELEGATE
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtEmail {
            self.txtPassword.becomeFirstResponder()
        } else if textField == self.txtPassword {
            self.txtPassword.resignFirstResponder()
        }
        return true
    }
}

extension ViewController {
    func insertData() {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Login", into: nscontext)
        entity.setValue(txtEmail.text, forKey:"email")
        entity.setValue(txtPassword.text, forKey: "password")
        do
        {
            try nscontext.save()
            txtEmail.text = ""
            txtPassword.text = ""
            
        }
        catch
        {
            
        }
        print("Record Inserted")
        reloadTableViewDelegate?.reloadTableView()
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- SAVE DATA
extension ViewController {
    func saveDataToFirebase() {
        if Helper.isConnectedToInternet() {
            ref = Database.database().reference()
            let parameters:[String:AnyObject] = ["email" : self.txtEmail.text as AnyObject,
                                                 "password": self.txtPassword.text as AnyObject]
            ref.child("Login").childByAutoId().setValue(parameters) { (error, DatabaseRef) in
                if error != nil {
                    print(error?.localizedDescription ?? "error")
                } else {
                    reloadTableViewDelegate?.reloadTableView()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    }
}
