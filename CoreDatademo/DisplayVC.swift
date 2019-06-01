//
//  DisplayVC.swift
//  CoreDatademo
//


import UIKit
import CoreData
import FirebaseDatabase
import Firebase


var currentUserInfo = String()

protocol ReloadTableViewDelegate {
    func reloadTableView()
}

var reloadTableViewDelegate: ReloadTableViewDelegate?

class DisplayVC: UIViewController,UISearchBarDelegate {

    @IBOutlet var tbl_reload: UITableView!
    
    var window: UIWindow?
    var item :[Any] = []
    var dict = NSMutableDictionary()
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference!
    var arrEmail = [String]()
    var arrPassword = [String]()
    var arrKeys = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTableViewDelegate = self
        if Helper.isConnectedToInternet() {
            self.fetchDataFromFirebase()
            self.getAllKeys()
        } else {
            self.arrEmail = Helper.getArrPREF("email") ?? []
            self.arrPassword = Helper.getArrPREF("password") ?? []
        }
        self.fetchData()
    }

    func fetchData() {
        let context = appdelegate.persistentContainer.viewContext
        var locations  = [Login]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Login")
        fetchRequest.returnsObjectsAsFaults = false
        locations = try! context.fetch(fetchRequest) as! [Login]
        for location in locations {
            item.append(location)
        }
        print(item)
        tbl_reload.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tbl_reload.reloadData()
    }
    
    
    @IBAction func btn_next(_ sender: UIBarButtonItem) {
        let navigation = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(navigation, animated: true)
    }

}


//MARK:- TABLE VIEW DELEGATE METHODS
extension DisplayVC: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return item.count
        return self.arrPassword.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
//        let dic = item[indexPath.row]  as! NSManagedObject
//        cell.lbl_email?.text = dic.value(forKey: "email" ) as? String
//        cell.lbl_password?.text = dic.value(forKey: "password" )  as? String
        cell.lbl_email.text = self.arrEmail[indexPath.row]
        cell.lbl_password.text = self.arrPassword[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if Helper.isConnectedToInternet() {
            let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
                let updatevc = self.storyboard?.instantiateViewController(withIdentifier: "UpdateVC") as! UpdateVC
                //            let temp = self.item[indexPath.row] as! NSManagedObject
                //            getrecord = temp
                let nav = UINavigationController.init(rootViewController: updatevc)
                updatevc.email = self.arrEmail[indexPath.row]
                updatevc.key = self.arrKeys[indexPath.row]
                updatevc.password = self.arrPassword[indexPath.row]
                self.present(nav, animated: true, completion: nil)
            })
            
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
                if Helper.isConnectedToInternet() {
                    self.getAllKeys()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        self.ref = Database.database().reference()
                        self.ref.child("Login").child(self.arrKeys[indexPath.row]).removeValue()
                        self.arrPassword.remove(at: indexPath.row)
                        self.arrEmail.remove(at: indexPath.row)
                        self.tbl_reload.deleteRows(at: [indexPath], with: .automatic)
                        self.arrKeys = []
                        self.tbl_reload.reloadData()
                    })
                    
                }
            })
            
            return [deleteAction, editAction]
        } else {
            return []
        }
        
    }
}

//MARK:- CUSTOM DELEGATE
extension DisplayVC: ReloadTableViewDelegate {
    func reloadTableView() {
        self.item = []
        self.arrPassword = []
        self.arrEmail = []
        self.fetchData()
        self.fetchDataFromFirebase()
        self.tbl_reload.reloadData()
    }
}

extension DisplayVC {
    func fetchDataFromFirebase() {
        if Helper.isConnectedToInternet() {
            ref = Database.database().reference()
            ref.child("Login").observeSingleEvent(of: .value, with: { (snapshots) in
                if snapshots.exists() {
                    for snap in snapshots.children.allObjects as! [DataSnapshot] {
                        let dict = snap.value as? [String:AnyObject]
                        let email = dict?["email"]
                        let password = dict?["password"]
                        self.arrEmail.append(email as? String ?? "")
                        self.arrPassword.append(password as? String ?? "")
                        Helper.setArrPREF(self.arrEmail, key: "email")
                        Helper.setArrPREF(self.arrPassword, key: "password")
                        self.tbl_reload.reloadData()
                    }
                } else {
                    print("No Value to fetch")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
    }
    
    func getAllKeys() {
        if Helper.isConnectedToInternet() {
            ref = Database.database().reference()
            ref.child("Login").observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let key = snap.key
                    self.arrKeys.append(key)
                    print(self.arrKeys)
                }
            }
        }
        
    }
    
    
}
