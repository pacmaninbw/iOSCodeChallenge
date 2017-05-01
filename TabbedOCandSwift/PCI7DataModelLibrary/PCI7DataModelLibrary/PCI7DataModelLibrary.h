//
//  PCI7DataModelLibrary.h
//  PCI7DataModelLibrary
//
//  Created by Paul Chernick on 4/18/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PCI7DataModelLibrary : NSObject

- (id) init;
- (BOOL) IsGpsAvailable;
- (NSString *) provideGPSLocationData;
- (NSString *) provideBatteryLevelAndState;
- (NSString *) provideNetworkAccessData;
- (UIAlertController*) provideGPSAlerters;

@end
