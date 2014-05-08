//
//  SCHLoginViewController.m
//  SchulzeClient
//
//  Created by Team NaN on 5/2/14.
//  Copyright (c) 2014 Commission Junction. All rights reserved.
//

#import "SCHLoginViewController.h"

@interface SCHLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *serverTextField;
@property (weak, nonatomic) IBOutlet UITextField *voterTextField;

@end

@implementation SCHLoginViewController

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
    self.serverTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Server"];
    self.voterTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Voter"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonClick:(id)sender {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [self saveLoginValues];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString* ) indentifier sender:(id)sender {
    return [self loginDataIsValid];
}

-(BOOL)loginDataIsValid {
    NSString * server = [[self serverTextField] text];
    NSString * voter = [[self voterTextField] text];
    
    if ([server length] == 0) {
        return NO;
    }
    if ([voter length] == 0) {
        return NO;
    }
    
    NSDictionary * voterDict = [NSDictionary dictionaryWithObjectsAndKeys:voter, @"name", nil];
    //NSLog(@"%@", voterDict);
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:voterDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[server stringByAppendingString:@"/voters"]]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:5];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    
    NSHTTPURLResponse * response = nil;
    NSError * errors = nil;
    NSData * result = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response error:&errors];
    
    if (errors != nil) {
        NSLog(@"%@", [errors localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Cannot reach server."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (response.statusCode != 200) {
        NSLog(@"RESULT %@", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Server rejected voter."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}

-(void)saveLoginValues {
    [[NSUserDefaults standardUserDefaults] setObject:self.serverTextField.text forKey:@"Server"];
    [[NSUserDefaults standardUserDefaults] setObject:self.voterTextField.text forKey:@"Voter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
