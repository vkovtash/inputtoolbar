/*
 *  UIInputToolbarViewController.m
 *  
 *  Created by Brandon Hamilton on 2011/05/03.
 *  Copyright 2011 Brandon Hamilton.
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "UIInputToolbarViewController.h"

#define handle_tap(view, delegate, selector) do {\
view.userInteractionEnabled = YES;\
[view addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:delegate action:selector]];\
} while(0)

#define kDefaultToolbarHeight 40

@interface UIInputToolbarViewController()
@property (strong, nonatomic) UIButton *leftInputButton;
@property (strong, nonatomic) UIButton *rightInputButton;
@property (strong, nonatomic) UIColor *originalColor;
@end

@implementation UIInputToolbarViewController

@synthesize inputToolbar;

#pragma mark - View lifecycle

- (void) viewDidLoad{
    [super viewDidLoad];
    
    keyboardIsVisible = NO;
    
    self.originalColor = [[UIApplication sharedApplication].delegate window].tintColor;
    
    /*Toolbar right View*/
    self.rightInputButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.rightInputButton.frame = CGRectMake(0, 0, 44, 38);
    self.rightInputButton.backgroundColor = [UIColor redColor];
    [self.rightInputButton addTarget:self action:@selector(rigthInputButtonPressed)
                    forControlEvents:UIControlEventTouchUpInside];
    
    /*Toolbar left View*/
    self.leftInputButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.leftInputButton.frame = CGRectMake(0, 0, 44, 38);
    self.leftInputButton.backgroundColor = [UIColor greenColor];
    [self.leftInputButton addTarget:self action:@selector(leftInputButtonPressed)
                    forControlEvents:UIControlEventTouchUpInside];
    
    /* Create toolbar */
    self.inputToolbar = [[ZIMInputToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - kDefaultToolbarHeight, self.view.bounds.size.width, kDefaultToolbarHeight)
                                                        label:@"Send"];
    
    self.inputToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.inputToolbar];
    inputToolbar.inputDelegate = self;
    inputToolbar.textView.placeholder = @"Placeholder";
    inputToolbar.textView.maximumNumberOfLines = 4;
    handle_tap(self.view, self, @selector(dismissToolbar:));
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	/* No longer listen for keyboard */
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                          duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.inputToolbar.textView.maximumNumberOfLines = 4;
    }
    else{
        self.inputToolbar.textView.maximumNumberOfLines = 2;
    }
}

- (IBAction)rightButtonSwitchChanged:(UISwitch *)sender {
    self.inputToolbar.isPlusButtonVisible = sender.on;
}

- (IBAction)rightInputViewSwitchChanged:(UISwitch *)sender {
    if (sender.on) {
        inputToolbar.textView.rightView = self.rightInputButton;
    }
    else {
        inputToolbar.textView.rightView = nil;
    }
}

- (IBAction)leftInputViewSwitchPressed:(UISwitch *)sender {
    if (sender.on) {
        inputToolbar.textView.leftView = self.leftInputButton;
        inputToolbar.textView.leftViewVerticalAlign = ZIMExpandingTextViewVerticalAlignTop;
    }
    else {
        inputToolbar.textView.leftView = nil;
    }
}

- (IBAction)tintColorControllChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [[UIApplication sharedApplication].delegate window].tintColor = self.originalColor;
            break;
            
        case 1:
            [[UIApplication sharedApplication].delegate window].tintColor = [UIColor redColor];
            break;
            
        case 2:
            [[UIApplication sharedApplication].delegate window].tintColor = [UIColor purpleColor];
            break;
            
        default:
            break;
    }
}


- (void) rigthInputButtonPressed {
    NSLog(@"rigthInputButtonPressed");
}

- (void) leftInputButtonPressed {
    NSLog(@"leftInputButtonPressed");
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat newHeight = self.view.frame.size.height - [self.view convertRect:keyboardRect fromView:nil].origin.y;
    CGRect frame = self.inputToolbar.frame;
    frame.origin.y = self.view.bounds.size.height - newHeight - frame.size.height;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.inputToolbar.frame = frame;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark tap recogonizer

- (void)dismissToolbar: (UITapGestureRecognizer *)recogonizer{
    [self.inputToolbar.textView resignFirstResponder];
}

- (void)inputButtonPressed:(ZIMInputToolbar *) toolbar {
    /* Called when toolbar button is pressed */
    NSLog(@"Pressed button with text: '%@'", toolbar.textView.text);
    toolbar.textView.text = @"";
    [self.inputToolbar.textView resignFirstResponder];
}

- (void) plusButtonPressed:(ZIMInputToolbar *) toolbar {
    NSLog(@"Plus button pressed");
}
@end
