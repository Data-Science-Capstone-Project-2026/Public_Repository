-- CLEANING the admissions table

Delete FROM staging.wu_app
  WHERE round LIKE '%PNCA%';


UPDATE staging.wu_app
SET testing_plan = CASE
  WHEN testing_plan LIKE '%Yes%' THEN '1'::integer
  WHEN testing_plan LIKE '%not%' THEN '0'::integer
END;

UPDATE staging.wu_app
SET common_app_fee_waiver = CASE
  WHEN common_app_fee_waiver LIKE 'Yes' THEN '1'::integer
  WHEN common_app_fee_waiver LIKE 'No' THEN '0'::integer
  WHEN common_app_fee_waiver LIKE 'TRUE' THEN '1'::integer
  WHEN common_app_fee_waiver LIKE 'FALSE' THEN '0'::integer
END;

ALTER TABLE staging.wu_app RENAME COLUMN "person_efc/sai" TO efc_sai;
ALTER TABLE staging.wu_app RENAME COLUMN "edi/access_check" TO edi_access_check;
ALTER TABLE staging.wu_app RENAME COLUMN "need-based_aid" TO need_based_aid;

ALTER TABLE staging.wu_app
ALTER COLUMN person_fafsa_submit_date TYPE date USING person_fafsa_submit_date::date,
ALTER COLUMN need_based_aid TYPE smallint,
ALTER COLUMN testing_plan TYPE smallint USING testing_plan::smallint,
ALTER COLUMN common_app_fee_waiver TYPE smallint USING common_app_fee_waiver::smallint;



-----------------------------
-- Dual Degree
-----------------------------

UPDATE staging.wu_app
  SET has_dual_degree_letter = case
  when has_dual_degree_letter LIKE 'Yes' THEN '1'
  when has_dual_degree_letter LIKE 'No' THEN '0'
  ELSE has_dual_degree_letter
  END;

ALTER TABLE staging.wu_app
ALTER COLUMN has_dual_degree_letter TYPE smallint USING has_dual_degree_letter::smallint;

-----------------------------
-- cleaning round, admission_plan, and adding transfer column
-----------------------------

ALTER TABLE staging.wu_app ADD COLUMN transfer smallint;

UPDATE staging.wu_app
SET transfer = case
when SPLIT_PART(round, ' ', 3) LIKE 'Transfer' then '1'::int
else '0'::int
END;


UPDATE staging.wu_app
SET admission_plan = case
when SPLIT_PART(round, ' ', 3) LIKE 'Transfer' then 'RD'
when SPLIT_PART(round, ' ', 3) LIKE 'Early' AND SPLIT_PART(round, ' ', 4) LIKE 'Decision' then 'ED' 
when SPLIT_PART(round, ' ', 3) LIKE 'Early' AND SPLIT_PART(round, ' ', 4) LIKE 'Action' then 'EA'
when SPLIT_PART(round, ' ', 3) LIKE 'Regular' AND SPLIT_PART(round, ' ', 4) LIKE 'Decision' then 'RD'
else admission_plan
END;

UPDATE staging.wu_app
  SET entry_term = case
  when entry_term LIKE 'Fall 2024' THEN '24/FA'
  when entry_term LIKE 'Fall 2025' THEN '25/FA'
  when entry_term LIKE 'Fall 2026' THEN '26/FA'
  when entry_term LIKE 'Fall 2027' THEN '27/FA'
  when entry_term LIKE 'Fall 2028' THEN '28/FA'
  when entry_term LIKE 'Spring 2025' THEN '25/SP'
  when entry_term LIKE 'Spring 2026' THEN '26/SP'
  when entry_term LIKE 'Fall 2023' THEN '23/FA'
  when entry_term LIKE 'Spring 2024' THEN '24/SP'
  END;
----------------------------------------------------------------------------------
  -- Making Numeric Scales for relevant columns
----------------------------------------------------------------------------------

------------------------------
---- Student Athlete
------------------------------

UPDATE staging.wu_app
  SET student_athlete = case
  when student_athlete LIKE '%Yes%' then '1'::int
  when student_athlete LIKE '%No%' then '0'::int
  END;

------------------------------
---- Hold Decision
------------------------------
UPDATE staging.wu_app
  SET hold_decision_released = case
  when hold_decision_released LIKE '%Yes%' then '1'::int
  when hold_decision_released LIKE '%No%' then '0'::int
  END;

