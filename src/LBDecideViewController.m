#import "LBDecideViewController.h"

@implementation LBBarsView
- (id)initWithFrame:(CGRect)f { if ((self = [super initWithFrame:f])) { self.backgroundColor = [UIColor clearColor]; self.opaque = NO; } return self; }
- (void)dealloc { [labels release]; [probs release]; [winner release]; [super dealloc]; }
- (void)setLabels:(NSArray *)l probs:(NSDictionary *)p winner:(NSString *)w { [labels release]; labels = [l retain]; [probs release]; probs = [p retain]; [winner release]; winner = [w copy]; [self setNeedsDisplay]; }
- (void)drawRect:(CGRect)rect {
    if (!labels) return;
    CGFloat y = 4, rowH = 26, w = self.bounds.size.width;
    UIFont *f = [UIFont boldSystemFontOfSize:13];
    for (NSString *l in labels) {
        double p = [[probs objectForKey:l] doubleValue];
        BOOL win = [l isEqualToString:winner];
        CGRect track = CGRectMake(0, y + 4, w - 48, 16);
        [[UIColor colorWithWhite:0.82 alpha:1] setFill]; [[UIBezierPath bezierPathWithRoundedRect:track cornerRadius:8] fill];
        CGRect fill = CGRectMake(0, y + 4, MAX(16, (w - 48) * p), 16);
        [(win ? [LBStyle lime] : [UIColor colorWithWhite:0.6 alpha:1]) setFill]; [[UIBezierPath bezierPathWithRoundedRect:fill cornerRadius:8] fill];
        [(win ? [UIColor blackColor] : [UIColor colorWithWhite:0.25 alpha:1]) set];
        [l drawInRect:CGRectMake(8, y + 5, w - 60, 16) withFont:f lineBreakMode:UILineBreakModeTailTruncation];
        [[NSString stringWithFormat:@"%d%%", (int)(p*100 + 0.5)] drawInRect:CGRectMake(w - 44, y + 5, 44, 16) withFont:f lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
        y += rowH;
    }
}
@end

@implementation LBDecideViewController
- (id)init { if ((self = [super initWithNibName:nil bundle:nil])) { self.title = @"Decide"; self.tabBarItem.title = @"Decide"; options = [[NSMutableArray alloc] initWithArray:([[NSUserDefaults standardUserDefaults] arrayForKey:@"lb_options"] ?: [NSArray arrayWithObjects:@"Pizza", @"Sushi", @"Cook at home", nil])]; } return self; }
- (void)dealloc { [table release]; [options release]; [context release]; [bars release]; [verdict release]; [super dealloc]; }
- (void)loadView {
    UIView *root = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    root.backgroundColor = [LBStyle paper]; self.view = root; [root release];
    CGRect b = root.bounds;
    context = [[UITextField alloc] initWithFrame:CGRectMake(12, 10, b.size.width - 24, 32)];
    context.borderStyle = UITextBorderStyleRoundedRect; context.placeholder = @"Situation (optional): rainy, broke, tired"; context.font = [UIFont systemFontOfSize:14];
    context.returnKeyType = UIReturnKeyDone; context.delegate = self; context.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    context.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"lb_context"];
    [root addSubview:context];
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, b.size.width, 144) style:UITableViewStylePlain];
    table.dataSource = self; table.delegate = self; table.rowHeight = 36; table.backgroundColor = [UIColor whiteColor];
    [root addSubview:table];
    verdict = [[UILabel alloc] initWithFrame:CGRectMake(12, 198, b.size.width - 24, 30)];
    verdict.font = [UIFont boldSystemFontOfSize:20]; verdict.textAlignment = UITextAlignmentCenter; verdict.backgroundColor = [UIColor clearColor]; verdict.textColor = [LBStyle olive];
    verdict.text = @"Shake to decide"; verdict.adjustsFontSizeToFitWidth = YES;
    [root addSubview:verdict];
    bars = [[LBBarsView alloc] initWithFrame:CGRectMake(12, 232, b.size.width - 24, b.size.height - 236)];
    [root addSubview:bars];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Shake" style:UIBarButtonItemStyleBordered target:self action:@selector(shaken)] autorelease];
}
- (void)setEditing:(BOOL)e animated:(BOOL)a { [super setEditing:e animated:a]; [table setEditing:e animated:a]; [table reloadData]; }
- (void)persist { [[NSUserDefaults standardUserDefaults] setObject:options forKey:@"lb_options"]; [[NSUserDefaults standardUserDefaults] setObject:context.text ?: @"" forKey:@"lb_context"]; [[NSUserDefaults standardUserDefaults] synchronize]; }
- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    if (tf != context) {   // option row editor
        NSString *t = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (tf.tag >= 100 && tf.tag - 100 < (NSInteger)[options count]) { if ([t length]) [options replaceObjectAtIndex:tf.tag-100 withObject:t]; }
        else if ([t length]) { [options addObject:t]; tf.text = @""; [table reloadData]; }
        [self persist];
    }
    [tf resignFirstResponder]; return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)tf { if (tf == context) [self persist]; else [self textFieldShouldReturn:tf]; }
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s { return [options count] + 1; }
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    c.selectionStyle = UITableViewCellSelectionStyleNone;
    UITextField *f = [[[UITextField alloc] initWithFrame:CGRectMake(12, 4, c.contentView.bounds.size.width - 24, 28)] autorelease];
    f.autoresizingMask = UIViewAutoresizingFlexibleWidth; f.font = [UIFont systemFontOfSize:16]; f.delegate = self; f.returnKeyType = UIReturnKeyDone;
    f.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; f.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    if (ip.row < (NSInteger)[options count]) { f.text = [options objectAtIndex:ip.row]; f.tag = 100 + ip.row; }
    else { f.placeholder = @"Add an option"; f.tag = 999; }
    [c.contentView addSubview:f];
    return c;
}
- (BOOL)tableView:(UITableView *)tv canEditRowAtIndexPath:(NSIndexPath *)ip { return ip.row < (NSInteger)[options count]; }
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)st forRowAtIndexPath:(NSIndexPath *)ip {
    if (st == UITableViewCellEditingStyleDelete && ip.row < (NSInteger)[options count]) { [options removeObjectAtIndex:ip.row]; [self persist]; [tv reloadData]; }
}
- (void)shaken {
    if (busy) return;
    [self.view endEditing:YES]; [self persist];
    if ([options count] < 2) { verdict.text = @"Add at least two options"; return; }
    busy = YES; verdict.text = @"Thinking...";
    NSArray *labels = [NSArray arrayWithArray:options];
    NSString *ctx = [context.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *state = [NSString stringWithFormat:@"The user must choose one of these options: %@.%@", [labels componentsJoinedByString:@", "], [ctx length] ? [NSString stringWithFormat:@" Situation: %@", ctx] : @""];
    __block NSDictionary *ans = nil; __block NSString *err = nil;
    [self runOffMain:^{ NSString *e = nil; ans = [[LBLaya choose:@"Which option is the best choice for the user right now?" among:labels state:state error:&e] retain]; err = [e copy]; } then:^{
        busy = NO;
        if (!ans) { verdict.text = err ?: @"No answer"; [err release]; return; }
        NSString *w = [ans objectForKey:@"choice"];
        verdict.text = w;
        [bars setLabels:labels probs:[ans objectForKey:@"probabilities"] winner:w];
        [ans release]; [err release];
    }];
}
@end
