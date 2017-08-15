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
static NSString* const kInputButtonTitleSend = @"Send";
static CGFloat kToolbarEdgeSeparatorWidth = -8;
static CGFloat kAnchorsWidth = 0;

@interface ZIMInputToolbar()
@property (nonatomic, assign) CGFloat touchBeginY;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) NSString *maxInputButtonTitle;
@property (strong, nonatomic) NSString *textBackup;
@property (strong, nonatomic) UIBarButtonItem *leftTextAnchor;
@property (strong, nonatomic) UIBarButtonItem *rightTextAnchor;
@property (strong, nonatomic) UIView *topAccessoryContainer;
@property (weak, nonatomic) UIView *rigthButtonPlaceholder;
@property (weak, nonatomic) UIView *leftButtonPlaceholder;
@end

@implementation ZIMInputToolbar
@synthesize plusButton = _plusButton;
@synthesize inputButton = _inputButton;
@synthesize edgeSeparator = _edgeSeparator;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupToolbar:kInputButtonTitleSend possibleLabels:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame label:(NSString *)label possibleLabels:(NSSet *)possibleLabels {
    if ((self = [super initWithFrame:frame])) {
        [self setupToolbar:label possibleLabels:possibleLabels];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame label:(NSString *)label {
    return [self initWithFrame:frame label:label possibleLabels:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame
                         label:kInputButtonTitleSend
                possibleLabels:[NSSet setWithObjects:kInputButtonTitleSend, nil]];
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 40, 40) label:kInputButtonTitleSend possibleLabels:nil];
}

+ (instancetype)defaultToolbarWithFrame:(CGRect)frame {
    ZIMInputToolbar *toolbar = [[self alloc] initWithFrame:frame];

    /* Custom Background image */
    UIImage *textViewBackgroundImage = [UIImage imageNamed:@"textbg_7"];
    textViewBackgroundImage =
        [textViewBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(floorf(textViewBackgroundImage.size.height / 2),
                                                                              floorf(textViewBackgroundImage.size.width / 2),
                                                                              floorf(textViewBackgroundImage.size.height / 2),
                                                                              floorf(textViewBackgroundImage.size.width / 2))];

    toolbar.textView.textViewBackgroundImage.image = textViewBackgroundImage;
    return toolbar;
}

- (void)setupToolbar:(NSString *)buttonLabel possibleLabels:(NSSet *)possibleLabels {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    _inputButton = nil;
    _plusButton = nil;
    _minHeight = 44;
    _topAccessoryHeight = 44;
    _isInputButtonEnabled = YES;
    
    _maxInputButtonTitle = buttonLabel;
    for(NSString *possibleLabel in possibleLabels) {
        if (possibleLabel.length > _maxInputButtonTitle.length) {
            _maxInputButtonTitle = possibleLabel;
        }
    }
    
    [self addSubview:self.inputButton];
    [self addSubview:self.plusButton];
    
    UIView *rigthButtonPlaceholder = [[UIView alloc] initWithFrame:self.inputButton.frame];
    _rigthButtonPlaceholder = rigthButtonPlaceholder;
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rigthButtonPlaceholder];
    
    UIView *leftButtonPlaceholder = [[UIView alloc] initWithFrame:self.plusButton.frame];
    _leftButtonPlaceholder = leftButtonPlaceholder;
    _leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButtonPlaceholder];
    
    [self.inputButton setTitle:buttonLabel forState:UIControlStateNormal];
    [self.inputButton addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.plusButton addTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    /* Create UIExpandingTextView input */
    _textView = [[ZIMExpandingTextView alloc] initWithFrame:self.bounds];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.center = CGPointMake(_textView.center.x, CGRectGetMidY(self.bounds));
    _textView.clipsToBounds = YES;
    [self addSubview:_textView];
    
    _leftTextAnchor =
        [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                             0,
                                                                                             kAnchorsWidth,
                                                                                             CGRectGetHeight(self.bounds))]];
    _leftTextAnchor.customView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    _rightTextAnchor =
        [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                             0,
                                                                                             kAnchorsWidth,
                                                                                             CGRectGetHeight(self.bounds))]];
    _rightTextAnchor.customView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    UIView *topAccessoryContainer = [UIView new];
    [self addSubview:topAccessoryContainer];
    [self sendSubviewToBack:topAccessoryContainer];
    _topAccessoryContainer = topAccessoryContainer;
    _topAccessoryContainer.hidden = _topAccessoryView == nil;
    
    self.textView.delegate = self;
    self.animateHeightChanges = YES;
    
    [self adjustVisibleItems];
    [self updateHeight];
}

