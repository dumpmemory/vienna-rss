//
//  CriteriaTree.m
//  Vienna
//
//  Created by Steve on Thu Apr 29 2004.
//  Copyright (c) 2004-2005 Steve Palmer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "Criteria.h"
#import "Vienna-Swift.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wprotocol"
@implementation Criteria
#pragma clang diagnostic pop

/* init
 * Initialise an empty Criteria.
 */
-(instancetype)init
{
	return [self initWithField:@"" withOperator:0 withValue:@""];
}

/* initWithField
 * Initalises a new Criteria with the specified values.
 */
-(instancetype)initWithField:(NSString *)newField withOperator:(VNACriteriaOperator)newOperator withValue:(NSString *)newValue
{
	if ((self = [super init]) != nil)
	{
		self.field = newField;
		self.operator = newOperator;
		self.value = newValue;
	}
	return self;
}

/* arrayOfOperators
 * Returns an array of NSNumbers that represent all supported operators.
 */
+(NSArray *)arrayOfOperators
{
	return @[
			 @(VNACriteriaOperatorEqualTo),
			 @(VNACriteriaOperatorNotEqualTo),
			 @(VNACriteriaOperatorAfter),
			 @(VNACriteriaOperatorBefore),
			 @(VNACriteriaOperatorOnOrAfter),
			 @(VNACriteriaOperatorOnOrBefore),
			 @(VNACriteriaOperatorContains),
			 @(VNACriteriaOperatorContainsNot),
			 @(VNACriteriaOperatorLessThan),
			 @(VNACriteriaOperatorLessThanOrEqualTo),
			 @(VNACriteriaOperatorGreaterThan),
			 @(VNACriteriaOperatorGreaterThanOrEqualTo),
			 @(VNACriteriaOperatorUnder),
			 @(VNACriteriaOperatorNotUnder)
			 ];
}

/* setField
 * Sets the field element of a criteria.
 */
-(void)setField:(NSString *)newField
{
	field = [newField copy];
}

/* setOperator
 * Sets the operator element of a criteria.
 */
-(void)setOperator:(VNACriteriaOperator)newOperator
{
	// Convert deprecated under/not-under operators
	// to is/is-not.
	if (newOperator == VNACriteriaOperatorUnder)
		newOperator = VNACriteriaOperatorEqualTo;
	if (newOperator == VNACriteriaOperatorNotUnder)
		newOperator = VNACriteriaOperatorNotEqualTo;
	operator = newOperator;
}

/* setValue
 * Sets the value element of a criteria.
 */
-(void)setValue:(NSString *)newValue
{
	value = [newValue copy];
}

/* field
 * Returns the field element of a criteria.
 */
-(NSString *)field
{
	return field;
}

/* operator
 * Returns the operator element of a criteria
 */
-(VNACriteriaOperator)operator
{
	return operator;
}

/* value
 * Returns the value element of a criteria.
 */
-(NSString *)value
{
	return value;
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wprotocol"
@implementation CriteriaTree
#pragma clang diagnostic pop

@synthesize criteriaTree;

static NSString *const CRITERIAGROUP_TAG = @"criteriagroup";
static NSString *const CRITERIAGROUP_CONDITION_ATTRIBUTE = @"condition";

static NSString *const CRITERIAGROUP_CONDITION_VALUE_ALL = @"all";
static NSString *const CRITERIAGROUP_CONDITION_VALUE_ANY = @"any";
static NSString *const CRITERIAGROUP_CONDITION_VALUE_NONE = @"none";

static NSString *const CRITERIA_TAG = @"criteria";
static NSString *const CRITERIA_FIELD_ATTRIBUTE = @"field";

static NSString *const CRITERIA_VALUE_TAG = @"value";
static NSString *const CRITERIA_OPERATOR_TAG = @"operator";

/* init
 * Initialise an empty CriteriaTree
 */
-(instancetype)init
{
	return [self initWithXml:nil];
}

/* initWithString
 * Initialises an criteria tree object with the specified string. The caller is responsible for
 * releasing the tree.
 */
-(instancetype)initWithString:(NSString *)string
{
    NSError *error = nil;
    NSXMLDocument *criteriaTreeDoc = [[NSXMLDocument alloc]
                                      initWithXMLString:string
                                      options:NSXMLNodeOptionsNone
                                      error:&error];

    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }

    return [self initWithXml:criteriaTreeDoc.rootElement];
}

