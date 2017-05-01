//
//  AppDelegate.h
//  DevAndNetInfo2
//
//  Created by Paul Chernick on 4/18/17.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PCI7DataModelLibrary/PCI7DataModelLibrary/PCI7DataModelLibrary.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong) UITabBarController *tabBarController;

// Create the library as a property so that consumer objects can use a getter to receive a pointer to it.
// Prevent objects that use the library from changing it.
@property (readonly, strong) PCI7DataModelLibrary *dataModelLibrary;

- (void)saveContext;


@end

