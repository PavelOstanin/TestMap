//
//  POBookmarksTableViewController.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 12/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POBookmarksTableViewController : UITableViewController

@property (nonatomic, copy) void (^blockGetIndexBookmark)(NSInteger index);
@property (strong, nonatomic) NSMutableArray *bookmarksList;

@end
