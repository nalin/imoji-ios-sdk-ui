//
//  ViewController.m
//  imoji-editor
//
//  Created by Nima Khoshini on 9/4/15.
//  Copyright (c) 2015 Imoji. All rights reserved.
//

#import <ImojiSDK/ImojiSDK.h>
#import "ViewController.h"

@interface ViewController () <IMCreateImojiViewControllerDelegate>

@end

@implementation ViewController


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithSourceImage:[UIImage imageNamed:@"big-big-dog.jpg"] session:[IMImojiSession imojiSession]];

    self.createDelegate = self;
    if (self) {
        // nothing really to do :(
    }

    return self;
}

- (void)userDidFinishCreatingImoji:(IMImojiObject *)imoji withError:(NSError *)error {
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Unable to create Imoji :("
                                   message:[NSString stringWithFormat:@"error: %@", error]
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Imoji Created!"
                                   message:@"You did it!"
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil] show];
    }
}

@end
