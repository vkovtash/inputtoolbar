/*
 *  ZIMInputToolbar.m
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

#import "ZIMInputToolbar.h"

static CGFloat kDefaultButtonHeight = 26;
static CGFloat kInputFieltMargin = 8;
static NSString* const kInputButtonTitleSend = @"Send";
static CGFloat kToolbarEdgeSeparatorWidth = -12;

@interface ZIMInputToolbar()
@property (nonatomic, strong) UIBarButtonItem *textInputItem;
@property (nonatomic, assign) CGFloat touchBeginY;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) NSString *maxInputButtonTitle;
@end

@implementation ZIMInputToolbar
@synthesize plusButton = _plusButton;
@synthesize inputButton = _inputButton;
@synthesize edgeSeparator = _edgeSeparator;

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupToolbar:kInputButtonTitleSend possibleLabels:nil];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame label:(NSString *)label {
    return [self initWithFrame:frame label:label possibleLabels:nil];
}

- (instancetype) initWithFrame:(CGRect)frame label:(NSString *)label possibleLabels:(NSSet *)possibleLabels {
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:label possibleLabels:possibleLabels];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:kInputButtonTitleSend possibleLabels:[NSSet setWithObjects:kInputButtonTitleSend, nil]];
    }
    return self;
}

- (instancetype) init {
    if ((self = [super init])) {
        [self setupToolbar:kInputButtonTitleSend possibleLabels:nil];
    }
    return self;
}

- (void) setupToolbar:(NSString *)buttonLabel possibleLabels:(NSSet *)possibleLabels {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    _isPlusButtonVisible = YES;
    _inputButton = nil;
    _plusButton = nil;
    
    _maxInputButtonTitle = buttonLabel;
    for(NSString *possibleLabel in possibleLabels) {
        if (possibleLabel.length > _maxInputButtonTitle.length) {
            _maxInputButtonTitle = possibleLabel;
        }
    }
    
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.inputButton];
    _rightBarButtonItem.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.plusButton];
    _leftBarButtonItem.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self.inputButton setTitle:buttonLabel forState:UIControlStateNormal];
    [self.inputButton addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.plusButton addTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    /* Create UIExpandingTextView input */
    _textView = [[ZIMExpandingTextView alloc] initWithFrame:self.bounds];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textView.frame = CGRectOffset(self.textView.frame, 0, (self.bounds.size.height - self.textView.bounds.size.height) / 2);
    
    _textInputItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _textInputItem.customView = self.textView;
    
    [self adjustVisibleItems];
    
    self.textView.delegate = self;
    self.animateHeightChanges = YES;
}

- (UIButton *) plusButton {
    if (!_plusButton) {
        _plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_plusButton setTitle:@"+" forState:UIControlStateNormal];
        _plusButton.bounds = CGRectMake(0, 0, _inputButton.bounds.size.height, _inputButton.bounds.size.height);
        _plusButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 8, 0);
        _plusButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:35];
    }
    return _plusButton;
}

- (UIButton *) inputButton {
    if (!_inputButton) {
        _inputButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _inputButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [_inputButton setTitle:self.maxInputButtonTitle forState:UIControlStateNormal];
        [_inputButton sizeToFit];
        
        CGRect bounds = _inputButton.bounds;
        bounds.size.height = kDefaultButtonHeight;
        _inputButton.bounds = bounds;
    }
    return _inputButton;
}

- (UIBarButtonItem *) edgeSeparator {
    if (!_edgeSeparator) {
        _edgeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        _edgeSeparator.width = kToolbarEdgeSeparatorWidth;
    }
    return _edgeSeparator;
}

- (void) setIsPlusButtonVisible:(BOOL)isPlusButtonVisible {
    if (_isPlusButtonVisible != isPlusButtonVisible) {
        _isPlusButtonVisible = isPlusButtonVisible;
        [self adjustVisibleItems];
    }
}

- (void) tintColorDidChange {
    UIColor *tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    self.rightBarButtonItem.tintColor = tintColor;
    self.leftBarButtonItem.tintColor = tintColor;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect i = self.rightBarButtonItem.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.rightBarButtonItem.customView.frame = i;
    
    i = self.leftBarButtonItem.customView.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.leftBarButtonItem.customView.frame = i;
    
    self.textView.animateHeightChange = self.animateHeightChanges;
}

- (void) inputButtonPressed {
    if ([self.textView.text length] > 0 &&
        [self.inputDelegate respondsToSelector:@selector(inputButtonPressed:)]) {
        [self.inputDelegate inputButtonPressed:self];
    }
}

- (void) plusButtonPressed {
    if ([self.inputDelegate respondsToSelector:@selector(plusButtonPressed:)]) {
        [self.inputDelegate plusButtonPressed:self];
    }
}

- (void) adjustVisibleItems {
    if (self.isPlusButtonVisible) {
        [self setItems:@[self.edgeSeparator, self.leftBarButtonItem, self.textInputItem, self.rightBarButtonItem, self.edgeSeparator]
              animated:NO];
    }
    else {
        [self setItems:@[self.edgeSeparator, self.textInputItem, self.rightBarButtonItem, self.edgeSeparator]
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
        if ([item.customView isKindOfClass:[ZIMExpandingTextView class]]) {
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

#pragma mark - UIExpandingTextView delegate

- (void) expandingTextView:(ZIMExpandingTextView *)expandingTextView willChangeHeight:(CGFloat)height {
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (self.textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:WillChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self willChangeHeight:r.size.height];
    }
    
    self.frame = r;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:DidChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self didChangeHeight:self.frame.size.height];
    }
}

- (void) expandingTextViewDidChange:(ZIMExpandingTextView *)expandingTextView {
    /* Enable/Disable the button */
    self.inputButton.enabled = (expandingTextView.text.length > 0);
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChange:)]) {
        [self.inputDelegate inputToolbarViewDidChange:self];
    }
}

- (BOOL) expandingTextViewShouldBeginEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldBeginEditing:)]) {
        return [self.inputDelegate inputToolbarShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL) expandingTextViewShouldEndEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldEndEditing:)]) {
        return [self.inputDelegate inputToolbarShouldEndEditing:self];
    }
    return YES;
}

- (void) expandingTextViewDidBeginEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidBeginEditing:)]) {
        [self.inputDelegate inputToolbarDidBeginEditing:self];
    }
}

- (void) expandingTextViewDidEndEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidEndEditing:)]) {
        [self.inputDelegate inputToolbarDidEndEditing:self];
    }
}

- (BOOL) expandingTextView:(ZIMExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:shouldChangeTextInRange:replacementText:)]) {
        return [self.inputDelegate inputToolbar:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void) expandingTextViewDidChangeSelection:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChangeSelection:)]) {
        [self.inputDelegate inputToolbarViewDidChangeSelection:self];
    }
}

@end
