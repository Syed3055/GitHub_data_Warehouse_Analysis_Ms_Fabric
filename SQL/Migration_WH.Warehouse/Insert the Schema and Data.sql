CREATE SCHEMA control;  -- governance / repos
GO

CREATE SCHEMA mdm;      -- target business schema (example)
GO

CREATE SCHEMA audit;    -- logs / health snapshots
GO
--------------------------------------
-- Master list of in-scope tables
CREATE TABLE control.REPOS_TABLE
(
    repos_table_id        INT            NOT NULL,           -- supply explicitly
    source_catalog        VARCHAR(128)   NULL,
    source_schema         VARCHAR(128)   NOT NULL,
    source_table          VARCHAR(128)   NOT NULL,

    target_schema         VARCHAR(128)   NOT NULL,
    target_table          VARCHAR(128)   NOT NULL,

    require_ct            BIT            NOT NULL,           -- 0/1
    require_stream        BIT            NOT NULL,           -- 0/1
    require_daily_cdc     BIT            NOT NULL,           -- 0/1

    expected_stream_name  VARCHAR(256)   NULL,
    uk_name               VARCHAR(128)   NULL,
    uk_columns_csv        VARCHAR(4000)  NULL,

    active_flag           BIT            NOT NULL,           -- 0/1
    created_utc           DATETIME2(3)   NOT NULL,           -- set in INSERT
    updated_utc           DATETIME2(3)   NULL
);
GO

ALTER TABLE control.REPOS_TABLE
  ADD CONSTRAINT PK_REPOS_TABLE
  PRIMARY KEY NONCLUSTERED (repos_table_id) NOT ENFORCED;
GO

-- Column-level registry
CREATE TABLE control.REPOS_COLUMN
(
    repos_column_id       INT            NOT NULL,           -- supply explicitly
    repos_table_id        INT            NOT NULL,
    column_name           VARCHAR(128)   NOT NULL,
    column_datatype       VARCHAR(128)   NOT NULL,           -- e.g. 'INT', 'VARCHAR(50)'
    length                INT            NULL,
    precision             INT            NULL,
    scale                 INT            NULL,
    is_nullable           BIT            NOT NULL,

    column_used_in_mdm    BIT            NOT NULL,
    column_in_uk          BIT            NOT NULL,
    cdc_flag              BIT            NOT NULL,

    ordinal_position      INT            NOT NULL,
    created_utc           DATETIME2(3)   NOT NULL
);
GO

ALTER TABLE control.REPOS_COLUMN
  ADD CONSTRAINT PK_REPOS_COLUMN
  PRIMARY KEY NONCLUSTERED (repos_column_id) NOT ENFORCED;

ALTER TABLE control.REPOS_COLUMN
  ADD CONSTRAINT FK_REPOS_COLUMN_TO_TABLE
  FOREIGN KEY (repos_table_id)
  REFERENCES control.REPOS_TABLE(repos_table_id)
  NOT ENFORCED;
GO

-- Streams registry (populated by your monitoring job)
CREATE TABLE control.STREAMS_REGISTRY
(
    stream_name           VARCHAR(256)   NOT NULL,
    target_schema         VARCHAR(128)   NOT NULL,
    target_table          VARCHAR(128)   NOT NULL,
    status                VARCHAR(32)    NOT NULL,   -- 'Active'/'Inactive'/...
    last_message_time     DATETIME2(3)   NULL,
    min_event_time        DATETIME2(3)   NULL,
    max_event_time        DATETIME2(3)   NULL,
    captured_utc          DATETIME2(3)   NOT NULL
);
GO

ALTER TABLE control.STREAMS_REGISTRY
  ADD CONSTRAINT PK_STREAMS_REGISTRY
  PRIMARY KEY NONCLUSTERED (stream_name) NOT ENFORCED;
GO

-- Optional: discovered source metadata
CREATE TABLE control.SOURCE_INVENTORY
(
    source_catalog        VARCHAR(128)   NULL,
    source_schema         VARCHAR(128)   NOT NULL,
    source_table          VARCHAR(128)   NOT NULL,
    ct_enabled            BIT            NOT NULL,
    stream_available      BIT            NOT NULL,
    last_seen_utc         DATETIME2(3)   NOT NULL
);
GO

ALTER TABLE control.SOURCE_INVENTORY
  ADD CONSTRAINT PK_SOURCE_INVENTORY
  PRIMARY KEY NONCLUSTERED (source_schema, source_table) NOT ENFORCED;
GO
--------------------------********************------------------------------------