------------------------------
---- Relative Attended WU
------------------------------
UPDATE staging.wu_app
  SET relative_attended_wu = case
  when relative_attended_wu is null then '0'::int
  when relative_attended_wu LIKE '%Yes%' then '1'::int
  END;

-------------------------------
-- Rec value
-------------------------------
  
ALTER TABLE staging.wu_app RENAME COLUMN "recommender's_value" TO rec_value;

-- 1: no basis, 2: with reservation, 3:fairly strongly, 4: strongly, 5: enthusiastically

UPDATE staging.wu_app
SET rec_value = case
  when rec_value LIKE '%basis%' then '1'::int
  when rec_value LIKE '%With%' then '2'::int
  when rec_value LIKE '%Fairly%' then '3'::int
  when rec_value LIKE 'Strongly' then '4'::int
  when rec_value LIKE '%Enthusi%' then '5'::int
  END;

ALTER TABLE staging.wu_app
ALTER COLUMN rec_value TYPE smallint USING rec_value::smallint;

-------------------
-- co-curricular rating and curriculum rating
-- 1:below average, 2:average, 3:above average, 4:demanding, 5:very demanding, 6: most demanding
-------------------
ALTER TABLE staging.wu_app RENAME COLUMN "co-curricular_rating" TO co_curricular_rating;

UPDATE staging.wu_app
  SET co_curricular_rating = case
  when co_curricular_rating LIKE '%Below%' then '1'::int
  when co_curricular_rating LIKE 'Average' then '2'::int
  when co_curricular_rating LIKE '%Above%' then '3'::int
  when co_curricular_rating LIKE 'Demanding' then '4'::int
  when co_curricular_rating LIKE '%Very%' then '5'::int
  when co_curricular_rating LIKE '%Most%' then '6'::int
  END;

UPDATE staging.wu_app
  SET curriculum_rating = case
  when curriculum_rating LIKE '%Below%' then '1'::int
  when curriculum_rating LIKE 'Average' then '2'::int
  when curriculum_rating LIKE '%Above%' then '3'::int
  when curriculum_rating LIKE 'Demanding' then '4'::int
  when curriculum_rating LIKE '%Very%' then '5'::int
  when curriculum_rating LIKE '%Most%' then '6'::int
  END;

ALTER TABLE staging.wu_app
ALTER COLUMN co_curricular_rating TYPE smallint USING co_curricular_rating::smallint,
ALTER COLUMN curriculum_rating TYPE smallint USING curriculum_rating::smallint;
-------------------
-- Writing rating
-------------------

UPDATE staging.wu_app
  SET writing_rating = case
  when writing_rating LIKE 'Below%' then '1'::int
  when writing_rating LIKE 'Average' then '2'::int
  when writing_rating LIKE 'Above%' then '3'::int
  when writing_rating LIKE 'Outstanding' then '4'::int
  END;

--------------------------------------------------------------------
-- numeric edits - mostly to 1/0
--------------------------------------------------------------------

ALTER TABLE staging.wu_app DROP COLUMN transfer;
ALTER TABLE staging.wu_app RENAME COLUMN student_type TO transfer;

UPDATE staging.wu_app
SET  transfer= case
when SPLIT_PART(round, ' ', 3) LIKE 'Transfer' then '1'::int
else '0'::int
END;

ALTER TABLE staging.wu_app
  ALTER COLUMN transfer TYPE smallint USING transfer::smallint;


UPDATE staging.wu_app
  SET has_competitive_scholarship_application = case
  when has_competitive_scholarship_application LIKE '%Yes%' then '1'::int
  when has_competitive_scholarship_application LIKE '%No%' then '0'::int
  END;

ALTER TABLE staging.wu_app
  ALTER COLUMN has_competitive_scholarship_application TYPE smallint USING has_competitive_scholarship_application::smallint;
  
ALTER TABLE staging.wu_app
  ALTER COLUMN relative_attended_wu TYPE smallint USING relative_attended_wu::smallint;
  
ALTER TABLE staging.wu_app RENAME COLUMN "first_wc_in-person_visit" TO first_wc_in_person_visit;
ALTER TABLE staging.wu_app RENAME COLUMN "most_recent_wc_in-person_visit" TO most_recent_wc_in_person_visit;

 
ALTER TABLE staging.wu_app
  ALTER COLUMN person_calculated_merit_rank TYPE smallint,
  ALTER COLUMN converted_satr_superscore TYPE smallint,
  ALTER COLUMN permanent_resident TYPE smallint,
  ALTER COLUMN app_weighted_gpa TYPE float4 USING app_weighted_gpa::float4,
  ALTER COLUMN app_unweighted_gpa TYPE float4 USING app_unweighted_gpa::float4,
  ALTER COLUMN student_athlete TYPE float4 USING student_athlete::float4,
  ALTER COLUMN relative_attended_wu TYPE float4 USING relative_attended_wu::float4,
  ALTER COLUMN hold_decision_released TYPE float4 USING hold_decision_released::float4,
  ALTER COLUMN app_transfer_gpa TYPE float4 USING app_transfer_gpa::float4;


