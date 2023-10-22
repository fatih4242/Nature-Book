//
//  ViewController.swift
//  NatureBook
//
//  Created by Fatih Toker on 19.10.2023.
//

import UIKit
import CoreData



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dbArray = [DatabaseHelper.GalleryModel]()
    var selectedElement: DatabaseHelper.GalleryModel?
   
    var clickedAddItem = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = dbArray[indexPath.row].name
        return cell
    }
    

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemTap))
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        getDBData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDBData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func getDBData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("no app delegate")
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DatabaseHelper.Gallery.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            dbArray.removeAll()
            
            let response = try context.fetch(fetchRequest)
            for res in response as! [NSManagedObject] {
                if let name = res.value(forKey: DatabaseHelper.Gallery.name) as? String,
                   let place = res.value(forKey: DatabaseHelper.Gallery.place) as? String,
                   let year = res.value(forKey: DatabaseHelper.Gallery.year) as? Int,
                   let image = res.value(forKey: DatabaseHelper.Gallery.image) as? Data,
                   let id = res.value(forKey: DatabaseHelper.Gallery.id) as? UUID
                {
                    dbArray.append(DatabaseHelper.GalleryModel(id: id, name: name, place: place, image: image, year: year))
                }
                
                self.tableView.reloadData()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }

    @objc func addItemTap() {
        clickedAddItem = true
        performSegue(withIdentifier: SecondViewController.sequeValue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SecondViewController.sequeValue && !clickedAddItem {
            let destinationVC = segue.destination as! SecondViewController
            destinationVC.selectedElement = self.selectedElement
        }
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickedAddItem = false
        selectedElement = dbArray[indexPath.row]
        performSegue(withIdentifier: SecondViewController.sequeValue, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("no app delegate")
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DatabaseHelper.Gallery.entityName)
        
        let uuid = dbArray[indexPath.row].id.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", uuid)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(fetchRequest).first as! NSManagedObject
            context.delete(result)
            
            getDBData()
        } catch {
            print(error.localizedDescription)
        }
    }
}

