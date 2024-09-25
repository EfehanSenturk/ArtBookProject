//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Efehan Şentürk on 25.09.2024.
//

import UIKit
import CoreData


class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != ""{
            saveButton.isHidden = true
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            
            
            do{
                let results = try context.fetch(fetchRequest)
                
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        nameText.text = name
                    }
                    if let artist = result.value(forKey: "artist") as? String{
                        artistText.text = artist
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearText.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                }
                
            } catch{
                print("Error")
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        //Recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer) // ekranda herhangi bir yere tıklanınca kapanması için gesture recognizeri direkt viewe verdik.
        
        imageView.isUserInteractionEnabled = true
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGesture)
        
        
        
    }
    
    
    
    @objc func hideKeyboard(){
        view.endEditing(true) // ekranda biyere tıklanınca klavyeyi kapattıracak.
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // kullanıcı resmi nerden seçecek galeriden mi kameradan mı.
        picker.allowsEditing = true // kullanıcı resmi seçtikten sonra düzenleyebilcek mi onu true yaptık.
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage // any dönen kısmı UIImage olarak cast ettik imageViewin içeriğine atadık.
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil) //açtığımız pickeri kapattık bu kısımda.
    }
    
    
    
    @IBAction func saveButton(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate  // Burası app delegeteye erişmek için oluşturduğumuz değişken. Ezber bilgi.
        let context = appdelegate.persistentContainer.viewContext // burasıda ezber context üzerinden erişicez.
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context) //veritabanında oluşturduğumuz Paintings entitysinin içine new Painting olarak kaydedicez.
        
        //Attributes
        newPainting.setValue(nameText.text!, forKey: "name")  //new painting üzerinden kaydetme yapıyoruz.
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5) // resimi dataya çevirdik.
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch{
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil) // Tüm appe new data diye bir notification yollayacak.
        
        self.navigationController?.popViewController(animated: true) // Bir önceki view controllere döndürdük butona basıldıktan sonra.
        
    }
    

}
