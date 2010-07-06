//
//  AudioStreamPlayer.h
//  radikker
//
//  Created by saiten on 10/03/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define AUDIOBUFFER_COUNT 3
#define AUDIOBUFFER_SIZE  32000
#define PACKET_DESC_COUNT 160

@interface AudioStreamPlayer : NSObject {
	id delegate;

	NSFileHandle *inputHandle;

	AudioFileStreamID audioStreamId;
	AudioStreamBasicDescription audioBasicDesc;
	AudioQueueRef audioQueue;

	UInt32 bufferSize;
	AudioQueueBufferRef audioBuffers[AUDIOBUFFER_COUNT];
	BOOL useBuffer[AUDIOBUFFER_COUNT];
	int targetBufferIndex;
	UInt32 fillBufferSize;
	
	AudioStreamPacketDescription packetDescs[PACKET_DESC_COUNT];
	UInt32 fillPacketDescIndex;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSFileHandle *inputHandle;

- (id)initWithDelegate:(id)aDelegate bufferSize:(UInt32)size;
- (void)play;
- (void)stop;

@end

@interface NSObject(AudioStreamPlayerDelegate)
- (void)audioStreamPlayerDidPlay:(AudioStreamPlayer*)player;
- (void)audioStreamPlayerDidStop:(AudioStreamPlayer*)player;
- (void)audioStreamPlayerDidEmptyBuffer:(AudioStreamPlayer*)player;
@end