//
//  AppDelegate.h
//  ORC-testProject
//
//  Created by 李翔 on 17/2/14.
//  Copyright © 2017年 李翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property ( strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property ( strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

