//
//  NewTodoViewController.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/17.
//

import UIKit
import PhotosUI
import Nuke

protocol NewTodoViewControllerDelegate: AnyObject {
    func didChangeTodo(todo: TodoModel?, progressCount: Int)
    func addTodo(todo: TodoModel?, progressCount: Int)
}

class NewTodoViewController: UIViewController {
    
    @IBOutlet weak var newTodoTableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    weak var delegate: NewTodoViewControllerDelegate?
    
    var todoData: TodoModel?
    
    var isNewTodo = false
    var isEdited = false
    var isEditedImage = false
    
    var oldImageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        oldImageUrl = todoData?.imageURl ?? ""
    }
    
    @IBAction func tapDoneButton(_ sender: Any) {
        getCellData()
        
        if todoData?.title == "" {
            let alert = UIAlertController(title: nil, message: "제목을 입력해주세요.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true)
        } else {
            if isNewTodo {
                FirebaseAPI.uploadImage(image: todoData?.image) { result in
                    switch result {
                    case .success(let urlString):
                        
                        self.todoData?.imageURl = urlString
                        
                        TodosAPI.addTodo(todo: self.todoData) { result in
                            switch result {
                            case .success(let todo):
                                self.todoData?.id = todo.id ?? 0
                                self.delegate?.addTodo(todo: self.todoData, progressCount: self.todoData?.progressCount ?? 0)
                                
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                            case .failure(let error):
                                print(error)
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                if isEditedImage {
                    FirebaseAPI.deleteImage(url: oldImageUrl) { result in
                        switch result {
                        case .success(_):
                            FirebaseAPI.uploadImage(image: self.todoData?.image) { result in
                                switch result {
                                case .success(let urlString):
                                    self.todoData?.imageURl = urlString
                                    TodosAPI.updateTodo(id: self.todoData?.id ?? 0 , updateData: self.todoData) { result in
                                        switch result {
                                        case .success(_):
                                            self.delegate?.didChangeTodo(todo: self.todoData, progressCount: self.todoData?.progressCount ?? 0)
                                            
                                            DispatchQueue.main.async {
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                            
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                } else {
                    TodosAPI.updateTodo(id: todoData?.id ?? 0 , updateData: todoData) { result in
                        switch result {
                        case .success(_):
                            self.delegate?.didChangeTodo(todo: self.todoData, progressCount: self.todoData?.progressCount ?? 0)
                            
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    @objc func tapPriorityButton(button: UIButton) {
        todoData?.colorCount = button.tag
        
        enabledDoneButton()
        newTodoTableView.reloadSections(IndexSet(3...3), with: .none)
    }
    
    @objc func tapEnergyCostsButton(button: UIButton) {
        todoData?.progressCount = button.tag
        enabledDoneButton()
        newTodoTableView.reloadSections(IndexSet(4...4), with: .none)
    }
    
    @objc func tapAddImageButton() {
        guard let cell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageTableViewCell else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if cell.todoImageView.image == nil {
            let add = UIAlertAction(title: "추가하기", style: .default) { _ in
                
                var configuratoin = PHPickerConfiguration()
                configuratoin.selectionLimit = 1
                configuratoin.filter = .images
                
                let picker = PHPickerViewController(configuration: configuratoin)
                picker.delegate = self
                picker.modalPresentationStyle = .fullScreen
                
                self.present(picker, animated: true)
            }
            alert.addAction(add)
            
        } else {
            let delete = UIAlertAction(title: "삭제하기", style: .destructive) { _ in
                self.todoData?.image = nil
                self.todoData?.imageURl = nil
                self.isEditedImage = true
                
                self.enabledDoneButton()
                
                DispatchQueue.main.async {
                    self.newTodoTableView.reloadSections(IndexSet(integer: 0), with: .none)
                }
            }
            alert.addAction(delete)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
}

extension NewTodoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageTableViewCell else { return UITableViewCell() }
            cell.configData(image: todoData?.image, imageUrlStr: todoData?.imageURl)
            cell.addImageButton.addTarget(self, action: #selector(tapAddImageButton), for: .touchUpInside)
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }
            cell.titleTextField.delegate = self
            cell.configData(title: todoData?.title)
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }
            cell.contentTextView.delegate = self
            cell.configData(content: todoData?.content)
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PriorityCell", for: indexPath) as? PriorityTableViewCell else { return UITableViewCell() }
            cell.configPriorityButton(count: todoData?.colorCount ?? 0)
            cell.priorityButtons.forEach({$0.addTarget(self, action: #selector(tapPriorityButton(button:)), for: .touchUpInside)})
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EnergyCostsCell", for: indexPath) as? EnergyCostsTableViewCell else { return UITableViewCell() }
            cell.configEnergyCostsButton(count: todoData?.progressCount ?? 0)
            cell.energyCostsButtons.forEach({$0.addTarget(self, action: #selector(tapEnergyCostsButton(button:)), for: .touchUpInside)})
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension NewTodoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1,3,4:
            return 60
        case 2:
            return 200
        default:
            return tableView.rowHeight
        }
    }
}

extension NewTodoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enabledDoneButton()
        return true
    }
}

extension NewTodoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        enabledDoneButton()
        
        if textView.text == "" {
            if let cell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ContentTableViewCell {
                cell.placeholderLabel.isHidden = false
            }
        } else {
            if let cell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ContentTableViewCell {
                cell.placeholderLabel.isHidden = true
            }
        }
    }
}

extension NewTodoViewController {
    func setup() {
        todoData = isNewTodo ? nil : todoData
        
        self.navigationItem.title = todoData != nil ? "할 일" : "등록하기"
        doneButton.isEnabled = false
        
        newTodoTableView.keyboardDismissMode = .onDrag
    }
    
    func enabledDoneButton() {
        
        if !isEdited {
            isEdited = true
            
            DispatchQueue.main.async {
                self.doneButton.isEnabled = true
            }
        }
    }
    
    func getCellData() {
        guard let imageCell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageTableViewCell,
              let titleCell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TitleTableViewCell,
              let contentCell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ContentTableViewCell,
              let priorityCell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? PriorityTableViewCell,
              let energyCostsCell = newTodoTableView.cellForRow(at: IndexPath(row: 0, section: 4)) as? EnergyCostsTableViewCell
        else { return }
        
        todoData?.image = imageCell.todoImageView.image
        todoData?.title = titleCell.titleTextField.text ?? ""
        todoData?.content = contentCell.contentTextView.text ?? ""
        todoData?.colorCount = priorityCell.selectedButtonIndex
        todoData?.progressCount = energyCostsCell.selectedButtonIndex
    }
}

extension NewTodoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let error = error {
                    print(error)
                }
            
                self.todoData?.image = image as? UIImage
                self.enabledDoneButton()
                
                DispatchQueue.main.async {
                    self.newTodoTableView.reloadSections(IndexSet(integer: 0), with: .none)
                }
            }
        }
    }
}

