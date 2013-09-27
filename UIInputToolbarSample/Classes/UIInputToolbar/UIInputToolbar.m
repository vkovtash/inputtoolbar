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
@synthesize inputDelegate = _inputDelegate;

-(void)inputButtonPressed
{
    if ([_inputDelegate respondsToSelector:@selector(inputButtonPressed:)])
    {
        [_inputDelegate inputButtonPressed:self];
    }
}

- (void)plusButtonPressed{
    if ([self.inputDelegate respondsToSelector:@selector(plusButtonPressed:)]) {
        [self.inputDelegate plusButtonPressed:self];
    }
}

-(void)setupToolbar:(NSString *)buttonLabel
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:buttonLabel forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    UIButton *buttonPlus = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonPlus setTitle:@"+" forState:UIControlStateNormal];
    [buttonPlus addTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchDown];
    buttonPlus.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    /* Create UIExpandingTextView input */
    self.textView = [[UIExpandingTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 26)]; //System blue
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGFloat toolbarEdgeSeparatorWidth = 0;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")){
        
        UIImage *toolbarBackground = nil;
        UIImage *buttonImage = nil;
        toolbarBackground = [UIImage imageNamed:@"toolbarbg.png"];
        toolbarBackground = [toolbarBackground stretchableImageWithLeftCapWidth:floorf(toolbarBackground.size.width/2)
                                                                   topCapHeight:floorf(toolbarBackground.size.height/2)];
        [self setBackgroundImage:toolbarBackground forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        
        buttonImage = [UIImage imageNamed:@"buttonbg.png"];
        buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(floorf(buttonImage.size.height/2),
                                                                                floorf(buttonImage.size.height/2),
                                                                                floorf(buttonImage.size.height/2),
                                                                                floorf(buttonImage.size.height/2))];
        
        UIImage *plusButtonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [button setBackgroundImage:buttonImage forState:UIControlStateDisabled];
        
        [buttonPlus setBackgroundImage:plusButtonImage forState:UIControlStateNormal];
        [buttonPlus setBackgroundImage:plusButtonImage forState:UIControlStateDisabled];
        
        /* Create custom send button*/
        button.bounds = CGRectMake(0, 0, 58, 26);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        button.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [button setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
                     forState:UIControlStateDisabled];
        
        buttonPlus.bounds = CGRectMake(0, 0, button.bounds.size.height, button.bounds.size.height);
        buttonPlus.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 6, 2);
        buttonPlus.titleLabel.font = [UIFont boldSystemFontOfSize:30.0f];
        buttonPlus.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [buttonPlus setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
                         forState:UIControlStateDisabled];
        
        toolbarEdgeSeparatorWidth = -6;
    }
    
    else{
        UIColor *buttonNormalColor = [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1];
        UIColor *buttonHighlightedColor = [UIColor colorWithRed:0.6 green:0.8 blue:1 alpha:1];
        UIColor *buttonDisabledColor = [UIColor lightGrayColor];
        
        button.bounds = CGRectMake(0, 0, 48, 26);
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        [button setTitleColor:buttonNormalColor forState:UIControlStateNormal];
        [button setTitleColor:buttonHighlightedColor forState:UIControlStateHighlighted];
        [button setTitleColor:buttonDisabledColor forState:UIControlStateDisabled];
        
        buttonPlus.bounds = CGRectMake(0, 0, button.bounds.size.height, button.bounds.size.height);
        buttonPlus.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 8, 0);
        buttonPlus.titleLabel.font = [UIFont systemFontOfSize:40.0f];
        [buttonPlus setTitleColor:buttonNormalColor forState:UIControlStateNormal];
        [buttonPlus setTitleColor:buttonHighlightedColor forState:UIControlStateHighlighted];
        [buttonPlus setTitleColor:buttonDisabledColor forState:UIControlStateDisabled];
        
        self.textView.font = [UIFont systemFontOfSize:16];
        
        toolbarEdgeSeparatorWidth = -12;
    }
    

    self.plusButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonPlus];
    self.inputButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    /* Disable button initially */
    self.inputButton.enabled = NO;
    
    /* Right align the toolbar button */
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexItem.customView = self.textView;
    
    UIBarButtonItem *edgeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    edgeSeparator.width = toolbarEdgeSeparatorWidth;
    
    NSArray *items = [NSArray arrayWithObjects: edgeSeparator, self.plusButtonItem, flexItem, self.inputButton, edgeSeparator, nil];
    [self setItems:items animated:NO];
    
    CGRect frame = self.textView.frame;
    frame.origin.y = (self.bounds.size.height - self.textView.textViewBackgroundImage.bounds.size.height) / 2;
    frame.size.width = self.inputButton.customView.frame.origin.x - self.plusButtonItem.customView.frame.origin.x - self.plusButtonItem.customView.frame.size.width - 12;
    frame.origin.x = self.plusButtonItem.customView.frame.origin.x + self.plusButtonItem.customView.frame.size.width + 6;
    self.textView.frame = frame;
    
    self.textView.delegate = self;
    
    self.animateHeightChanges = YES;
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

- (void) layoutSubviews{
    [super layoutSubviews];
    
    CGRect i = self.inputButton.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.inputButton.customView.frame = i;
    
    i = self.plusButtonItem.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.plusButtonItem.customView.frame = i;
    
    self.textView.animateHeightChange = self.animateHeightChanges;
}

#pragma mark - UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:WillChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self WillChangeHeight:r.size.height];
    }
    
    self.frame = r;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:DidChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self DidChangeHeight:self.frame.size.height];
    }
}

-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    if ([expandingTextView.text length] > 0)
        self.inputButton.enabled = YES;
    else
        self.inputButton.enabled = NO;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChange:)]) {
        [self.inputDelegate inputToolbarViewDidChange:self];
    }
}

- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldBeginEditing:)]) {
        return [self.inputDelegate inputToolbarShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)expandingTextViewShouldEndEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldEndEditing:)]) {
        return [self.inputDelegate inputToolbarShouldEndEditing:self];
    }
    return YES;
}

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidBeginEditing:)]) {
        [self.inputDelegate inputToolbarDidBeginEditing:self];
    }
}

- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidEndEditing:)]) {
        [self.inputDelegate inputToolbarDidEndEditing:self];
    }
}

- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:shouldChangeTextInRange:replacementText:)]) {
        return [self.inputDelegate inputToolbar:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)expandingTextViewDidChangeSelection:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChangeSelection:)]) {
        [self.inputDelegate inputToolbarViewDidChangeSelection:self];
    }
}

@end
