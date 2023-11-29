//
//  ExpenseTableViewCell.swift
//  ExpenseTracking
//
//  Created by Noa Fredman.
//

import UIKit

final class ExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var expenseView: ExpenseView!
    var createExpenseViewDelegate: ExpenseFormViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupInfo(_ item: Expense, shouldHideSeperator: Bool) {
        expenseView.titleLabel.text = item.title
        expenseView.amountLabel.text = (Locale.current.currencySymbol ?? "") + (item.amount.toStringWithFractionDigits() ?? "")
        expenseView.lineSeperatorView.isHidden = shouldHideSeperator
    }
}
