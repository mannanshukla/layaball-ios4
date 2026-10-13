#import "LBLaya.h"
@interface LBBallView : UIView { NSString *answer; CGFloat window; }   // window: 0 = blank, 1 = answer fully visible
@property (nonatomic, copy) NSString *answer;
@property (nonatomic, assign) CGFloat window;
@end
@interface LBEightBallViewController : LBShakeViewController <UITextFieldDelegate> {
    UITextField *question; LBBallView *ball; UILabel *detail; UIActivityIndicatorView *spinner; BOOL busy;
}
@end
