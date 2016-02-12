/*
 *  ZIMInputToolbar.h
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

#import <UIKit/UIKit.h>
#import "ZIMExpandingTextView.h"

@class ZIMInputToolbar;

@protocol ZIMInputToolbarDelegate <NSObject>
@optional
- (void) inputButtonPressed:(ZIMInputToolbar *)toolbar;
- (void) plusButtonPressed:(ZIMInputToolbar *)toolbar;
- (void) inputToolbar:(ZIMInputToolbar *)inputToolbar didChangeHeight:(CGFloat)height;
- (void) inputToolbar:(ZIMInputToolbar *)inputToolbar willChangeHeight:(CGFloat)height;

- (BOOL) inputToolbarShouldBeginEditing:(ZIMInputToolbar *)inputToolbar;
- (BOOL) inputToolbarShouldEndEditing:(ZIMInputToolbar *)inputToolbar;
- (void) inputToolbarDidBeginEditing:(ZIMInputToolbar *)inputToolbar;
- (void) inputToolbarDidEndEditing:(ZIMInputToolbar *)inputToolbar;
- (BOOL) inputToolbar:(ZIMInputToolbar *)inputToolbar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void) inputToolbarViewDidChange:(ZIMInputToolbar *)inputToolbar;
- (void) inputToolbarViewDidChangeSelection:(ZIMInputToolbar *)inputToolbar;
@end

@interface ZIMInputToolbar : UIToolbar <ZIMExpandingTextViewDelegate>
@property (nonatomic, readonly) ZIMExpandingTextView *textView;
@property (readwrite, nonatomic) NSString *text;
@property (nonatomic, readonly) UIButton *inputButton;
@property (nonatomic, readonly) UIButton *plusButton;
@property (nonatomic, strong) NSArray *alternativeBarButtonItems;
@property (nonatomic, readonly) UIBarButtonItem *edgeSeparator;
@property (nonatomic, weak) id <ZIMInputToolbarDelegate> inputDelegate;
@property (nonatomic, assign) BOOL isPlusButtonVisible;
@property (nonatomic, assign) BOOL animateHeightChanges;
@property (nonatomic, assign) BOOL isInAlternativeMode;

- (instancetype) initWithFrame:(CGRect)frame label:(NSString *)label;
- (instancetype) initWithFrame:(CGRect)frame label:(NSString *)label possibleLabels:(NSSet *)possibleLabels;

- (void) setIsInAlternativeMode:(BOOL)isInAlternativeMode animated:(BOOL)animated;
- (void) setIsPlusButtonVisible:(BOOL)isPlusButtonVisible animated:(BOOL)animated;
@end
