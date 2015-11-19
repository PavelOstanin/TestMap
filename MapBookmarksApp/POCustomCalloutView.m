//
//  POCustomCalloutView.m
//  MapBookmarksApp
//
//  Created by Pavel Ostanin on 19/11/2015.
//  Copyright © 2015 PavelOstanin. All rights reserved.
//

#import "POCustomCalloutView.h"
#import <MapKit/MapKit.h>

@interface POCustomCalloutView ()

@property (weak, nonatomic) IBOutlet UILabel *name;

@end

@implementation POCustomCalloutView

+ (POCustomCalloutView*)addCalloutViewWithLocation:(Location*)location{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"POCustomCalloutView" owner:self options:nil];
    POCustomCalloutView *mainView = [[POCustomCalloutView alloc] init];
    mainView = [views objectAtIndex:0];
    mainView.name.text = location.name;
    if ([location.name length] > 0) {
        mainView.name.text = location.name;
    }
    else {
        mainView.name.text = [NSString stringWithFormat:@"%f %f", ((CLLocation*)location.location).coordinate.latitude,((CLLocation*)location.location).coordinate.longitude];
    }
    return mainView;
}
- (IBAction)segueToDetailInfo:(id)sender {
    [self.delegate clickSegueButton:self];
}

@end
