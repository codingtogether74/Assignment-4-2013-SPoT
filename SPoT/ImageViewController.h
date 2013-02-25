//
//  ImageViewController.h
//  Shutterbug
//
//  Created by Tatiana Kornilova on 2/22/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
#import "RotatableViewController.h"

@interface ImageViewController : RotatableViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic,strong) NSURL *imageURL;

@end
