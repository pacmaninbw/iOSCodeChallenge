//
//  ObjectivCViewController.m
//      - Implements the Objective-C view controller specified in the coding challenge
//  TabbedOCandSwift
//
//  Created by Paul Chernick on 4/18/17.

#import "ObjectiveCViewController.h"
#import "AppDelegate.h"

@interface ObjectivCViewController ()

- (UIButton *) makeAButton: (CGFloat) yButtonStart title: (NSString *) buttonTitle underSubview: (nullable UIView *) previousSiblingView;
- (UILabel *) makeALablel: (CGFloat) yLabelStart height: (CGFloat) height underSubview: (nullable UIView *) previousSiblingView;
- (void) addButtonAndLabels;
- (void) setSubViewSizeVariablesBasedOnViewBounds;
- (void) setLabelWithGPSLatitudeAndLongitudeWithTimeStampData;
- (void) setLabelWithBatteryLevelAndState;
- (void) setLabelActionNetwork;

@end

@implementation ObjectivCViewController
// Instance variables.
{
    UIButton *getGPSLongitudeAndLatitudeWithTimeStamp;
    UIButton *getBatteryLevelAndState;
    UIButton *getNetworkData;
    UILabel *displayButtonAction;
    UILabel *screenTitle;
    PCI7DataModelLibrary *displayDataModel;     // Imported with AppDelegate
    BOOL isFirstGpsClick;

// The following variables are used in multiple functions. They are constant during the display of the super view
// and control the size of the subviews
    CGFloat selfWidth;
    CGFloat verticalSpaceAvailableToUse;
    CGFloat buttonHeight;
    CGFloat viewElementWidth;
    CGFloat viewElementVerticalSpace;
    CGFloat buttonYCenterOffset;
    CGFloat buttonXCenter;
    CGFloat buttonXInit;
    CGFloat startingVerticalLocation;
    CGFloat displayLabelHeight;
    CGFloat tabBarHeight;
}

#pragma mark - Set up subviews (buttons and labels)

// Set the button and label sizes, preferrable based on device orientation and size
- (void) setSubViewSizeVariablesBasedOnViewBounds {
    selfWidth = self.view.bounds.size.width;
    verticalSpaceAvailableToUse = self.view.bounds.size.height - tabBarHeight;
    viewElementVerticalSpace = verticalSpaceAvailableToUse / 14.0;
    viewElementWidth = 0.85 * selfWidth;
    buttonHeight = viewElementVerticalSpace * 0.65;
    buttonYCenterOffset = buttonHeight / 2.0;
    buttonXCenter = selfWidth / 2.0;
    buttonXInit = (selfWidth - viewElementWidth) / 2.0;
    startingVerticalLocation = 295.0;           // Chosen based on experimentation in the simulator
    displayLabelHeight = 3.0 * viewElementVerticalSpace;
}

- (UILabel *) makeALablel: (CGFloat) yLabelStart height: (CGFloat) height underSubview: (nullable UIView *) previousSiblingView
{
    UILabel* thisLabel;

    thisLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonXInit, yLabelStart, viewElementWidth, height)];
    [thisLabel setFont:[UIFont systemFontOfSize:12]];     // Reduce the size of the text so that more output fits on a single line
    thisLabel.lineBreakMode = NSLineBreakByWordWrapping;
    thisLabel.numberOfLines = 0;                          // Allow the label to grow as necessary
    thisLabel.textAlignment = NSTextAlignmentCenter;
    thisLabel.textColor = [UIColor blackColor];

    if (previousSiblingView) {
        [self.view insertSubview:thisLabel belowSubview:previousSiblingView];
    }
    else {
        [self.view addSubview:thisLabel];
    }

    return thisLabel;
}

// Create a button with the starting y coordinate, the button title, and the sibling view to appear under the first item passed in
// may not have a sibling subview, but all following buttons should have a previous sibling view.
// The target action is not set in this function, I haven't found documentation on how to pass a function into a function.
- (UIButton *) makeAButton: (CGFloat) yButtonStart title: (NSString *) buttonTitle underSubview: (nullable UIView *) previousSiblingView
{
    UIButton *thisButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [thisButton setFrame:CGRectMake(buttonXInit, yButtonStart, viewElementWidth, buttonHeight)];
    [thisButton setCenter:CGPointMake(buttonXCenter, yButtonStart + buttonYCenterOffset)];
    [thisButton setTitle:buttonTitle forState:UIControlStateNormal];
    [thisButton setBackgroundColor:[UIColor yellowColor]];
    [thisButton setTitleColor:[UIColor blackColor]  forState:UIControlStateNormal];
    
    if (previousSiblingView) {
        [self.view insertSubview:thisButton belowSubview:previousSiblingView];
    }
    else {
        [self.view addSubview:thisButton];
    }
    
    return thisButton;
}

// Add the necessary sub-view buttons and labels to the application
// Assumptions here, all instance variables for buttons and labels have been set
// to null by the calling function.
// TODO: Put the titles, previous subviews and, object types and action selectors into a table and loop through the table.

