CREATE TABLE [control].[REPOS_TABLE] (

	[repos_table_id] int NOT NULL, 
	[source_catalog] varchar(128) NULL, 
	[source_schema] varchar(128) NOT NULL, 
	[source_table] varchar(128) NOT NULL, 
	[target_schema] varchar(128) NOT NULL, 
	[target_table] varchar(128) NOT NULL, 
	[require_ct] bit NOT NULL, 
	[require_stream] bit NOT NULL, 
	[require_daily_cdc] bit NOT NULL, 
	[expected_stream_name] varchar(256) NULL, 
	[uk_name] varchar(128) NULL, 
	[uk_columns_csv] varchar(4000) NULL, 
	[active_flag] bit NOT NULL, 
	[created_utc] datetime2(3) NOT NULL, 
	[updated_utc] datetime2(3) NULL
);


GO
ALTER TABLE [control].[REPOS_TABLE] ADD CONSTRAINT PK_REPOS_TABLE primary key NONCLUSTERED ([repos_table_id]);