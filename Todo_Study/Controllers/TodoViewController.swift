//
//  ViewController.swift
//  Todo_Study
//
//  Created by PKW on 2023/03/16.
//

import UIKit

// MARK: [Class or Struct] ----------
class TodoViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var todoSearchBar: UISearchBar!
    
    // MARK: [Let Or Var] ----------
    var progressTodos = [TodoModel]()
    var completedTodos = [TodoModel]()
    
    var filteredProgressTodos = [TodoModel]()
    var filteredCompletedTodos = [TodoModel]()
    
    var isFilter = false
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        TodosAPI.fetchTodos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let todos):
                // 할 일 / 완료 나누기
                self.progressTodos = todos.filter({$0.progressCount == 0 || $0.progressCount == 1}).sorted(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                self.completedTodos = todos.filter({$0.progressCount == 2}).sorted(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                
                DispatchQueue.main.async {
                    self.todoListTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let updateTodos = (progressTodos + completedTodos).filter({$0.isEdited == true})
        
        if !updateTodos.isEmpty {
            
            updateTodos.forEach { todo in
                
                TodosAPI.updateTodo(id: todo.id ?? 0, updateData: todo) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let id):
                        
                        if self.progressTodos.contains(where: {$0.id == id}) {
                            if let index = self.progressTodos.firstIndex(where: {$0.id == id}) {
                                self.progressTodos[index].isEdited = false
                            }
                        } else {
                            if let index = self.completedTodos.firstIndex(where: {$0.id == id}) {
                                self.completedTodos[index].isEdited = false
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapProgressButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        if let contentView = button.superview?.superview,
           let cell = contentView.superview as? TodoListTableViewCell,
           let indexPath = todoListTableView.indexPath(for: cell) {
            
            if isFilter {
                switch indexPath.section {
                case 0:
                    let index = progressTodos.firstIndex(where: {$0.id == filteredProgressTodos[indexPath.row].id}) ?? 0
                    
                    if button.tag == 2 {
                        var todo = filteredProgressTodos[indexPath.row]
                        todo.progressCount = button.tag
                        todo.isEdited = true
                        
                        progressTodos.remove(at: index)
                        completedTodos.insert(todo, at: 0)
                        completedTodos.sort(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                        
                        filteredProgressTodos.remove(at: indexPath.row)
                        filteredCompletedTodos.insert(todo, at: 0)
                        filteredCompletedTodos.sort(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                        
                    } else {
                        filteredProgressTodos[indexPath.row].progressCount = button.tag
                        progressTodos[index].progressCount = button.tag
                    }
                case 1:
                    if button.tag < 2 {
                        filteredCompletedTodos[indexPath.row].progressCount = button.tag
                        
                        var todo = filteredCompletedTodos[indexPath.row]
                        todo.progressCount = button.tag
                        todo.isEdited = true
                        
                        let index = completedTodos.firstIndex(where: {$0.id == todo.id}) ?? 0
                        
                        filteredCompletedTodos.remove(at: indexPath.row)
                        filteredProgressTodos.insert(todo, at: 0)
                        filteredProgressTodos.sort(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                        
                        completedTodos.remove(at: index)
                        progressTodos.insert(todo, at: 0)
                        progressTodos.sort(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                    }
                default:
                    print("default")
                }
            } else {
                switch indexPath.section {
                case 0:
                    if button.tag == 2 {
                        var todo = progressTodos[indexPath.row]
                        todo.progressCount = button.tag
                        todo.isEdited = true
                        
                        progressTodos.remove(at: indexPath.row)
                        completedTodos.insert(todo, at: 0)
                        completedTodos.sort(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                    } else {
                        progressTodos[indexPath.row].progressCount = button.tag
                        progressTodos[indexPath.row].isEdited = true
                    }
                case 1:
                    if button.tag < 2 {
                        var todo = completedTodos[indexPath.row]
                        todo.progressCount = button.tag
                        todo.isEdited = true
                        
                        completedTodos.remove(at: indexPath.row)
                        progressTodos.insert(todo, at: indexPath.row)
                        progressTodos.sort(by: {$0.createdDate ?? "" > $1.createdDate ?? ""})
                    }
                default:
                    print("default")
                }
            }
            
            DispatchQueue.main.async {
                if indexPath.section == 0 && 0...1 ~= button.tag {
                    self.todoListTableView.reloadSections(IndexSet(0...1), with: .none)
                } else {
                    self.todoListTableView.reloadSections(IndexSet(0...1), with: .automatic)
                }
            }
        }
    }
    
    @IBAction func tapNewTodoButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "NewTodoViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NewTodoVC") as? NewTodoViewController else { return }
        vc.delegate = self
        vc.isNewTodo = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapSearchButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.35) {
            if self.todoSearchBar.isHidden {
                self.todoSearchBar.isHidden = false
            } else {
                self.todoSearchBar.isHidden = true
            }
        }
    }
    
    // MARK: [Function] ----------
    func setup() {
        // 테이블뷰 헤더 등록
        todoListTableView.register(UINib(nibName: "TodoListHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TodoListHeaderView")
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        todoListTableView.keyboardDismissMode = .onDrag
        todoSearchBar.searchTextField.textColor = .white
        
        if #available(iOS 15.0, *) {
            todoListTableView.sectionHeaderTopPadding = 0.0
        }
    }
    
    
    func updateTodoListTableView(indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            todoListTableView.reloadRows(at: [indexPath], with: .none)
        case 1:
            todoListTableView.reloadRows(at: [indexPath], with: .none)
        default:
            print("default")
        }
    }
}
// MARK: [TableView - DataSource] ----------
extension TodoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isFilter ? filteredProgressTodos.count : progressTodos.count
        case 1:
            return isFilter ? filteredCompletedTodos.count : completedTodos.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell") as? TodoListTableViewCell else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0:
            isFilter ? cell.configData(todo: filteredProgressTodos[indexPath.row]) : cell.configData(todo: progressTodos[indexPath.row])
            return cell
        case 1:
            isFilter ? cell.configData(todo: filteredCompletedTodos[indexPath.row]) : cell.configData(todo: completedTodos[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isFilter {
                switch indexPath.section {
                case 0:
                    let url = filteredProgressTodos[indexPath.row].imageURl
                    let id = filteredProgressTodos[indexPath.row].id ?? 0
                    
                    FirebaseAPI.deleteImage(url: url) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(_):
                            TodosAPI.deleteTodo(id: id) { result in
                                switch result {
                                case .success(_):
                                    let index = self.progressTodos.firstIndex(where: {$0.id == id}) ?? 0
                                    let filterIndex = self.filteredProgressTodos.firstIndex(where: {$0.id == id}) ?? 0
                                    
                                    self.progressTodos.remove(at: index)
                                    self.filteredProgressTodos.remove(at: filterIndex)
                                    
                                    DispatchQueue.main.async {
                                        self.todoListTableView.reloadSections(IndexSet(integer: 0), with: .none)
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                case 1:
                    let url = filteredCompletedTodos[indexPath.row].imageURl
                    let id = filteredCompletedTodos[indexPath.row].id ?? 0
                    
                    FirebaseAPI.deleteImage(url: url) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(_):
                            TodosAPI.deleteTodo(id: id) { result in
                                switch result {
                                case .success(_):
                                    let index = self.completedTodos.firstIndex(where: {$0.id == id}) ?? 0
                                    let filterIndex = self.filteredCompletedTodos.firstIndex(where: {$0.id == id}) ?? 0
                                    
                                    self.completedTodos.remove(at: index)
                                    self.filteredCompletedTodos.remove(at: filterIndex)
                                    
                                    DispatchQueue.main.async {
                                        self.todoListTableView.reloadSections(IndexSet(integer: 1), with: .none)
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                default:
                    print("default")
                }
            } else {
                switch indexPath.section {
                case 0:
                    let url = progressTodos[indexPath.row].imageURl
                    let id = progressTodos[indexPath.row].id ?? 0
                    
                    FirebaseAPI.deleteImage(url: url) { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(_):
                            TodosAPI.deleteTodo(id: id) { result in
                                switch result {
                                case .success(_):
                                    self.progressTodos.remove(at: indexPath.row)
                                    
                                    DispatchQueue.main.async {
                                        self.todoListTableView.reloadSections(IndexSet(integer: 0), with: .fade)
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                case 1:
                    let url = completedTodos[indexPath.row].imageURl
                    let id = completedTodos[indexPath.row].id ?? 0
                    
                    FirebaseAPI.deleteImage(url: url) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(_):
                            TodosAPI.deleteTodo(id: id) { result in
                                switch result {
                                case .success(_):
                                    self.completedTodos.remove(at: indexPath.row)
                                    
                                    DispatchQueue.main.async {
                                        self.todoListTableView.reloadSections(IndexSet(integer: 1), with: .fade)
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                default:
                    print("default")
                }
            }
        }
    }
}

// MARK: [TableView - Delegate] ----------
extension TodoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "NewTodoViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NewTodoVC") as? NewTodoViewController else { return }
        vc.delegate = self
        
        switch indexPath.section {
        case 0:
            progressTodos[indexPath.row].isEdited = false
            vc.todoData = progressTodos[indexPath.row]
        case 1:
            completedTodos[indexPath.row].isEdited = false
            vc.todoData = completedTodos[indexPath.row]
        default:
            print("default")
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TodoListHeaderView") as? TodoListHeaderView else { return UIView() }
        
        switch section {
        case 0:
            headerView.titleLabel.text = "할 일"
            return headerView
        case 1:
            headerView.titleLabel.text = "완료된 할 일"
            return headerView
        default:
            return headerView
        }
    }
}

// MARK: [Extention Delegate] ----------
extension TodoViewController: NewTodoViewControllerDelegate {
    func addTodo(todo: TodoModel?, progressCount: Int) {
        if progressCount == 2 {
            
            if let todo = todo {
                completedTodos.insert(todo, at: 0)
            }
            
            DispatchQueue.main.async {
                self.todoListTableView.reloadSections(IndexSet(1...1), with: .none)
            }
        } else {
            if let todo = todo {
                progressTodos.insert(todo, at: 0)
            }
            
            DispatchQueue.main.async {
                self.todoListTableView.reloadSections(IndexSet(0...0), with: .none)
            }
        }
    }
    
    func didChangeTodo(todo: TodoModel?, progressCount: Int) {
        if progressCount == 2 {
            if progressTodos.contains(where: {$0.id == todo?.id}) {
                if let index = progressTodos.firstIndex(where: {$0.id == todo?.id}) {
                    progressTodos.remove(at: index)
                    
                    if let todo = todo {
                        completedTodos.insert(todo, at: 0)
                    }
                    
                    DispatchQueue.main.async {
                        self.todoListTableView.reloadData()
                    }
                }
            } else {
                if let index = completedTodos.firstIndex(where: {$0.id == todo?.id}) {
                    if let todo = todo {
                        completedTodos[index] = todo
                    }
                    
                    DispatchQueue.main.async {
                        self.todoListTableView.reloadSections(IndexSet(1...1), with: .none)
                    }
                }
            }
        } else {
            if progressTodos.contains(where: {$0.id == todo?.id}) {
                if let index = progressTodos.firstIndex(where: {$0.id == todo?.id}) {
                    if let todo = todo {
                        progressTodos[index] = todo
                    }
                    
                    DispatchQueue.main.async {
                        self.todoListTableView.reloadSections(IndexSet(0...0), with: .none)
                    }
                }
            } else {
                if let index = completedTodos.firstIndex(where: {$0.id == todo?.id}) {
                    completedTodos.remove(at: index)
                    
                    if let todo = todo {
                        progressTodos.insert(todo, at: 0)
                    }
                    
                    DispatchQueue.main.async {
                        self.todoListTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension TodoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredProgressTodos.removeAll()
        filteredCompletedTodos.removeAll()
        
        if searchText == "" {
            isFilter = false
            
            DispatchQueue.main.async {
                self.todoListTableView.reloadData()
            }
        } else {
            isFilter = true
            
            filteredProgressTodos = progressTodos.filter({($0.title ?? "").contains(searchText)})
            filteredCompletedTodos = completedTodos.filter({($0.title ?? "").contains(searchText)})
            
            DispatchQueue.main.async {
                self.todoListTableView.reloadData()
            }
        }
    }
}



