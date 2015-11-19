//
//  POBookmarkTableViewCell.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 16/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POBookmarkTableViewCell.h"
#import <MapKit/MapKit.h>

@interface POBookmarkTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation POBookmarkTableViewCell

- (void)setNameWithLocation:(Location*)location{
    if ([location.name length]) {
        self.name.text = location.name;
    }
    else {
        self.name.text = [NSString stringWithFormat:@"%f %f",((CLLocation*)((Location*)location).location).coordinate.latitude, ((CLLocation*)((Location*)location).location).coordinate.longitude];
    }
}

@end
