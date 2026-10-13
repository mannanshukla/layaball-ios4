#import "LBLaya.h"
@interface LBMeterView : UIView { double score; NSArray *levels; NSDictionary *probs; }
- (void)setScore:(double)s levels:(NSArray *)l probs:(NSDictionary *)p;
@end
@interface LBVibeViewController : LBShakeViewController <UITextViewDelegate> { UITextView *draft; LBMeterView *meter; UILabel *verdict; UILabel *extra; BOOL busy; }
@end
