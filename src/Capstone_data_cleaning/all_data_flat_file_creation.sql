-- Combining all of the data into one flat file, mostly for use in Machine Learning


CREATE TABLE staging.all_data as 
SELECT *
FROM staging.wu_app a
INNER JOIN staging.nsc_fall_23_24_25 n
ON a.colleague_id = n.appl_students_id;


