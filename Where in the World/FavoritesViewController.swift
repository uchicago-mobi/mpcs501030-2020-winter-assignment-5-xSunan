//
//  FavoritesViewController.swift
//  Where in the World
//
//  Created by sunan xiang on 2020/2/11.
//  Copyright © 2020 sunan xiang. All rights reserved.
//

import UIKit


class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: PlacesFavoritesDelegate?
    
    @IBOutlet var tableView: UITableView!
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var faveList = UserDefaults.standard.object(forKey: "faveList") as! [String]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faveList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = faveList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
        print("here \(faveList[indexPath.row])")
        self.delegate?.favoritePlace(name: faveList[indexPath.row])
        dismiss(animated: true, completion: nil)
    }

}
