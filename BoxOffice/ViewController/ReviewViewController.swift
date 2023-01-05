//
//  ReviewViewController.swift
//  BoxOffice
//
//  Created by 천승희 on 2023/01/04.
//

import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "별명"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        
        return textField
    }()
    
    private lazy var nickNameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nickNameLabel, nickNameTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        return stackView
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "암호"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        
        return textField
    }()
    
    private lazy var passwordStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        return stackView
    }()
    
    
    private lazy var rateView: RateView = {
        let view = RateView()
        
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = "내용"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var contentTextField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.black.cgColor
        
        return textField
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [contentLabel, contentTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        button.addTarget(self, action: #selector(self.didTapSaveButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nickNameStackView, passwordStackView, rateView, contentStackView, saveButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    var db = Firestore.firestore()
    var ReviewList: [Review] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constraints()
    }
}

extension ReviewViewController {
    private func constraints() {
        vStackViewConstraints()
    }
    
    private func vStackViewConstraints() {
        self.view.addSubview(vStackView)
        self.vStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = [
            self.vStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.vStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.vStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(layout)
    }
}

extension ReviewViewController {
    @objc private func didTapSaveButton() {
        saveFirestore()
    }
    
    private func saveFirestore() {
        guard let nickname = nickNameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        let starRating = rateView.currentStar
        guard let content = contentTextField.text else { return }
        let imageURL = ""
        
        let pattern = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$]).{6,20}"
        let isValidPassword = password.range(of: pattern, options: .regularExpression) != nil
        
        if isValidPassword {
            db.collection("ReviewList").document().setData(["nickname": nickname, "password": password, "starRating": starRating, "content": content, "imageURL": imageURL])
            
            let alert = UIAlertController(title: "저장 성공", message: "저장이 완료되었습니다", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler : nil)
            alert.addAction(defaultAction)
            present(alert, animated: false, completion: nil)
        } else {
            let alert = UIAlertController(title: "저장 실패", message: "암호 입력이 잘못되었습니다", preferredStyle: UIAlertController.Style.alert)
            let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler : nil)
            alert.addAction(defaultAction)
            present(alert, animated: false, completion: nil)
        }
    }
    
    private func readFirestore() {
        db.collection("ReviewList").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("\(String(describing: error))")
                return
            }
            
            self.ReviewList = documents.compactMap { doc -> Review? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                    let review = try JSONDecoder().decode(Review.self, from: jsonData)
                    return review
                } catch let error {
                    print("\(error)")
                    return nil
                }
            }
            
            DispatchQueue.main.async {
                print(self.ReviewList)
            }
        }
    }
    
    private func deleteFirestore() {
        db.collection("ReviewList").document().delete()
    }
}
