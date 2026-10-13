#import "LBLaya.h"
@interface LBRPSViewController : LBShakeViewController {
    UISegmentedControl *hand; UILabel *big; UILabel *result; UILabel *score; UILabel *hint;
    NSMutableArray *history; NSInteger wins, losses, ties; BOOL busy;
}
@end
