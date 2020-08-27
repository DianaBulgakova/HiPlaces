//
//  TextFieldCell.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 23.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectionStyle = .none
    }
}
