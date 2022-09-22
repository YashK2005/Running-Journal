//
//  ShoesViewController.swift
//  Running Journal
//
//  Created by Yash Kothari on 2022-09-21.
//

import UIKit

class ShoesViewController: UIViewController {

    @IBOutlet weak var shoeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shoeTableView.delegate = self
        shoeTableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addShoeButtonClicked(_ sender: UIButton) {
    }
    
     @IBAction func deleteShoeButtonClicked(_ sender: UIButton) {
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
    
    
}
extension ShoesViewController: UITableViewDataSource
{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = shoeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! shoeCell
        cell.distanceLabel.text = "Distance"
        cell.nameLabel.text = "Shoe Name"
        
        return cell
        
    }
        
    
}

