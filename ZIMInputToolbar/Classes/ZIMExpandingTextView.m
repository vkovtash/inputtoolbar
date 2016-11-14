/*
 *  ZIMExpandingTextView.m
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
 *  This class is based on UIExpandingTextView by Brandon Hamilton 
 *  https://github.com/brandonhamilton/inputtoolbar
 */

#import "ZIMExpandingTextView.h"

#define kTextInsetX 4

@interface ZIMExpandingTextView()
@property (assign, nonatomic) CGFloat currentWidth;
@end

@implementation ZIMExpandingTextView

@synthesize internalTextView = _internalTextView;
@synthesize text = _text;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize textAlignment = _textAlignment;
@synthesize selectedRange = _selectedRange;
@synthesize editable = _editable;
@synthesize dataDetectorTypes = _dataDetectorTypes;
@synthesize animateHeightChange = _animateHeightChange;
@synthesize returnKeyType = _returnKeyType;
@synthesize textViewBackgroundImage = _textViewBackgroundImage;
@synthesize placeholder = _placeholder;
@synthesize placeholderLabel = _placeholderLabel;
@synthesize minimumNumberOfLines = _minimumNumberOfLines;
@synthesize maximumNumberOfLines = _maximumNumberOfLines;
@synthesize minimumHeight = _minimumHeight;
@synthesize maximumHeight = _maximumHeight;
@synthesize forceSizeUpdate = _forceSizeUpdate;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        self.forceSizeUpdate = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		CGRect backgroundFrame = frame;
        backgroundFrame.origin.y = 0;
		backgroundFrame.origin.x = 0;
        
        CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, 0);
        
        self.textViewBackgroundImage = [[UIImageView alloc] initWithFrame:backgroundFrame];
        self.internalTextView = [[UITextView alloc] initWithFrame:self.textViewBackgroundImage.bounds];
        self.placeholderLabel = [[UILabel alloc] initWithFrame: textViewFrame];
        
        /* Custom Background image */
        UIImage *textViewBackgroundImage = nil;
        
        textViewBackgroundImage = [UIImage imageNamed:@"textbg_7"];
        UIEdgeInsets originalInset = self.internalTextView.textContainerInset;
        originalInset.bottom = 6;
        self.internalTextView.textContainerInset = originalInset;
        
        textViewBackgroundImage = [textViewBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(floorf(textViewBackgroundImage.size.height/2),
                                                                                                        floorf(textViewBackgroundImage.size.width/2),
                                                                                                        floorf(textViewBackgroundImage.size.height/2),
                                                                                                        floorf(textViewBackgroundImage.size.width/2))];
        
        self.textViewBackgroundImage.image = textViewBackgroundImage;
        self.textViewBackgroundImage.contentMode = UIViewContentModeScaleToFill;
        self.textViewBackgroundImage.clipsToBounds = YES;
        self.textViewBackgroundImage.userInteractionEnabled = YES;
        self.textViewBackgroundImage.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        /* Internal Text View component */
        
		self.internalTextView.delegate = self;
        self.internalTextView.text = @"-";
        self.internalTextView.opaque = NO;
        self.internalTextView.backgroundColor = [UIColor clearColor];
        self.internalTextView.showsHorizontalScrollIndicator = NO;
        self.internalTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        /* set placeholder */
        self.placeholderLabel.text = self.placeholder;
        self.placeholderLabel.font = self.internalTextView.font;
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textColor = [UIColor grayColor];
        self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [self.textViewBackgroundImage addSubview:self.placeholderLabel];
        [self.textViewBackgroundImage addSubview:self.internalTextView];
        [self addSubview:self.textViewBackgroundImage];

        /*set default parameters*/
        [self setFont:[UIFont systemFontOfSize:15]];
		[self setMinimumNumberOfLines:1];
		[self setMaximumNumberOfLines:5];
        
        [self clearText];
        [self sizeToFit];
        self.currentWidth = CGRectGetWidth(self.internalTextView.bounds);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Should recalculate text view height on width change
    CGFloat newWidth = CGRectGetWidth(self.internalTextView.bounds);
    if (self.currentWidth != newWidth) {
        self.currentWidth = newWidth;
        [self textViewDidChange:self.internalTextView];
    }
}

- (void) setRightView:(UIView *)rightView {
    if (_rightView != rightView) {
        //restore text insets
        _internalTextView.textContainerInset = UIEdgeInsetsMake(_internalTextView.textContainerInset.top,
                                                                _internalTextView.textContainerInset.left,
                                                                _internalTextView.textContainerInset.bottom,
                                                                _internalTextView.textContainerInset.right - _rightView.frame.size.width);
        //replace view
        [_rightView removeFromSuperview];
        _rightView = rightView;
        [self addSubview:_rightView];
        [self alignRightView];
        
        //set new text insets
        _internalTextView.textContainerInset = UIEdgeInsetsMake(_internalTextView.textContainerInset.top,
                                                                _internalTextView.textContainerInset.left,
                                                                _internalTextView.textContainerInset.bottom,
                                                                _internalTextView.textContainerInset.right + _rightView.frame.size.width);
        [self textViewDidChange:_internalTextView];
    }
}

