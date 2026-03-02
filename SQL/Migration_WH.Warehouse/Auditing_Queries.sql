---------------****Auditing****---------------------------

-----Entry in REPOS_TABLE but not in REPOS_COLUMN (by repos_table_id--------
select t.repos_table_id,t.source_catalog,t.source_schema,t.source_table,t.target_schema,t.target_table, c.repos_table_id 
 from [Migration_WH].[control].[REPOS_TABLE] t left join [Migration_WH].[control].[REPOS_COLUMN] c on
 t.repos_table_id=c.repos_table_id where c.repos_table_id is null and t.active_flag=1


---------------Entry in REPOS_COLUMN but not in REPOS_TABLE-------------------

select c.repos_table_id, t.repos_table_id
From [Migration_WH].[control].[REPOS_COLUMN] c 
left join [Migration_WH].[control].[REPOS_TABLE] t 
on c.repos_table_id = t.repos_table_id where t.repos_table_id is null 

-----------------Duplicates in REPOS_TABLE (based on table identity)---------------------

select repos_table_id, source_schema, source_table,
count(*) as repeated from [Migration_WH].[control].[REPOS_TABLE] t 
group by repos_table_id , source_schema, source_table
having count(*) >1

----------------Duplicates in REPOS_COLUMN (same column twice on a table)-------

select repos_table_id, column_name,
count(*) repeated_columns from [Migration_WH].[control].[REPOS_COLUMN] c
group by  repos_table_id,  column_name having count(*) >1

-------------------UK columns present & flagged properly (all columns in uk_columns_csv must exist in
--- REPOS_COLUMN with column_in_uk=1, and must be column_used_in_mdm=1 & cdc_flag=1)-----------
select * from [Migration_WH].[control].[REPOS_COLUMN] c
inner join [Migration_WH].[control].[REPOS_TABLE] t 
on c.repos_table_id=t.repos_table_id and c.column_name =t.uk_columns_csv
where c.column_in_uk = 1 and c.column_used_in_mdm =1 and c.cdc_flag=1

-----------------At least one column marked for MDM & CDC per table-------------
------------------Work in Progress---------Thank You-----------------



















































































































