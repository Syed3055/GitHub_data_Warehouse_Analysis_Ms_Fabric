CREATE TABLE [mdm].[Customer] (

	[CustomerID] int NOT NULL, 
	[CustomerCode] varchar(50) NOT NULL, 
	[CustomerName] varchar(200) NOT NULL, 
	[Email] varchar(200) NULL, 
	[Country] varchar(100) NULL, 
	[IsActive] bit NOT NULL, 
	[CreatedUTC] datetime2(3) NOT NULL
);


GO
ALTER TABLE [mdm].[Customer] ADD CONSTRAINT PK_Customer primary key NONCLUSTERED ([CustomerID]);
GO
ALTER TABLE [mdm].[Customer] ADD CONSTRAINT UQ_Customer_CustomerCode unique NONCLUSTERED ([CustomerCode]);