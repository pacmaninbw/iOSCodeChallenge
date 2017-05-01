//
//  SwiftViewController.swift
//  SwiftTabForApp
//

import UIKit

@objc class SwiftViewController: UIViewController {
    var getGPSLongitudeAndLatitudeWithTimeStamp : UIButton?
    var getBatteryLevelAndState : UIButton?
    var getNextorkImplementation : UIButton?
    var displayButtonAction : UILabel?
    var screenTitle : UILabel?
    var displayDataModel : PCI7DataModelLibrary?
    var isFirstGpsClick : Bool = true
    
    // The following variables are used in multiple functions. They are constant during the display of the super view
    // and control the size of the subviews. They should change when the orientation changes
    var selfWidth : CGFloat = 0.0
    var verticalSpaceAvailableToUse: CGFloat = 0.0
    var buttonHeight : CGFloat = 0.0
    var viewElementWidth : CGFloat = 0.0
    var viewElementVerticalSpace : CGFloat = 0.0
    var buttonXInit : CGFloat = 0.0
    var startingVerticalLocation : CGFloat = 0.0
    var displayLabelHeight: CGFloat = 0.0
    var selfUsableHeight: CGFloat = 0.0
    var tabBarHeight: CGFloat = 0.0
    
    // Size the buttons and labels based on the available width and height.
    func initFramingValuesOfMyDisplay() {
        selfWidth = self.view.bounds.width
        verticalSpaceAvailableToUse = self.view.bounds.height - tabBarHeight
        viewElementWidth = 0.85 * selfWidth;
        viewElementVerticalSpace = verticalSpaceAvailableToUse / 14.0
        buttonHeight = viewElementVerticalSpace * 0.65
        buttonXInit = (selfWidth - viewElementWidth) / 2.0;
        startingVerticalLocation = 110.0  // chosen based on experimentation in the simulator
        displayLabelHeight = viewElementVerticalSpace * 3.0
    }
    
    // This function is called when the getGPSLongitudeAndLatitudeWithTimeStamp button is receives the touchUpInside event.
    func setLabelWithGPSLatitudeAndLongitudeWithTimeStampData()
    {
        var actionString : String = "Testing Label Text"
        
        if (self.displayDataModel != nil) {
            if (self.isFirstGpsClick) {
                // Call to the DataModel library that receives a pointer UIAlertView object from the GPS library implementation
                // If the UIAlertView pointer is nil proceed with the displaying the latitude, longitude and timestamp.
                // If the UIAlertView has a value show the alert, the alert should contain a function to update data in the GPS model.
                // This will enable the user to approve of using WiFi or Radio triangulation when the GPS is not available.
                self.isFirstGpsClick = false;
                let gpsAlert : UIAlertController? = self.displayDataModel!.provideGPSAlerters();
                if (gpsAlert != nil) {
                    self.present(gpsAlert!, animated:false, completion:nil);
                }
            }
            actionString = (self.displayDataModel?.provideGPSLocationData())!
        }
        else {
            actionString = "GPS Button Action Failure: Data Model not created"
        }
        
        DispatchQueue.main.async {
            self.displayButtonAction?.text = nil
            self.displayButtonAction?.text = actionString
        }
    }
    
    // This function is called when the getBatteryLevelAndState button is receives the touchUpInside event.
    func setLabelWithBatteryLevelAndState() {
        var actionString : String = "Get Battery Level and State";
        
        if (self.displayDataModel != nil) {
            actionString = (self.displayDataModel?.provideBatteryLevelAndState())!
        }
        else {
            actionString = "Battery Button Action Failure: Data Model not created"
        }
        
        DispatchQueue.main.async {
            self.displayButtonAction?.text = nil
            self.displayButtonAction?.text = actionString
        }
    }
    
    // This function is called when the getNextorkImplementation button is receives the touchUpInside event.
    func setLabelActionNetwork() {
        var actionString :String = "Fake Button set to American Express Stock Price"
        
        if (self.displayDataModel != nil) {
            actionString = (self.displayDataModel?.provideNetworkAccessData())!
        }
        else {
            actionString = "Network Button Action Failure: Data Model not created"
        }
        
        DispatchQueue.main.async {
            self.displayButtonAction?.text = nil
            self.displayButtonAction?.text = actionString
        }
    }
    
    func makeAButton(yButtonStart : CGFloat, buttonTitle: String, underSubview: UIView?) -> UIButton
    {
        let thisButton = UIButton.init(type: .system)
        thisButton.frame = CGRect(x: buttonXInit, y: yButtonStart, width: viewElementWidth, height: buttonHeight)
        thisButton.setTitle(buttonTitle, for:UIControlState.normal)
        thisButton.backgroundColor = UIColor.yellow
        thisButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        if ((underSubview) == nil) {
            self.view.addSubview(thisButton)
        }
        else {
            self.view.insertSubview(thisButton, belowSubview:underSubview!)
        }
        
        return thisButton;
    }
    
