-- NSC cleaning (can probs be applied to all NSC tables)

-- creating backup tables
CREATE TABLE staging.nsc_fall_25_backup (
    LIKE staging.nsc_fall_25 INCLUDING ALL
);

INSERT INTO staging.nsc_fall_25_backup
SELECT * FROM staging.nsc_fall_25;


-- actual cleaning
---------------------------------------------------------
-- THINGS TO CHANGE
-- Make columns the same in all three tables so that they can be unioned
-- make sure school names are consistent within and across tables
---------------------------------------------------------

-- using fall 25 as the "baseline" since it is the newest and what would be accurate moving forward
-- I know the business question does not apply to 2 year 4 year, but I think that could be a very interesting thing to look at
-- therefore, it is staying for now


ALTER TABLE staging.nsc_fall_23
DROP COLUMN POS,
DROP COLUMN college_code_branch;

SELECT distinct
appl_acad_program
from staging.nsc_fall_25_backup;

SELECT distinct
college
from staging.nsc_fall_23;

ALTER TABLE staging.nsc_fall_23
ADD COLUMN appl_acad_program VARCHAR(255);

UPDATE staging.nsc_fall_23
SET appl_acad_program = 'BA.UND';

ALTER TABLE staging.nsc_fall_23
DROP COLUMN college;

select distinct
public_private
from staging.nsc_fall_23;

ALTER TABLE staging.nsc_fall_23
ADD COLUMN private int;

UPDATE staging.nsc_fall_23
SET private = case
WHEN public_private LIKE 'Public' THEN '0'::int
WHEN public_private LIKE 'Private' THEN '1'::int
END;

ALTER TABLE staging.nsc_fall_23 
DROP COLUMN public_private

ALTER TABLE staging.nsc_fall_23
ALTER COLUMN private TYPE smallint;

select distinct
  appl_start_term
  from staging.nsc_fall_25;

ALTER TABLE staging.nsc_fall_23
ADD COLUMN appl_start_term varchar(255);

UPDATE staging.nsc_fall_23
SET appl_start_term = case
WHEN enrollment_begin < '2023-12-31' AND enrollment_begin > '2023-07-31' THEN '23/FA'
WHEN enrollment_begin < '2023-08-01' AND enrollment_begin > '2023-06-30' THEN '23/SU'
END;

ALTER TABLE staging.nsc_fall_23
DROP COLUMN enrollment_begin;

--------------------------------
-- doing the above for the fall 24 table
--------------------------------

ALTER TABLE staging.nsc_fall_24
ADD COLUMN appl_acad_program VARCHAR(255),
ADD COLUMN private smallint,
ADD COLUMN appl_start_term varchar(255);

UPDATE staging.nsc_fall_24
SET appl_acad_program = 'BA.UND';

UPDATE staging.nsc_fall_24
SET private = case
WHEN public_private LIKE 'Public' THEN '0'::int
WHEN public_private LIKE 'Private' THEN '1'::int
END;
UPDATE staging.nsc_fall_24
SET appl_start_term = case
WHEN enrollment_begin < '2024-12-31' AND enrollment_begin > '2024-07-31' THEN '24/FA'
WHEN enrollment_begin < '2024-08-01' AND enrollment_begin > '2024-06-30' THEN '24/SU'
END;

ALTER TABLE staging.nsc_fall_24
DROP COLUMN enrollment_begin,
DROP COLUMN public_private,
DROP COLUMN college,
DROP COLUMN POS,
DROP COLUMN college_code_branch;

------------------
-- Unioning the fall 23 and fall 24 tables
------------------

CREATE TABLE staging.nsc_fall_23_24 AS 
SELECT * FROM staging.nsc_fall_23
UNION ALL
SELECT * FROM staging.nsc_fall_24;

-----------------------
-- adding a 2/4 yr col to 25
-- unioning all of the nsc tables together
-----------------------

ALTER TABLE staging.nsc_fall_25
ADD COLUMN _2_year_4_year int
ADD COLUMN private smallint

  
UPDATE staging.nsc_fall_25
SET private = case
WHEN public_private LIKE 'Public' THEN '0'::int
WHEN public_private LIKE 'Private' THEN '1'::int
END;

ALTER TABLE staging.nsc_fall_25
  DROP COLUMN public_private

CREATE TABLE staging.nsc_fall_23_24_25 AS 
SELECT appl_students_id, appl_acad_program, appl_start_term, college_name, college_state, private, _2_year_4_year FROM staging.nsc_fall_23_24
UNION ALL
SELECT appl_students_id, appl_acad_program, appl_start_term, college_name, college_state, private, _2_year_4_year FROM staging.nsc_fall_25;


--------------------------------

SELECT count(*)
FROM staging.nsc_fall_23_24_25;

ALTER TABLE staging.nsc_fall_23_24_25
ALTER COLUMN _2_year_4_year TYPE smallint;

ALTER TABLE staging.nsc_fall_23_24_25
  DROP COLUMN _2_year_4_year;

-------------------------------
--fixing duplicate college names by adding location
-------------------------------

SELECT t1.*
FROM staging.nsc_fall_23_24_25 t1
JOIN (
    SELECT college_name
    FROM staging.nsc_fall_23_24_25
    GROUP BY college_name
    HAVING COUNT(DISTINCT college_state) > 1
) t2 ON t1.college_name = t2.college_name;

UPDATE staging.nsc_fall_23_24_25
SET college_name = case
when college_name LIKE 'UNIVERSITY OF ST THOMAS' then CONCAT(college_name, '-', college_state)
when college_name LIKE 'WHEATON COLLEGE' then CONCAT(college_name, '-', college_state)
ELSE college_name
END;

----------------------------------
--Duplicate applicant ids
----------------------------------

WITH DuplicateCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY appl_students_id
               ORDER BY appl_start_term ASC
               
           ) AS row_num
    FROM staging.nsc_fall_23_24_25
)
DELETE FROM staging.nsc_fall_23_24_25 n
  USING DuplicateCTE c
WHERE n.appl_students_id = c.appl_students_id AND c.row_num > 1;


