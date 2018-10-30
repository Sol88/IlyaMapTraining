//
//  ClusterAnnotationView.swift
//  IlyaMapTraining
//
//  Created by Kovalenko Ilia on 26/10/2018.
//  Copyright © 2018 Kovalenko Ilia. All rights reserved.
//

import UIKit
import MapKit

class ClusterAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        collisionMode = .circle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let cluster = annotation as? MKClusterAnnotation {
            
            let totalImages = cluster.memberAnnotations.count
            
            if count() > 0 {
                image = drawImageCount(count: totalImages)
            }
            
            displayPriority = .defaultLow
        }
    }
    
    private func drawImageCount(count: Int) -> UIImage {
        return drawRatio(0, to: count)
    }
    
    private func drawRatio(_ fraction: Int, to whole: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: Constants.graphicImageRendererSideSize, height: Constants.graphicImageRendererSideSize))
        
        return renderer.image { _ in
            
            UIColor.black.setFill()
            UIBezierPath(ovalIn: CGRect(x: Constants.blackCircleOffsetXY, y: Constants.blackCircleOffsetXY, width: Constants.blackCircleDiameter, height: Constants.blackCircleDiameter)).fill()
            
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: Constants.whiteCircleOffsetXY, y: Constants.whiteCircleOffsetXY, width: Constants.whiteCircleDiameter, height: Constants.whiteCircleDiameter)).fill()
            
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: Constants.fontSize)]
            
            let text = "\(whole)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: Constants.fontSize - size.width / 2, y: Constants.fontSize - size.height / 2, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
            
        }
    }
    
    private func count() -> Int {
        guard let cluster = annotation as? MKClusterAnnotation else {
            return 0
        }
        
        return cluster.memberAnnotations.count
    }
    
}

extension ClusterAnnotationView {
    
    private enum Constants {
        static let graphicImageRendererSideSize: CGFloat = 40
        static let blackCircleDiameter: CGFloat = 34
        static let blackCircleOffsetXY: CGFloat = 6
        static let whiteCircleOffsetXY: CGFloat = 8
        static let whiteCircleDiameter: CGFloat = 30
        static let fontSize: CGFloat = 23
    }
    
}
