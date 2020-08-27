//
//  TextFieldCell.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 23.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import UIKit

final class TextFieldCell: UITableViewCell {
    
    static let cellReuseIdentifier = "TextFieldCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
}