- (BOOL)usesOldSchoolLayout {
    return _leftTextAnchor.customView.superview == self;
}

- (UIButton *)plusButton {
    if (!_plusButton) {
        _plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_plusButton setTitle:@"+" forState:UIControlStateNormal];
        _plusButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:35];
        _plusButton.bounds = CGRectMake(0, 0, 18, kDefaultButtonHeight);
        _plusButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 8, 0);
    }
    return _plusButton;
}

- (UIButton *)inputButton {
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

- (UIBarButtonItem *)edgeSeparator {
    if (!_edgeSeparator) {
        _edgeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        _edgeSeparator.width = kToolbarEdgeSeparatorWidth;
    }
    return _edgeSeparator;
}

- (void)setAlternativeInputViewController:(UIInputViewController *)alternativeInputViewController {
    _alternativeInputViewController = alternativeInputViewController;
    if (_alternativeInputViewController) {
        [self adjustVisibleItems];
        [self layoutExpandingTextViewAnimated:NO];
    }
}

- (BOOL)isPlusButtonVisible {
    return self.alternativeInputViewController != nil;
}

- (BOOL)isTopAccessoryVisible {
    return !self.isInAlternativeMode && self.topAccessoryView != nil;
}

- (void)setIsInAlternativeMode:(BOOL)isInAlternativeMode {
    [self setIsInAlternativeMode:isInAlternativeMode animated:NO];
}

- (void)setIsInAlternativeMode:(BOOL)isInAlternativeMode animated:(BOOL)animated {
    if (!self.alternativeInputViewController) {
        return;
    }
    
    if (_isInAlternativeMode == isInAlternativeMode) {
        return;
    }
    _isInAlternativeMode = isInAlternativeMode;
    
    void(^animations)() = ^{
        if (isInAlternativeMode) {
            self.textBackup = self.textView.text;
            self.textView.text = @"";
        }
        else {
            self.textView.text = self.textBackup;
            self.textBackup = nil;
        }
        
        [self updateHeight];
        
        [self adjustVisibleItems];
        
        [UIView performWithoutAnimation:^{
            [self layoutSubviews];
        }];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:animations];
    }
    else {
        animations();
    }
    
    [self setAlternativeInputModeOn:_isInAlternativeMode];
    [self applyTopAccessoryVisibilityAnimated:animated];
}

- (void)setAlternativeInputModeOn:(BOOL)on {
    if (!self.alternativeInputViewController) {
        return;
    }
    
    self.plusButton.selected = on;
    self.textView.inputView = on ? self.alternativeInputViewController.inputView : nil;
    
    if (self.textView.internalTextView.isFirstResponder) {
        [self.textView reloadInputViews];
    }
    else if (on) {
        [self.textView becomeFirstResponder];
    }
}

- (void)setMinHeight:(CGFloat)minHeight {
    _minHeight = minHeight;
    [self updateHeight];
}

- (void)setTextFieldInsets:(UIEdgeInsets)textFieldInsets {
    _textFieldInsets = textFieldInsets;
    [self updateHeight];
}

- (NSString *)text {
    return self.isInAlternativeMode ? self.textBackup : self.textView.text;
}

- (void)setText:(NSString *)text {
    if (self.isInAlternativeMode) {
        self.textBackup = text;
    }
    else {
        self.textView.text = text;
    }
}

- (void)setAnimateHeightChanges:(BOOL)animateHeightChanges {
    self.textView.animateHeightChange = animateHeightChanges;
}

- (void)setTopAccessoryView:(UIView *)topAccessoryView {
    [self setTopAccessoryView:topAccessoryView animated:NO];
}

- (void)setTopAccessoryView:(UIView *)topAccessoryView animated:(BOOL)animated {
    if (_topAccessoryView == topAccessoryView) {
        return;
    }

    [_topAccessoryView removeFromSuperview];
    if (topAccessoryView) {
        [self.topAccessoryContainer addSubview:topAccessoryView];
        [self bringSubviewToFront:self.topAccessoryContainer];
    }
    _topAccessoryView = topAccessoryView;
    _topAccessoryView.frame = _topAccessoryContainer.bounds;

    BOOL isHidden = self.isTopAccessoryVisible;

    if (!animated) {
        [self applyTopAccessoryVisibilityAnimated:NO];
        [self updateHeight];
        return;
    }

    [UIView animateWithDuration:0.2 animations:^{
        [self applyTopAccessoryVisibilityAnimated:YES];
        [self updateHeight];
    }];
}

