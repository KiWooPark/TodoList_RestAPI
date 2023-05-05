//
//  TodoListTableViewCell.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/16.
//

import UIKit

class TodoListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var progressButtons: [UIButton]!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        configLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        progressButtons.forEach { button in
            button.tintColor = .systemGray3
        }
    }
    
    // 셀사이 간격주기
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    func configLayout() {
        contentView.layer.cornerRadius = 5
    }
    
    func configData(todo: TodoModel) {
        titleLabel.text = todo.title ?? ""
        configColorViewBackground(colorCount: todo.colorCount ?? 0)
        configProgressButtons(progressCount: todo.progressCount ?? 0)
    }
    
    func configProgressButtons(progressCount: Int) {
        for i in 0...progressCount {
            progressButtons[i].tintColor = .systemTeal
        }
    }
    
    func configColorViewBackground(colorCount: Int) {
        switch colorCount {
        case 0:
            colorView.backgroundColor = .systemTeal
        case 1:
            colorView.backgroundColor = .systemYellow
        case 2:
            colorView.backgroundColor = .systemRed
        default:
            print("default")
        }
    }
}
