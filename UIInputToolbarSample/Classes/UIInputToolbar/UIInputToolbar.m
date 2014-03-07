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

static CGFloat kDefaultButtonHeight = 26;
static CGFloat kInputFieltMargin = 8;
static NSString* const kInputButtonTitleSend = @"Send";
static NSString* const kInputButtonTitleSay = @"Say";

@interface UIInputToolbar()
@property (strong, nonatomic) UIBarButtonItem *edgeSeparator;
@property (strong, nonatomic) UIBarButtonItem *textInputItem;
@property (nonatomic) CGFloat touchBeginY;
@property (strong, nonatomic) UIButton *rightButton;
@end

@implementation UIInputToolbar

@synthesize textView;
@synthesize inputButton;
@synthesize inputDelegate = _inputDelegate;

-(void)inputButtonPressed
{
	if ([textView.text length] > 0)
	{
		if ([_inputDelegate respondsToSelector:@selector(inputButtonPressed:)])
		{
			[_inputDelegate inputButtonPressed:self];
		}
	}
	else
	{
		if ([_inputDelegate respondsToSelector:@selector(sayButtonPressed:)])
		{
			[_inputDelegate sayButtonPressed:self];
		}
        
	}
}

- (void)plusButtonPressed{
    if ([self.inputDelegate respondsToSelector:@selector(plusButtonPressed:)]) {
        [self.inputDelegate plusButtonPressed:self];
    }
}

-(void)setupToolbar:(NSString *)buttonLabel possibleLabels:(NSSet *) possibleLabels
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    _isPlusButtonVisible = YES;
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitle:buttonLabel forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    NSString *maxRightButtonTitle = nil;
    for(NSString *possibleLabel in possibleLabels) {
        if (possibleLabel.length > maxRightButtonTitle.length) {
            maxRightButtonTitle = possibleLabel;
        }
    }
    
    UIButton *buttonPlus = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonPlus setTitle:@"+" forState:UIControlStateNormal];
    [buttonPlus addTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchDown];
    buttonPlus.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    CGFloat toolbarEdgeSeparatorWidth = 0;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")){
        
        UIImage *toolbarBackground = nil;
        UIImage *buttonImage = nil;
        toolbarBackground = [UIImage imageNamed:@"toolbarbg.png"];
        toolbarBackground = [toolbarBackground stretchableImageWithLeftCapWidth:floorf(toolbarBackground.size.width/2)
                                                                   topCapHeight:floorf(toolbarBackground.size.height/2)];
        [self setBackgroundImage:toolbarBackground
              forToolbarPosition:UIToolbarPositionBottom
                      barMetrics:UIBarMetricsDefault];
        
        buttonImage = [UIImage imageNamed:@"buttonbg.png"];
        buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(floorf(buttonImage.size.height/2),
                                                                                floorf(buttonImage.size.height/2),
                                                                                floorf(buttonImage.size.height/2),
                                                                                floorf(buttonImage.size.height/2))];
        
        UIImage *plusButtonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        
        [self.rightButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self.rightButton setBackgroundImage:buttonImage forState:UIControlStateDisabled];
        
        [buttonPlus setBackgroundImage:plusButtonImage forState:UIControlStateNormal];
        [buttonPlus setBackgroundImage:plusButtonImage forState:UIControlStateDisabled];
        
        /* Create custom send button*/
        
        
        self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        self.rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.rightButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self.rightButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
                               forState:UIControlStateDisabled];
        [self.rightButton setTitle:maxRightButtonTitle forState:UIControlStateNormal];
        [self.rightButton sizeToFit];
        
        CGRect bounds = self.rightButton.bounds;
        bounds.size.height = kDefaultButtonHeight;
        self.rightButton.bounds = bounds;
        [self.rightButton setTitle:buttonLabel forState:UIControlStateNormal];
        
        buttonPlus.bounds = CGRectMake(0, 0, self.rightButton.bounds.size.height, self.rightButton.bounds.size.height);
        buttonPlus.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 6, 2);
        buttonPlus.titleLabel.font = [UIFont boldSystemFontOfSize:30.0f];
        buttonPlus.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [buttonPlus setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
                         forState:UIControlStateDisabled];
        
        toolbarEdgeSeparatorWidth = -6;
    }
    
    else{
        UIColor *buttonNormalColor = [[[UIApplication sharedApplication] delegate] window].tintColor;
        CGFloat hue, saturation, brightness, alpha;
        [buttonNormalColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        if (brightness > 0.5) {
            brightness -= 0.2;
        }
        else {
            brightness += 0.2;
        }
        UIColor *buttonHighlightedColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
        UIColor *buttonDisabledColor = [UIColor lightGrayColor];
        
        /* Create custom send button*/
        self.rightButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [self.rightButton setTitleColor:buttonNormalColor forState:UIControlStateNormal];
        [self.rightButton setTitleColor:buttonHighlightedColor forState:UIControlStateHighlighted];
        [self.rightButton setTitleColor:buttonDisabledColor forState:UIControlStateDisabled];
        [self.rightButton setTitle:maxRightButtonTitle forState:UIControlStateNormal];
        [self.rightButton sizeToFit];
        
        CGRect bounds = self.rightButton.bounds;
        bounds.size.height = kDefaultButtonHeight;
        self.rightButton.bounds = bounds;
        [self.rightButton setTitle:buttonLabel forState:UIControlStateNormal];
        
        buttonPlus.bounds = CGRectMake(0, 0, self.rightButton.bounds.size.height, self.rightButton.bounds.size.height);
        buttonPlus.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 8, 0);
        buttonPlus.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:35];
        [buttonPlus setTitleColor:buttonNormalColor forState:UIControlStateNormal];
        [buttonPlus setTitleColor:buttonHighlightedColor forState:UIControlStateHighlighted];
        [buttonPlus setTitleColor:buttonDisabledColor forState:UIControlStateDisabled];
        toolbarEdgeSeparatorWidth = -12;
    }
    
    self.plusButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonPlus];
    self.inputButton = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    /* Create UIExpandingTextView input */
    self.textView = [[UIExpandingTextView alloc] initWithFrame:self.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.frame = CGRectOffset(self.textView.frame, 0, (self.bounds.size.height - self.textView.bounds.size.height) / 2);
    
    _textInputItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _textInputItem.customView = self.textView;
    
    _edgeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    _edgeSeparator.width = toolbarEdgeSeparatorWidth;
    
    [self adjustVisibleItems];
    
    self.textView.delegate = self;
    self.animateHeightChanges = YES;
}

