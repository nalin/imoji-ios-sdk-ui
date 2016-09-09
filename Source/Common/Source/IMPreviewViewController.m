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

#import <ImojiSDK/IMImojiCategoryObject.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMPreviewViewController.h>
#import <Masonry/View+MASAdditions.h>

@interface IMPreviewViewController ()

@property(nonatomic, strong) UIView *previewView;

@end

@implementation IMPreviewViewController

- (instancetype)initWithView:(UIView *)view {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.previewView = view;

        [self.view addSubview:self.previewView];

        [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.previewView isKindOfClass:[IMCollectionView class]]) {
        if (self.previewCategory) {
            [(IMCollectionView *) self.previewView loadImojisFromCategory:self.previewCategory contributingImoji:self.previewImojiImage];
        } else {
            [(IMCollectionView *) self.previewView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
        }
    }
}


@end