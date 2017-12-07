#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, FontTrait) {
    FontTraitNone = 0,
    FontTraitBold = 1 << 0,
    FontTraitItalic = 1 << 1,
    FontTraitCode = 1 << 8,
    FontTraitParagraph = 1 << 9,
    FontTraitHeadingOne = 1 << 10,
    FontTraitHeadingTwo = 1 << 11,
    FontTraitHeadingThree = 1 << 12,
    FontTraitPreformat = 1 << 13,
    FontTraitBlockquote = 1 << 14
};

extern NSString *const kMessageParserStyleKey;
extern NSString *const kMessageParserLinkKey;
extern NSString *const kMessageParserIndentLevelKey;
extern NSString *const kMessageParserBlockPaddingKey;

extern NSString *const kConversationMessageMentionTagName;
extern NSString *const kConversationMessageMentionIDKey;
extern NSString *const kConversationMessageMentionTypeKey ;
extern NSString *const kConversationMessageMentionGroupTypeKey;
extern NSString *const kConversationMessageMentionTypePersonValue;
extern NSString *const kConversationMessageMentionTypeGroupMentionValue;


@interface MessageParser : NSObject

+ (instancetype)sharedInstance;

- (NSAttributedString *)translateToAttributedString:(NSString *)textWithMarkup;
- (NSString *)translateToMarkedUpString:(NSAttributedString *)attributedString;
- (NSString *)taggedStringForString:(NSString *)string tag:(NSString *)tag attributes:(NSDictionary *)attributes;

@end