- (void) setLeftView:(UIView *)leftView {
    if (_leftView != leftView) {
        //restore text insets
        _internalTextView.textContainerInset = UIEdgeInsetsMake(_internalTextView.textContainerInset.top,
                                                                _internalTextView.textContainerInset.left - _leftView.frame.size.width,
                                                                _internalTextView.textContainerInset.bottom,
                                                                _internalTextView.textContainerInset.right);
        _placeholderLabel.center = CGPointMake(_placeholderLabel.center.x - _leftView.frame.size.width, _placeholderLabel.center.y);
        
        //replace view
        [_leftView removeFromSuperview];
        _leftView = leftView;
        [self addSubview:_leftView];
        [self alignLeftView];
        
        //set new text insets
        _internalTextView.textContainerInset = UIEdgeInsetsMake(_internalTextView.textContainerInset.top,
                                                                _internalTextView.textContainerInset.left + _leftView.frame.size.width,
                                                                _internalTextView.textContainerInset.bottom,
                                                                _internalTextView.textContainerInset.right);
        _placeholderLabel.center = CGPointMake(_placeholderLabel.center.x + _leftView.frame.size.width, _placeholderLabel.center.y);
        [self textViewDidChange:_internalTextView];
    }
}

- (void) setRightViewVerticalAlign:(ZIMExpandingTextViewVerticalAlign)rightViewVerticalAlign {
    if (_rightViewVerticalAlign != rightViewVerticalAlign) {
        _rightViewVerticalAlign = rightViewVerticalAlign;
        [self alignRightView];
    }
}

- (void) setLeftViewVerticalAlign:(ZIMExpandingTextViewVerticalAlign)leftViewVerticalAlign {
    if (_leftViewVerticalAlign != leftViewVerticalAlign) {
        _leftViewVerticalAlign = leftViewVerticalAlign;
        [self alignLeftView];
    }
}

- (void) alignRightView {
    if (!_rightView) {
        return;
    }
    
    switch (_rightViewVerticalAlign) {
            case ZIMExpandingTextViewVerticalAlignBottom:
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
            _rightView.center = CGPointMake(self.bounds.size.width - _rightView.bounds.size.width/2,
                                           self.bounds.size.height - _rightView.bounds.size.height/2);
            break;
            
            case ZIMExpandingTextViewVerticalAlignCenter:
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            _rightView.center = CGPointMake(self.bounds.size.width - _rightView.bounds.size.width/2,
                                           self.bounds.size.height/2);
            break;
            
            case ZIMExpandingTextViewVerticalAlignTop:
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
            _rightView.center = CGPointMake(self.bounds.size.width - _rightView.bounds.size.width/2,
                                           _rightView.bounds.size.height/2);
            break;
    }
}

- (void) alignLeftView {
    if (!_leftView) {
        return;
    }
    
    switch (_leftViewVerticalAlign) {
            case ZIMExpandingTextViewVerticalAlignBottom:
            _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
            _leftView.center = CGPointMake(_leftView.bounds.size.width/2,
                                            self.bounds.size.height - _leftView.bounds.size.height/2);
            break;
            
            case ZIMExpandingTextViewVerticalAlignCenter:
            _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            _leftView.center = CGPointMake(_leftView.bounds.size.width/2,
                                            self.bounds.size.height/2);
            break;
            
            case ZIMExpandingTextViewVerticalAlignTop:
            _leftView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
            _leftView.center = CGPointMake(_leftView.bounds.size.width/2,
                                            _leftView.bounds.size.height/2);
            break;
    }
}

- (CGFloat) maximumHeight {
    return _maximumHeight;
}

- (void) setMaximumHeight:(CGFloat)maximumHeight {
    if (_maximumHeight != maximumHeight) {
        _maximumHeight = maximumHeight;
        
        if (self.maximumHeight < [self measureHeight]) {
            self.forceSizeUpdate = YES;
            [self textViewDidChange:self.internalTextView];
        }
    }
}

- (void) sizeToFit {
    CGRect r = self.frame;
    if ([self.text length] > 0) {
        /* No need to resize is text is not empty */
        return;
    }
    r.size.height = self.minimumHeight;
    self.frame = r;
}

- (void) clearText {
    self.text = @"";
    [self textViewDidChange:self.internalTextView];
}

