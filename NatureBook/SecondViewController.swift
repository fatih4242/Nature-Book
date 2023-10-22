//
//  SecondViewController.swift
//  NatureBook
//
//  Created by Fatih Toker on 19.10.2023.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    static let sequeValue = "secondViewController"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
    var selectedElement: DatabaseHelper.GalleryModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedElement != nil {
            //Core Data verileri buraya gelecek
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("no app delegate")
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DatabaseHelper.Gallery.entityName)
            fetchRequest.predicate = NSPredicate(format: "id = %@", selectedElement!.id.uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let response = try context.fetch(fetchRequest).first as! NSManagedObject
        
                selectedElement?.name = response.value(forKey: DatabaseHelper.Gallery.name) as! String
                selectedElement?.image = response.value(forKey: DatabaseHelper.Gallery.image) as! Data
                selectedElement?.place = response.value(forKey: DatabaseHelper.Gallery.place) as! String
                selectedElement?.year = response.value(forKey: DatabaseHelper.Gallery.year) as! Int
                
                nameTextField.text = selectedElement?.name
                imageView.image = UIImage(data: selectedElement!.image)
                placeTextField.text = selectedElement?.place
                yearTextField.text = String(describing: selectedElement?.year)
                
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("no value")
        }

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToGallery))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func goToGallery(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func saveClickedButton(_ sender: Any) {
        //Save Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: DatabaseHelper.Gallery.entityName, into: context)
        
        saveData.setValue(UUID(), forKey: DatabaseHelper.Gallery.id)
        saveData.setValue(nameTextField.text!, forKey: DatabaseHelper.Gallery.name)
        saveData.setValue(placeTextField.text!, forKey: DatabaseHelper.Gallery.place)
        
        if let year = Int(yearTextField.text!) {
            saveData.setValue(year, forKey: DatabaseHelper.Gallery.year)
        }
        
        let imageData = imageView.image?.jpegData(compressionQuality: 1)
        saveData.setValue(imageData, forKey: DatabaseHelper.Gallery.image)
        
        do {
            try context.save()
            print("successfull save")
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    
    
}
