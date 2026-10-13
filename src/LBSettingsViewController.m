#import "LBSettingsViewController.h"
#import "LBLaya.h"
@implementation LBSettingsViewController
- (id)init { if ((self = [super initWithStyle:UITableViewStyleGrouped])) { self.title = @"Settings"; self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)] autorelease]; } return self; }
- (void)dealloc { [keyField release]; [super dealloc]; }
- (void)viewDidLoad {
    [super viewDidLoad];
    keyField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 260, 30)];
    keyField.placeholder = @"or_..."; keyField.text = [LBLaya apiKey]; keyField.secureTextEntry = YES; keyField.font = [UIFont systemFontOfSize:15];
    keyField.autocorrectionType = UITextAutocorrectionTypeNo; keyField.autocapitalizationType = UITextAutocapitalizationTypeNone; keyField.returnKeyType = UIReturnKeyDone; keyField.delegate = self;
    keyField.clearButtonMode = UITextFieldViewModeWhileEditing; keyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
}
- (void)save { [LBLaya setApiKey:[keyField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]; }
- (void)done { [self save]; [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)textFieldShouldReturn:(UITextField *)tf { [tf resignFirstResponder]; return YES; }
- (void)textFieldDidEndEditing:(UITextField *)tf { [self save]; }
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv { return 2; }
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s { return 1; }
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)s { return s == 0 ? @"OpenRelay API Key" : @"About"; }
- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)s { return s == 0 ? @"Every shake is one call to openrelay/laya, a decision model. It costs about a thousandth of a cent." : @"Laya Ball for iOS 4. Shake the iPod."; }
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    UITableViewCell *c = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
    c.selectionStyle = UITableViewCellSelectionStyleNone;
    if (ip.section == 0) { keyField.frame = CGRectMake(10, 7, c.contentView.bounds.size.width - 20, 30); keyField.autoresizingMask = UIViewAutoresizingFlexibleWidth; [c.contentView addSubview:keyField]; }
    else { c.textLabel.text = @"Laya Ball"; c.detailTextLabel.text = @"1.0"; }
    return c;
}
@end
