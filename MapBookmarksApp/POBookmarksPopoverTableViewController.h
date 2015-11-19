//
//  POBookmarksTableViewController.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 12/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^blockGetIndexBookmark)(NSInteger index);

@interface POBookmarksPopoverTableViewController : UITableViewController

@property (copy, nonatomic) blockGetIndexBookmark block;
@property (strong, nonatomic) NSMutableArray *bookmarksList;

@end
