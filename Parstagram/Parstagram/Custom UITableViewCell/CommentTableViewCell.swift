//
//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by Super MattMatt on 11/25/19.
//  Copyright © 2019 Parstagram. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    // MARK: - Props
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
