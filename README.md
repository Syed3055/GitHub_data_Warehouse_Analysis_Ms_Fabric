
# 📘 SQL‑Driven Fabric Analytics

## 🚀 Project Overview
This project demonstrates a complete SQL‑driven end‑to‑end analytics solution built using Microsoft Fabric.
The workflow covers:

Ingesting GitHub data using Fabric Data Factory
Storing raw files in a Lakehouse
→ (Git_Lakehouse->Git_bronze_data(Schema)
### Creating a Warehouse using SQL
Loading Lakehouse data into Warehouse tables using SQL ingestion scripts
##### Performing advanced business analytics entirely through SQL, including

First‑visited customer

Repeated customer

Total product sales

Product % share

Payment method % share

Best product of the month

MTD & YTD sales

Daily order counts

Average sales per customer and More....



##### This project demonstrates how SQL can be used as the primary analytical engine in Fabric.

### 🏗️ Architecture
GitHub → Fabric Data Factory → Git_Lakehouse → Fabric Warehouse → SQL Analytics Layer


### 📥 1. Data Ingestion (GitHub → Data Factory → Lakehouse)
#### ✔ Data Factory Pipeline
Data ingestion is performed using Fabric Data Factory, utilizing:

Web activity – Fetch GitHub file metadata
Set Variable – Store dynamic values (file URLs, names, sizes, etc.)
Filter activity – Filter desired files
ForEach activity – Loop through filtered results
Copy Data activity – Copy each file into Git_Lakehouse

### ✔ Pipeline Screenshot
(Your pipeline diagram with Web → SetVariable → Filter → ForEach → Copy Data)

📸 Included image:
<img width="1591" height="407" alt="image" src="https://github.com/user-attachments/assets/42a9b306-9582-40e4-8fbb-b492126c7132" />

### ✔ Lakehouse Storage
The downloaded GitHub dataset is stored under:
Git_Lakehouse
  └── Files/


### 🗄️ 2. Loading Data Into Fabric Warehouse Using SQL
After ingestion, a Warehouse named:
##### Git_data_WH
was created.
Data was loaded into Warehouse tables using SQL ingestion like:
SQLINSERT INTO SalesTableSELECT * FROM Git_Lakehouse.Files.Sales;Show more lines
Tables, views, and queries are managed with the SQL editor in Fabric.

### 🧠 3. SQL Analytics Performed
All analysis is written purely in SQL inside the Fabric Warehouse.
### 🧩 Customer Insights (SQL)

First visited (new) customer
Repeated customer
Customer order frequency
Average sales per customer

### 📈 Sales Analytics (SQL)

Total product sales
Product‑wise % contribution
Best product of the month
Daily sales values
Monthly totals

### ⏱️ Time‑Series Metrics (SQL)

MTD Sales
YTD Sales
Running totals
Daily trends

### 💳 Payment Insights (SQL)

Payment method totals
Payment method contribution %

Every calculation was implemented as SQL queries under:
Queries → SQL Analysis


### 🔄 4. GitHub Source Control Integration
The Fabric workspace is connected to GitHub so that:

SQL queries saved as items are version‑controlled
Views / stored procedures are exported as .sql definition files
Warehouse schema is stored as a SQL project structure

### SQL is the main driver of this repository.

#### 📂 Repository Structure

├── README_SQL_Fabric_Analytics.md
├── Pipelines/
│    └── DataFactory_Pipeline.png

├── Lakehouse/
│    └── Raw_Files/

├── Warehouse/

│    ├── Tables/

│    ├── Views/

│    └── SQL_Ingestion/

└── SQL_Analytics/

      ├── Customer_Insights.sql
      ├── Sales_Analysis.sql
      ├── Payment_Analysis.sql
      ├── MTD_YTD_Calculations.sql
      └── Daily_Orders.sql


### 🎯 Key Outcomes

✔ Full SQL‑based analytics pipeline

✔ Automated ingestion using Data Factory

✔ Lakehouse + Warehouse architecture

✔ Business‑ready SQL insights

✔ GitHub‑synced SQL project

✔ Extendable to Power BI reporting

## ⭐ Final Note
#### This project shows how SQL remains central in modern analytics — even in a Lakehouse environment. Fabric’s unified architecture makes SQL‑only analytics fast, scalable, and version‑controlled.

###### ------------------Thank You --------------------------