- (void)applyTopAccessoryVisibilityAnimated:(BOOL)animated {
    BOOL isVisible = self.isTopAccessoryVisible;

    if (!animated) {
        self.topAccessoryContainer.hidden = !isVisible;
        self.topAccessoryView.alpha = isVisible ? 1.0f : 0.0f;
        return;
    }

    if (isVisible) {
        self.topAccessoryContainer.hidden = NO;
    }

    [UIView animateWithDuration:0.2 animations:^{
        self.topAccessoryView.alpha = isVisible ? 1.0f : 0.0f;
    } completion:^(BOOL isFinished) {
        self.topAccessoryContainer.hidden = !isVisible;
    }];
}

- (void)setTopAccessoryHeight:(CGFloat)topAccessoryHeight {
    _topAccessoryHeight = topAccessoryHeight;
    [self updateHeight];
}

- (void)setIsInputButtonEnabled:(BOOL)isInputButtonEnabled {
    _isInputButtonEnabled = isInputButtonEnabled;
    self.inputButton.enabled = _isInputButtonEnabled && self.textView.text.length > 0;
}

- (void)setDisableInputButtonAutomatically:(BOOL)disableInputButtonAutomatically {
    _disableInputButtonAutomatically = disableInputButtonAutomatically;
    [self updateInputButton];
    
    if (!disableInputButtonAutomatically) {
        self.inputButton.enabled = YES;
    }
}

- (BOOL)animateHeightChanges {
    return self.textView.animateHeightChange;
}

- (void)tintColorDidChange {
    UIColor *tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    self.rightBarButtonItem.tintColor = tintColor;
    self.leftBarButtonItem.tintColor = tintColor;
}

