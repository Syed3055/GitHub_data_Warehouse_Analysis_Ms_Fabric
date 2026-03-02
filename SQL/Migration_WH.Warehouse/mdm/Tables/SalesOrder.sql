CREATE TABLE [mdm].[SalesOrder] (

	[SalesOrderID] bigint NOT NULL, 
	[OrderNumber] varchar(40) NOT NULL, 
	[CustomerID] int NOT NULL, 
	[OrderDate] datetime2(3) NOT NULL, 
	[Currency] char(3) NOT NULL, 
	[TotalAmount] decimal(18,2) NOT NULL, 
	[CreatedUTC] datetime2(3) NOT NULL
);


GO
ALTER TABLE [mdm].[SalesOrder] ADD CONSTRAINT PK_SalesOrder primary key NONCLUSTERED ([SalesOrderID]);
GO
ALTER TABLE [mdm].[SalesOrder] ADD CONSTRAINT UQ_SalesOrder_OrderNumber unique NONCLUSTERED ([OrderNumber]);
GO
ALTER TABLE [mdm].[SalesOrder] ADD CONSTRAINT FK_SalesOrder_Customer FOREIGN KEY ([CustomerID]) REFERENCES [mdm].[Customer]([CustomerID]);