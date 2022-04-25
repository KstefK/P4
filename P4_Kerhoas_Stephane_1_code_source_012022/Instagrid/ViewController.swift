//
//  ViewController.swift
//  dayly2
//
//  Created by Stéphane KERHOAS on 28/02/2022.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Main view
    @IBOutlet weak var mainView: UIView!
    
    // Swipe2Share area
    @IBOutlet weak var swipeStackview: UIStackView!
    @IBOutlet weak var swipeState: UILabel!
    
    // Grid area
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var image1: UIButton!
    @IBOutlet weak var image2: UIButton!
    @IBOutlet weak var image3: UIButton!
    @IBOutlet weak var image4: UIButton!
    
    // Grid selector area
    @IBOutlet weak var selectorButton1: UIButton!
    @IBOutlet weak var selectorButton2: UIButton!
    @IBOutlet weak var selectorButton3: UIButton!
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare grid selector buttons
        setCorrectImageForSelectedButton(selectorButton1)
        setCorrectImageForSelectedButton(selectorButton2)
        setCorrectImageForSelectedButton(selectorButton3)
        
        selectorButton3.isSelected = true //Default view -- Button #3 selected
        
        // Gesture recognizer instantiation, for left and up
        let gestureSwipeRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(whenSwipeIsDetected(_:)))
        gestureSwipeRecognizerLeft.direction = .left
        
        let gestureSwipeRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(whenSwipeIsDetected(_:)))
        gestureSwipeRecognizerUp.direction = .up
        
        mainView.isUserInteractionEnabled = true
        
        // Attach a gesture recognizer to the main view
        mainView.addGestureRecognizer(gestureSwipeRecognizerLeft)
        mainView.addGestureRecognizer(gestureSwipeRecognizerUp)
    }
    
    // Functions
    // Grid selector management
    @IBAction func selectButton1(_ sender: Any) {
        
        selectorButton1.isSelected = true
        selectorButton2.isSelected = false
        selectorButton3.isSelected = false
        
        image1.isHidden = false
        image2.isHidden = true
        image3.isHidden = false
        image4.isHidden = false
    }
    
    @IBAction func selectButton2(_ sender: Any) {
        
        selectorButton1.isSelected = false
        selectorButton2.isSelected = true
        selectorButton3.isSelected = false
        
        image1.isHidden = false
        image2.isHidden = false
        image3.isHidden = false
        image4.isHidden = true
    }
    
    @IBAction func selectButton3(_ sender: Any) {
        
        selectorButton1.isSelected = false
        selectorButton2.isSelected = false
        selectorButton3.isSelected = true
        
        image1.isHidden = false
        image2.isHidden = false
        image3.isHidden = false
        image4.isHidden = false
        
    }
    
    // Grid selector - Function to set image("SelectedLarge") on button when selected
    private func setCorrectImageForSelectedButton(_ button: UIButton) {
        button.setImage(UIImage(named: "SelectedLarge"), for: .selected)
        button.setImage(UIImage(), for: .normal)
    }
    
    
    // We need to know what is device orientation so that we can set up the correct text in the swipe stack view
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isPortrait {
            swipeState.text = "Swipe up to share"
        } else if UIDevice.current.orientation.isLandscape {
            swipeState.text = "Swipe left to share"
        }
    }
    
    // Grid view - buttons clicked management to present picked image
    var pickedButton: UIButton? = nil
    
    @IBAction func buttonImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        pickedButton = sender
    }
    
    // imagePicker controller instantiation to fill up button background image with selected
    var imagePickerController: UIImagePickerController?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        pickedButton?.setTitle("", for: .normal)
        pickedButton?.clipsToBounds = true
        pickedButton?.contentMode = .scaleAspectFit
        pickedButton?.setBackgroundImage(imagePicked, for: .normal)
        pickedButton = nil
        self.dismiss(animated: true, completion: nil)
    }
    // if pickerController canceled (optionnal)
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    // Share image when a swipe is detected
    @objc func whenSwipeIsDetected(_ sender : UIGestureRecognizer){
        guard let swipeGesture = sender as? UISwipeGestureRecognizer else {
            return
        }
        
        // Define what to do with swipe gesture regarding device orientation
        
        let swipePortraitDirection = swipeGesture.direction == .up && UIDevice.current.orientation.isPortrait
        let swipeLandscapeDirection = swipeGesture.direction == .left && UIDevice.current.orientation.isLandscape
        
        // We have to init both the preview constants
        guard swipePortraitDirection || swipeLandscapeDirection else {
            return
        }
        
        // Transition animation settings
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        var translationTransform : CGAffineTransform
        
        // Then ...
        if UIDevice.current.orientation.isPortrait {
            translationTransform = CGAffineTransform(translationX: 0, y: -screenHeight)
            
        } else {
            translationTransform = CGAffineTransform(translationX: -screenWidth, y:0)
        }
        
        // Arrange the Activity Controller to prepare sharing the view
        
        let renderer = UIGraphicsImageRenderer(size: gridView.bounds.size)
        let imageToShare = renderer.image { rendererContext in
            gridView.layer.render(in: rendererContext.cgContext)
        }
        
        UIView.animate(withDuration : 0.3, animations: {
            self.mainView.transform = translationTransform

        })

       
        
        
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (_ ,_ ,_ ,_ ) in
            UIView.animate(withDuration : 0.3, animations: {
                self.mainView.transform = .identity
            })
        }
        
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
    
    
}

