------------------------------------
-- Creation of the tables in the actual schema to then load the data into
------------------------------------
--CREATE SCHEMA capstone

CREATE TABLE IF NOT EXISTS capstone.attend_school(
  college_name varchar PRIMARY KEY,
  college_state varchar,
  private smallint NOT NULL
  );


CREATE table capstone.applicant (
  slate_id int,
  person_id int PRIMARY KEY,
  city varchar(255),
  region varchar(255),
  country varchar(255),
  sex varchar,
  first_gen_status smallint,
  citizenship_status varchar,
  primary_citizenship varchar, 
  secondary_citizenship varchar(255),
  permanent_resident smallint,
  ipeds_classification varchar(255),
  college_name varchar NOT NULL, 
  past_school_name varchar,
  past_school_code varchar,
  past_school_geomarket varchar,
  CONSTRAINT FK_attend_wu
    FOREIGN KEY (college_name) REFERENCES capstone.attend_school(college_name)
    ON DELETE CASCADE
);

CREATE TABLE capstone.wu_interest (
  person_id int PRIMARY KEY,
  first_source_origin varchar,
  prospect_created_date date,
  inquiry_date date,
  applicant_date date,
  relative_attended_wu smallint,
  first_wc_in_person_visit date,
  first_wc_virtual_visit date,
  most_recent_wc_virtual_visit date,
  most_recent_wc_in_person_visit date,
  CONSTRAINT FK_wu_person
    FOREIGN KEY (person_id) REFERENCES capstone.applicant(person_id)
    ON DELETE CASCADE
);

CREATE TABLE capstone.financials(
  person_id int PRIMARY KEY,
  common_app_fee_waiver smallint,
  need_based_aid smallint,
  talent_scholarship varchar,
  fafsa_submit_date date,
  efc_sai int,
  CONSTRAINT FK_fin_person
    FOREIGN KEY (person_id) REFERENCES capstone.applicant(person_id)
    ON DELETE CASCADE
);

CREATE TABLE capstone.interests (
  person_id int PRIMARY KEY,
  primary_academic_interest varchar,
  academic_interest text,
  activity_interest text,
  comp_scholarship_interest varchar,
  dual_degree_interest varchar,
  CONSTRAINT FK_interests_person
    FOREIGN KEY (person_id) REFERENCES capstone.applicant(person_id)
    ON DELETE CASCADE
);

CREATE TABLE capstone.academics (
  person_id int PRIMARY KEY,
  weighted_gpa float,
  unweighted_gpa float,
  transfer_gpa float,
  co_curricular_rating varchar,
  curriculum_rating varchar,
  writing_rating varchar,
  converted_satr_superscore smallint,
  calc_merit_rank smallint,
  edi_access_check smallint,
  CONSTRAINT FK_academics_person
    FOREIGN KEY (person_id) REFERENCES capstone.applicant(person_id)
    ON DELETE CASCADE
);

CREATE TABLE capstone.application(
  person_id int PRIMARY KEY,
  app_created date,
  app_submitted date,
  round varchar,
  admission_plan varchar,
  testing_plan smallint,
  app_origin varchar,
  rec_value varchar,
  transfer smallint,
  entry_term varchar,
  appl_start_term varchar,
  CONSTRAINT FK_app_person
    FOREIGN KEY (person_id) REFERENCES capstone.applicant(person_id)
    ON DELETE CASCADE
);
