//
//  POCoreDataManager.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 09/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface POCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(instancetype)shared;

-(NSManagedObjectContext *)managedObjectContext;
-(NSMutableArray *)fetchRequestWithEntityName:(NSString *)entityName;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
