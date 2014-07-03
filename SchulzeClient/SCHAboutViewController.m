//
//  SCHAboutViewController.m
//  SchulzeClient
//
//  Created by Team NaN on 7/3/14.
//  Copyright (c) 2014 Commission Junction. All rights reserved.
//

#import "SCHAboutViewController.h"
#import "CJAFInternals.h"

@interface SCHAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionField;
@property (weak, nonatomic) IBOutlet UILabel *installTimeField;
@end

@implementation SCHAboutViewController

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self versionField].text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    double whenInstalledMillis = [[[CJInternals identify] objectForKey:@"when-installed"] doubleValue];
    NSDate * whenInstalledDate = [NSDate dateWithTimeIntervalSince1970:(whenInstalledMillis / 1000)];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [self installTimeField].text = [formatter stringFromDate:whenInstalledDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
