//
//  PhotoTableViewCell.swift
//  Flicker Search
//
//  Created by Ayoub Khayatti on 04/04/16.
//  Copyright © 2016 Ayoub Khayati. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        self.photoImageView.image = nil
        self.titleLabel.text = nil
        self.ownerLabel.text = nil
    }
    
}
