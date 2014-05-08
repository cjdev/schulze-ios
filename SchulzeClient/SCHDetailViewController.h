//
//  SCHDetailViewController.h
//  SchulzeClient
//
//  Created by Team NaN on 5/2/14.
//  Copyright (c) 2014 Commission Junction. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) id electionName;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
