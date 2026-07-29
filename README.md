# Delivery Performance and Customer Satisfaction Analysis

An end-to-end data analytics project based on the Brazilian Olist
e-commerce dataset.

The project investigates delivery performance, shipping delays, seller
fulfilment, and the relationship between delivery experience and
customer review scores.

The original SQLite data is migrated to PostgreSQL, validated, cleaned,
and transformed before further analysis in SQL, Python, and Power BI.

## Project Objectives

The main goals of the project are to:

- evaluate delivery performance and identify late orders;
- measure the main stages of the order delivery process;
- investigate factors associated with shipping delays;
- compare delivery outcomes across sellers, product categories, and
  geographic regions;
- analyze the relationship between delivery performance and customer
  satisfaction;

## Technology Stack

- SQL
- Python
- Power BI
- Git

## Project Workflow

1. Migrate the original Olist SQLite database to PostgreSQL.
2. Validate the migrated source data.
3. Convert imported columns to appropriate PostgreSQL data types.
4. Clean and normalize the database structure.
5. Create primary keys, foreign keys, constraints, and indexes.
6. Build a cleaned ZIP-code-level geolocation table.
7. Perform delivery performance and customer satisfaction analysis.
8. Create analytical views and a Power BI dashboard.
9. Document findings and business recommendations.

## Data Quality Validation

Before applying PostgreSQL data types, primary keys, foreign keys, and
other constraints, the migrated source tables are validated using
[`sql/01_data_quality_checks.sql`](sql/01_data_quality_checks.sql).

The validation covers:

- uniqueness and completeness of primary key candidates;
- NULL profiles for required and optional attributes;
- referential integrity between related tables;
- safety of planned data type conversions;
- valid value ranges;
- chronological consistency of order lifecycle timestamps;
- consistency between order statuses and delivery dates;
- suspicious or undefined source values.

The results of these checks are used to define the cleaning and schema
transformation steps applied in the following SQL scripts.

## Repository Structure

```text
Olist-Delivery-Analysis/
├── images/
├── notebooks/
├── powerbi/
├── sql/
│   ├── 01_data_quality_checks.sql
│   ├── 02_schema_setup.sql
│   ├── 03_create_zip_geolocation.sql
│   ├── 04_constraints_and_indexes.sql
│   └── 05_post_migration_validation.sql
├── src/
│   └── migrate_olist.py
├── .env.example
├── .gitignore
└── README.md