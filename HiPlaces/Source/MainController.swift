//
//  MainController.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 20.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import UIKit
import RealmSwift

final class MainController: UIViewController {
    
    private var places: Results<Place>?
    private var filteredPlaces: Results<Place>?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.placeholder = "Search"
        
        return controller
    }()
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        
        return text.isEmpty
    }
    
    private var isFiltering: Bool { searchController.isActive && !searchBarIsEmpty }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Places"
        
        places = ModelManager.realm?.objects(Place.self).sorted(byKeyPath: "date", ascending: true)
        
        tableView.register(UINib(nibName: PlaceCell.cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: PlaceCell.cellReuseIdentifier)
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.searchController = searchController
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @objc
    private func addTapped() {
        let controller = PlaceDetailController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction
    private func sortSelection(_ sender: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places?.sorted(byKeyPath: "date", ascending: true)
        } else {
            places = places?.sorted(byKeyPath: "name", ascending: true)
        }
        
        tableView.reloadData()
    }
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? (filteredPlaces?.count ?? 0) : (places?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlaceCell.cellReuseIdentifier) as? PlaceCell,
            let place = isFiltering ? filteredPlaces?[indexPath.row] : places?[indexPath.row] else { return UITableViewCell() }
        
        cell.setup(place: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let place = isFiltering ? filteredPlaces?[indexPath.row] : places?[indexPath.row] else { return }
        
        let controller = PlaceDetailController(place: place)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            guard let self = self,
                let place = self.isFiltering ? self.filteredPlaces?[indexPath.row] : self.places?[indexPath.row] else { return }
            
            ModelManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension MainController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        filteredPlaces = places?.filter("name CONTAINS [c] %@ OR location CONTAINS [c] %@", text, text)
        tableView.reloadData()
    }
}
