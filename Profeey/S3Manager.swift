//
//  S3Manager.swift
//  Profeey
//
//  Created by Antonio Zdelican on 29/12/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import Foundation
import AWSMobileHubHelper

protocol S3Manager {

    // MARK: Download
    
    func downloadImageS3(_ imageKey: String, imageType: ImageType)
    func removeImageS3(_ imageKey: String)
}
