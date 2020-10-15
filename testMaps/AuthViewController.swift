//
//  AuthViewController.swift
//  testMaps
//
//  Created by Kseniya Lukoshkina on 06.10.2020.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class AuthViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var regButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordField.autocorrectionType = .no
        loginField.autocorrectionType = .no
        
//        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
//        blurredView.frame = self.view.bounds
//        self.view.addSubview(blurredView)
        loginButton?.isEnabled = false
        regButton?.isEnabled = false
        configureLoginBindings()
    }
    
    
    func configureLoginBindings() {
            Observable
    // Объединяем два обсервера в один
                .combineLatest(
                    loginField.rx.text,
                    passwordField.rx.text
                )
                .map { login, password in
                    return !(login ?? "").isEmpty && (password ?? "").count >= 6
                }
//    // Подписываемся на получение событий
                .bind { [weak loginButton, weak regButton] inputFilled in
//    // Если событие означает успех, активируем кнопку, иначе деактивируем
                    loginButton?.isEnabled = inputFilled
                    regButton?.isEnabled = inputFilled
            }
    }

    
    @IBAction func clickButtonLogin(_ sender: Any) {
        print("LOGIN CLICK")
        guard let login = loginField.text, let password = passwordField.text else {return}
        
        do {
            let realm = try Realm()
            let path = realm.objects(UserEntity.self).filter("login == %@", login)
            if path.isEmpty {
                self.showAlert("Пользователь с таким логином не найден")
            } else {
                if path[0].password == password {
                    self.login()
                } else {
                    self.showAlert("Неверный пароль!")
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func login() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "MapViewController")
        vc.modalPresentationStyle = .fullScreen
        self.show(vc, sender: nil)
    }
    
    private func showAlert(_ text: String) {
        let vc = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {_ in
            return
        })
        vc.addAction(ok)
        self.show(vc, sender: nil)
    }
    
    @IBAction func clickButtonReg(_ sender: Any) {
        print("REG CLICK")
        
        guard let login = loginField.text, let password = passwordField.text else {return}
        
        do {
            let realm = try Realm()
            let path = realm.objects(UserEntity.self).filter("login == %@", login)
            realm.beginWrite()
            if path.isEmpty {
                let newUser = UserEntity()
                newUser.login = login
                newUser.password = password
                realm.add(newUser)
                self.login()
            } else {
                path[0].password = password
                self.login()
            }
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }

}
