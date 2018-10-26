//
//  ImageMapViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 25/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import MapKit
import Photos

class ImageMapViewController: UIViewController {

    //MARK: - Property
    private var imageSheetViewController: ImageSheetViewController!
    private let imageManager = PHCachingImageManager()
    private var images: PHFetchResult<PHAsset>?
    var mapView: MKMapView!
    
    //MARK: - Initialization
    init(with frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        
        configureMapView(with: frame)
        configureImageSheetViewController()
        if checkAuthorizationStatus() {
            prepareImages()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Action
    @objc func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        imageSheetViewController.newLocationForImage = locationCoordinate
        imageSheetViewController.showActionSheet()
    }
    
    //MARK: - Method
    func configureMapView(with frame: CGRect) {
        let longPressGestrueRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        
        mapView = MKMapView(frame: frame)
        mapView.addGestureRecognizer(longPressGestrueRecognizer)
        mapView.mapType = .standard
        mapView.delegate = self
        
        mapView.register(CircleImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    func configureImageSheetViewController() {
        imageSheetViewController = ImageSheetViewController()
        imageSheetViewController.targetSize = mapView.frame.size
        imageSheetViewController.getThumbnailImageHandler = { [weak self] image, location in
            if let location = location {
                let imageData = ImageData.init(image: image, location: location.coordinate)
                let annotation = CircleImageAnnotation(imageData: imageData)
                self?.mapView.addAnnotation(annotation)
            }
        }
        addChild(imageSheetViewController)
    }
    
    func prepareImages() {
        resetCachedAssets()
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        images = PHAsset.fetchAssets(with: allPhotosOptions)
        
        addAnnotationsOnMap()
    }
    
    func addAnnotationsOnMap() {
        guard let images = images else { return }
        for i in 0..<images.count {
            let asset = images.object(at: i)
            if let location = asset.location {
                let annotation = CircleImageAnnotation()
                annotation.representedAssetIdentifier = asset.localIdentifier
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                    if annotation.representedAssetIdentifier == asset.localIdentifier {
                        let imageData = ImageData.init(image: image!, location: location.coordinate)
                        annotation.imageData = imageData
                        self?.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
}

extension ImageMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CircleImageAnnotation else { return nil }

        let annotationView = CircleImageAnnotationView(annotation: annotation, reuseIdentifier: CircleImageAnnotationView.reuseID)
        
        return annotationView
    }
}

extension ImageMapViewController {
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }
    
    private func checkAuthorizationStatus() -> Bool{
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
        case .denied, .restricted, .notDetermined:
            requestAuthorizationForPhoto()
            return false
        }
    }
    
    private func requestAuthorizationForPhoto() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if status == .authorized {
                self?.prepareImages()
            }
        }
    }
}
