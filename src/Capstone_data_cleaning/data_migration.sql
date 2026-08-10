-----------------------------------

-- Migration of data into the tables in the capstone schema

-----------------------------------


BEGIN TRANSACTION;


-- 1. Populate colleges
INSERT INTO capstone.attend_school(college_name, college_state, private)
SELECT DISTINCT college_name, college_state, private
FROM staging.nsc_fall_23_24_25
WHERE college_name is not null;

--2. Populate applicant
INSERT INTO capstone.applicant(person_id, city, region, country,
  sex, first_gen_status, citizenship_status, primary_citizenship, secondary_citizenship,
  permanent_resident, ipeds_classification, college_name, past_school_name, past_school_code, past_school_geomarket)
SELECT DISTINCT a.colleague_id, a.active_city, a.active_region, a.active_country, a.sex,
  a.first_gen_status, a.person_citizenship_status, a.primary_citizenship, a.secondary_citizenship,
  a.permanent_resident, a.ipeds_classification, n.college_name, a.school_1_name, a.school_1_code, a.school_1_address_geomarket
  FROM staging.wu_app a 
  INNER JOIN staging.nsc_fall_23_24_25 n ON a.colleague_id = n.appl_students_id
  WHERE n.appl_students_id is not NULL and a.colleague_id is not NULL;

--3. Populate financials
INSERT INTO capstone.financials(person_id, common_app_fee_waiver, need_based_aid,
  talent_scholarship, fafsa_submit_date, efc_sai)
SELECT DISTINCT a.colleague_id, a.common_app_fee_waiver, a.need_based_aid, a.talent_scholarships,
  a.person_fafsa_submit_date, a.efc_sai
  FROM staging.wu_app a
  INNER JOIN staging.nsc_fall_23_24_25 n ON a.colleague_id = n.appl_students_id
  WHERE n.appl_students_id is not null AND a.colleague_id is NOT NULL;

--4. Populate academics
INSERT INTO capstone.academics(person_id, weighted_gpa, unweighted_gpa, transfer_gpa,
  co_curricular_rating, curriculum_rating, writing_rating, converted_satr_superscore,
  calc_merit_rank, edi_access_check)
  SELECT DISTINCT a.colleague_id, a.app_weighted_gpa, a.app_unweighted_gpa, a.app_transfer_gpa,
  a.co_curricular_rating, a.curriculum_rating, a.writing_rating, a.converted_satr_superscore, 
  a.person_calculated_merit_rank, a.edi_access_check

  FROM staging.wu_app a
  INNER JOIN staging.nsc_fall_23_24_25 n ON a.colleague_id = n.appl_students_id
  WHERE n.appl_students_id is not null AND a.colleague_id is NOT NULL;

--5. Populate Interests
INSERT INTO capstone.interests(person_id, primary_academic_interest, academic_interest,
  activity_interest, comp_scholarship_interest, dual_degree_interest)
SELECT DISTINCT a.colleague_id, a.app_academic_interest, a.academic_interest, a.activity_interest,
  a.competitive_scholarship_interest, a.dual_degree_interest

FROM staging.wu_app a 
INNER JOIN staging.nsc_fall_23_24_25 n ON a.colleague_id = n.appl_students_id
  WHERE n.appl_students_id is not null AND a.colleague_id is NOT NULL;

--6. Populate Wu_Interests
INSERT INTO capstone.wu_interest(person_id, first_source_origin, prospect_created_date, inquiry_date,
  applicant_date, relative_attended_wu, first_wc_in_person_visit, first_wc_virtual_visit,
  most_recent_wc_virtual_visit, most_recent_wc_in_person_visit)

SELECT DISTINCT a.colleague_id, a.first_source_origin_first_source_memo, a.prospect_created_date,
  a.inquiry_date, a.applicant_date, a.relative_attended_wu, a.first_wc_in_person_visit,
  a.first_wc_virtual_visit, a.most_recent_wc_virtual_visit, a.most_recent_wc_in_person_visit

FROM staging.wu_app a 
INNER JOIN staging.nsc_fall_23_24_25 n ON a.colleague_id = n.appl_students_id
  WHERE n.appl_students_id is not null AND a.colleague_id is NOT NULL;
--7. Populate application
INSERT INTO capstone.application(person_id, app_created, app_submitted, round, admission_plan,
  testing_plan, app_origin, rec_value, transfer,
  entry_term, appl_start_term)

SELECT DISTINCT a.colleague_id, a.app_created, a.app_submitted, a.round, a.admission_plan,
  a.testing_plan, a.application_origin, a.rec_value, a.transfer, a.entry_term, n.appl_start_term

FROM staging.wu_app a 
INNER JOIN staging.nsc_fall_23_24_25 n ON a.colleague_id = n.appl_students_id
  WHERE n.appl_students_id is not null AND a.colleague_id is NOT NULL;


COMMIT;
