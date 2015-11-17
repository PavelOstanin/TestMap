//
//  Location.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 17/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Location : NSManagedObject

@property (nullable, nonatomic, retain) id location;
@property (nullable, nonatomic, retain) NSString *name;

@end