    func makeALabel(yLabelStart : CGFloat, height: CGFloat, underSubview: UIView?) -> UILabel
    {
        let thisLabel = UILabel.init()
        thisLabel.frame = CGRect(x: buttonXInit, y: yLabelStart, width: viewElementWidth, height: height)
        thisLabel.font = thisLabel.font.withSize(12)     // Reduce the size of the text so that more output fits on a single line
        thisLabel.lineBreakMode = .byWordWrapping;
        thisLabel.numberOfLines = 0;                          // Allow the label to grow as necessary
        thisLabel.textAlignment = NSTextAlignment.center;
        thisLabel.textColor = UIColor.black;
        
        if ((underSubview) == nil) {
            self.view.addSubview(thisLabel)
        }
        else {
            self.view.insertSubview(thisLabel, belowSubview:underSubview!)
        }
        
        return thisLabel;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // rather than assume a particular background color, set the background color so that everything can be seen.
        self.view.backgroundColor = UIColor.white
    }
    
    func addButtonAndLabels() -> Void {
        // If the width of the screen hasn't been used as a base for the size of the sub-views then
        // this function is not ready to generate the sub-views.
        if (selfWidth < 1.0) {
            return;
        }
        var viewElementVerticalLocation: CGFloat = startingVerticalLocation;
        
        self.screenTitle = makeALabel(yLabelStart: viewElementVerticalLocation, height: buttonHeight, underSubview: nil)
        self.screenTitle?.text = "Swift Implementation"
        self.screenTitle?.font = self.screenTitle?.font.withSize(16)
        viewElementVerticalLocation += viewElementVerticalSpace
        
        self.getGPSLongitudeAndLatitudeWithTimeStamp = makeAButton(yButtonStart: viewElementVerticalLocation, buttonTitle: "Get GPS Location with TimeStamp", underSubview: nil)
        self.getGPSLongitudeAndLatitudeWithTimeStamp?.addTarget(self, action: #selector(setLabelWithGPSLatitudeAndLongitudeWithTimeStampData), for:  .touchUpInside)
        viewElementVerticalLocation += viewElementVerticalSpace
        
        self.getBatteryLevelAndState = makeAButton(yButtonStart: viewElementVerticalLocation, buttonTitle: "Get Battery Level and State", underSubview: getGPSLongitudeAndLatitudeWithTimeStamp)
        self.getBatteryLevelAndState?.addTarget(self, action: #selector(setLabelWithBatteryLevelAndState), for:  .touchUpInside)
        viewElementVerticalLocation += viewElementVerticalSpace
        
        self.getNextorkImplementation = makeAButton(yButtonStart: viewElementVerticalLocation, buttonTitle: "Get the American Express Stock Price", underSubview: getBatteryLevelAndState)
        self.getNextorkImplementation?.addTarget(self, action: #selector(setLabelActionNetwork), for:  .touchUpInside)
        viewElementVerticalLocation += viewElementVerticalSpace
        
        
        self.displayButtonAction = makeALabel(yLabelStart: viewElementVerticalLocation, height: displayLabelHeight, underSubview: getNextorkImplementation)
    }
    
    func displayModelLibraryInitialization() -> CBool {
        if (self.displayDataModel == nil) {
            if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
                self.displayDataModel = myDelegate.dataModelLibrary;
            }
        }
        return (self.displayDataModel == nil)
    }
    
    /*
     * The view is changing, either being displayed or rotated.
     * Set the button and label variables to nil to decrease any resource counters.
     * Redraw the buttons.
     */
    override func viewWillLayoutSubviews()
    {
        self.view.backgroundColor = UIColor.white
        self.getGPSLongitudeAndLatitudeWithTimeStamp = nil
        self.getGPSLongitudeAndLatitudeWithTimeStamp = nil
        self.getNextorkImplementation = nil
        self.screenTitle = nil
        self.displayButtonAction = nil
        /*
         * Get the tab bar height from the Application Delegate so that the total vertical space
         * can be calculated.
         */
        if let myDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Tab Bar Height is larger than myDelegate.tabBarController.tabBar.frame.size.height indicates
            tabBarHeight = myDelegate.tabBarController.tabBar.frame.size.height * 2.5;
        }

        initFramingValuesOfMyDisplay()
        addButtonAndLabels()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
        if (self.displayDataModel == nil) {
            if (self.displayModelLibraryInitialization()) {
                abort()
            }
            self.getGPSLongitudeAndLatitudeWithTimeStamp = nil
            self.getGPSLongitudeAndLatitudeWithTimeStamp = nil
            self.getNextorkImplementation = nil
            self.screenTitle = nil
            self.displayButtonAction = nil
        }
        initFramingValuesOfMyDisplay()
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        if (self.displayDataModel == nil) {
            if (self.displayModelLibraryInitialization()) {
                abort()
            }
            self.getGPSLongitudeAndLatitudeWithTimeStamp = nil
            self.getGPSLongitudeAndLatitudeWithTimeStamp = nil
            self.getNextorkImplementation = nil
            self.screenTitle = nil
            self.displayButtonAction = nil
        }
        initFramingValuesOfMyDisplay()
    }
}
