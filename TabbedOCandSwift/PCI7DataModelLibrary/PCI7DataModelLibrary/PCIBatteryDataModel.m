//
//  PCIBatteryDataModel.m
//  PCIDataModelLibrary
//

// Provides public interfaces to get the battery level and battery state from the device.

#import <UIKit/UIKit.h>
#import "PCIBatteryDataModel.h"

@implementation PCIBatteryDataModel
{
    UIDevice *thisDevice;
}

- (id)init {
    if (self = [super init]) {
        // To optimize performance of the calls to getBatteryLevelAndState, getBatterLevel, getBatteryState
        // get a pointer to the device only once and enable battery monitoring only once. Battery monitoring
        // must be enabled to get the information from the device or the simulator. The simulator does not
        // fully support modeling the battery.
        thisDevice = [UIDevice currentDevice];
        [thisDevice setBatteryMonitoringEnabled:YES];
    }
    return  self;
}

// each of the following functions could return [NSString stringWithFormat: FORMATSTRING, arguments], but
// the following functions/methods implementations allow for editing and improvements.
// getBatteryLevelAndState could have performed all of the operations, but I try to follow the Single
// Responsibility Principle as well as the KISS principle.

- (NSString *)provideBatteryLevelAndState {
    NSString *batteryStateAndLevel = nil;
    
    batteryStateAndLevel = [NSString stringWithFormat:@"%@\n%@", self.provideBatteryState, self.provideBatteryLevel];
    
    return batteryStateAndLevel;
}

- (NSString *)provideBatteryLevel {
    NSString *batteryLevelString = nil;
    
    batteryLevelString = [NSString stringWithFormat:@"Battery Level = %0.2f", [thisDevice batteryLevel]];
    
    return batteryLevelString;
}

- (NSString *)provideBatteryState
{
    NSString *batterStateString = nil;
    NSArray *batteryStateArray = @[
                                   @"Battery state is unknown",
                                   @"Battery is not plugged into a charging source",
                                   @"Battery is charging",
                                   @"Battery state is full"
                                   ];
    
    batterStateString = [NSString stringWithFormat:@"Battery state = %@", batteryStateArray[thisDevice.batteryState]];
    
    return batterStateString;
    
}

@end
