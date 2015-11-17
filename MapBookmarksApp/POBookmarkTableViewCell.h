//
//  POBookmarkTableViewCell.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 16/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface POBookmarkTableViewCell : UITableViewCell

- (void)setNameWithLocation:(Location*)location;

@end