-(id)initWithFrame:(CGRect)frame label:(NSString *)label
{
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:label possibleLabels:[NSSet setWithObject:label]];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:kInputButtonTitleSay possibleLabels:[NSSet setWithObjects:kInputButtonTitleSay, kInputButtonTitleSend, nil]];
    }
    return self;
}

-(id)init
{
    if ((self = [super init])) {
        [self setupToolbar:kInputButtonTitleSay possibleLabels:[NSSet setWithObjects:kInputButtonTitleSay, kInputButtonTitleSend, nil]];
    }
    return self;
}

- (void) adjustVisibleItems {
    
    if (_isPlusButtonVisible) {
        [self setItems:@[self.edgeSeparator, self.plusButtonItem, self.textInputItem, self.inputButton, self.edgeSeparator]
              animated:NO];
    }
    else {
        [self setItems:@[self.edgeSeparator, self.textInputItem, self.inputButton, self.edgeSeparator]
              animated:NO];
    }
    [self layoutExpandingTextView];
}

- (void) layoutExpandingTextView {
    CGRect frame = self.textView.frame;
    frame.size.width = self.bounds.size.width;
    frame.origin.x = 0;
    
    BOOL calculatePosition = YES;
    
    for (UIBarButtonItem *item in self.items) {
        if ([item.customView isKindOfClass:[UIExpandingTextView class]]) {
            calculatePosition = NO;
        }
        else if (item.customView){
            if (calculatePosition) {
                frame.origin.x += item.width ? item.width : item.customView.frame.size.width;
            }
            frame.size.width -= item.width + item.customView.frame.size.width;
        }
    }
    
    frame.size.width -= kInputFieltMargin * 2;
    frame.origin.x += kInputFieltMargin;
    self.textView.frame = frame;
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

- (void) setIsPlusButtonVisible:(BOOL)isPlusButtonVisible {
    if (_isPlusButtonVisible != isPlusButtonVisible) {
        _isPlusButtonVisible = isPlusButtonVisible;
        [self adjustVisibleItems];
    }
}

#pragma mark - UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(CGFloat)height
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
    if ([expandingTextView.text length] > 0){
        [self.rightButton setTitle:kInputButtonTitleSend forState:UIControlStateNormal];
    }
    else {
        [self.rightButton setTitle:kInputButtonTitleSay forState:UIControlStateNormal];
    }
    
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
