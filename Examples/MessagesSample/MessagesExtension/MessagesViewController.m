//
//  MessagesViewController.m
//  MessagesExtension
//
//  Created by Nima on 6/30/16.
//  Copyright © 2016 Imoji. All rights reserved.
//

#import "MessagesViewController.h"
#import <ImojiSDK/ImojiSDK.h>
#import <ImojiSDKUI/IMCollectionViewController.h>

@interface MessagesViewController () <IMCollectionViewControllerDelegate>

@property(nonatomic, strong) IMImojiSession* session;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.session) {
        [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"748cddd4-460d-420a-bd42-fcba7f6c031b"]
                                      apiToken:@"U2FsdGVkX1/yhkvIVfvMcPCALxJ1VHzTt8FPZdp1vj7GIb+fsdzOjyafu9MZRveo7ebjx1+SKdLUvz8aM6woAw=="];
        self.session = [IMImojiSession imojiSession];
    }
    
    [self loadStickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Conversation Handling

-(void)didBecomeActiveWithConversation:(MSConversation *)conversation {
    
}

-(void)willResignActiveWithConversation:(MSConversation *)conversation {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dissmises the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
}

-(void)didReceiveMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
}

-(void)didStartSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user taps the send button.
}

-(void)didCancelSendingMessage:(MSMessage *)message conversation:(MSConversation *)conversation {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
}

-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
}

-(void)didTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
}

- (void)loadStickerView {
    for (UIViewController *child in self.childViewControllers) {
        [child willMoveToParentViewController:nil];
        [child.view removeFromSuperview];
        [child removeFromParentViewController];
    }
    
    IMCollectionViewController* stickerController = [[IMCollectionViewController alloc] initWithSession:self.session];
    stickerController.collectionViewControllerDelegate = self;
    
    // shows the sticker cells as MSStickerView's, allowing users to drag and drop them onto their conversations
    stickerController.collectionView.loadUsingStickerViews = YES;
    
    // load larger, non-bordered stickers
    stickerController.collectionView.renderingOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSize320 borderStyle:IMImojiObjectBorderStyleNone];
    
    [self addChildViewController:stickerController];
    
    [self.view addSubview:stickerController.view];
    stickerController.view.frame = self.view.bounds;
    
    [stickerController.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [stickerController.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [stickerController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [stickerController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    stickerController.searchView.userInteractionEnabled = YES;
    
    [stickerController didMoveToParentViewController:self];
    
    [stickerController.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}


- (void)userDidSelectImoji:(IMImojiObject *)imoji fromCollectionView:(IMCollectionView *)collectionView {
    if (self.activeConversation) {
        IMImojiObjectRenderingOptions *renderingOptions;
        if (imoji.supportsAnimation) {
            renderingOptions = [IMImojiObjectRenderingOptions optionsWithAnimationAndRenderSize:IMImojiObjectRenderSize320];
        } else {
            renderingOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSize320 borderStyle:IMImojiObjectBorderStyleSticker];
        }
        
        [self.session renderImojiAsMSSticker:imoji
                                     options:renderingOptions
                                    callback:^(NSObject * _Nullable msStickerObject, NSError * _Nullable error) {
                                        if (error) {
                                            NSLog(@":( looks like we got an error %@", error);
                                        } else {
                                            [self.activeConversation insertSticker:(MSSticker*) msStickerObject
                                                                 completionHandler:^(NSError * _Nullable insertError) {
                                                                     if (insertError) {
                                                                         NSLog(@":( looks like we got another terrible error %@", insertError);
                                                                     }
                                                                 }];
                                        }
                                    }];
    }
}

@end