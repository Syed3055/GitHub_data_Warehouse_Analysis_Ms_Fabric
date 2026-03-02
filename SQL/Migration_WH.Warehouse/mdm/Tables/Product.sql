CREATE TABLE [mdm].[Product] (

	[ProductID] int NOT NULL, 
	[SKU] varchar(50) NOT NULL, 
	[ProductName] varchar(200) NOT NULL, 
	[UnitPrice] decimal(18,2) NOT NULL, 
	[IsActive] bit NOT NULL, 
	[CreatedUTC] datetime2(3) NOT NULL
);


GO
ALTER TABLE [mdm].[Product] ADD CONSTRAINT PK_Product primary key NONCLUSTERED ([ProductID]);
GO
ALTER TABLE [mdm].[Product] ADD CONSTRAINT UQ_Product_SKU unique NONCLUSTERED ([SKU]);