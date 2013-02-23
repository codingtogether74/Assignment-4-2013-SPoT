//
//  ResentsTVC.m
//  SPoT
//
//  Created by Tatiana Kornilova on 2/23/13.
//  Copyright (c) 2013 Tatiana Kornilova. All rights reserved.
//

#import "ResentsTVC.h"
#import "RecentsUserDefaults.h"

@interface ResentsTVC ()

@end

@implementation ResentsTVC


- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.photos = [RecentsUserDefaults retrieveRecentsUserDefaults]; //if put in viewDidLoad, it only get called once after launching app
}



@end