----------------------------------------------------------------------------------------
-- duplicate issues with past school
----------------------------------------------------------------------------------------

--since there are many school names where the duplicate is just uppercase, changing all past school names to uppercase

UPDATE staging.wu_app
SET school_1_name = UPPER(school_1_name);


UPDATE staging.wu_app
SET school_1_name = case
  WHEN school_1_name = 'WEST HIGH SCHOOL' AND school_1_code = '20000' THEN 'WEST ANCHORAGE HIGH SCHOOL'
  WHEN school_1_name = 'BETTYE DAVIS EAST ANCHORAGE HIGH SCHOOL' AND school_1_code = '20002' THEN 'EAST ANCHORAGE HIGH SCHOOL'
  WHEN school_1_name = 'WEST VALLEY HIGH' AND school_1_code = '20028' THEN 'WEST VALLEY HIGH SCHOOL'
  WHEN school_1_name LIKE 'MONROE CATHOLIC J%' AND school_1_code = '20037' THEN 'MONROE CATHOLIC HIGH SCHOOL'
  WHEN school_1_name = 'FLAGSTAFF ARTS & LEADERSHIP AC' AND school_1_code = '30104' THEN 'FLAGSTAFF ARTS AND LEADERSHIP ACADEMY'
  WHEN school_1_name LIKE 'GREAT HEARTS%' AND school_1_code = '30649' THEN 'CHANDLER PREPARATORY ACADEMY'
  WHEN school_1_name = 'RANCHO SOLANO PREPARATORY SCHL' AND school_1_code='30658' THEN 'RANCHO SOLANO PREPARATORY SCHOOL'
  WHEN school_1_name = 'AMERICAN LEADERSHIP ACADEMY IRONWOOD 7-12' AND school_1_code = '30771' THEN 'AMERICAN LEADERSHIP ACADEMY IRONWOOD'
  WHEN school_1_name = 'FAYETTEVILLE SENIOR HIGH SCHOOL' AND school_1_code = '40770' THEN 'FAYETTEVILLE HIGH SCHOOL'
  WHEN school_1_name = 'ENCINAL JUNIOR/SENIOR HIGH SCHOOL' AND school_1_code = '50015' THEN 'ENCINAL HIGH SCHOOL'
  WHEN school_1_name = 'RAMONA CONVENT SECONDARY SCH' AND school_1_code = '50060' THEN 'RAMONA CONVENT SECONDARY SCHOOL'
  WHEN school_1_name = 'BEAUMONT HIGH SCHOOL, CHERRY VALLEY, CA, 92223' AND school_1_code = '50240' THEN 'BEAUMONT HIGH SCHOOL'
  WHEN school_1_name LIKE '%HEAD-ROYCE%' AND school_1_code = '50285' THEN 'THE HEAD-ROYCE SCHOOL'
  WHEN school_1_name = 'GIRLS ACADEMIC LEADERSHIP, DR MICHELLE KING SCHOOL FOR STEM' AND school_1_code = '50309' THEN 'GIRLS ACADEMIC LEADERSHIP ACADEMY'
  WHEN school_1_name = 'CAMARILLO (ADOLFO) HIGH' AND school_1_code = '50438' THEN 'ADOLFO CAMARILLO HIGH SCHOOL'
  WHEN school_1_code = '50470' THEN 'ARMY AND NAVY ACADEMY'
  WHEN school_1_code = '50658' THEN 'CLAYTON VALLEY CHARTER HIGH SCHOOL'
  WHEN school_1_code = '50724' THEN 'THE ATHENIAN SCHOOL'
  WHEN school_1_code = '50730' THEN 'DAVIS SENIOR HIGH SCHOOL'
  WHEN school_1_code = '50867' THEN 'CRESPI CARMELITE HIGH SCHOOL'
  WHEN school_1_code = '51088' THEN 'GRANADA HILLS CHARTER HIGH SCHOOL'
  WHEN school_1_code = '51095' THEN 'NEVADA UNION HIGH SCHOOL'
  WHEN school_1_code = '51120' THEN 'HALF MOON BAY HIGH SCHOOL'
  WHEN school_1_code = '51213' THEN 'THE NUEVA SCHOOL'
  WHEN school_1_code = '51330' THEN 'THE BISHOPS SCHOOL'
  WHEN school_1_code = '51335' THEN 'LA JOLLA HIGH SCHOOL'
  WHEN school_1_code = '51480' THEN 'LONG BEACH POLYTECHNIC HIGH SCHOOL'
  WHEN school_1_code = '51505' THEN 'WOODROW WILSON HIGH SCHOOL'
  WHEN school_1_code = '51525' THEN 'ALEXANDER HAMILTON HIGH SCHOOL'
  WHEN school_1_code = '51538' THEN 'GHIDOTTI EARLY COLLEGE HIGH SCHOOL'
  WHEN school_1_code = '51625' THEN 'IMMACULATE HEART HIGH SCHOOL'
  WHEN school_1_code = '51629' THEN 'VALLEY INTERNATIONAL PREPARATORY HIGH SCHOOL'
  WHEN school_1_code = '51727' THEN 'MILKEN COMMUNITY SCHOOL'
  WHEN school_1_code = '52347' THEN 'HENRY M GUNN HIGH SCHOOL'
  WHEN school_1_code = '52380' THEN 'FLINTRIDGE SACRED HEART ACADEMY'
  WHEN school_1_code = '52388' THEN 'JOHN MARSHALL FUNDAMENTAL SCHOOL'
  WHEN school_1_code = '52681' THEN 'ROLLING HILLS PREPARATORY SCHOOL'
  WHEN school_1_code = '52705' THEN 'C K MCCLATCHY HIGH SCHOOL'
  WHEN school_1_code = '52837' THEN 'CLAIREMONT HIGH SCHOOL'
  WHEN school_1_code = '52860' THEN 'MISSION BAY HIGH SCHOOL'
  WHEN school_1_code = '52862' THEN 'MOUNT CARMEL HIGH SCHOOL'
  WHEN school_1_code = '52984' THEN 'JEWISH COMMUNITY HIGH SCHOOL OF THE BAY'
  WHEN school_1_code = '53005' THEN 'SACRED HEART CATHEDRAL PREPARATORY'
  WHEN school_1_code = '53112' THEN 'SAINT MARGARETS EPISCOPAL SCHOOL'
  WHEN school_1_code = '53173' THEN 'KEHILLAH JEWISH HIGH SCHOOL'
  WHEN school_1_code = '53195' THEN 'SAN PEDRO HIGH SCHOOL'
  WHEN school_1_code = '53272' THEN 'SAN MARCOS HIGH SCHOOL'
  WHEN school_1_code = '53290' THEN 'GEORGIANA BRUCE KIRBY PREPARATORY SCHOOL'
  WHEN school_1_code = '53379' THEN 'ROYAL HIGH SCHOOL'
  WHEN school_1_code = '53410' THEN 'SOUTH PASADENA HIGH SCHOOL'
  WHEN school_1_code = '53435' THEN 'SAINT MARYS HIGH SCHOOL'
  WHEN school_1_code = '53468' THEN 'VILLAGE CHRISTIAN HIGH SCHOOL'
  WHEN school_1_code = '53540' THEN 'TAHOE TRUCKEE HIGH SCHOOL'
  WHEN school_1_code = '53878' THEN 'SUMMIT PREPARATORY HIGH SCHOOL'
  WHEN school_1_code = '53973' THEN 'VISTAMAR SCHOOL'
  WHEN school_1_code = '53985' THEN 'THE BAY SCHOOL OF SAN FRANCISCO'
  WHEN school_1_code = '54134' THEN 'LYDIAN ACADEMY LLC'
  WHEN school_1_code = '54494' THEN 'THE WALDORF SCHOOL OF SAN DIEGO: HIGH SCHOOL CAMPUS'
  WHEN school_1_code = '54566' THEN 'SLO CLASSICAL ACADEMY HIGH SCHOOL'
  WHEN school_1_code = '54639' THEN 'FUSION ACADEMY - LOS GATOS'
  WHEN school_1_code = '54683' THEN 'LARCHMONT CHARTER SCHOOL'
  WHEN school_1_code = '60051' THEN 'RALSTON VALLEY HIGH SCHOOL'
  WHEN school_1_code = '60465' THEN 'DOLORES HIGH SCHOOL'
  WHEN school_1_code = '60485' THEN 'DSST CEDAR HIGH SCHOOL'
  WHEN school_1_code = '60867' THEN 'ALEXANDER DAWSON SCHOOL'
  WHEN school_1_code = '120038' THEN 'HONOKAA HIGH SCHOOL'
  WHEN school_1_code = '120038' THEN 'HENRY J KAISER HIGH SCHOOL'
  WHEN school_1_code = '120040' THEN 'IOLANI SCHOOL'
  WHEN school_1_code = '120075' THEN 'MID PACIFIC INSTITUTE'
  WHEN school_1_code = '120090' THEN 'ROOSEVELT HIGH SCHOOL'
  WHEN school_1_code = '120161' THEN 'KAPOLEI HIGH SCHOOL'
  WHEN school_1_code = '120217' THEN 'KAMEHAMEHA SCHOOLS MAUI CAMPUS'
  WHEN school_1_code = '130043' THEN 'BORAH HIGH SCHOOL'
  WHEN school_1_code = '141009' THEN 'NOBLE STREET CHARTER HIGH SCHOOL'
  WHEN school_1_code = '241695' THEN 'WASHBURN HIGH SCHOOL'
  WHEN school_1_code = '290109' THEN 'FAITH LUTHERAN HIGH SCHOOL'
  WHEN school_1_code = '290140' THEN 'BISHOP MANOGUE CATHOLIC HIGH SCHOOL'
  WHEN school_1_code = '380049' THEN 'INTERNATIONAL SCHOOL OF BEAVERTON'
  WHEN school_1_code = '380062' THEN 'ADRIENNE C NELSON HIGH SCHOOL'
  WHEN school_1_code = '380081' THEN 'ARTS AND COMMUNICATION MAGNET ACADEMY'
  WHEN school_1_code = '380323' THEN 'WINSTON CHURCHILL HIGH SCHOOL'
  WHEN school_1_code = '380326' THEN 'HENRY D SHELDON HIGH SCHOOL'
  WHEN school_1_code = '380645' THEN 'MCMINNVILLE HIGH SCHOOL'
  WHEN school_1_code = '380655' THEN 'SAINT MARYS SCHOOL'
  WHEN school_1_code = '380660' THEN 'LOST RIVER JUNIOR-SENIOR HIGH SCHOOL'
  WHEN school_1_code = '380713' THEN 'JOHN F KENNEDY HIGH SCHOOL'
  WHEN school_1_code = '380750' THEN 'NORTH BEND HIGH SCHOOL'
  WHEN school_1_code = '380795' THEN 'LAKE OSWEGO HIGH SCHOOL'
  WHEN school_1_code = '380840' THEN 'BENSON POLYTECHNIC HIGH SCHOOL'
  WHEN school_1_code = '380859' THEN 'DE LA SALLE NORTH CATHOLIC HIGH SCHOOL'
  WHEN school_1_code = '380880' THEN 'GRANT HIGH SCHOOL'
  WHEN school_1_code = '380902' THEN 'MCDANIEL HIGH SCHOOL'
  WHEN school_1_code = '380920' THEN 'SAINT MARYS ACADEMY'
  WHEN school_1_code = '380937' THEN 'IDA B. WELLS-BARNETT HIGH SCHOOL'
  WHEN school_1_code = '381016' THEN 'BLANCHET CATHOLIC SCHOOL'
  WHEN school_1_code = '381024' THEN 'MCNARY HIGH SCHOOL'
  WHEN school_1_code = '381026' THEN 'DOUGLAS MCKAY HIGH SCHOOL'
  WHEN school_1_code = '381040' THEN 'SOUTH SALEM HIGH SCHOOL'
  WHEN school_1_code = '381055' THEN 'SANDY UNION HIGH SCHOOL'
  WHEN school_1_code = '381265' THEN 'WOODBURN HIGH SCHOOL'
  WHEN school_1_code = '440069' THEN 'LIBERAL ARTS & SCIENCE ACADEMY'
  WHEN school_1_code = '440209' THEN 'WATERLOO SCHOOL'
  WHEN school_1_code = '440300' THEN 'MCCALLUM HIGH SCHOOL'
  WHEN school_1_code = '440334' THEN 'GRIFFIN SCHOOL'
  WHEN school_1_code = '441147' THEN 'PRINCE OF PEACE CHRISTIAN SCHOOL'
  WHEN school_1_code = '441883' THEN 'UPLIFT LUNA PREPARATORY HIGH SCHOOL'
  WHEN school_1_code = '443293' THEN 'XAVIER ACADEMY'
  WHEN school_1_code = '443376' THEN 'KINDER HIGH SCHOOL FOR PERFORMING & VISUAL ARTS'
  WHEN school_1_code = '443378' THEN 'MICHAEL E DEBAKEY HIGH SCHOOL'
  WHEN school_1_code = '443760' THEN 'ENERGY INSTITUTE HIGH SCHOOL'
  WHEN school_1_code = '446283' THEN 'BASIS SAN ANTONIO SHAVANO'
  WHEN school_1_code = '450375' THEN 'JUDGE MEMORIAL CATHOLIC HIGH SCHOOL'
  WHEN school_1_code = '480046' THEN 'AUBURN RIVERSIDE HIGH SCHOOL'
  WHEN school_1_code = '480067' THEN 'EASTSIDE CATHOLIC HIGH SCHOOL'
  WHEN school_1_code = '480073' THEN 'OVERLAKE SCHOOL'
  WHEN school_1_code = '480539' THEN 'KENTWOOD HIGH SCHOOL'
  WHEN school_1_code = '480797' THEN 'MOUNT SI HIGH SCHOOL'
  WHEN school_1_code = '481070' THEN 'FOREST RIDGE SCHOOL SACRED HEART'
  WHEN school_1_code = '481085' THEN 'THE BUSH SCHOOL'
  WHEN school_1_code = '481127' THEN 'THE NORTHWEST SCHOOL'
  WHEN school_1_code = '481169' THEN 'UNIVERSITY PREPARATORY ACADEMY'
  WHEN school_1_code = '481355' THEN 'ANNIE WRIGHT SCHOOL'
  ELSE school_1_name
  END;



