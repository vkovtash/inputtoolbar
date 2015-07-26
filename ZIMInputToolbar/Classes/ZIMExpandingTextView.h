/*
 *  ZIMExpandingTextView.h
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

@class ZIMExpandingTextView;

@protocol ZIMExpandingTextViewDelegate

@optional
- (BOOL)expandingTextViewShouldBeginEditing:(ZIMExpandingTextView *)expandingTextView;
- (BOOL)expandingTextViewShouldEndEditing:(ZIMExpandingTextView *)expandingTextView;

- (void)expandingTextViewDidBeginEditing:(ZIMExpandingTextView *)expandingTextView;
- (void)expandingTextViewDidEndEditing:(ZIMExpandingTextView *)expandingTextView;

- (BOOL)expandingTextView:(ZIMExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)expandingTextViewDidChange:(ZIMExpandingTextView *)expandingTextView;

- (void)expandingTextView:(ZIMExpandingTextView *)expandingTextView willChangeHeight:(CGFloat)height;
- (void)expandingTextView:(ZIMExpandingTextView *)expandingTextView didChangeHeight:(CGFloat)height;

- (void)expandingTextViewDidChangeSelection:(ZIMExpandingTextView *)expandingTextView;
- (BOOL)expandingTextViewShouldReturn:(ZIMExpandingTextView *)expandingTextView;
@end


typedef NS_ENUM(int16_t, ZIMExpandingTextViewVerticalAlign) {
    ZIMExpandingTextViewVerticalAlignBottom,
    ZIMExpandingTextViewVerticalAlignCenter,
    ZIMExpandingTextViewVerticalAlignTop,
};


@interface ZIMExpandingTextView : UIView <UITextViewDelegate>
@property (nonatomic, weak) NSObject<ZIMExpandingTextViewDelegate> *delegate;
@property (nonatomic, strong) UITextView *internalTextView;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, assign) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic, assign) UIReturnKeyType returnKeyType;
@property (nonatomic, strong) UIImageView *textViewBackgroundImage;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) NSInteger maximumNumberOfLines;
@property (nonatomic, assign) NSInteger minimumNumberOfLines;
@property (nonatomic, assign) CGFloat minimumHeight;
@property (nonatomic, assign) CGFloat maximumHeight;
@property (nonatomic, assign) BOOL animateHeightChange;
@property (nonatomic, assign) BOOL forceSizeUpdate;
@property (nonatomic, readwrite) UIView *inputView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, assign) ZIMExpandingTextViewVerticalAlign rightViewVerticalAlign;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, assign) ZIMExpandingTextViewVerticalAlign leftViewVerticalAlign;

- (BOOL) hasText;
- (void) scrollRangeToVisible:(NSRange)range;
- (void) clearText;
- (void) replaceString:(NSString *)str withObjectFromString:(NSString *)stringToConvert;

@end
