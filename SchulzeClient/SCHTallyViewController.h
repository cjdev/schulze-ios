//
//  SCHTallyViewController.h
//  SchulzeClient
//
//  Created by Team NaN on 5/7/14.
//  Copyright (c) 2014 Commission Junction. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHTallyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id electionName;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