-- mdm.Customer
CREATE TABLE mdm.Customer
(
    CustomerID       INT            NOT NULL,
    CustomerCode     VARCHAR(50)    NOT NULL,
    CustomerName     VARCHAR(200)   NOT NULL,
    Email            VARCHAR(200)   NULL,
    Country          VARCHAR(100)   NULL,
    IsActive         BIT            NOT NULL,         -- set explicitly
    CreatedUTC       DATETIME2(3)   NOT NULL          -- set explicitly
);
GO
ALTER TABLE mdm.Customer
  ADD CONSTRAINT PK_Customer
  PRIMARY KEY NONCLUSTERED (CustomerID) NOT ENFORCED;

ALTER TABLE mdm.Customer
  ADD CONSTRAINT UQ_Customer_CustomerCode
  UNIQUE NONCLUSTERED (CustomerCode) NOT ENFORCED;
GO

-- mdm.Product
CREATE TABLE mdm.Product
(
    ProductID        INT            NOT NULL,
    SKU              VARCHAR(50)    NOT NULL,
    ProductName      VARCHAR(200)   NOT NULL,
    UnitPrice        DECIMAL(18,2)  NOT NULL,
    IsActive         BIT            NOT NULL,
    CreatedUTC       DATETIME2(3)   NOT NULL
);
GO
ALTER TABLE mdm.Product
  ADD CONSTRAINT PK_Product
  PRIMARY KEY NONCLUSTERED (ProductID) NOT ENFORCED;

ALTER TABLE mdm.Product
  ADD CONSTRAINT UQ_Product_SKU
  UNIQUE NONCLUSTERED (SKU) NOT ENFORCED;
GO

-- mdm.SalesOrder
CREATE TABLE mdm.SalesOrder
(
    SalesOrderID     BIGINT         NOT NULL,
    OrderNumber      VARCHAR(40)    NOT NULL,
    CustomerID       INT            NOT NULL,
    OrderDate        DATETIME2(3)   NOT NULL,
    Currency         CHAR(3)        NOT NULL,
    TotalAmount      DECIMAL(18,2)  NOT NULL,
    CreatedUTC       DATETIME2(3)   NOT NULL
);
GO
ALTER TABLE mdm.SalesOrder
  ADD CONSTRAINT PK_SalesOrder
  PRIMARY KEY NONCLUSTERED (SalesOrderID) NOT ENFORCED;

ALTER TABLE mdm.SalesOrder
  ADD CONSTRAINT UQ_SalesOrder_OrderNumber
  UNIQUE NONCLUSTERED (OrderNumber) NOT ENFORCED;

ALTER TABLE mdm.SalesOrder
  ADD CONSTRAINT FK_SalesOrder_Customer
  FOREIGN KEY (CustomerID) REFERENCES mdm.Customer(CustomerID)
  NOT ENFORCED;
GO

-------------***********************************----------------------

INSERT INTO mdm.Customer (CustomerID, CustomerCode, CustomerName, Email, Country, IsActive, CreatedUTC)
VALUES
(1, 'CUST-001', 'Syed Primary', 'syed@example.com', 'IN', 1, SYSUTCDATETIME()),
(2, 'CUST-002', 'ACME Retail',  'contact@acme.com', 'US', 1, SYSUTCDATETIME());

INSERT INTO mdm.Product (ProductID, SKU, ProductName, UnitPrice, IsActive, CreatedUTC)
VALUES
(10, 'SKU-RED-01', 'Red Widget', 15.99, 1, SYSUTCDATETIME()),
(11, 'SKU-BLU-01', 'Blue Widget', 21.49, 1, SYSUTCDATETIME());

INSERT INTO mdm.SalesOrder (SalesOrderID, OrderNumber, CustomerID, OrderDate, Currency, TotalAmount, CreatedUTC)
VALUES
(10001, 'SO-10001', 1, '2025-01-01T10:00:00', 'INR', 1000.00, SYSUTCDATETIME()),
(10002, 'SO-10002', 2, '2025-01-02T11:00:00', 'USD',  250.50, SYSUTCDATETIME());

-------------------------------***********************-------------------------

-- REPOS_TABLE
INSERT INTO control.REPOS_TABLE
(repos_table_id, source_catalog, source_schema, source_table, target_schema, target_table,
 require_ct, require_stream, require_daily_cdc, expected_stream_name, uk_name, uk_columns_csv,
 active_flag, created_utc)
VALUES
(1, 'OnPremSQL', 'dbo', 'Customer', 'mdm', 'Customer',
 1, 1, 1, 'stream_mdm_customer', 'UQ_Customer_CustomerCode', 'CustomerCode',
 1, SYSUTCDATETIME()),
(2, 'OnPremSQL', 'dbo', 'Product', 'mdm', 'Product',
 0, 1, 0, 'stream_mdm_product',  'UQ_Product_SKU',          'SKU',
 1, SYSUTCDATETIME());

