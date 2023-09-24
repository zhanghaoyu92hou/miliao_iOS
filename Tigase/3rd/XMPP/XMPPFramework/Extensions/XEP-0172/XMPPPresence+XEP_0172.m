#import "XMPPPresence+XEP_0172.h"
#import "NSXMLElement+XMPP.h"

#define XMLNS_NICK @"http://jabber.org/protocol/nick"

@implementation XMPPPresence (XEP_0172)

- (NSString *)nick{
	return [[self elementForName:@"nick" xmlns:XMLNS_NICK] stringValue];
}

- (void)addNick:(NSString *)nick
{
    NSXMLElement *nickElement = [NSXMLElement elementWithName:@"nick" xmlns:XMLNS_NICK];
    [nickElement WH_addChild:[NSXMLNode textWithStringValue:nick]];
    [self WH_addChild:nickElement];
}

@end
