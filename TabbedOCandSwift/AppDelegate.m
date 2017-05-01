//
//  AppDelegate.m
//  TabbedOCandSwift
//
//  Created by Paul Chernick on 4/18/17.
//

#import "AppDelegate.h"
#import "ObjectiveCViewController.h"
#import "TabbedOCandSwift-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize dataModelLibrary = _dataModelLibrary;

#pragma mark - The following functions were added or modified to implement a tabbed application implemented in swift and objective-c

- (BOOL)dataModelLibraryInitialize {
    BOOL libraryCreatedAndInitialized = YES;

    if (!self.dataModelLibrary || !_dataModelLibrary) {
        PCI7DataModelLibrary *tempLibPtr = [[PCI7DataModelLibrary alloc] init];
        if (!tempLibPtr) {
            // If the library can't be allocated or initialized none of the buttons will work in any view controller.
            NSLog(@"application didFinishLaunchingWithOptions: Unable to alloc or init the PCI7DataModelLibrary object");
            return NO;
        }
        _dataModelLibrary = tempLibPtr;
    }

    return libraryCreatedAndInitialized;
}

- (BOOL)createTabBarAndViewControllers {
    ObjectivCViewController* objectiveVC = nil;
    SwiftViewController* swiftVC = nil;
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    objectiveVC = [[ObjectivCViewController alloc] init];
    if (objectiveVC) {
        [objectiveVC setTitle:@"Objective-C"];
    }
    else {
        NSLog(@"In AppDelegate.createTabBarAndViewControllers: Unable to create objectiveVC");
        return NO;
    }
    
    swiftVC = [[SwiftViewController alloc] init];
    if (swiftVC) {
        [swiftVC setTitle:@"Swift"];
    }
    else {
        NSLog(@"In AppDelegate.createTabBarAndViewControllers: Unable to create swiftVC");
        return NO;
    }
    
    NSArray* controllers = [NSArray arrayWithObjects:objectiveVC, swiftVC,  nil];
    self.tabBarController.viewControllers = controllers;
    self.tabBarController.selectedIndex = 0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Create the library object if it hasn't already been created
    // There should only be one copy of the library.
    //      - Reduce memory usage, devices have limitied memory, no app should use more than it needs and only one library is necessary.
    //      - There is a runtime cost to starting up the library, if it is done once early in the life of the application
    //          the user will notice it less than when a viewcontroller starts or resumes.
    //      - There is asyncronous code that runs in the library in a serial manner to reduce possible interactions and prevent deadlock only one library should exist.
    if (![self dataModelLibraryInitialize]) {
        // If the library can't be allocated or initialized none of the buttons will work in any view controller.
        NSLog(@"application didFinishLaunchingWithOptions: Unable to alloc or init the PCI7DataModelLibrary object");
        return NO;
    }
    if (![self createTabBarAndViewControllers]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - The rest of this file is generated when creating a single Objective-C non-tabed application in Xcode

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DevAndNetInfo2"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
