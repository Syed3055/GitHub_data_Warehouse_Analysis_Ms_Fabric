CREATE TABLE [control].[REPOS_COLUMN] (

	[repos_column_id] int NOT NULL, 
	[repos_table_id] int NOT NULL, 
	[column_name] varchar(128) NOT NULL, 
	[column_datatype] varchar(128) NOT NULL, 
	[length] int NULL, 
	[precision] int NULL, 
	[scale] int NULL, 
	[is_nullable] bit NOT NULL, 
	[column_used_in_mdm] bit NOT NULL, 
	[column_in_uk] bit NOT NULL, 
	[cdc_flag] bit NOT NULL, 
	[ordinal_position] int NOT NULL, 
	[created_utc] datetime2(3) NOT NULL
);


GO
ALTER TABLE [control].[REPOS_COLUMN] ADD CONSTRAINT PK_REPOS_COLUMN primary key NONCLUSTERED ([repos_column_id]);
GO
ALTER TABLE [control].[REPOS_COLUMN] ADD CONSTRAINT FK_REPOS_COLUMN_TO_TABLE FOREIGN KEY ([repos_table_id]) REFERENCES [control].[REPOS_TABLE]([repos_table_id]);