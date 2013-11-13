/*
 *  UIExpandingTextView.h
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

#import <UIKit/UIKit.h>

@interface UITextView (readwriteInputView)
@property (readwrite, retain) UIView *inputView;
@end

@class UIExpandingTextView;

@protocol UIExpandingTextViewDelegate

@optional
- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView;
- (BOOL)expandingTextViewShouldEndEditing:(UIExpandingTextView *)expandingTextView;

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView;
- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView;

- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView;

- (void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(CGFloat)height;
- (void)expandingTextView:(UIExpandingTextView *)expandingTextView didChangeHeight:(CGFloat)height;

- (void)expandingTextViewDidChangeSelection:(UIExpandingTextView *)expandingTextView;
- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView;
@end

@interface UIExpandingTextView : UIView <UITextViewDelegate>
@property (weak,nonatomic) NSObject<UIExpandingTextViewDelegate> *delegate;
@property (nonatomic, strong) UITextView *internalTextView;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *textColor;
#ifdef __IPHONE_6_0
@property (nonatomic) NSTextAlignment textAlignment;
#else
@property (nonatomic) UITextAlignment textAlignment;
#endif
@property (nonatomic) NSRange selectedRange;
@property (nonatomic,getter=isEditable) BOOL editable;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic, strong) UIImageView *textViewBackgroundImage;
@property (nonatomic,copy) NSString *placeholder;
@property (strong,nonatomic) UILabel *placeholderLabel;
@property NSInteger maximumNumberOfLines;
@property NSInteger minimumNumberOfLines;
@property CGFloat minimumHeight;
@property CGFloat maximumHeight;
@property BOOL animateHeightChange;
@property BOOL forceSizeUpdate;
@property (readwrite, nonatomic) UIView *inputView;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;
- (void)clearText;

@end
