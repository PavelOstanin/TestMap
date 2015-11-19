//
//  POCustomCalloutView.h
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 19/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@class POCustomCalloutView;

@protocol POCustomCalloutDelegate <NSObject>

- (void)clickSegueButton:(POCustomCalloutView *)view;

@end


@interface POCustomCalloutView : UIView

@property (weak, nonatomic) id<POCustomCalloutDelegate> delegate;
+(POCustomCalloutView*)addCalloutViewWithLocation:(Location*)location;

@end
