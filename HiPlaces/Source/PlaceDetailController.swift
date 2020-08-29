//
//  PlaceDetailController.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 20.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import UIKit
import RealmSwift

final class PlaceDetailController: UIViewController {
    
    private let fields = Field.allCases
    
    private var place: Place?
    
    private var pickerElements = ["Restaurant", "Bar", "Hookah", "Veranda", "Club"]
    
    private var name: String?
    private var location: String?
    private var type: String?
    private var image: UIImage?
    
    private lazy var mapButton: UIButton = {
        let button = UIButton()
        
        button.addTarget(self, action: #selector(tapMapButton), for:.touchUpInside)
        button.setImage(#imageLiteral(resourceName: "map"), for: .normal)
        
        return button
    }()
    
    private lazy var placeImageView: UIImageView = {
        let view = UIImageView()
        
        view.clipsToBounds = true
        view.addGestureRecognizer(photoTapGesture)
        view.isUserInteractionEnabled = true
        
        view.addSubview(mapButton)
        
        mapButton.translatesAutoresizingMaskIntoConstraints = false
        mapButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        mapButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        mapButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        mapButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return view
    }()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ratingStars: RatingControl!
    
    private lazy var photoTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        
        gesture.addTarget(self, action: #selector(tapUserPhoto))
        
        return gesture
    }()
    
    private lazy var dismissKeyboardTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        
        gesture.addTarget(self, action: #selector(dismissKeyboard))
        gesture.cancelsTouchesInView = false
        
        return gesture
    }()
    
    private lazy var elementPicker: UIPickerView = {
        let picker = UIPickerView()
        
        picker.delegate = self
        
        return picker
    }()
    
    private lazy var toolBarField: UIToolbar = {
        let toolBar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        toolBar.sizeToFit()
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }()
    
    convenience init(place: Place?) {
        self.init()
        
        self.place = place
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Place"
        
        tableView.register(UINib(nibName: TextFieldCell.cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: TextFieldCell.cellReuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePlace))
        
        view.addGestureRecognizer(dismissKeyboardTapGesture)
        
        if let place = place {
            ratingStars.rating = place.rating
        }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func tapUserPhoto() {
        let alert = UIAlertController(title: "", message: "Choose your option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.openImagePicker(.camera)
        })
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openImagePicker(.photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func tapMapButton() {
        let controller = MapController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func openImagePicker(_ source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            let alert = UIAlertController(title: "Warning", message: "", preferredStyle: .alert)
            show(alert, sender: nil)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc
    private func savePlace() {
        if name == nil,
            place?.name == nil {
            showSaveAlert()
            return
        } else if (name ?? "").isEmpty {
            showSaveAlert()
            return
        }
        
        if place != nil {
            try? ModelManager.realm?.write {
                if let name = name {
                    place?.name = name
                }
                if let location = location {
                    place?.location = location
                }
                if let type = type {
                    place?.type = type
                }
                
//                place?.image = place?.image ?? image?.pngData() ?? nil
                
                if image?.pngData() != nil {
                    place?.image = image?.pngData()
                }
                
                place?.rating = ratingStars.rating
            }
        } else if let name = name {
            let newPlace = Place(name: name, location: location, type: type, image: image?.pngData(), rating: ratingStars.rating, date: Date())
            
            ModelManager.saveObject(newPlace)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func showSaveAlert() {
        let alert = UIAlertController(title: "Wrong format", message: "Please, wtite the name of your place", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let field = Field(rawValue: textField.tag) else { return }
        
        let newText = textField.text ?? ""
        
        switch field {
        case .name:
            name = newText
        case .location:
            location = newText
        case .type:
            type = newText
        }
    }
}

extension PlaceDetailController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.cellReuseIdentifier, for: indexPath) as? TextFieldCell else { return UITableViewCell() }
        
        let field = fields[indexPath.row]
        
        cell.title.text = field.title
        
        cell.textField.tag = field.rawValue
        cell.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        switch field {
        case .name:
            cell.textField.text = name ?? place?.name
        case .location:
            cell.textField.text = location ?? place?.location
        case .type:
            cell.textField.inputView = elementPicker
            cell.textField.inputAccessoryView = toolBarField
            cell.textField.text = type ?? place?.type
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        if let placeImage = place?.image {
            placeImageView.image = UIImage(data: placeImage)
            placeImageView.contentMode = .scaleAspectFill
        } else {
            placeImageView.image = #imageLiteral(resourceName: "defaultImage")
            placeImageView.contentMode = .scaleAspectFit
        }
        
        headerView.addSubview(placeImageView)
        placeImageView.translatesAutoresizingMaskIntoConstraints = false
        placeImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10).isActive = true
        placeImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        placeImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        placeImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
}

extension PlaceDetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        self.image = image
        placeImageView.image = image
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension PlaceDetailController: MapControllerDelegate {
    
    func addressSaved(_ address: String?) {
        location = address
        tableView.reloadData()
    }
}

extension PlaceDetailController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerElements.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerElements[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = pickerElements[row]
        tableView.reloadData()
    }
}
