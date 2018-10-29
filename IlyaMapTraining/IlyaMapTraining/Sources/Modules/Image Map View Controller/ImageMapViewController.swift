//
//  ImageMapViewController.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 25/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import VK_ios_sdk
import Kingfisher
import UIKit
import MapKit
import Photos

class ImageMapViewController: UIViewController {

    //MARK: - Property
    private var imageSheetViewController: ImageSheetViewController!
    private let imageManager = PHCachingImageManager()
    private var images: PHFetchResult<PHAsset>?
    
    var fromLibrary = true
    var mapView: MKMapView!
    
    //MARK: - Initialization
    init(with frame: CGRect, fromLibrary: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        self.fromLibrary = fromLibrary
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
            guard let location = location else { return }
            
            let imageData = ImageData.init(image: image, location: location.coordinate)
            let annotation = CircleImageAnnotation(imageData: imageData)
            self?.mapView.addAnnotation(annotation)
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
        if fromLibrary {
            addAnnotationsFromLibrary()
        } else {
            addAnnotationsFromVK()
        }
    }
    
    func addAnnotationsFromLibrary() {
        guard let images = images else { return }
        for i in 0..<images.count {
            
            let asset = images.object(at: i)
            guard let location = asset.location else { continue }
            
            let annotation = CircleImageAnnotation()
            annotation.representedAssetIdentifier = asset.localIdentifier
            
            imageManager.requestImage(for: asset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                guard annotation.representedAssetIdentifier == asset.localIdentifier else { return }
                
                let imageData = ImageData.init(image: image!, location: location.coordinate)
                annotation.imageData = imageData
                
                self?.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func addAnnotationsFromVK() {
        fetchImagesFromVK()
    }
    
    func fetchImagesFromVK() {
        let photoReq: VKRequest? = VKRequest(method: "photos.getAll", parameters: ["skip_hidden": 1])
        
        photoReq?.execute(resultBlock: { response in
            guard let jsonResult = response?.json as? [String: Any] else { return }
            
            let wrapper = VKPhotoResponse.init(JSON: jsonResult)
            guard let items = wrapper?.items else { return }
            for item in items {
                
                let url = URL(string: item.photo604!)!
                ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) {
                    [weak self] image, error, url, data in
                    if let image = image {
                        self?.getMetaData(for: image)
                    }
                }
                
            }
        }, errorBlock: { error in
            if let error = error {
                print(error)
            }
        })
    }
    
    func getMetaData(for image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        getMetaData(for: data)
    }
    
    func getMetaData(for data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        
        let count = CGImageSourceGetCount(source)
        print("count: \(count)")
        for index in 0..<count {
            
            if let metaData = CGImageSourceCopyMetadataAtIndex(source, 0, nil) {
                print("all metaData[\(index)]: \(metaData)")
                if let tags = CGImageMetadataCopyTags(metaData) as? [CGImageMetadataTag] {

                    print("number of tags - \(tags.count)")

                    for tag in tags {

//                        let tagType = CGImageMetadataTagGetTypeID()
                        if let name = CGImageMetadataTagCopyName(tag) {
                            print("name: \(name)")
                        }
                        
                        if let value = CGImageMetadataTagCopyValue(tag) {
                            print("value: \(value)")
                        }
                        
                        if let prefix = CGImageMetadataTagCopyPrefix(tag) {
                            print("prefix: \(prefix)")
                        }
                        
                        if let namespace = CGImageMetadataTagCopyNamespace(tag) {
                            print("namespace: \(namespace)")
                        }
                        
                        if let qualifiers = CGImageMetadataTagCopyQualifiers(tag) {
                            print("qualifiers: \(qualifiers)")
                        }
                        print("-------")
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
