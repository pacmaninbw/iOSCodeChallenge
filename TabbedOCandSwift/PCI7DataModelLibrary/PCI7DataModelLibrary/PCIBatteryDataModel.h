//
//  PCIBatteryDataModel.h
//  PCIDataModelLibrary
//
//

// Provides public interfaces to get the battery level and battery state from the device.


#import <Foundation/Foundation.h>

@interface PCIBatteryDataModel : NSObject

- (id)init;
- (NSString *)provideBatteryLevelAndState;
- (NSString *)provideBatteryLevel;
- (NSString *)provideBatteryState;

@end
