#import "LBRPSViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation LBRPSViewController
- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"RPS"; self.tabBarItem.title = @"RPS";
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        history = [[NSMutableArray alloc] initWithArray:([d arrayForKey:@"lb_rps_history"] ?: [NSArray array])];
        wins = [d integerForKey:@"lb_rps_w"]; losses = [d integerForKey:@"lb_rps_l"]; ties = [d integerForKey:@"lb_rps_t"];
    }
    return self;
}
- (void)dealloc { [hand release]; [big release]; [result release]; [score release]; [hint release]; [history release]; [super dealloc]; }
- (void)persist { NSUserDefaults *d = [NSUserDefaults standardUserDefaults]; [d setObject:history forKey:@"lb_rps_history"]; [d setInteger:wins forKey:@"lb_rps_w"]; [d setInteger:losses forKey:@"lb_rps_l"]; [d setInteger:ties forKey:@"lb_rps_t"]; [d synchronize]; }
- (void)loadView {
    UIView *root = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    root.backgroundColor = [LBStyle paper]; self.view = root; [root release];
    CGRect b = root.bounds;
    hint = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, b.size.width - 24, 40)];
    hint.font = [UIFont systemFontOfSize:13]; hint.textColor = [UIColor colorWithWhite:0.4 alpha:1]; hint.textAlignment = UITextAlignmentCenter; hint.numberOfLines = 2; hint.backgroundColor = [UIColor clearColor];
    hint.text = @"Pick your throw, then shake.\nLaya predicts your throw from your history.";
    [root addSubview:hint];
    hand = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Rock", @"Paper", @"Scissors", nil]];
    hand.frame = CGRectMake(12, 62, b.size.width - 24, 44); hand.selectedSegmentIndex = 0; hand.segmentedControlStyle = UISegmentedControlStyleBar; hand.tintColor = [LBStyle olive];
    [root addSubview:hand];
    big = [[UILabel alloc] initWithFrame:CGRectMake(12, 120, b.size.width - 24, 120)];
    big.font = [UIFont boldSystemFontOfSize:96]; big.textAlignment = UITextAlignmentCenter; big.backgroundColor = [UIColor clearColor]; big.text = @"?"; big.textColor = [UIColor colorWithWhite:0.75 alpha:1];
    [root addSubview:big];
    result = [[UILabel alloc] initWithFrame:CGRectMake(12, 240, b.size.width - 24, 84)];
    result.font = [UIFont boldSystemFontOfSize:16]; result.textAlignment = UITextAlignmentCenter; result.numberOfLines = 4; result.backgroundColor = [UIColor clearColor]; result.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    [root addSubview:result];
    score = [[UILabel alloc] initWithFrame:CGRectMake(12, b.size.height - 40, b.size.width - 24, 24)];
    score.font = [UIFont systemFontOfSize:14]; score.textAlignment = UITextAlignmentCenter; score.backgroundColor = [UIColor clearColor]; score.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    [root addSubview:score]; [self updateScore];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(reset)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Shake" style:UIBarButtonItemStyleBordered target:self action:@selector(shaken)] autorelease];
}
- (void)updateScore { score.text = [NSString stringWithFormat:@"You %ld   Laya %ld   Ties %ld   (%lu rounds)", (long)wins, (long)losses, (long)ties, (unsigned long)[history count]]; }
- (void)reset { [history removeAllObjects]; wins = losses = ties = 0; [self persist]; [self updateScore]; big.text = @"?"; result.text = @""; }
- (NSString *)symbol:(NSString *)t { return [t isEqualToString:@"rock"] ? @"✊" : [t isEqualToString:@"paper"] ? @"✋" : @"✌"; }
- (NSString *)counter:(NSString *)t { return [t isEqualToString:@"rock"] ? @"paper" : [t isEqualToString:@"paper"] ? @"scissors" : @"rock"; }
- (void)shaken {
    if (busy) return; busy = YES;
    NSArray *names = [NSArray arrayWithObjects:@"rock", @"paper", @"scissors", nil];
    NSString *mine = [names objectAtIndex:hand.selectedSegmentIndex];
    result.text = @"Laya is reading you..."; big.text = @"?";
    NSString *state = [history count]
        ? [NSString stringWithFormat:@"Rock paper scissors. The human's throws so far, oldest first: %@. Predict the human's next throw from their pattern.", [history componentsJoinedByString:@", "]]
        : @"Rock paper scissors, first round. Humans most often open with rock. Predict the human's first throw.";
    __block NSDictionary *ans = nil; __block NSString *err = nil;
    [self runOffMain:^{ NSString *e = nil; ans = [[LBLaya choose:@"What will the human throw next?" among:names state:state error:&e] retain]; err = [e copy]; } then:^{
        busy = NO;
        NSString *guess = ans ? [ans objectForKey:@"choice"] : [names objectAtIndex:arc4random() % 3];
        NSString *laya = [self counter:guess];
        NSString *outcome;
        if ([laya isEqualToString:mine]) { ties++; outcome = @"Tie"; }
        else if ([[self counter:mine] isEqualToString:laya]) { losses++; outcome = @"Laya wins"; }
        else { wins++; outcome = @"You win"; }
        [history addObject:mine]; if ([history count] > 40) [history removeObjectAtIndex:0];
        [self persist]; [self updateScore];
        big.text = [NSString stringWithFormat:@"%@  %@", [self symbol:mine], [self symbol:laya]];
        big.textColor = [UIColor blackColor];
        double p = ans ? [[[ans objectForKey:@"probabilities"] objectForKey:guess] doubleValue] : 0.33;
        result.text = [NSString stringWithFormat:@"%@.\nLaya guessed %@ (%d%%) and threw %@.%@", outcome, guess, (int)(p*100+0.5), laya, err ? [NSString stringWithFormat:@"\n%@", err] : @""];
        CABasicAnimation *pop = [CABasicAnimation animationWithKeyPath:@"transform.scale"]; pop.fromValue = [NSNumber numberWithFloat:0.6]; pop.toValue = [NSNumber numberWithFloat:1.0]; pop.duration = 0.25;
        [big.layer addAnimation:pop forKey:@"pop"];
        [ans release]; [err release];
    }];
}
@end