---------------------------------------------------------------------------------
---- 
----  Fixing duplicates in colleague_id 
----
----------------------------------------------------------------------------------


SELECT a.* 
FROM staging.wu_app a
--RIGHT JOIN staging.nsc_fall_23_24_25 n ON n.appl_students_id = a.colleague_id
  WHERE a.colleague_id IN (
    SELECT colleague_id
    FROM staging.wu_app
    GROUP BY colleague_id
    HAVING COUNT(*) > 1
);

-- If they want to transfer to WU after already applying, they are probably going to go to Willamette. We could look at just these people as a business question if desired
-- going to pick the earlier one

-- this deletes 102 rows

DELETE FROM staging.wu_app
WHERE slate_id IN (
    SELECT slate_id
    FROM (
        SELECT slate_id, 
               ROW_NUMBER() OVER (
                   PARTITION BY colleague_id
                   ORDER BY app_submitted ASC
               ) AS row_num
        FROM staging.wu_app
    ) t
    WHERE t.row_num > 1
);

delete from staging.wu_app
WHERE colleague_id is NULL;
-- deleted 1 row above


SELECT DISTINCT a.colleague_id, a.common_app_fee_waiver, a.need_based_aid, a.talent_scholarships,
  a.person_fafsa_submit_date, a.efc_sai
  FROM staging.wu_app a
  RIGHT JOIN staging.nsc_fall_23_24_25 n ON a.colleague_id = n.appl_students_id
  WHERE n.appl_students_id is not null AND a.colleague_id is not null;

--------------------------------------------------------------------------------
-----
----- Fixing data types for various columns
-----
--------------------------------------------------------------------------------

ALTER TABLE staging.wu_app
  ALTER COLUMN app_created TYPE date USING app_created::date,
  ALTER COLUMN app_submitted TYPE date USING app_submitted::date,
  ALTER COLUMN prospect_created_date TYPE date USING prospect_created_date::date,
  ALTER COLUMN inquiry_date TYPE date USING inquiry_date::date,
  ALTER COLUMN applicant_date TYPE date USING applicant_date::date,
  ALTER COLUMN first_wc_in_person_visit TYPE date USING first_wc_in_person_visit::date,
  ALTER COLUMN first_wc_virtual_visit TYPE date USING first_wc_virtual_visit::date,
  ALTER COLUMN most_recent_wc_in_person_visit TYPE date USING most_recent_wc_in_person_visit::date,
  ALTER COLUMN most_recent_wc_virtual_visit TYPE date USING most_recent_wc_virtual_visit::date,
  ALTER COLUMN person_fafsa_submit_date TYPE date USING person_fafsa_submit_date::date;