- (void) addButtonAndLabels {
    if (selfWidth < 1.0) {
        return;
    }
    
    CGFloat viewElementVerticalLocation = startingVerticalLocation;
    
    screenTitle = [self makeALablel:viewElementVerticalLocation height:buttonHeight underSubview:nil];
    NSString* titleText = @"Objective-C Implementation";
    [screenTitle setText:titleText];
    UIFont* titleFont = [UIFont boldSystemFontOfSize:16];
    [screenTitle setFont:titleFont];     // This is the title of the screen make it the larges text
    viewElementVerticalLocation += viewElementVerticalSpace;
 
    getGPSLongitudeAndLatitudeWithTimeStamp = [self makeAButton: viewElementVerticalLocation  title: @"Get GPS Location with TimeStamp" underSubview: screenTitle];
    // The target action is not set in makeAButton function, I haven't researched how to pass a selector/function into a function.
    [getGPSLongitudeAndLatitudeWithTimeStamp addTarget:self action: @selector(setLabelWithGPSLatitudeAndLongitudeWithTimeStampData) forControlEvents: UIControlEventTouchUpInside];
    viewElementVerticalLocation += viewElementVerticalSpace;

    getBatteryLevelAndState = [self makeAButton: viewElementVerticalLocation  title: @"Get Battery Level and State" underSubview: getGPSLongitudeAndLatitudeWithTimeStamp];
    [getBatteryLevelAndState addTarget:self action: @selector(setLabelWithBatteryLevelAndState) forControlEvents: UIControlEventTouchUpInside];
    viewElementVerticalLocation += viewElementVerticalSpace;
    
    getNetworkData = [self makeAButton: viewElementVerticalLocation  title: @"Get the American Express Stock Price" underSubview: getBatteryLevelAndState];
    [getNetworkData addTarget:self action: @selector(setLabelActionNetwork) forControlEvents: UIControlEventTouchUpInside];
    viewElementVerticalLocation += viewElementVerticalSpace;
    
    displayButtonAction = [self makeALablel:viewElementVerticalLocation height:displayLabelHeight underSubview:getNetworkData];
}

/*
 * The view is changing, either being displayed or rotated.
 * Set the button and label variables to nil to decrease any resource counters.
 * Redraw the buttons.
 */
- (void)viewWillLayoutSubviews {
    getGPSLongitudeAndLatitudeWithTimeStamp = nil;
    getBatteryLevelAndState = nil;
    getNetworkData = nil;
    displayButtonAction = nil;
    screenTitle = nil;
    /*
     * Get the tab bar height from the Application Delegate so that the total vertical space
     * can be calculated.
     */
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (appDelegate) {
        UITabBarController *TempTabBar = appDelegate.tabBarController;
        if (TempTabBar) {
            // Tab Bar Height is larger than myDelegate.tabBarController.tabBar.frame.size.height indicates
            tabBarHeight = TempTabBar.tabBar.frame.size.height * 2.5;
        }
    }
    
    [self setSubViewSizeVariablesBasedOnViewBounds];
    [self addButtonAndLabels];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Button Action functions
- (void) setLabelWithGPSLatitudeAndLongitudeWithTimeStampData {
    NSString *actionString = nil;
    
    if (displayDataModel) {
#if 0
        if (isFirstGpsClick) {
            // Call to the DataModel library that receives a pointer UIAlertView object from the GPS library implementation
            // If the UIAlertView pointer is nil proceed with the displaying the latitude, longitude and timestamp.
            // If the UIAlertView has a value show the alert, the alert should contain a function to update data in the GPS model.
            // This will enable the user to approve of using WiFi or Radio triangulation when the GPS is not available.
            /*
             * BUG - title and message are not appearing in the alert, the buttons in the alert work as expected
             *          clicking the YES button removes the warning message that there is no GPS hardware and just
             *          returns the data. Clicking the no message displays displays the warning message every time.
             */
            isFirstGpsClick = NO;
            UIAlertController* gpsAlert = [displayDataModel provideGPSAlerters];
            if (gpsAlert) {
                [self presentViewController:gpsAlert animated:NO completion:nil];
                return;
            }
        }
#endif
        actionString = [displayDataModel provideGPSLocationData];
    }
    else {
        actionString = @"GPS Button Action Failure: Data Model not created";
    }
    
    [displayButtonAction setText:actionString];
}

- (void) setLabelWithBatteryLevelAndState {
    NSString *actionString = nil;
    
    if (displayDataModel) {
        actionString = [displayDataModel provideBatteryLevelAndState];
    }
    else {
        actionString = @"Battery Button Action Failure: Data Model not created";
    }
    
    [displayButtonAction setText:actionString];
    
}

- (void) setLabelActionNetwork {
    NSString *actionString = nil;
    
    if (displayDataModel) {
        actionString = [displayDataModel provideNetworkAccessData];
    }
    else {
        actionString = @"Network Button Action Failure: Data Model not created";
    }
    
    [displayButtonAction setText:actionString];
    
}

#pragma mark - Memory management and class initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.displayModelLibraryInitialization) {
        NSLog(@"In Objective-C Implementation viewDidLoad - unable to initialize displayModelLibrary");
    }
}

- (BOOL) displayModelLibraryInitialization {
    // If the data model library is nil then get the pointer to the data library from the application delegate
    // The data model library should be created only once in the application delegate while the application launches.
    
    if (!displayDataModel) {
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        displayDataModel = appDelegate.dataModelLibrary;
    }
    return (displayDataModel == nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (id) init {
    self = [super init];
    isFirstGpsClick = YES;
    getGPSLongitudeAndLatitudeWithTimeStamp = nil;
    getBatteryLevelAndState = nil;
    getNetworkData = nil;
    displayButtonAction = nil;
    screenTitle = nil;
    displayDataModel = nil;     // Imported with AppDelegate
    if (self.displayModelLibraryInitialization) {
        NSLog(@"In Objective-C Implementation viewDidLoad - unable to initialize displayModelLibrary");
        return nil;
    }

    return self;
}

@end
