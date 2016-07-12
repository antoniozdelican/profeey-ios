//
//  PhotoPreviewViewController.swift
//  Profeey
//
//  Created by Antonio Zdelican on 19/06/16.
//  Copyright © 2016 Profeey. All rights reserved.
//

import UIKit

class PhotoPreviewViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: UIImage!
    
    // TESTING
    var openGLContext: EAGLContext!
    var ciContext: CIContext!
    var ciImage: CIImage!
    //var cgImage: CGImage!
    
    var firstImage: UIImage?
    var secondImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoImageView.image = photo
        
        //let image2 = photo.fixOrientation()
        
        // TESTING
        guard let cgimg = photo.CGImage else {
            print("Error!")
            return
        }
        
        self.openGLContext = EAGLContext(API: .OpenGLES2)
        self.ciContext = CIContext(EAGLContext: openGLContext!)
        
        self.ciImage = CIImage(CGImage: cgimg)
        
        self.configureFirstFilter()
        self.configureSecondFilter()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TESTING
    
    func setZeroFilter() {
        self.photoImageView.image = photo
    }
    
    func setFirstFilter() {
        self.photoImageView.image = self.firstImage
    }
    
    func setSecondFilter() {
        self.photoImageView.image = self.secondImage
    }
    
    func configureFirstFilter() {
        let sepiaFilter = CIFilter(name: "CISepiaTone")
        sepiaFilter?.setValue(self.ciImage, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(1, forKey: kCIInputIntensityKey)
        
        if let sepiaOutput = sepiaFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
            let exposureFilter = CIFilter(name: "CIExposureAdjust")
            exposureFilter?.setValue(sepiaOutput, forKey: kCIInputImageKey)
            exposureFilter?.setValue(1, forKey: kCIInputEVKey)
            
            if let exposureOutput = exposureFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
                let output = self.ciContext.createCGImage(exposureOutput, fromRect: exposureOutput.extent)
                let result = UIImage(CGImage: output)
                self.firstImage = result
            }
        }
    }
    
    func configureSecondFilter() {
        let exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter?.setValue(self.ciImage, forKey: kCIInputImageKey)
        exposureFilter?.setValue(1, forKey: kCIInputEVKey)
        
        if let exposureOutput = exposureFilter?.valueForKey(kCIOutputImageKey) as? CIImage {
            let output = self.ciContext.createCGImage(exposureOutput, fromRect: exposureOutput.extent)
            let result = UIImage(CGImage: output)
            self.secondImage = result
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: IBActions
    
    @IBAction func segmentedControllChanged(sender: AnyObject) {
        guard let segmentedControll = sender as? UISegmentedControl else {
            return
        }
        switch segmentedControll.selectedSegmentIndex {
        case 1:
            self.setFirstFilter()
        case 2:
            self.setSecondFilter()
        default:
            self.setZeroFilter()
        }
    }

}
