# Data Cleaning Notebook
## Willamette Applicant Trajectory - SQL Cleaning Process
**Scripts Location** `src/Capstone_data_cleaning/`
**Last Updated** 2026-07-07

## Overview
This notebook writes out the data cleaning decisions that were made across the five SQL scripts that transform the raw data into cleaned flat files and join the NSC enrollment and Slate applicant data. 

The cleaning process follows this order:
1. schema_creation.sql : creates the capstone schema and all normalized tables
2. nsc_cleaning.sql : cleans and standardizes the NSC staging tables and unions them across all three application cycles
3. wu_app_cleaning.sql : cleans and standardizes the Slate applicant staging table
4. data_migration.sql : migrates cleaned data from the staging schema into the capstone schema
5. all_data_flat_file_creation.sql : joins all data into a single flat file for analysis and use in machine learning techniques

## 1. Schema Setup

Before any cleaning begins, the capstone schema is created along with its normalized tables: applicant, academics, application, attend_school, financials, interests, and wu_interest. These tables define the structure that cleaned data will be migrated into to illustrate the different categories in the data.

The raw data is imported separately into a staging schema in Beekeeper Studio using New Table from File, before any scripts are run. The staging schema acts as a holding area for raw data that has not yet been cleaned or validated.

## 2. NSC Data Cleaning

The NSC data arrived as three separate CSV files, one for each application cycle (Fall 2023, Fall 2024, Fall 2025). Because these files came from different export formats, they had inconsistent column structures and needed to be standardized before being combined.

We chose to use the Fall 2025 file as the "baseline" since it is the newest and would allow consistent formatting.

Key standardization steps:
- Adding `appl_acad_program` column with value BA.UND for both 23 and 24 files
- Calculating and inputting `appl_start_term` from enrollment_begin date column
- Updating `public_private` column to hold 0 for public and 1 for private schools and renaming to `private`
- Dropping extra columns that existed in 23 and 24 files

We fixed duplicate college names by adding a "- college state abbreviation" after the college name.

Some students appeared more than once in the combined NSC table. For example, this could occur if a student transferred institutions between terms and was reported under multiple enrollment records. We decided to treat a student's first recorded enrollment destination as the ground truth, which aligns with the research question of predicting where a student initially enrolls after leaving Willamette's applicant pool.

## 3. Willamette Applicant Data Cleaning

We started with dropping rows that were out of the scope of our research question, specifically applicants for PNCA and an application that had no link to a colleague record.

Similar to NSC records, some students had multiple application records in Slate. When a student appeared more than once, the record with the earliest app_submitted date was retained. This keeps the student's original application profile rather than a later re-application, which is more representative of their initial decision-making context. This dropped 102 rows from our analysis.

Several columns were converted from text fields to binary (1/0/null) data types for analysis. Those columns were:
- `testing_plan`
- `common_app_fee_waiver`
- `has_dual_degree_letter`
- `student_athlete`
- `hold_decision_released`
- `relative_attended_wu`
- `has_competitive_scholarship_application`

Additionally, a few columns that had text field ratings were converted to ordered numeric scalings. Those columns were:
- `rec_value`
- `co_curricular_rating`
- `curriculum_rating`
- `writing_rating`

Entry term and school names were standardized to match the format of NSC data. The `school_1_name` column contained numerous inconsistencies, including abbreviations, alternate spellings, and mixed casing. All names were converted to uppercase, and approximately 80+ specific school names were corrected using `school_1_code` as the authoritative identifier, since the code is a stable assigned value while the name field was prone to data entry variation.

## 4. Data Migration

Once both the NSC and Slate data were cleaned in the staging schema, the relevant columns were migrated into the normalized capstone schema tables defined in Stage 1.

The migration used an inner join of Slate data onto NSC data, joining on the shared student identifier (`colleague_id` = `appl_students_id`). This scopes the dataset to students who appear in both sources and therefore have both a full application profile and a confirmed enrollment destination.

Each of the seven capstone tables was populated in a single transaction, ensuring that either all inserts succeed or none do, preventing partial data loads.

## 5. Flat File Creation

The final step combines all cleaned data into a single flat file (staging.all_data) by joining the Slate applicant data onto the NSC enrollment data using an inner join on the shared student identifier.

The resulting flat file contains **6,558** rows and **65** columns and is exported as a CSV into data/interim/ for further feature engineering steps before moving to data/processed.

