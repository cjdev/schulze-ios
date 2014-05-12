#import <UIKit/UIKit.h>

@interface SCHDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) id electionName;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
