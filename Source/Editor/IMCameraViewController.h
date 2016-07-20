//
//  ImojiSDKUI
//
//  Created by Alex Hoang
//  Copyright (C) 2016 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <ImojiSDK/IMImojiSession.h>

//extern CGFloat const NavigationBarHeight;
//extern CGFloat const DefaultButtonTopOffset;
//extern CGFloat const CaptureButtonBottomOffset;
//extern CGFloat const CameraViewBottomButtonBottomOffset;

@protocol IMCameraViewControllerDelegate;

@interface IMCameraViewController : UIViewController

@property(nonatomic, strong, readonly, nonnull) IMImojiSession *session;
@property(nonatomic, readonly) UIImageOrientation currentOrientation;

// Top toolbar
//@property(nonatomic, strong, readonly, nullable) UIToolbar *navigationBar;
//@property(nonatomic, strong, readonly, nullable) UIBarButtonItem *cancelButton;
//
//// Bottom buttons
//@property(nonatomic, strong, readonly, nullable) UIButton *captureButton;
//@property(nonatomic, strong, readonly, nullable) UIButton *flipButton;
//@property(nonatomic, strong, readonly, nullable) UIButton *photoLibraryButton;

@property(nonatomic, weak, nullable) id <IMCameraViewControllerDelegate> delegate;

- (nonnull instancetype)initWithSession:(IMImojiSession *__nonnull)session;

+ (nonnull instancetype)imojiCameraViewControllerWithSession:(IMImojiSession *__nonnull)session;

@end

@protocol IMCameraViewControllerDelegate <NSObject>

@optional

- (void)userDidCancelCameraViewController:(nonnull IMCameraViewController *)viewController;

- (void)userDidCaptureImage:(UIImage *__nonnull)image metadata:(NSDictionary *__nonnull)metadata fromCameraViewController:(nonnull IMCameraViewController *)viewController;

- (void)userDidPickMediaWithInfo:(NSDictionary<NSString *, id> *__nonnull)info fromImagePickerController:(nonnull UIImagePickerController *)picker;

@end
