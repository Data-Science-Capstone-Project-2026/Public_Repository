---------------------------------------------
------
------ Joining the college Size Data
------
---------------------------------------------
UPDATE staging.college_size
SET instnm = UPPER(instnm);



SELECT 
a.*,
b.ic2025size as size
FROM staging.nsc_fall_24_old a
INNER JOIN staging.college_size b on a.college_code_branch = b.instnm;


with names as (
  select 
  SPLIT_PART(college_code_branch, '-', 1) as college_code_branch
  from staging.nsc_fall_24_backup
  )
SELECT 
names.*,
b.ic2025size as size
FROM names 
INNER JOIN staging.college_size b on names.college_code_branch = b.instnm;