- (void) setPlaceholder:(NSString *)placeholders {
    _placeholder = placeholders;
    self.placeholderLabel.text = placeholders;
}

- (NSInteger) maximumNumberOfLines {
    return _maximumNumberOfLines;
}
     
- (void) setMaximumNumberOfLines:(NSInteger)n {
    BOOL didChange            = NO;
    NSString *saveText        = self.internalTextView.text;
    NSString *newText         = @"-";
    self.internalTextView.hidden   = YES;
    self.internalTextView.delegate = nil;
    for (int i = 2; i <= n; ++i) {
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    self.internalTextView.text = newText;
    CGFloat height = [self measureHeight];
    didChange = (self.maximumHeight != height);
    self.maximumHeight = height;
    self.internalTextView.text = saveText;
    self.internalTextView.hidden = NO;
    self.internalTextView.delegate = self;
    _maximumNumberOfLines = n;
    if (didChange) {
        self.forceSizeUpdate = YES;
        [self textViewDidChange:self.internalTextView];
    }
}

- (NSInteger) minimumNumberOfLines {
    return _minimumNumberOfLines;
}

- (void) setMinimumNumberOfLines:(NSInteger)m {
    NSString *saveText        = self.internalTextView.text;
    NSString *newText         = @"-";
    self.internalTextView.hidden   = YES;
    self.internalTextView.delegate = nil;
    for (int i = 2; i < m; ++i) {
        newText = [newText stringByAppendingString:@"\n|W|"];
    }
    self.internalTextView.text = newText;
    self.minimumHeight = [self measureHeight];
    self.internalTextView.text = saveText;
    self.internalTextView.hidden = NO;
    self.internalTextView.delegate = self;
    _minimumNumberOfLines = m;
}


// Code from apple developer forum - @Steve Krulewitz, @Mark Marszal, @Eric Silverberg
- (CGFloat) measureHeight {
    CGRect frame = self.internalTextView.bounds;
    CGSize fudgeFactor;
    // The padding added around the text on iOS6 and iOS7 is different.
    fudgeFactor = CGSizeMake(10.0, 16.0);
    
    frame.size.height -= fudgeFactor.height;
    frame.size.width -= fudgeFactor.width + self.internalTextView.textContainerInset.left + self.internalTextView.textContainerInset.right;
    
    static NSMutableAttributedString* textToMeasure;
    if(self.internalTextView.attributedText && self.internalTextView.attributedText.length > 0){
        textToMeasure = [[NSMutableAttributedString alloc] initWithAttributedString:self.internalTextView.attributedText];
    }
    else{
        textToMeasure = [[NSMutableAttributedString alloc] initWithString:self.internalTextView.text];
        [textToMeasure addAttribute:NSFontAttributeName value:self.internalTextView.font range:NSMakeRange(0, textToMeasure.length)];
    }
    
    if ([textToMeasure.string hasSuffix:@"\n"])
    {
        [textToMeasure appendAttributedString:[[NSAttributedString alloc] initWithString:@"-" attributes:@{NSFontAttributeName: self.internalTextView.font}]];
    }
    
    // NSAttributedString class method: boundingRectWithSize:options:context is
    // available only on ios7.0 sdk.
    CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil];
    
    return CGRectGetHeight(size) + fudgeFactor.height;
}

- (void) textViewDidChange:(UITextView *)textView {
    
    self.placeholderLabel.alpha = textView.text.length == 0 ? 1 : 0;
    
    CGFloat textHeight = [self measureHeight];
	__block CGFloat newHeight = textHeight;
	
    if(newHeight < self.minimumHeight || ![self hasText]) {
        newHeight = self.minimumHeight;
    }
    
    if (newHeight > self.maximumHeight) {
        newHeight = self.maximumHeight;
    }
    
	if (self.frame.size.height != newHeight || self.forceSizeUpdate) {
        self.forceSizeUpdate = NO;
		if (newHeight <= self.maximumHeight) {
            
            if (self.animateHeightChange) {
                [UIView animateWithDuration:0.2 animations:^{
                    [self updateHeight:newHeight];
                }];
            }
            else {
                [self updateHeight:newHeight];
            }
		}
	}
    
    if (textHeight > self.maximumHeight) {
        CGRect line = [textView caretRectForPosition:
                       textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height
        - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = textView.contentOffset;
            offset.y += overflow + textView.textContainerInset.bottom;
            [textView setContentOffset:offset];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(expandingTextViewDidChange:)]) {
		[self.delegate expandingTextViewDidChange:self];
	}
}

