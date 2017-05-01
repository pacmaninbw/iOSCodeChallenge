//
//  PCI7DataModelLibrary.m
//  PCI7DataModelLibrary
//
//  Created by Paul Chernick on 4/18/17.
//

// This object provides a library interface to GPS data, battery data and a network service.
// The library consists of three different data models, one for the GPS data, one for the battery data and one
// for the network data. Each of the different data models is contained within it's own class. This library was
// implemented this way to ease the implementation, ease debugging, and allow multiple engineers to work in
// parallel to implement the library. This implementation follows what is sometimes know as the Single
// Responsibility Principle.
//
// Each child data model has it's own initialization functions and is completely self contained. There are no
// dependencies between the different data models.

#import "PCI7DataModelLibrary.h"
#import "PCIGpsDataModel.h"
#import "PCIBatteryDataModel.h"
#import "PCINetworkingDataModel.h"

// TODO : create a tabel of data models and symbolic constants that provide indexes into that table.
@implementation PCI7DataModelLibrary
{
    PCIBatteryDataModel *batteryDataModel;
    PCIGpsDataModel *gpsDataModel;
    PCINetworkingDataModel *networkDataModel;
    BOOL unableToEstableConnection;
}

- (BOOL)IsGpsAvailable {
    BOOL GpsIsAvailble = NO;
    
    if (gpsDataModel) {
        GpsIsAvailble = gpsDataModel.doesGPSHardWareExists;
    }
    
    return GpsIsAvailble;
}

- (UIAlertController*)provideGPSAlerters {
    UIAlertController* gpsAlertController = nil;
    if (gpsDataModel) {
        gpsAlertController = gpsDataModel.alertUserNoGPSHardware;
    }
    
    return gpsAlertController;
}

- (NSString *)provideGPSLocationData {
    NSString *gpsLocationData = nil;
    
    if (gpsDataModel) {
        gpsLocationData = [gpsDataModel provideGPSLongitudeAndLatitudeWithTimeStamp];
    }
    else {
        gpsLocationData = @"Unable to access location data at this time.";
    }
    
    return gpsLocationData;
}

- (NSString *)provideBatteryLevelAndState {
    NSString *batteryLevelAndState = nil;
    
    if (batteryDataModel) {
        batteryLevelAndState = batteryDataModel.provideBatteryLevelAndState;
    }
    else {
        batteryLevelAndState = @"Unable to access battery state and level at this time";
    }
    
    return batteryLevelAndState;
}

- (NSString *)provideNetworkAccessData {
    NSString *networkAccessData = nil;
    
    if (networkDataModel) {
        networkAccessData = networkDataModel.provideANetworkAccess;
    }
    else {
        // If an attemp to create the
        if (unableToEstableConnection) {
            networkAccessData = @"Unable to establish network connection";
        }
        else {
            networkAccessData = @"provideANetworkAccess Not Implemented Yet";
        }
    }
    
    return networkAccessData;
}

- (id)init {
    if (self = [super init]) {
        batteryDataModel = [[PCIBatteryDataModel alloc] init];
        gpsDataModel = [[PCIGpsDataModel alloc] init];
        networkDataModel = [[PCINetworkingDataModel alloc] init];
        // TODO : add error handling for failure of any of the child initialization.
        // This includes handling memory allocation errors, device errors and
        // networking errors. Catch all lower level exceptions here
        // return nil if error is uncorrectible.
        if (!networkDataModel) {
            //  Don't report errors at this point, report errors when the user clicks the button.
            unableToEstableConnection = YES;
        }
        // If none of the data models can be constructed then this object has no meaning.
        // If there are more than the 3 data models create a table of data models and loop
        // through all of them to check if any of the data models are created.
        if ((!batteryDataModel) && (!gpsDataModel) && (!networkDataModel)) {
            return  nil;
        }
    }
    
    return  self;
}

@end
