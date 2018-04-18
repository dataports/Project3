//
//  LatLonTableViewCell.swift
//  Project3
//
//  Created by Sophia Amin on 4/18/18.
//  Copyright © 2018 Sophia Amin. All rights reserved.
//

import UIKit

class LatLonTableViewCell: UITableViewCell {

     // MARK: - Properties
    static let reuseIdentifier = "LatLonCell"
    
    @IBOutlet weak var latLabel: UILabel!
    
    @IBOutlet weak var lonLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
