//
//  UserDetailsViewController.swift
//  UsersAPIfrontendApp
//
//  Created by Narek Stepanyan on 15/09/2019.
//  Copyright © 2019 Narek Stepanyan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UserDetailsViewController: UIViewController {

    var viewModel: UserDetailsViewModel?
    var user: UserInfo?
    
    let disposeBag = DisposeBag()
    let reloadData = PublishRelay<Void>()
    
    @IBOutlet weak var firstNameInputView: InputView!
    @IBOutlet weak var lastNameInputView: InputView!
    @IBOutlet weak var emailInputView: InputView!
    @IBOutlet weak var avatarURLinputView: InputView!
    
    @IBOutlet weak var inputs: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reloadData.accept(())
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user == nil ? "Новый пользователь" : "\(user!.firstName) \(user!.lastName)"
        viewModel = UserDetailsViewModel(for: user == nil ? .post : .patch, userID: user?.id)
        guard let viewModel = viewModel else { return }
        
        /// Кнопка 'Создать' в навбаре
        let createButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = createButton
        createButton.rx.tap.bind(to: viewModel.createButton).disposed(by: disposeBag)
        
        /// Настройка полей ввода и отравка результатов в viewModel
        firstNameInputView.setup(withTitle: "Имя", text: user?.firstName ?? "", inputType: .name)
            .bind(to: viewModel.firstName)
            .disposed(by: disposeBag)
        
        lastNameInputView.setup(withTitle: "Фамилия", text: user?.lastName ?? "", inputType: .name)
            .bind(to: viewModel.lastName)
            .disposed(by: disposeBag)
        
        emailInputView.setup(withTitle: "Email", text: user?.email ?? "", inputType: .email)
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        avatarURLinputView.setup(withTitle: "URL аватарки", text: user?.avatarURL ?? "", inputType: .avatarURL)
            .bind(to: viewModel.avatarURL)
            .disposed(by: disposeBag)
        
        /// Вернуться на предыдущий экран
        viewModel.requestResult
            .filter { $0 }
            .drive(onNext:{ [weak self] _ in self?.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
        
        /// Активация кнопки 'Создать'
        viewModel.buttonIsActive
            .drive(createButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        /// Блокировка кнопки во время отправки запроса
        viewModel.blockScreen.drive(onNext:{ [weak self, createButton] in
            createButton.isEnabled = false
            self?.view.endEditing(true)
            self?.descriptionLabel.isHidden = false
            self?.loadingIndicator.startAnimating()
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.inputs.alpha = 0.4
            })
        }).disposed(by: disposeBag)
    }
}
