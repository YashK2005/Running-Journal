//
//  ShoesViewController.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-09-21.
//

import UIKit
import CoreData

class ShoesViewController: UIViewController {
    let userDefaults = UserDefaults.standard
    var distanceUnits = "km"
    
    var shoes: [NSManagedObject] = []
    @IBOutlet weak var shoeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shoeTableView.delegate = self
        shoeTableView.dataSource = self
        getShoeData()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addShoeButtonClicked(_ sender: UIButton) {
        
        let refreshAlert = UIAlertController(title: "Add A Shoe", message: "Enter shoe name",  preferredStyle: UIAlertController.Style.alert)

        
        refreshAlert.addTextField()
        let textField = refreshAlert.textFields![0]
        
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
           //   print("Handle Cancel Logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
           //Add shoe to database
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                return
              }
            var shoeNames:[String] = []
            for shoe in self.shoes
            {
                shoeNames.append(shoe.value(forKey: "shoeName") as! String)
            }
            var text = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            text = text.capitalized
            
            
            if text == "" || shoeNames.contains(text ?? "") || text == "Deleted Shoe"
            {
                
                let errorAlert = UIAlertController(title: "Error", message: "Shoe name must be unique",  preferredStyle: UIAlertController.Style.alert)
                errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                   //   print("Handle Cancel Logic here")
                }))
                self.present(errorAlert, animated: true, completion: nil)
            }
            else
            {
                let managedContext =
                    appDelegate.persistentContainer.viewContext
                  
                  // 2
                let entity =
                    NSEntityDescription.entity(forEntityName: "Shoe",
                                               in: managedContext)!
                let shoe = NSManagedObject(entity: entity,
                                              insertInto: managedContext)
                shoe.setValue(text, forKey: "shoeName")
                shoe.setValue(0, forKey: "shoeDistance")
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                self.getShoeData()
                
            }
            
            
        }))

        self.present(refreshAlert, animated: true, completion: nil)
        
        
    
        
    }
    
    
    func getShoeData()
    {
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else {
             return
         }
         
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         //2
         let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "Shoe")
        
        
         //3
         do {
           shoes = try managedContext.fetch(fetchRequest)
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
        
        
        
        shoeTableView.reloadData()
    }
    
    
    
    /* // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShoesViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me!")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] action, view, completionHandler in
            //delete shoe from coredata, change shoeUsed to Deleted Shoe for each run, remove shoe from tableview
            let deleteAlert = UIAlertController(title: "Delete Shoe", message: "Shoe will be permanently deleted.",  preferredStyle: UIAlertController.Style.alert)
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
               //   print("Handle Cancel Logic here")
                self.getShoeData()
                
            }))
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                print("deleting")
                let deletedShoeName:String = self.shoes[indexPath.row].value(forKey: "shoeName") as! String
                
                print(deletedShoeName)
                guard let appDelegate =
                   UIApplication.shared.delegate as? AppDelegate else
                {
                    return
                }
                 
                 let managedContext =
                   appDelegate.persistentContainer.viewContext
                 
                 //2
                 let fetchRequest =
                   NSFetchRequest<NSManagedObject>(entityName: "UserRun")
                
                fetchRequest.predicate = NSPredicate(format: "shoe == %@", deletedShoeName)
             //   fetchRequest.sortDescriptors = descriptors
                 
                 //3
                var runs:[NSManagedObject] = []
                 do {
                   runs = try managedContext.fetch(fetchRequest)
                 } catch let error as NSError {
                   print("Could not fetch. \(error), \(error.userInfo)")
                 }
                for run in runs
                {
                    run.setValue("Deleted Shoe", forKey: "shoe")
                }
                managedContext.delete(self.shoes[indexPath.row])
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                self.getShoeData()
            }))
            
            self.present(deleteAlert, animated: true, completion: nil)
            
            
            
           // shoeTableView.deleteRows(at: [indexPath], with: .fade)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    
}
extension ShoesViewController: UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shoe = shoes[indexPath.row]
        let cell = shoeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! shoeCell
        let name: String = (shoe.value(forKeyPath: "shoeName"))! as! String
        cell.nameLabel.text = name
        
        //calculate shoe distance
        guard let appDelegate =
           UIApplication.shared.delegate as? AppDelegate else
        {
            return cell
        }
         
         let managedContext =
           appDelegate.persistentContainer.viewContext
         
         //2
         let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "UserRun")
        
        fetchRequest.predicate = NSPredicate(format: "shoe == %@", name)
     //   fetchRequest.sortDescriptors = descriptors
         
         //3
        var runs:[NSManagedObject] = []
         do {
           runs = try managedContext.fetch(fetchRequest)
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
        
        var distance = 0.0
        for runWithShoe in runs
        {
            distance += runWithShoe.value(forKey: "distance") as! Double
        }
        let units = userDefaults.string(forKey: K.userDefaults.distance) ?? "km"
        if units == "mi"
        {
            distance = unitConversions.kmToMiles(km: distance)
        }
        distance = round(distance * 100) / 100.0
        cell.distanceLabel.text = "\(distance)\(units)"
        
        return cell
        
    }
        
    
}

