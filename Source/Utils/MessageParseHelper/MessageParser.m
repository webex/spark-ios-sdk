#import "MessageParser.h"

#import "GTMNSMutableString+HTML.h"
#import "gumbo.h"
#import "NSAttributedString+Extensions.h"
#import "RuntimeHelpers.h"

NSString *const kMessageParserStyleKey = @"MessageParserStyleKey";
NSString *const kMessageParserLinkKey = @"MessageParserLinkKey";
NSString *const kMessageParserIndentLevelKey = @"MessageParserIndentLevelKey";
NSString *const kMessageParserBlockPaddingKey = @"MessageParserBlockPaddingKey";

NSString *const kConversationMessageMentionTagName = @"spark-mention";
NSString *const kConversationMessageMentionIDKey = @"data-object-id";
NSString *const kConversationMessageMentionTypeKey = @"data-object-type";
NSString *const kConversationMessageMentionGroupTypeKey = @"data-group-type";
NSString *const kConversationMessageMentionTypePersonValue = @"person";
NSString *const kConversationMessageMentionTypeGroupMentionValue = @"groupMention";


static NSString *const kHTMLTagLinkName = @"a";
static NSString *const kHTMLTagBoldName = @"b";
static NSString *const kHTMLTagStrongName = @"strong";
static NSString *const kHTMLTagItalicName = @"i";
static NSString *const kHTMLTagEmName = @"em";
static NSString *const kHTMLTagCodeName = @"code";
static NSString *const kHTMLTagParagraphName = @"p";
static NSString *const kHTMLTagBlockquoteName = @"blockquote";
static NSString *const kHTMLTagUnorderedListName = @"ul";
static NSString *const kHTMLTagOrderedListName = @"ol";
static NSString *const kHTMLTagListItemName = @"li";
static NSString *const kHTMLTagBreakName = @"br";
static NSString *const kHTMLTagHeadingOneName = @"h1";
static NSString *const kHTMLTagHeadingTwoName = @"h2";
static NSString *const kHTMLTagHeadingThreeName = @"h3";
static NSString *const kHTMLTagPreformattedName = @"pre";




@interface ParserDelegate : NSObject

@property (nonatomic, readonly) NSMutableAttributedString *result;
@property (nonatomic, readonly) NSMutableArray *elements;

- (void)parserFoundCharacters:(NSString *)string;
- (void)parserDidStartElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
- (void)parserDidEndElement:(NSString *)elementName;

@end

@implementation MessageParser

+ (instancetype)sharedInstance {
    DISPATCH_ONCE_SINGLETON( ^{
        return [[MessageParser alloc] init];
    });
}

