#import <UIKit/UIKit.h>
// Thin client for OpenRelay's Decisions API (model openrelay/laya). Synchronous; call off the main thread.
@interface LBLaya : NSObject
+ (NSString *)apiKey; + (void)setApiKey:(NSString *)k;
// questions: {id: {type, instructions, criteria}}. Returns the "answers" dictionary or nil with *err set.
+ (NSDictionary *)decide:(id)state questions:(NSDictionary *)questions error:(NSString **)err;
// convenience
+ (NSDictionary *)yesNo:(NSString *)question error:(NSString **)err;                          // -> {noul, confidence}
+ (NSDictionary *)choose:(NSString *)instructions among:(NSArray *)labels state:(NSString *)state error:(NSString **)err;  // -> {choice, probabilities, confidence}
+ (NSDictionary *)score:(NSString *)instructions levels:(NSArray *)levels state:(NSString *)state error:(NSString **)err;  // -> {score, probabilities, confidence}
@end

// Shake plumbing shared by every screen: subclass, override -shaken.
@interface LBShakeViewController : UIViewController
- (void)shaken;
- (void)runOffMain:(void (^)(void))work then:(void (^)(void))done;   // background work, main-thread completion
@end

// drawing helpers
@interface LBStyle : NSObject
+ (UIColor *)lime; + (UIColor *)olive; + (UIColor *)paper;
+ (UIImage *)buttonImage:(UIColor *)top bottom:(UIColor *)bottom border:(UIColor *)border;
@end
