//
//  JKViewController.h
//  RJBadgeKit
//
//  Created by zhangjie on 2018/3/27.
//  Copyright (c) 2017 RylanJIN. All rights reserved.
//

#import "JKViewController.h"
#import "JKBadgeKit.h"

NSString * const DEMO_PARENT_PATH = @"root.p365";
NSString * const DEMO_CHILD_PATH1 = @"root.p365.test1";
NSString * const DEMO_CHILD_PATH2 = @"root.p365.test2";

@interface JKViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel     *countLabel;
@property (weak, nonatomic) IBOutlet UILabel     *pathLabel;
@property (weak, nonatomic) IBOutlet UITextField *countField;
//p365
@property (weak, nonatomic) IBOutlet UIButton    *parentButton;
//test1
@property (weak, nonatomic) IBOutlet UIButton    *childButton1;
//test2 按钮
@property (weak, nonatomic) IBOutlet UIButton    *childButton2;

@end

@implementation JKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.countField setDelegate:self];
    [self.countField setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.pathLabel setText:DEMO_CHILD_PATH1];
 
    // self.parentButton.badgeOffset = CGPointMake(-50, 0);
    
    // observe parent button 'root.p365'
    [self.badgeController observePath:DEMO_PARENT_PATH
                            badgeView:self.parentButton
                                block:^(id observer, NSDictionary *info) {
        NSLog(@"root.p365 => %@", info);
    }];
    // observe child button 'root.p365.test2'
    [self.badgeController observePath:DEMO_CHILD_PATH2 badgeView:self.childButton2 block:nil];
    // observe child button 'root.p365.test1'
    [self.badgeController observePath:DEMO_CHILD_PATH1
                            badgeView:self.childButton1
                                block:^(JKViewController *observer, NSDictionary *info) {
        NSUInteger count = [info[JKBadgeCountKey] unsignedIntegerValue];
        [observer.countLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)count]];
    }];
    
    NSUInteger count = [JKBadgeController countForKeyPath:DEMO_CHILD_PATH1];
    [self.countLabel setText:[@(count) stringValue]];
    
   
    
  
    /**
     DEBUG FOR PARENT BADGE COUNTING
     */
    [JKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH2 count:2];
}

#pragma mark - Click Button
- (IBAction)setBadgePathWithCount:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (!self.countField.text) return;
    
    [JKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1
                                    count:[self.countField.text integerValue]];
}

- (IBAction)setBadgePath:(UIButton *)sender {
    [JKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1];
}

- (IBAction)clearBadgePath:(UIButton *)sender {
    [JKBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH1];
}

- (IBAction)clickChildButton1:(UIButton *)sender
{
    BOOL needShow = [JKBadgeController statusForKeyPath:DEMO_CHILD_PATH1];
    if (needShow) {
        [JKBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH1];
    } else {
        [JKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH1];
    }
}

- (IBAction)clickChildButton2:(UIButton *)sender
{
    BOOL needShow = [JKBadgeController statusForKeyPath:DEMO_CHILD_PATH2];
    if (needShow) {
        [JKBadgeController clearBadgeForKeyPath:DEMO_CHILD_PATH2];
    } else {
        [JKBadgeController setBadgeForKeyPath:DEMO_CHILD_PATH2 count:2];
    }
}

- (IBAction)clickParentButton:(UIButton *)sender {
    [JKBadgeController clearBadgeForKeyPath:DEMO_PARENT_PATH forced:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString *)number
{
    BOOL res = YES;
    int i    = 0;
    
    NSCharacterSet *tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) { res = NO; break; }
        
        i++;
    }
    return res;
}

@end
