//
//  ViewController.swift
//  testMaps
//
//  Created by Kseniya Lukoshkina on 25.09.2020.
//

import UIKit
import GoogleMaps
import RealmSwift

class ViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
//    private var locationManager: CLLocationManager?
    
    // Центр Москвы
    let coordinate = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)

    
    let locationManager = LocationManager.instance
    private var previousPath: GMSMutablePath?
    
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var stopImage: UIImageView!
    
    var polyline: GMSPolyline?
    var path: GMSMutablePath?
    
    var isRunning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
        configureLocationManager()
        
//        locationManager?.delegate = self
        
        do {
            let realm = try Realm()
            print(realm.configuration.fileURL)
            let path = realm.objects(PathEntity.self)
            if !path.isEmpty, let encodePath = path[0].encodedPath {
                previousPath = GMSMutablePath(fromEncodedPath: encodePath)
            }
        } catch {
            print(error)
        }
        
        updateButton()
    }
    
    func configureMap() {
    // Создаём камеру с использованием координат и уровнем увеличения
            let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
    // Устанавливаем камеру для карты
            mapView.camera = camera
    }
    
    func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.path?.add(location.coordinate)
                // Обновляем путь у линии маршрута путём повторного присвоения
                self?.polyline?.path = self?.path
                
                // Чтобы наблюдать за движением, установим камеру на только что добавленную
                // точку
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.mapView.animate(to: position)
            }
        locationManager.mapView = self.mapView
    }

    override func viewDidAppear(_ animated: Bool) {
        updateButton()
    }
    
    private func updateButton() {
        if isRunning {
            playImage.isHidden = true
            stopImage.isHidden = false
        } else {
            playImage.isHidden = false
            stopImage.isHidden = true
        }
    }

    @IBAction func clickButton(_ sender: Any) {
        if !isRunning {
            start()
        } else {
            stop()
        }
        isRunning = !isRunning
        updateButton()
    }
    
    private func downloadPreviousPath() {
        polyline?.map = mapView
        path = previousPath
        polyline?.path = path
        
        if let previousPath = previousPath {
            let bounds = GMSCoordinateBounds(path: previousPath)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
            mapView.moveCamera(update)
        }
    }
    
    @IBAction func clickPreviousPath(_ sender: Any) {
        if isRunning {
            let alert = UIAlertController(title: "Закончить трек?", message: "Чтобы посмотреть предыдущий трек, необходимо завершить текущий.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Закончить", style: .default, handler: { _ in
                self.stop()
                self.isRunning = false
                self.updateButton()
                self.downloadPreviousPath()
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in return}))
            self.present(alert, animated: true)
        } else {
            downloadPreviousPath()
        }
    }
    @IBOutlet weak var TMPImage: UIImageView!
    
    @IBAction func clickSetProfileImage(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePickerController = UIImagePickerController()
        // Источник изображений: камера
                imagePickerController.sourceType = .camera
        // Изображение можно редактировать
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                
        // Показываем контроллер
                present(imagePickerController, animated: true)

    }
    
    private func start() {
//        locationManager?.startUpdatingLocation()
//        locationManager?.allowsBackgroundLocationUpdates = true
        
        locationManager.startUpdatingLocation()
        
        polyline?.map = nil
        polyline = GMSPolyline()
        polyline?.strokeWidth = 5
        polyline?.strokeColor = .red
        polyline?.map = mapView
        path = GMSMutablePath()
    }
    
    private func stop() {
//        locationManager?.stopUpdatingLocation()
//        locationManager?.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        
        polyline?.map = nil
        path = nil
        
        do {
            let realm = try Realm()
            print(realm.configuration.fileURL)
            let path = realm.objects(PathEntity.self)
            realm.beginWrite()
            if path.isEmpty {
                let firstPath = PathEntity()
                firstPath.encodedPath = self.path?.encodedPath()
                realm.add(firstPath)
            } else {
                path[0].encodedPath = self.path?.encodedPath()
            }
            previousPath = self.path
            try realm.commitWrite()
        } catch {
            print(error)
        }

    }
    
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
// Если нажали на кнопку Отмена, то UIImagePickerController надо закрыть
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //// Мы получили медиа от контроллера
        //// Изображение надо достать из словаря info
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        print(image!)
// Закрываем UIImagePickerController
//        TMPImage.image = image
        locationManager.photoImage = image
        picker.dismiss(animated: true)
    }
    
// Метод, извлекающий изображение
    private func extractImage(from info: [String: Any]) -> UIImage? {
// Пытаемся извлечь отредактированное изображение
        if let image = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage {
            return image
// Пытаемся извлечь оригинальное
        } else if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            return image
        } else {
// Если изображение не получено, возвращаем nil
            return nil
        }
    }
}