-- REPOS_COLUMN (Customer)
INSERT INTO control.REPOS_COLUMN
(repos_column_id, repos_table_id, column_name, column_datatype, length, precision, scale, is_nullable,
 column_used_in_mdm, column_in_uk, cdc_flag, ordinal_position, created_utc)
VALUES
(1001, 1, 'CustomerID',   'INT',          NULL, NULL, NULL, 0, 1, 0, 1, 1, SYSUTCDATETIME()),
(1002, 1, 'CustomerCode', 'VARCHAR(50)',  50,   NULL, NULL, 0, 1, 1, 1, 2, SYSUTCDATETIME()),
(1003, 1, 'CustomerName', 'VARCHAR(200)', 200,  NULL, NULL, 0, 1, 0, 1, 3, SYSUTCDATETIME()),
(1004, 1, 'Email',        'VARCHAR(200)', 200,  NULL, NULL, 1, 0, 0, 1, 4, SYSUTCDATETIME()),
(1005, 1, 'Country',      'VARCHAR(100)', 100,  NULL, NULL, 1, 0, 0, 0, 5, SYSUTCDATETIME()),
(1006, 1, 'IsActive',     'BIT',          NULL, NULL, NULL, 0, 0, 0, 0, 6, SYSUTCDATETIME()),
(1007, 1, 'CreatedUTC',   'DATETIME2(3)', NULL, NULL, NULL, 0, 0, 0, 0, 7, SYSUTCDATETIME());

-- REPOS_COLUMN (Product)
INSERT INTO control.REPOS_COLUMN
(repos_column_id, repos_table_id, column_name, column_datatype, length, precision, scale, is_nullable,
 column_used_in_mdm, column_in_uk, cdc_flag, ordinal_position, created_utc)
VALUES
(2001, 2, 'ProductID',   'INT',          NULL, NULL, NULL, 0, 1, 0, 1, 1, SYSUTCDATETIME()),
(2002, 2, 'SKU',         'VARCHAR(50)',  50,   NULL, NULL, 0, 1, 1, 1, 2, SYSUTCDATETIME()),
(2003, 2, 'ProductName', 'VARCHAR(200)', 200,  NULL, NULL, 0, 1, 0, 1, 3, SYSUTCDATETIME()),
(2004, 2, 'UnitPrice',   'DECIMAL(18,2)',NULL, 18,   2,    0, 0, 0, 0, 4, SYSUTCDATETIME()),
(2005, 2, 'IsActive',    'BIT',          NULL, NULL, NULL, 0, 0, 0, 0, 5, SYSUTCDATETIME()),
(2006, 2, 'CreatedUTC',  'DATETIME2(3)', NULL, NULL, NULL, 0, 0, 0, 0, 6, SYSUTCDATETIME());

-- Streams snapshot
INSERT INTO control.STREAMS_REGISTRY
(stream_name, target_schema, target_table, status, last_message_time, min_event_time, max_event_time, captured_utc)
VALUES
('stream_mdm_customer', 'mdm', 'Customer', 'Active',
 DATEADD(MINUTE, -10, SYSUTCDATETIME()), DATEADD(MINUTE, -70, SYSUTCDATETIME()), SYSUTCDATETIME(), SYSUTCDATETIME()),
('stream_mdm_product',  'mdm', 'Product',  'Active',
 DATEADD(MINUTE, -130, SYSUTCDATETIME()), DATEADD(HOUR, -3, SYSUTCDATETIME()), DATEADD(HOUR, -2, SYSUTCDATETIME()), SYSUTCDATETIME());

-- Source inventory example
INSERT INTO control.SOURCE_INVENTORY
(source_catalog, source_schema, source_table, ct_enabled, stream_available, last_seen_utc)
VALUES
('OnPremSQL', 'dbo', 'Customer', 1, 1, SYSUTCDATETIME()),
('OnPremSQL', 'dbo', 'Product',  0, 1, SYSUTCDATETIME());

----------------------------*********************************----------------------------------

------------REPOS table entry without any REPOS columns---------------
---------------------------------------------------------------
SELECT t.repos_table_id, t.source_schema, t.source_table, t.target_schema, t.target_table
FROM control.REPOS_TABLE t
LEFT JOIN (SELECT DISTINCT repos_table_id FROM control.REPOS_COLUMN) c
ON t.repos_table_id = c.repos_table_id
WHERE c.repos_table_id IS NULL AND t.active_flag = 1;

--------------REPOS column entry whose table is missing----------------------------------

SELECT c.repos_column_id, c.repos_table_id, c.column_name
FROM control.REPOS_COLUMN c
LEFT JOIN control.REPOS_TABLE t
ON t.repos_table_id = c.repos_table_id
WHERE t.repos_table_id IS NULL;

select * from [Migration_WH].[control].[REPOS_COLUMN]

select * from [Migration_WH].[control].[REPOS_TABLE]






































