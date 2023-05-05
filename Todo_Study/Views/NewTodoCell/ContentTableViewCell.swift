//
//  ContentTableViewCell.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/21.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var todoBackgroundView: UIView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        todoBackgroundView.layer.cornerRadius = 5
        
        // 텍스트뷰 inset 없애기
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.textContainerInset = UIEdgeInsets(top: 9, left: 7, bottom: 9, right: 7)
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
    
    func configData(content: String?) {
        placeholderLabel.isHidden = content != nil ? true : false
        contentTextView.text = content ?? ""
    }

}
