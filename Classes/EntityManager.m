//
//  EntityManager.m
//  calendar
//
//  Created by Fravic Fernando on 12-04-04.
//  Copyright 2012 University of Waterloo. All rights reserved.
//

#import "EntityManager.h"


@implementation EntityManager

@synthesize entitiesByClass=_entities;

- (id)initWithView:(UIView*)view andDelegate:(id<CalendarViewDelegate>)delegate {
	_view = view;
	_delegate = delegate;
	_entities = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)registerEntity:(CalendarEntity*)entity withKey:(NSObject*)key {
	[_view addSubview:entity];
	
	if ([_entities objectForKey:[entity class]] == nil) {
		[_entities setObject:[[NSMutableDictionary alloc] init] forKey:[entity class]];
	}
	
	[[_entities objectForKey:[entity class]] setObject:entity forKey:key];
	[entity setEntKey:key];
}

- (NSArray*)allEntities {
	NSEnumerator *classes = [_entities objectEnumerator];
	NSMutableArray *entities = [[NSMutableArray alloc] init];
	
	NSDictionary *entitiesOfClass;
	while (entitiesOfClass = [classes nextObject]) {
		[entities addObjectsFromArray:[entitiesOfClass allValues]];
	}
	
	return entities;
}

- (void)removeEntity:(CalendarEntity*)entity {
	[[_entities objectForKey:[entity class]] removeObjectForKey:[entity entKey]];
	[entity removeFromSuperview];
}

- (BOOL)entityExistsWithClass:(Class)type andKey:(NSObject*)key {
	NSMutableDictionary *entsOfClass = [_entities objectForKey:type];
	return [entsOfClass objectForKey:key] != nil;
}

- (CalendarDay*)createCalendarDayWithStartTime:(NSTimeInterval)startTime {
	CGSize size = CGSizeMake([_view frame].size.width, [_delegate getPixelsPerHour] * HOURS_PER_DAY);
	int endTime = startTime + SECONDS_PER_HOUR * HOURS_PER_DAY;
	CalendarDay *newDay = [[CalendarDay alloc] initWithSize:size startTime:startTime endTime:endTime andDelegate:_delegate];
	return newDay;
}

- (EventBlock*)createEventBlockWithStartTime:(NSTimeInterval)startTime {
	CGSize size = CGSizeMake([_view frame].size.width, [_delegate getPixelsPerHour] * HOURS_PER_DAY);
	int numEventBlocks = [(NSDictionary*)[_entities objectForKey:[EventBlock class]] count];
	EventBlock *newBlock = [[EventBlock alloc] initWithSize:size startTime:startTime endTime:startTime andDelegate:_delegate];
	[self registerEntity:newBlock withKey:[NSNumber numberWithInt:numEventBlocks]];
	return newBlock;
}

@end