-(instancetype) initWithXml:(NSXMLElement *)xml {

    if ((self = [super init]) == nil) {
        return self;
    }

    criteriaTree = [[NSMutableArray alloc] init];
    condition = VNACriteriaConditionAll;

    condition = [CriteriaTree conditionFromString:[xml attributeForName:CRITERIAGROUP_CONDITION_ATTRIBUTE].stringValue];
    if (condition == VNACriteriaConditionInvalid) {
        // For backward compatibility, the absence of the condition attribute
        // assumes that we're matching ALL conditions.
        condition = VNACriteriaConditionAll;
    }

    for (NSXMLNode *groupElementChild in xml.children) {

        if (![groupElementChild isKindOfClass:[NSXMLElement class]]) {
            [NSException raise:@"CriteriaXmlContentException"
                        format:@"Illegal subelement of criteriagroup, must only contain xml elements but contained %@", [groupElementChild class]];
        }

        NSXMLElement *criteriaElementXml = (NSXMLElement *)groupElementChild;

        if ([CRITERIAGROUP_TAG isEqualToString: criteriaElementXml.name]) {
            CriteriaTree *newCriteria = [[CriteriaTree alloc] initWithXml:criteriaElementXml];
            [self addCriteria:newCriteria];
        } else if ([CRITERIA_TAG isEqualToString:criteriaElementXml.name]) {
            NSString *fieldname = [criteriaElementXml attributeForName:CRITERIA_FIELD_ATTRIBUTE].stringValue;
            NSString *operator = [criteriaElementXml elementsForName:CRITERIA_OPERATOR_TAG].firstObject.stringValue;
            NSString *value = [criteriaElementXml elementsForName:CRITERIA_VALUE_TAG].firstObject.stringValue;

            Criteria *newCriteria = [[Criteria alloc]
                                     initWithField:fieldname
                                     withOperator:operator.integerValue
                                     withValue:value];
            [self addCriteria:newCriteria];
        } else {
            continue; //TODO maybe log something or throw error
        }
    }

    return self;
}

/* conditionFromString
 * Converts a condition string to its condition value. Returns -1 if the
 * string is invalid.
 * Note: the strings which are written to the XML file are NOT localized.
 */
+(VNACriteriaCondition)conditionFromString:(NSString *)string
{
	if (string != nil)
	{
		if ([string.lowercaseString isEqualToString:CRITERIAGROUP_CONDITION_VALUE_ANY])
			return VNACriteriaConditionAny;
		if ([string.lowercaseString isEqualToString:CRITERIAGROUP_CONDITION_VALUE_ALL])
			return VNACriteriaConditionAll;
        if ([string.lowercaseString isEqualToString:CRITERIAGROUP_CONDITION_VALUE_NONE])
            return VNACriteriaConditionNone;
	}
	return VNACriteriaConditionInvalid;
}

/* conditionToString
 * Returns the string representation of the specified condition.
 * Note: Do NOT localise these strings. They're written to the XML file.
 */
+(NSString *)conditionToString:(VNACriteriaCondition)condition
{
	if (condition == VNACriteriaConditionAny)
		return CRITERIAGROUP_CONDITION_VALUE_ANY;
	if (condition == VNACriteriaConditionAll)
		return CRITERIAGROUP_CONDITION_VALUE_ALL;
    if (condition == VNACriteriaConditionNone)
        return CRITERIAGROUP_CONDITION_VALUE_NONE;
	return @"";
}

/* condition
 * Return the criteria condition.
 */
-(VNACriteriaCondition)condition
{
	return condition;
}

/* setCondition
 * Sets the criteria condition.
 */
-(void)setCondition:(VNACriteriaCondition)newCondition
{
	condition = newCondition;
}

/* criteriaEnumerator
 * Returns an enumerator that will iterate over the criteria
 * object. We do it this way because we can't necessarily guarantee
 * that the criteria will be stored in an NSArray or any other collection
 * object for which NSEnumerator is supported.
 */
-(NSEnumerator<NSObject<CriteriaElement> *> *)criteriaEnumerator
{
	return [criteriaTree objectEnumerator];
}

/* addCriteria
 * Adds the specified criteria to the criteria array.
 */
-(void)addCriteria:(NSObject<CriteriaElement> *)newCriteria
{
	[criteriaTree addObject:newCriteria];
}

-(NSXMLElement *)toXml {
    NSDictionary * conditionDict = @{CRITERIAGROUP_CONDITION_ATTRIBUTE: [CriteriaTree conditionToString:condition]};
    NSXMLElement *criteriaGroup = [[NSXMLElement alloc] initWithName:CRITERIAGROUP_TAG];
    [criteriaGroup setAttributesWithDictionary:conditionDict];

    for (Criteria *criteria in criteriaTree) {
        NSXMLElement *criteriaElement;
        if ([criteria isKindOfClass:[CriteriaTree class]]) {
            criteriaElement = [(CriteriaTree *)criteria toXml];
        } else {
            criteriaElement = [[NSXMLElement alloc] initWithName:CRITERIA_TAG];
            [criteriaElement setAttributesWithDictionary:@{CRITERIA_FIELD_ATTRIBUTE: criteria.field}];
            NSXMLElement *operatorElement = [[NSXMLElement alloc]
                                             initWithName:CRITERIA_OPERATOR_TAG
                                             stringValue:[NSString stringWithFormat:
                                                          @"%lu", (unsigned long)criteria.operator]];
            NSXMLElement *valueElement = [[NSXMLElement alloc]
                                          initWithName:CRITERIA_VALUE_TAG
                                          stringValue:criteria.value];

            [criteriaElement addChild:operatorElement];
            [criteriaElement addChild:valueElement];
        }
        [criteriaGroup addChild:criteriaElement];
    }

    return criteriaGroup;
}

-(NSXMLDocument *)toXmlDocument {
    NSXMLDocument *criteriaDoc = [NSXMLDocument document];
    [criteriaDoc setStandalone:YES];
    criteriaDoc.characterEncoding = @"UTF-8";
    criteriaDoc.version = @"1.0";

    [criteriaDoc addChild:[self toXml]];
    return criteriaDoc;
}

/* string
 * Returns the complete criteria tree as a string.
 */
-(NSString *)string {
	return [self toXmlDocument].XMLString;
}

@end
