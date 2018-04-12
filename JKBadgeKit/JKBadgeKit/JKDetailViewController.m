//
//  RJDetailViewController.m
//  RJBadgeKit_Example
//
//  Created by zhangjie on 2018/3/27.
//  Copyright © 2017 RylanJIN. All rights reserved.
//

#import "JKDetailViewController.h"
#import "JKBadgeKit.h"

NSString * const RJItemPath1 = @"root.bb.page.item1";
NSString * const RJItemPath2 = @"root.bb.page.item2";

@interface JKDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *item1;
@property (weak, nonatomic) IBOutlet UIButton *item2;

@end

@implementation JKDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [JKBadgeController setBadgeForKeyPath:RJItemPath1];
    [JKBadgeController setBadgeForKeyPath:RJItemPath2];
    
    [self.badgeController observePath:RJItemPath1 badgeView:self.item1 block:nil];
    [self.badgeController observePath:RJItemPath2 badgeView:self.item2 block:nil];
    
    [self.item1 setBadgeImage:[UIImage imageNamed:@"badgeNew"]];
}

- (IBAction)clickItem1:(UIButton *)sender
{
    BOOL needShow = [JKBadgeController statusForKeyPath:RJItemPath1];
    if (needShow) {
        [JKBadgeController clearBadgeForKeyPath:RJItemPath1];
    } else {
        [JKBadgeController setBadgeForKeyPath:RJItemPath1];
    }
}

- (IBAction)clickItem2:(UIButton *)sender
{
    BOOL needShow = [JKBadgeController statusForKeyPath:RJItemPath2];
    if (needShow) {
        [JKBadgeController clearBadgeForKeyPath:RJItemPath2];
    } else {
        [JKBadgeController setBadgeForKeyPath:RJItemPath2];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
