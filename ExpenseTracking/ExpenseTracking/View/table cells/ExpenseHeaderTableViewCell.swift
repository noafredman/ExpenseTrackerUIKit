//
//  ExpenseHeaderTableViewCell.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

final class ExpenseHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
