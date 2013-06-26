//
//  MetadataCell.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 26/06/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

@interface MetadataCell : UITableViewCell

#pragma mark - Public Properties

/**	Used to display the metadata.*/
@property (nonatomic, strong)	UILabel	*metadataLabel;
/**	Used to display the type of the metadata.*/
@property (nonatomic, strong)	UILabel	*metadataTypeLabel;

@end