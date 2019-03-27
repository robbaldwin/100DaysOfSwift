//
//  ViewController.swift
//  Instafilter
//
//  Created by Rob Baldwin on 24/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import CoreImage
import UIKit

final class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var filterNameLabel: UILabel!
    @IBOutlet private var slider1Label: UILabel!
    @IBOutlet private var slider2Label: UILabel!
    @IBOutlet private var slider1: UISlider!
    @IBOutlet private var slider2: UISlider!
    
    private var currentImage: UIImage!
    private var previousStageImage: UIImage!
    private var context: CIContext!
    
    private var currentFilter: CIFilter! {
        didSet {
            let name = currentFilter.name.replacingOccurrences(of: "CI", with: "")
            filterNameLabel.text = name
        }
    }
    
    // Dictionary of available Filters containing:
    // Dictionary of parameters and default values
    private var filters: [String: [String: Float]] = [
        "CIExposureAdjust" : [
            kCIInputEVKey : 0.5
        ],
        "CIUnsharpMask" : [
            kCIInputIntensityKey : 0.5,
            kCIInputRadiusKey : 2.5
        ],
        "CIGaussianBlur" : [
            kCIInputRadiusKey : 10.0
        ],
        "CIMotionBlur" : [
            kCIInputRadiusKey : 20.0,
            kCIInputAngleKey : 3.0
        ],
        "CIColorControls" : [
            kCIInputSaturationKey : 1.0,
            kCIInputContrastKey : 1.0
        ],
        "CIVignette" : [
            kCIInputRadiusKey : 1.0,
            kCIInputIntensityKey : 1.0
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()
        currentFilter = CIFilter(name: "CIExposureAdjust")
        currentImage = UIImage(named: "MV")
        setFilter()
    }
    
    @objc
    private func importPicture() {
        
        // Requires: Info.plist entry
        // Privacy - Photo Library Additions Usage Description
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func copyCurrentStageImage() {
        guard let cgImg = currentImage.cgImage?.copy() else { return }
        previousStageImage = UIImage(cgImage: cgImg)
    }

    @objc
    private func setFilter() {
        guard currentImage != nil else { return }
        
        copyCurrentStageImage()
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        // Hide controls
        slider1Label.text = ""
        slider2Label.text = ""
        slider1.isEnabled = false
        slider1.alpha = 0.0
        slider2.isEnabled = false
        slider2.alpha = 0.0
        
        guard let parameters = filters[currentFilter.name] else { return }
        
        if let value = parameters[kCIInputIntensityKey] {
            slider1Label.text = "Intensity"
            slider1.maximumValue = value * 2
            slider1.value = value
        }
        
        if let value = parameters[kCIInputEVKey] {
            slider1Label.text = "EV"
            slider1.maximumValue = value * 2
            slider1.value = value
        }
        
        if let value = parameters[kCIInputAmountKey] {
            slider1Label.text = "Amount"
            slider1.maximumValue = value * 2
            slider1.value = value
        }
        
        if let value = parameters[kCIInputAngleKey] {
            slider1Label.text = "Angle"
            slider1.maximumValue = value * 2
            slider1.value = value
        }
        
        if let value = parameters[kCIInputRadiusKey] {
            slider2Label.text = "Radius"
            slider2.maximumValue = value * 2
            slider2.value = value
        }
        
        if let value = parameters[kCIInputSaturationKey] {
            slider1Label.text = "Saturation"
            slider1.maximumValue = value * 2
            slider1.value = value
        }
        
        if let value = parameters[kCIInputContrastKey] {
            slider2Label.text = "Contrast"
            slider2.maximumValue = value * 2
            slider2.value = value
        }
        
        // Enable and Show Sliders if TextLabel has text set
        if let text = slider1Label.text, !text.isEmpty  {
            slider1.isEnabled = true
            slider1.alpha = 1.0
        }
        
        if let text = slider2Label.text, !text.isEmpty {
            slider2.isEnabled = true
            slider2.alpha = 1.0
        }
        
        applyProcessing()
    }
    
    private func applyProcessing() {
        
        guard let paramaters = filters[currentFilter.name] else { return }
  
        for paramater in paramaters {
            
            switch paramater.key {
            case kCIInputRadiusKey:
                currentFilter.setValue(slider2.value, forKey: paramater.key)
            case kCIInputContrastKey:
                currentFilter.setValue(slider2.value, forKey: paramater.key)
            default:
                currentFilter.setValue(slider1.value, forKey: paramater.key)
            }
        }

        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
            currentImage = processedImage
        }
    }
    
    @objc
    private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    @IBAction private func changeFilterButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        
        for filter in filters {
            let title = filter.key.replacingOccurrences(of: "CI", with: "")
            ac.addAction(UIAlertAction(title: title, style: .default, handler: { [weak self] _ in
                self?.currentFilter = CIFilter(name: filter.key)
                self?.setFilter()
            }))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction private func undoButtonTapped(_ sender: Any) {
        guard let cgImg = previousStageImage.cgImage?.copy() else { return }
        currentImage = UIImage(cgImage: cgImg)
        imageView.image = currentImage
        currentFilter = CIFilter(name: "CIExposureAdjust")
        setFilter()
    }
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction private func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction private func radiusChanged(_ sender: Any) {
        applyProcessing()
    }
    
    // MARK: - ImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true, completion: nil)
        currentImage = image
        setFilter()
    }
}

