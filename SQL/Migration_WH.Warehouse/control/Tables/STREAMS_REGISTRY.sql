CREATE TABLE [control].[STREAMS_REGISTRY] (

	[stream_name] varchar(256) NOT NULL, 
	[target_schema] varchar(128) NOT NULL, 
	[target_table] varchar(128) NOT NULL, 
	[status] varchar(32) NOT NULL, 
	[last_message_time] datetime2(3) NULL, 
	[min_event_time] datetime2(3) NULL, 
	[max_event_time] datetime2(3) NULL, 
	[captured_utc] datetime2(3) NOT NULL
);


GO
ALTER TABLE [control].[STREAMS_REGISTRY] ADD CONSTRAINT PK_STREAMS_REGISTRY primary key NONCLUSTERED ([stream_name]);