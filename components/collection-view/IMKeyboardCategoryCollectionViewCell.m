//
// Created by Nima on 7/30/15.
// Copyright (c) 2015 Jeff. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "IMKeyboardCategoryCollectionViewCell.h"
#import "ImojiTextUtil.h"
#import "IMCollectionView.h"


@implementation IMKeyboardCategoryCollectionViewCell {

}


- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage {
    float imageHeightRatio = 0.66f;
    float textHeightRatio = 0.18f;
    int inBetweenPadding = 3;

    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        float padding = (self.frame.size.height - (imageHeightRatio*self.frame.size.height) - (textHeightRatio*self.frame.size.height) - inBetweenPadding)/2.f;

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.width.equalTo(self.mas_height).multipliedBy(imageHeightRatio);
            make.top.equalTo(self.mas_top).offset(padding);
        }];
    }

    if (!self.titleView) {
        self.titleView = [UILabel new];

        [self addSubview:self.titleView];
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(self);
            make.height.equalTo(self.mas_height).multipliedBy(textHeightRatio);
            make.top.equalTo(self.imojiView.mas_bottom).offset(inBetweenPadding);
        }];
    }

    if (imojiImage) {
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        self.imojiView.image = imojiImage;
        self.imojiView.highlightedImage = [self tintImage:imojiImage withColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
    } else {
        self.imojiView.contentMode = UIViewContentModeCenter;
        self.imojiView.image = [IMCollectionView placeholderImageWithRadius:20];
    }

    self.titleView.attributedText = [ImojiTextUtil attributedString:categoryTitle
                                                       withFontSize:14.0f
                                                          textColor:[UIColor colorWithRed:60/255.f green:60/255.f blue:60/255.f alpha:1.f]
                                                      textAlignment:NSTextAlignmentCenter];
}

- (UIImage *)tintImage:(UIImage*)image withColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect drawRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

@end
