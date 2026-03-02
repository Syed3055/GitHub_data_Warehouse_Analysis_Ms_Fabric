CREATE TABLE [control].[SOURCE_INVENTORY] (

	[source_catalog] varchar(128) NULL, 
	[source_schema] varchar(128) NOT NULL, 
	[source_table] varchar(128) NOT NULL, 
	[ct_enabled] bit NOT NULL, 
	[stream_available] bit NOT NULL, 
	[last_seen_utc] datetime2(3) NOT NULL
);


GO
ALTER TABLE [control].[SOURCE_INVENTORY] ADD CONSTRAINT PK_SOURCE_INVENTORY primary key NONCLUSTERED ([source_schema], [source_table]);