- (void) updateHeight:(CGFloat) newHeight {
    if ([self.delegate respondsToSelector:@selector(expandingTextView:willChangeHeight:)]) {
        [self.delegate expandingTextView:self willChangeHeight:(newHeight)];
    }
    
    if (newHeight >= self.maximumHeight) {
        // Enable vertical scrolling
        if(!self.internalTextView.scrollEnabled) {
            self.internalTextView.scrollEnabled = YES;
            [self.internalTextView flashScrollIndicators];
        }
    }
    else {
        // Disable vertical scrolling
        self.internalTextView.scrollEnabled = NO;
    }
    
    // Force UITextView to rerender text after height changes
    if (self.frame.size.height < newHeight) {
        self.internalTextView.frame = CGRectInset(self.internalTextView.frame, 1, 0);
        self.internalTextView.frame = CGRectInset(self.internalTextView.frame, -1, 0);
    }
    
    // Resize the frame
    CGRect r = self.frame;
    r.size.height = newHeight;
    self.frame = r;

    if ([self.delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)]) {
        [self.delegate expandingTextView:self didChangeHeight:self.frame.size.height];
    }
}

- (void) reloadInputViews {
    [self.internalTextView reloadInputViews];
}

- (void) setInputView:(UIView *)inputView {
    [self.internalTextView setInputView:inputView];
}

- (UIView *) inputView {
    return self.internalTextView.inputView;
}

- (BOOL) becomeFirstResponder {
    return [self.internalTextView becomeFirstResponder];
}

- (BOOL) resignFirstResponder {
	[super resignFirstResponder];
	return [self.internalTextView resignFirstResponder];
}

#pragma mark UITextView properties

-(void) setText:(NSString *)atext {
	self.internalTextView.text = atext;
    [self performSelector:@selector(textViewDidChange:) withObject:self.internalTextView];
}

- (NSString *) text {
	return self.internalTextView.text;
}

- (void) setFont:(UIFont *)afont {
	self.internalTextView.font = afont;
    self.placeholderLabel.font = afont;
    [self setMaximumNumberOfLines:self.maximumNumberOfLines];
	[self setMinimumNumberOfLines:self.minimumNumberOfLines];
}

- (UIFont *) font {
	return self.internalTextView.font;
}	

- (void) setTextColor:(UIColor *)color {
	self.internalTextView.textColor = color;
}

- (UIColor *) textColor {
	return self.internalTextView.textColor;
}

- (void) setTextAlignment:(NSTextAlignment)aligment {
	self.internalTextView.textAlignment = aligment;
}

- (NSTextAlignment) textAlignment {
	return self.internalTextView.textAlignment;
}

- (void) setSelectedRange:(NSRange)range {
	self.internalTextView.selectedRange = range;
}

- (NSRange) selectedRange {
	return self.internalTextView.selectedRange;
}

- (void) setEditable:(BOOL)beditable {
	self.internalTextView.editable = beditable;
}

- (BOOL) isEditable {
	return self.internalTextView.editable;
}

- (void) setReturnKeyType:(UIReturnKeyType)keyType {
	self.internalTextView.returnKeyType = keyType;
}

- (UIReturnKeyType) returnKeyType {
	return self.internalTextView.returnKeyType;
}

- (void) setDataDetectorTypes:(UIDataDetectorTypes)datadetector {
	self.internalTextView.dataDetectorTypes = datadetector;
}

- (UIDataDetectorTypes) dataDetectorTypes {
	return self.internalTextView.dataDetectorTypes;
}

- (BOOL) hasText {
	return self.internalTextView.text.length > 0;
}

- (void) scrollRangeToVisible:(NSRange)range {
	[self.internalTextView scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark UIExpandingTextViewDelegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(expandingTextViewShouldBeginEditing:)]) {
		return [self.delegate expandingTextViewShouldBeginEditing:self];
	}
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(expandingTextViewShouldEndEditing:)]) {
		return [self.delegate expandingTextViewShouldEndEditing:self];
	}
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(expandingTextViewDidBeginEditing:)]) {
		[self.delegate expandingTextViewDidBeginEditing:self];
	}
}

- (void) textViewDidEndEditing:(UITextView *)textView  {
	if ([self.delegate respondsToSelector:@selector(expandingTextViewDidEndEditing:)]) {
		[self.delegate expandingTextViewDidEndEditing:self];
	}
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext {
	if(![textView hasText] && [atext isEqualToString:@""]) {
        return NO;
	}
    
	if ([atext isEqualToString:@"\n"]) {
		if ([self.delegate respondsToSelector:@selector(expandingTextViewShouldReturn:)]) {
			if (![self.delegate performSelector:@selector(expandingTextViewShouldReturn:) withObject:self]) {
				return YES;
			} 
            else {
				[textView resignFirstResponder];
				return NO;
			}
		}
	}
	return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
	if ([self.delegate respondsToSelector:@selector(expandingTextViewDidChangeSelection:)]) {
		[self.delegate expandingTextViewDidChangeSelection:self];
	}
}

@end
