//
//  ImojiSDKUI
//
//  Created by Thor Harald Johansen, Nima Khoshini
//  Copyright (C) 2015 Imoji
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

#import "IMEditorView.h"
#import <ImojiGraphics/ImojiGraphics.h>

@interface IMEditorView ()

@property(nonatomic) IGContext *igContext;
@property(nonatomic, readwrite) IGImage *igInputImage;
@property(nonatomic) IGEditor *igEditor;
@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, assign) BOOL firstDrawRect;

@end

@implementation IMEditorView

//@synthesize outputImage;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.firstDrawRect = YES;
        self.multipleTouchEnabled = YES;
        self.contentScaleFactor = 1;

        self.igContext = igContextCreate();
        self.context = (__bridge EAGLContext *) self.igContext->appleEAGLContext;

        self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
        self.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
        self.drawableStencilFormat = GLKViewDrawableStencilFormat8;

        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        self.displayLink.paused = true; // Don't waste battery with 60 FPS animation when idle!
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }

    return self;
}

- (void)dealloc {
    self.displayLink.paused = true;
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    if (self.igEditor != nil) {
        igEditorDestroy(self.igEditor);
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.igInputImage != nil) {
        if (self.firstDrawRect) {
            self.firstDrawRect = NO;

            // Fetch OpenGL viewport bounds into array
            GLint viewport[4];//GLint UnsafeMutablePointer < GLint >.alloc(4)
            glGetIntegerv((GLenum) GL_VIEWPORT, viewport);

            // Calculate width/height from it
            GLint viewportWidth = viewport[2] - viewport[0];
            GLint viewportHeight = viewport[3] - viewport[1];

            if (igImageGetWidth(self.igInputImage) > viewportWidth) {
                igEditorZoomTo(self.igEditor, (CGFloat) viewportWidth / (CGFloat) igImageGetWidth(self.igInputImage));
            } else if (igImageGetHeight(self.igInputImage) > viewportHeight) {
                igEditorZoomTo(self.igEditor, (CGFloat) viewportHeight / (CGFloat) igImageGetHeight(self.igInputImage));
            }
        }

        igEditorDisplay(self.igEditor);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.igEditor != nil) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self];
            igEditorTouchEvent(self.igEditor, IG_TOUCH_BEGAN, (__bridge void *) touch, (IGfloat) location.x, (IGfloat) location.y);
        }

        self.displayLink.paused = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.igEditor != nil) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self];
            igEditorTouchEvent(self.igEditor, IG_TOUCH_MOVED, (__bridge void *) touch, (IGfloat) location.x, (IGfloat) location.y);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.igEditor != nil) {
        self.displayLink.paused = YES;

        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self];
            igEditorTouchEvent(self.igEditor, IG_TOUCH_ENDED, (__bridge void *) touch, (IGfloat) location.x, (IGfloat) location.y);
        }

        [self setNeedsDisplay];

        if (self.editorDelegate && [self.editorDelegate respondsToSelector:@selector(userDidUpdatePathInEditorView:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.editorDelegate userDidUpdatePathInEditorView:self];
            });
        }
    }
}

- (void)undo {
    if (self.igEditor != nil) {
        igEditorUndo(self.igEditor);
        [self setNeedsDisplay];
    }
}

- (BOOL)hasOutputImage {
    return self.igEditor != nil && igEditorImojiIsReady(self.igEditor);
}

- (BOOL)canUndo {
    return self.igEditor != nil && igEditorCanUndo(self.igEditor);
}

- (void)scrollTo:(CGPoint)point {
    if (!self.igEditor) {
        return;
    }

    igEditorScrollTo(self.igEditor, point.x, point.y);
}

- (void)zoomTo:(CGFloat)zoom {
    if (!self.igEditor) {
        return;
    }

    igEditorZoomTo(self.igEditor, zoom);
}

- (void)loadImage:(UIImage *)image {
    self.igInputImage = igImageFromNative(self.igContext, image.CGImage, 1);

    [self reset];
}

- (void)reset {
    if (!self.igInputImage) {
        return;
    }

    if (self.igEditor != nil) {
        igEditorDestroy(self.igEditor);
    }

    self.igEditor = igEditorCreate(self.igInputImage);
    self.firstDrawRect = YES;

    [self setNeedsDisplay];
}

- (UIImage *)outputImage {
    if (!self.hasOutputImage) {
        return nil;
    }

    IGImage *trimmedImage = igEditorGetTrimmedOutputImage(self.igEditor);
    CGImageRef pImage = igImageToNative(trimmedImage);
    igImageDestroy(trimmedImage);

    return [UIImage imageWithCGImage:pImage];
}

- (UIImage *)borderedOutputImage {
    UIImage* image = self.outputImage;
    if (!image) {
        return nil;
    }

    IGBorder* border = igBorderCreatePreset(image.size.width, image.size.height, IG_BORDER_CLASSIC);
    IGImage *igPlainImage = igImageFromNative(self.igContext, image.CGImage, igBorderGetPadding(border));
    IGint padding = igBorderGetPadding(border);
    IGImage *outputImage = igImageCreate(self.igContext, igImageGetWidth(igPlainImage) + (padding * 2), igImageGetHeight(igPlainImage) + (padding * 2));

    igBorderRender(border, igPlainImage, outputImage, (IGfloat) padding, (IGfloat) padding, 1, 1);

    CGImageRef pImage = igImageToNative(outputImage);
    UIImage *borderedImoji = [UIImage imageWithCGImage:pImage];

    igImageDestroy(igPlainImage);
    igImageDestroy(outputImage);
    
    return borderedImoji;
}

@end
