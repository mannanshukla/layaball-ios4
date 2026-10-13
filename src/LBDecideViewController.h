#import "LBLaya.h"
@interface LBBarsView : UIView { NSArray *labels; NSDictionary *probs; NSString *winner; }
- (void)setLabels:(NSArray *)l probs:(NSDictionary *)p winner:(NSString *)w;
@end
@interface LBDecideViewController : LBShakeViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    UITableView *table; NSMutableArray *options; UITextField *context; LBBarsView *bars; UILabel *verdict; BOOL busy;
}
@end