static inline layoutBarButton(UIToolbar *toolbar, UIView *button, CGFloat Y) {
    if (button.superview == toolbar) {
        CGPoint point = button.center;
        point.y = Y;
        button.center = point;
    }
    else {
        CGPoint point = button.superview.center;
        point.y = Y;
        button.superview.center = point;
        button.superview.backgroundColor = [UIColor redColor];
        button.backgroundColor = [UIColor greenColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutExpandingTextViewAnimated:NO];
    [self layoutBarButtons];
}

- (void)updateInputButton {
    if (self.disableInputButtonAutomatically) {
        self.inputButton.enabled = self.isInputButtonEnabled && self.textView.text.length > 0;
    }
}

- (void)inputButtonPressed {
    if ([self.inputDelegate respondsToSelector:@selector(inputButtonPressed:)]) {
        [self.inputDelegate inputButtonPressed:self];
    }
}

- (void)plusButtonPressed {
    [self setIsInAlternativeMode:!self.isInAlternativeMode animated:YES];
    
    if ([self.inputDelegate respondsToSelector:@selector(plusButtonPressed:)]) {
        [self.inputDelegate plusButtonPressed:self];
    }
}

- (void)adjustVisibleItems {
    NSMutableArray *barItems = [NSMutableArray array];
    
    [barItems addObject:self.edgeSeparator];
    
    if (self.isPlusButtonVisible) {
        [barItems addObject:self.leftBarButtonItem];
    }
    
    UIBarButtonItem *inset = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    inset.width = self.usesOldSchoolLayout ? -5 : 5;
    
    [barItems addObject:inset];
    
    if (self.isInAlternativeMode) {
        [barItems addObject:self.leftTextAnchor];
        [barItems addObjectsFromArray:self.alternativeBarButtonItems];
        [barItems addObject:self.rightTextAnchor];
    }
    else {
        [barItems addObject:self.leftTextAnchor];
        [barItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        [barItems addObject:self.rightTextAnchor];
        [barItems addObject:self.rightBarButtonItem];
    }
    
    [barItems addObject:self.edgeSeparator];
    
    [self setItems:barItems animated:NO];
    
    self.textView.alpha = self.isInAlternativeMode ? 0 : 1;
    
    self.inputButton.alpha = self.isInAlternativeMode ? 0 : 1;
    self.inputButton.userInteractionEnabled = !self.isInAlternativeMode;
    
    self.plusButton.alpha = self.isPlusButtonVisible ? 1 : 0;
    self.plusButton.userInteractionEnabled = self.isPlusButtonVisible;
    
    [self setNeedsLayout];
}

- (void)layoutBarButtons {
    UIView *rigthButtonPlaceholder = self.rightBarButtonItem.customView;
    UIView *leftButtonPlaceholder = self.leftBarButtonItem.customView;
    
    [self bringSubviewToFront:self.plusButton];
    [self bringSubviewToFront:self.inputButton];
    
    CGFloat newY = CGRectGetHeight(self.bounds) - self.minHeight;
    
    if (rigthButtonPlaceholder.window) {
        CGRect rect = [self convertRect:rigthButtonPlaceholder.bounds fromView:rigthButtonPlaceholder];
        rect.origin.y = newY;
        rect.size.height = self.minHeight;
        self.inputButton.frame = rect;
    }

    if (leftButtonPlaceholder.window) {
        CGRect rect = [self convertRect:leftButtonPlaceholder.bounds fromView:leftButtonPlaceholder];
        rect.origin.y = newY;
        rect.size.height = self.minHeight;
        self.plusButton.frame = rect;
    }
}

- (void)layoutExpandingTextViewAnimated:(BOOL)animated {
    void(^layout)() = ^{
        UIEdgeInsets insets = self.textFieldInsets;
        CGFloat textRectHeigth = CGRectGetHeight(self.textView.bounds) + insets.top + insets.bottom;
        CGFloat topAccessoryHeigth = self.isTopAccessoryVisible ? self.topAccessoryHeight : 0;

        CGFloat y = insets.top + topAccessoryHeigth;

        if (textRectHeigth < self.minHeight) {
            y += (self.minHeight - textRectHeigth) / 2;
        }
        
        UIView *rightAnchorView = self.rightTextAnchor.customView;
        UIView *leftAnchorView = self.leftTextAnchor.customView;
        
        CGRect rightAnchorFrame = [self convertRect:rightAnchorView.bounds fromView:rightAnchorView];
        CGRect leftAnchorFrame = [self convertRect:leftAnchorView.bounds fromView:leftAnchorView];

        CGRect frame = self.textView.frame;
        frame.size.width = CGRectGetMinX(rightAnchorFrame) - CGRectGetMaxX(leftAnchorFrame) - insets.left - insets.right;
        frame.origin.x = CGRectGetMaxX(leftAnchorFrame) + insets.left;
        frame.origin.y = y;
        self.textView.frame = frame;

        self.topAccessoryContainer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.topAccessoryHeight);
        [self bringSubviewToFront:self.textView];
    };
    
    [UIView performWithoutAnimation:^{
        [super layoutIfNeeded];
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:layout];
    }
    else {
        [UIView performWithoutAnimation:layout];
    }
}

- (void)updateHeight {
    [self expandingTextView:_textView didChangeHeight:CGRectGetHeight(self.textView.frame)];
}

#pragma mark - UIExpandingTextView delegate

- (void)expandingTextView:(ZIMExpandingTextView *)expandingTextView didChangeHeight:(CGFloat)height {
    /* Adjust the height of the toolbar when the input component expands */

    CGFloat fullHeight = height + self.textFieldInsets.top + self.textFieldInsets.bottom;
    CGFloat newHeight = MAX(fullHeight, self.minHeight);
    if (self.isTopAccessoryVisible) {
        newHeight += self.topAccessoryHeight;
    }

    CGRect newBounds = self.bounds;
    newBounds.size.height = newHeight;

    CGPoint newCenter = CGPointMake(self.center.x, self.center.y + (CGRectGetHeight(self.bounds) - newHeight) / 2);

    if (CGRectEqualToRect(self.bounds, newBounds) && CGPointEqualToPoint(self.center, newCenter)) {
        return;
    }

    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:willChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self willChangeHeight:CGRectGetHeight(newBounds)];
    }

    self.bounds = newBounds;
    self.center = newCenter;

    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:didChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self didChangeHeight:CGRectGetHeight(self.bounds)];
    }
}

- (void)expandingTextViewDidChange:(ZIMExpandingTextView *)expandingTextView {
    [self updateInputButton];
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChange:)]) {
        [self.inputDelegate inputToolbarViewDidChange:self];
    }
}

- (BOOL)expandingTextViewShouldBeginEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldBeginEditing:)]) {
        return [self.inputDelegate inputToolbarShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)expandingTextViewShouldEndEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldEndEditing:)]) {
        return [self.inputDelegate inputToolbarShouldEndEditing:self];
    }
    return YES;
}

- (void)expandingTextViewDidBeginEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidBeginEditing:)]) {
        [self.inputDelegate inputToolbarDidBeginEditing:self];
    }
}

- (void)expandingTextViewDidEndEditing:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidEndEditing:)]) {
        [self.inputDelegate inputToolbarDidEndEditing:self];
    }
}

- (BOOL)expandingTextView:(ZIMExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:shouldChangeTextInRange:replacementText:)]) {
        return [self.inputDelegate inputToolbar:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)expandingTextViewDidChangeSelection:(ZIMExpandingTextView *)expandingTextView {
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChangeSelection:)]) {
        [self.inputDelegate inputToolbarViewDidChangeSelection:self];
    }
}

@end
