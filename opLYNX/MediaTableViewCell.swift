//
//  MediaTableViewCell.swift
//  opLYNX
//
//  Created by oplynx developer on 2017-10-12.
//  Copyright © 2017 CIS. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var mediaCommentsTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
