//
//  PlaceCell.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 23.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {
    
    static let cellReuseIdentifier = "PlaceCell"
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameOfPlace: UILabel!
    @IBOutlet weak var locationOfPlace: UILabel!
    @IBOutlet weak var typeOfPlace: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
