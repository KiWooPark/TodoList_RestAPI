//
//  EnergyCostsTableViewCell.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/21.
//

import UIKit

class EnergyCostsTableViewCell: UITableViewCell {

    @IBOutlet weak var todoBackgroundView: UIView!
    @IBOutlet var energyCostsButtons: [UIButton]!
    var selectedButtonIndex: Int?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        todoBackgroundView.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        energyCostsButtons.forEach({$0.tintColor = .systemGray3})
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
    
    func configEnergyCostsButton(count: Int?) {
        guard let index = count else { return }
        selectedButtonIndex = index

        for i in 0...index {
            energyCostsButtons[i].tintColor = .systemTeal
        }
    }
}
