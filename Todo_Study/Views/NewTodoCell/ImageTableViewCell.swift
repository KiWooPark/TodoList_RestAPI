//
//  ImageTableViewCell.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/21.
//

import UIKit
import Nuke

// MARK: [Protocol] ----------
protocol ImageTableViewCellDelegate: AnyObject {
    func updateImage(image: UIImage?)
}

// MARK: [Class or Struct] ----------
class ImageTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet weak var todoImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    
    // MARK: [Let Or Var] ----------
    weak var delegate: ImageTableViewCellDelegate?
    
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
       
        todoImageView.layer.cornerRadius = 5
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
    func configData(image: UIImage?, imageUrlStr: String?) {
        if image == nil && imageUrlStr == nil {
            todoImageView.image = nil
            addImageButton.setTitle("이미지 추가", for: .normal)
        } else if image != nil && imageUrlStr == nil {
            todoImageView.image = image
            addImageButton.setTitle("", for: .normal)
        } else {
            if let url = URL(string: imageUrlStr ?? "") {
                Nuke.loadImage(with: url, into: todoImageView)
            }
            addImageButton.setTitle("", for: .normal)
        }
    }
}
