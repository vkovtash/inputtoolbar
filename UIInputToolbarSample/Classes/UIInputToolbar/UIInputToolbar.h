/*
 *  UIInputToolbar.h
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
#import "UIExpandingTextView.h"
@class UIInputToolbar;

@protocol UIInputToolbarDelegate <NSObject>
@optional
-(void)inputButtonPressed:(UIInputToolbar *) toolbar;
-(void)plusButtonPressed:(UIInputToolbar *) toolbar;
-(void)inputToolbar:(UIInputToolbar *) inputToolbar DidChangeHeight:(CGFloat) height;
-(void)inputToolbar:(UIInputToolbar *) inputToolbar WillChangeHeight:(CGFloat) height;

- (BOOL)inputToolbarShouldBeginEditing:(UIInputToolbar *)inputToolbar;
- (BOOL)inputToolbarShouldEndEditing:(UIInputToolbar *)inputToolbar;
- (void)inputToolbarDidBeginEditing:(UIInputToolbar *)inputToolbar;
- (void)inputToolbarDidEndEditing:(UIInputToolbar *)inputToolbar;
- (BOOL)inputToolbar:(UIInputToolbar *)inputToolbar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)inputToolbarViewDidChange:(UIInputToolbar *)inputToolbar;
- (void)inputToolbarViewDidChangeSelection:(UIInputToolbar *)inputToolbar;
@end

@interface UIInputToolbar : UIToolbar <UIExpandingTextViewDelegate>
@property (nonatomic) BOOL animateHeightChanges;
@property (strong,nonatomic) UIExpandingTextView *textView;
@property (strong,nonatomic) UIBarButtonItem *inputButton;
@property (strong,nonatomic) UIBarButtonItem *plusButtonItem;
@property (nonatomic) BOOL isPlusButtonVisible;
@property (weak,nonatomic) NSObject<UIInputToolbarDelegate> *inputDelegate;

- (id)initWithFrame:(CGRect)frame label:(NSString *)label;
@end
