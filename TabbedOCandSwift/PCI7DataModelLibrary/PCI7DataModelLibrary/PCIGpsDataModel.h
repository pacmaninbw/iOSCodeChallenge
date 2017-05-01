//
//  PCIGpsDataModel.h
//  PCIDataModelLibrary
//

//  The GPSDataModel class is responsible for interfacing with the CLLocationManager to retrieve the
//  GPS Latitude and Longitude.

#import <Foundation/Foundation.h>

@interface PCIGpsDataModel : NSObject

- (id)init;
- (BOOL)doesGPSHardWareExists;
- (NSString*)provideGPSLongitudeAndLatitudeWithTimeStamp;
- (UIAlertController*)alertUserNoGPSHardware;

@end
