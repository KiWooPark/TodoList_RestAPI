//
//  TitleTableViewCell.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/21.
//

import UIKit

// MARK: [Class or Struct] ----------
class TitleTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet weak var todoBackgroundView: UIView!
    @IBOutlet weak var titleTextField: UITextField!

    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        todoBackgroundView.layer.cornerRadius = 5
        titleTextField.attributedPlaceholder = NSAttributedString(string: "제목을 입력해주세요.", attributes: [.foregroundColor: UIColor.systemGray2])
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
    func configData(title: String?) {
        titleTextField.text = title ?? ""
    }
}
