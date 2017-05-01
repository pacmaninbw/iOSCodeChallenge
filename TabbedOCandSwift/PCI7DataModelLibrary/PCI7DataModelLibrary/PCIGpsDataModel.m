//
//  PCIGpsDataModel.m
//  PCIDataModelLibrary
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "PCIGpsDataModel.h"


@interface PCIGpsDataModel () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (void) initializeGPSHardwareExists;
- (NSString*) dateFromLocation;
- (NSString*) latitudeFromLocation;
- (NSString*) longitudeFromLocation;

@end

@implementation PCIGpsDataModel
{
    BOOL mustUseGPSHardware;
    BOOL hardwareExistsOnDevice;
    BOOL firstTimeGPSDataRequested;         // Flag to allow asking user to use alternate method rather than GPS and to enable location service
    CLLocation *lastReportedLocation;
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    }
    return _dateFormatter;
}

#pragma mark - Private Functions

- (void) initializeGPSHardwareExists {
    if (lastReportedLocation) {
        // The GPS hardware provides better accuracy than WiFi or Radio triangulation.
        // Both horizontal and vertical accuracy will be greater than zero if the GPS hardware is available.
        if (([lastReportedLocation horizontalAccuracy] > 0) && ([lastReportedLocation verticalAccuracy] > 0)) {
            hardwareExistsOnDevice = YES;
        }
        else {
            hardwareExistsOnDevice = NO;
        }
        
    }
    else {
        hardwareExistsOnDevice = NO;
    }
}

- (NSString*) dateFromLocation {
    NSString* dateString = nil;
    
    if (lastReportedLocation) {
        NSDate* timeStampInDateForm = [lastReportedLocation timestamp];
        dateString = [self.dateFormatter stringFromDate:timeStampInDateForm];
    }
    else {
        dateString = @"No location data.";
    }
    
    return dateString;
}

- (NSString*) latitudeFromLocation {
    NSString* latitude = nil;
    
    if (lastReportedLocation) {
        CGFloat untranslatedLatitude = lastReportedLocation.coordinate.latitude;
        NSString* direction = @"North";
        
        if (untranslatedLatitude < 0.0) {
            direction = @"South";
        }
        
        latitude = [NSString stringWithFormat:@"Latitude = %4.2f %@", fabs(untranslatedLatitude), direction];
    }
    else {
        latitude = @"No location data.";
    }
    
    return latitude;
}

- (NSString*) longitudeFromLocation {
    NSString* longitude = nil;
    
    if (lastReportedLocation) {
        CGFloat untranslatedLongitude = lastReportedLocation.coordinate.longitude;
        NSString* direction = @"East";
        
        if (untranslatedLongitude < 0.0) {
            direction = @"West";
        }
        longitude = [NSString stringWithFormat:@"Longitude = %4.2f %@", fabs(untranslatedLongitude), direction];
    }
    else {
        longitude = @"No location data.";
    }
    
    return longitude;
}

#pragma mark - Location Manager Interactions

/*
 * Callback function, the CLLocationManager calls this function with updated location data when changes to the location occur.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (([newLocation horizontalAccuracy] > 0) && ([newLocation verticalAccuracy] > 0)) {
        hardwareExistsOnDevice = YES;
    }
    else {
        hardwareExistsOnDevice = NO;
    }
    
    lastReportedLocation = newLocation;
    [self initializeGPSHardwareExists];
    
}

- (BOOL) doesGPSHardWareExists {
    return hardwareExistsOnDevice;
}

#pragma mark - public interfaces

- (UIAlertController*) alertUserNoGPSHardware {
    UIAlertController *alertToPresent = nil;
    NSString* alertTitleString = @"GPS Alert";
    NSString* alertMessage = @"No GPS hardware use Triangulation?";
    
    if (!hardwareExistsOnDevice && mustUseGPSHardware) {
        alertToPresent = [UIAlertController alertControllerWithTitle: alertTitleString message:alertMessage
                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {mustUseGPSHardware = NO;}];
        [alertToPresent addAction:yesButton];
        UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {mustUseGPSHardware = YES;}];
        [alertToPresent addAction:noButton];
    }
    
    return alertToPresent;
}

- (NSString*) provideGPSLongitudeAndLatitudeWithTimeStamp {
    NSString *gpsLongitudeAndLatitudeWithTimeStamp = nil;

// There should be additional checks in this function, the problem statement said get GPS data, the GPS is not available on all
// devices and is not available in the simulator.
// The additional checks should determin if the user has requested GPS data only, report problems in the return string if that
// is the case.
    
    if (!lastReportedLocation) {
        gpsLongitudeAndLatitudeWithTimeStamp = @"No Location data available";
    }
    else {
        if (hardwareExistsOnDevice || !mustUseGPSHardware) {
            gpsLongitudeAndLatitudeWithTimeStamp = [NSString stringWithFormat:@"%@\n%@\n time stamp = %@", self.latitudeFromLocation, self.longitudeFromLocation, self.dateFromLocation];
        }
        else {
            gpsLongitudeAndLatitudeWithTimeStamp = [NSString
                stringWithFormat:@"GPS hardware not on device using alternate method\n%@\n%@\n time stamp = %@",
                self.latitudeFromLocation, self.longitudeFromLocation, self.dateFromLocation];
        }
    }
    
    firstTimeGPSDataRequested = NO;
    
    return  gpsLongitudeAndLatitudeWithTimeStamp;
}

- (void) gpsSetMustUseGPSHardware {
    mustUseGPSHardware = YES;           // Not current checked.
}

- (void) gpsAllowWiFiOrRadioTriangulation {
    mustUseGPSHardware = NO;           // Not current checked.
}

- (void) gpsSetHardwareExists {
    hardwareExistsOnDevice = NO;        // This value may be changed on the first or following location updates.
}

// CLLocationManager returns locations based on the delegate model, Apple does not provide an alternate method. The locations are returned based
// on the device moving a specified distance. Requesting greater accuracy can for the service to use GPS hardware if it is available, it may
// default to WiFi or Radio triangulation. Using when the GPS hardware is used, it can affect power usage, this should be considered
// during implementation in real life.

// The CLLocation manager is configured and data collection is started during the initialization of this data model,
// I considered it a better than doing all this work during the first click of the button. The initialization will fail
// if the user clicks the "Don't Allow" button on the alert. This initialization will also failed if Info.plist does not
// contain the following
//      <key>NSLocationWhenInUseUsageDescription</key>
//      <string>This will be used to obtain your current location.</string>
//      <key>NSLocationAlwaysUsageDescription</key>
//      <string>This application requires location services to work</string>

- (id) init {
    if (self = [super init]) {
        mustUseGPSHardware = YES;
        firstTimeGPSDataRequested = YES;
        lastReportedLocation = nil;         // This is updated periodically, set to nil to prevent access to uknown address until update
        _locationManager = [[CLLocationManager alloc] init];
        if (_locationManager) {
            // Attempt to force the device to use the GPS rather than WiFi or Radio Triagulation
            self.locationManager.desiredAccuracy = [ @"AccuracyBest" doubleValue];
            // If the user moves 100 meters then a location update should occur.
            self.locationManager.distanceFilter = [@100.0 doubleValue];
            // The following code checks to see if the user has authorized GPS use.
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            // Now that the configuration of the CLLocationManager has been completed start updating the location.
            [self.locationManager startUpdatingLocation];
        }
        self.locationManager.delegate = self;
    }
    
    
    return  self;
}

@end
