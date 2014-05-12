#import <UIKit/UIKit.h>

@interface SCHTallyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id electionName;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
