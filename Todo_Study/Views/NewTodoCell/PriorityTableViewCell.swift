//
//  PriorityTableViewCell.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/21.
//

import UIKit

// MARK: [Class or Struct] ----------
class PriorityTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet weak var todoBackgroundView: UIView!
    @IBOutlet var priorityButtons: [UIButton]!
    
    // MARK: [Let Or Var] ----------
    var selectedButtonIndex: Int?
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        todoBackgroundView.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        priorityButtons.forEach({$0.setImage(UIImage(systemName: "circle.fill"), for: .normal)})
    }
    
    // 셀사이 간격주기
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: [Function] ----------
    func configPriorityButton(count: Int?) {
        guard let index = count else { return }
        selectedButtonIndex = index
    
        switch count {
        case 0:
            priorityButtons[index].setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        case 1:
            priorityButtons[index].setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        case 2:
            priorityButtons[index].setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        default:
            print("default")
        }
    }
}
