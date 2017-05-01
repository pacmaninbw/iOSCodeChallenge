//
//  PCINetworkingDataModel.h
//  PCIDataModelLibrary
//
//  Created by Paul Chernick on 4/17/17.

//  Provides an internet connection interface that retrieves the 15 minute delayed price of American Express.

#import <Foundation/Foundation.h>

@interface PCINetworkingDataModel : NSObject<NSURLSessionDataDelegate>

- (id)init;
- (NSString*)provideANetworkAccess;

@end