- (NSAttributedString *)translateToAttributedString:(NSString *)textWithMarkup {
    if (textWithMarkup.length == 0) {
        return nil;
    }
    
    textWithMarkup = [textWithMarkup stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    ParserDelegate *delegate = [[ParserDelegate alloc] init];
    GumboOutput *output = gumbo_parse(textWithMarkup.UTF8String);
    if (output) {
        [self traverseNode:output->root delegate:delegate];
    }
    gumbo_destroy_output(&kGumboDefaultOptions, output);
    return [delegate.result attributedStringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (void)traverseNode:(GumboNode *)node delegate:(ParserDelegate *)delegate {
    if (!node) {
        return;
    }
    switch (node->type) {
        case GUMBO_NODE_ELEMENT: {
            GumboElement element = node->v.element;
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
            for (NSUInteger i = 0; i < element.attributes.length; i++) {
                GumboAttribute *attribute = element.attributes.data[i];
                if (attribute) {
                    [attributes setObject:[NSString stringWithUTF8String:attribute->value]
                                   forKey:[NSString stringWithUTF8String:attribute->name]];
                }
            }
            NSString *elementName;
            if (element.tag == GUMBO_TAG_UNKNOWN && element.original_end_tag.length) {
                GumboStringPiece tag_text = element.original_tag;
                gumbo_tag_from_original_text(&tag_text);
                elementName = [[NSString alloc] initWithBytes:tag_text.data length:tag_text.length encoding:NSUTF8StringEncoding];
            } else {
                elementName = [NSString stringWithUTF8String:gumbo_normalized_tagname(element.tag)];
            }
            [delegate parserDidStartElement:elementName attributes:attributes];
            for (NSUInteger i = 0; i < element.children.length; i++) {
                GumboNode *child = element.children.data[i];
                [self traverseNode:child delegate:delegate];
            }
            [delegate parserDidEndElement:elementName];
            break;
        }
        case GUMBO_NODE_TEXT:
        case GUMBO_NODE_WHITESPACE: {
            GumboText text = node->v.text;
            [delegate parserFoundCharacters:[NSString stringWithUTF8String:text.text]];
            break;
        }
        case GUMBO_NODE_DOCUMENT:
        case GUMBO_NODE_CDATA:
        case GUMBO_NODE_COMMENT:
        default:
            break;
    }
}

+ (NSDictionary *)fontTraitForTag {
    DISPATCH_ONCE_SINGLETON((^{
        return @{ kHTMLTagBoldName : @(FontTraitBold),
                  kHTMLTagStrongName : @(FontTraitBold),
                  kHTMLTagItalicName : @(FontTraitItalic),
                  kHTMLTagEmName : @(FontTraitItalic),
                  kHTMLTagCodeName : @(FontTraitCode),
                  kHTMLTagParagraphName : @(FontTraitParagraph),
                  kHTMLTagHeadingOneName : @(FontTraitHeadingOne),
                  kHTMLTagHeadingTwoName : @(FontTraitHeadingTwo),
                  kHTMLTagHeadingThreeName : @(FontTraitHeadingThree),
                  kHTMLTagPreformattedName : @(FontTraitPreformat),
                  kHTMLTagBlockquoteName : @(FontTraitBlockquote) };
    }));
}

+ (NSSet *)blockElementTags {
    DISPATCH_ONCE_SINGLETON((^{
        return [NSSet setWithArray:@[ kHTMLTagParagraphName,
                                      kHTMLTagHeadingOneName,
                                      kHTMLTagHeadingTwoName,
                                      kHTMLTagHeadingThreeName,
                                      kHTMLTagPreformattedName,
                                      kHTMLTagBlockquoteName,
                                      kHTMLTagUnorderedListName,
                                      kHTMLTagOrderedListName]];
    }));
}

- (NSString *)translateToMarkedUpString:(NSAttributedString *)attributedString {
    if (attributedString.length <= 0) {
        return nil;
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [mutableAttributedString.mutableString encodeHTMLEntitiesWithUnicode:YES];
    NSMutableString *markedUpText = mutableAttributedString.mutableString;
    [mutableAttributedString enumerateAttributesInRange:NSMakeRange(0, markedUpText.length)
                                                options:NSAttributedStringEnumerationReverse
                                             usingBlock:
     ^(NSDictionary *attrs, NSRange range, BOOL *stop) {
         NSDictionary *mentionAttributesDictionary = attrs[kConversationMessageMentionTagName];
         if (mentionAttributesDictionary) {
             NSString *substring = [mutableAttributedString.string substringWithRange:range];
             [markedUpText replaceCharactersInRange:range withString:[self taggedStringForString:substring
                                                                                             tag:kConversationMessageMentionTagName
                                                                                      attributes:mentionAttributesDictionary]];
         }
     }];
    
    return [markedUpText copy];
}

# pragma mark - Supporting Methods

- (NSString *)taggedStringForString:(NSString *)string tag:(NSString *)tag attributes:(NSDictionary *)attributes {
    if (tag.length <= 0 || string.length <= 0) {
        return nil;
    }
    
    NSMutableString *mutableString = [NSMutableString stringWithFormat:@"<%@", tag];
    for (NSString *key in [attributes keysSortedByValueUsingSelector:@selector(compare:)]) {
        NSString *obj = attributes[key];
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
            [mutableString appendFormat:@" %@=\"%@\"", key, obj];
        }
    };
    [mutableString appendFormat:@">%@</%@>", string, tag];
    return [mutableString copy];
}

@end

@implementation ParserDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _result = [[NSMutableAttributedString alloc] init];
        _elements = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)parserFoundCharacters:(NSString *)string {
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    for (NSDictionary *element in self.elements) {
        NSNumber *fontTraitNumber = [MessageParser fontTraitForTag][element.allKeys.firstObject];
        if (fontTraitNumber) {
            if (fontTraitNumber.unsignedIntegerValue & (FontTraitPreformat | FontTraitBlockquote)) {
                attributes[kMessageParserIndentLevelKey] = @([attributes[kMessageParserIndentLevelKey] unsignedIntegerValue] + 1);
            }
            attributes[kMessageParserStyleKey] = @([attributes[kMessageParserStyleKey] unsignedIntegerValue] | fontTraitNumber.unsignedIntegerValue);
        } else if (element[kHTMLTagUnorderedListName] || element[kHTMLTagOrderedListName]) {
            if ([attributes[kMessageParserIndentLevelKey] unsignedIntegerValue] > 0) {
                attributes[kMessageParserIndentLevelKey] = @([attributes[kMessageParserIndentLevelKey] unsignedIntegerValue] + 1);
            }
        } else if (element[kConversationMessageMentionTagName]) {
            attributes[kConversationMessageMentionTagName] = element[kConversationMessageMentionTagName];
        } else if (element[kHTMLTagLinkName]) {
            attributes[kMessageParserLinkKey] = element[kHTMLTagLinkName];
        }
    }
    [self.result appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:attributes]];
}

- (void)parserDidStartElement:(NSString *)elementName attributes:(NSDictionary *)attributes {
    [self padElementIfNecessary:elementName];
    if ([elementName isEqualToString:kConversationMessageMentionTagName] && attributes[kConversationMessageMentionTypeKey]) {
        if (attributes[kConversationMessageMentionIDKey]) {
            [self.elements addObject:@{ elementName : [attributes dictionaryWithValuesForKeys:@[kConversationMessageMentionIDKey, kConversationMessageMentionTypeKey]] }];
        } else if (attributes[kConversationMessageMentionGroupTypeKey]) {
            [self.elements addObject:@{ elementName : [attributes dictionaryWithValuesForKeys:@[kConversationMessageMentionGroupTypeKey, kConversationMessageMentionTypeKey]] }];
        }
    } else if ([elementName isEqualToString:kHTMLTagLinkName] && attributes[@"href"]) {
        [self.elements addObject:@{ elementName : attributes[@"href"] }];
    } else if ([MessageParser fontTraitForTag][elementName]) {
        [self.elements addObject:@{ elementName : [NSNull null] }];
    } else if ([elementName isEqualToString:kHTMLTagBreakName]) {
        [self parserFoundCharacters:@"\n"];
    } else if ([elementName isEqualToString:kHTMLTagUnorderedListName] || [elementName isEqualToString:kHTMLTagOrderedListName]) {
        NSNumber *start = @([attributes[@"start"] integerValue] ?: 1);
        [self.elements addObject:[@{ elementName : start } mutableCopy]];
    } else if ([elementName isEqualToString:kHTMLTagListItemName]) {
        [self.elements enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *parentElementName = obj.allKeys.firstObject;
            if ([parentElementName isEqualToString:kHTMLTagUnorderedListName] || [parentElementName isEqualToString:kHTMLTagOrderedListName]) {
                NSUInteger index = [obj[parentElementName] unsignedIntegerValue];
                obj[parentElementName] = @(index + 1);
                if (index != 1) {
                    [self parserFoundCharacters:@"\n"];
                }
                if ([parentElementName isEqualToString:kHTMLTagOrderedListName]) {
                    [self parserFoundCharacters:[NSString stringWithFormat:@" %lu. ", (unsigned long)index]];
                } else {
#ifndef __clang_analyzer__ // Avoid localization check. Ensuring fully localized HTML lists is more complicated than using localized string macros.
                    [self parserFoundCharacters:@" • "];
#endif
                }
                *stop = YES;
            }
        }];
    }
}

- (void)padElementIfNecessary:(NSString *)elementName {
    static NSAttributedString *padding;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        padding = [[NSAttributedString alloc] initWithString:@"\n\n" attributes:@{ kMessageParserBlockPaddingKey : [NSNull null] }];
    });
    if ([[MessageParser blockElementTags] containsObject:elementName] && ![self.result.string hasSuffix:padding.string]) {
        [self.result appendAttributedString:padding];
    }
}

- (void)parserDidEndElement:(NSString *)elementName {
    if (self.elements.lastObject[elementName]) {
        [self.elements removeLastObject];
        [self padElementIfNecessary:elementName];
    }
}







@end
