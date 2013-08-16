/*
 *  UIInputToolbar.m
 *
 *  Created by Vlad Kovtash on 2013/03/26.
 *  Copyright 2013 Vlad Kovtash.
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

/*
 *  This class is based on UIInputToolbar by Brandon Hamilton
 *  https://github.com/brandonhamilton/inputtoolbar
 */

#import "UIInputToolbar.h"

@interface UIInputToolbar()
@property (nonatomic) CGFloat touchBeginY;
@end

@implementation UIInputToolbar

@synthesize textView;
@synthesize inputButton;
@synthesize delegate;

-(void)inputButtonPressed
{
    if ([delegate respondsToSelector:@selector(inputButtonPressed:)]) 
    {
        [delegate inputButtonPressed:self];
    }
}

- (void)plusButtonPressed{
    if ([delegate respondsToSelector:@selector(plusButtonPressed:)]) {
        [self.delegate plusButtonPressed:self];
    }
}

-(void)setupToolbar:(NSString *)buttonLabel
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.tintColor = [UIColor lightGrayColor];
    
    /* Create custom send button*/
    UIImage *buttonImage = [UIImage imageNamed:@"buttonbg.png"];
    buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(floorf(buttonImage.size.height/2),
                                                                            floorf(buttonImage.size.height/2),
                                                                            floorf(buttonImage.size.height/2),
                                                                            floorf(buttonImage.size.height/2))];
    
    UIButton *button               = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font         = [UIFont boldSystemFontOfSize:15.0f];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.titleEdgeInsets         = UIEdgeInsetsMake(0, 2, 0, 2);
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImage forState:UIControlStateDisabled];
    [button setTitle:buttonLabel forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
                 forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
    [button sizeToFit];
    
    UIImage *plusButtonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIButton *buttonPlus               = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonPlus.titleLabel.font         = [UIFont boldSystemFontOfSize:30.0f];
    buttonPlus.titleLabel.shadowOffset = CGSizeMake(0, -1);
    buttonPlus.titleEdgeInsets         = UIEdgeInsetsMake(0, 2, 6, 2);
    [buttonPlus setBackgroundImage:plusButtonImage forState:UIControlStateNormal];
    [buttonPlus setBackgroundImage:plusButtonImage forState:UIControlStateDisabled];
    [buttonPlus setTitle:@"+" forState:UIControlStateNormal];
    [buttonPlus setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
                 forState:UIControlStateDisabled];
    [buttonPlus addTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchDown];
    buttonPlus.frame = CGRectMake(0, 0, button.frame.size.height, button.frame.size.height);
    buttonPlus.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    self.plusButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonPlus];
    self.inputButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    /* Disable button initially */
    self.inputButton.enabled = NO;

    /* Create UIExpandingTextView input */
    self.textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(45, 7, 200, 26)];
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
    self.textView.delegate = self;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.textView];
    
    /* Right align the toolbar button */
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = [NSArray arrayWithObjects: self.plusButtonItem,flexItem, self.inputButton, nil];
    [self setItems:items animated:NO];
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:@"Send"];
    }
    return self;
}

-(id)init
{
    if ((self = [super init])) {
        [self setupToolbar:@"Send"];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage *backgroundImage = [UIImage imageNamed:@"toolbarbg.png"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
    [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    CGRect i = self.inputButton.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.inputButton.customView.frame = i;
    
    i = self.plusButtonItem.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.plusButtonItem.customView.frame = i;
}

#pragma mark - UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    
    if ([self.delegate respondsToSelector:@selector(inputToolbar:WillChangeHeight:)]) {
        [self.delegate inputToolbar:self WillChangeHeight:r.size.height];
    }
    
    self.frame = r;
    
    if ([self.delegate respondsToSelector:@selector(inputToolbar:DidChangeHeight:)]) {
        [self.delegate inputToolbar:self DidChangeHeight:self.frame.size.height];
    }
}

-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    if ([expandingTextView.text length] > 0)
        self.inputButton.enabled = YES;
    else
        self.inputButton.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(inputToolbarViewDidChange:)]) {
        [self.delegate inputToolbarViewDidChange:self];
    }
}

- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.delegate respondsToSelector:@selector(inputToolbarShouldBeginEditing:)]) {
        return [self.delegate inputToolbarShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)expandingTextViewShouldEndEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.delegate respondsToSelector:@selector(inputToolbarShouldEndEditing:)]) {
        return [self.delegate inputToolbarShouldEndEditing:self];
    }
    return YES;
}

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.delegate respondsToSelector:@selector(inputToolbarDidBeginEditing:)]) {
        [self.delegate inputToolbarDidBeginEditing:self];
    }
}

- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.delegate respondsToSelector:@selector(inputToolbarDidEndEditing:)]) {
        [self.delegate inputToolbarDidEndEditing:self];
    }
}

- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self.delegate respondsToSelector:@selector(inputToolbar:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate inputToolbar:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)expandingTextViewDidChangeSelection:(UIExpandingTextView *)expandingTextView{
    if ([self.delegate respondsToSelector:@selector(inputToolbarViewDidChangeSelection:)]) {
        [self.delegate inputToolbarViewDidChangeSelection:self];
    }
}

@end
