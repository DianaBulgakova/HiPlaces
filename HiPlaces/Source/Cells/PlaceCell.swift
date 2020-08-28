//
//  PlaceCell.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 23.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import UIKit

final class PlaceCell: UITableViewCell {
    
    static let cellReuseIdentifier = "PlaceCell"
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameOfPlace: UILabel!
    @IBOutlet weak var locationOfPlace: UILabel!
    @IBOutlet weak var typeOfPlace: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ratingControl.isUserInteractionEnabled = false
        ratingControl.starSize = CGSize(width: 30, height: 30)
    }
    
    func setup(place: Place) {
        nameOfPlace.text = place.name
        locationOfPlace.text = place.location
        typeOfPlace.text = place.type
        ratingControl.rating = place.rating
        
        if let data = place.image,
            let image = UIImage(data: data) {
            imageOfPlace.image = image
        } else {
            imageOfPlace.image = #imageLiteral(resourceName: "defaultImage")
        }
    }
}
