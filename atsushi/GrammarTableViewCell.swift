//
//  GrammarTableViewCell.swift
//  atsushi
//
//  Created by 廖淳聿 on 2016/5/3.
//  Copyright © 2016年 廖淳聿. All rights reserved.
//

import UIKit

class GrammarTableViewCell: UITableViewCell {
    @IBOutlet weak var G_NUMBER: UILabel!
    @IBOutlet weak var LEVEL: UILabel!
    @IBOutlet weak var CONTENT: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
