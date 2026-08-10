# Studio Charter: <project name>

> Filled in live during the **Studio Charter** session in week 3. Every section below is committed in the same commit at the end of that class block. See [Studio Charter (single-session inception)](https://courses.lpcordova.phd/data510/project-framework/charter-inception.html) for the script and time-boxes.

**Owner team:** Courtney St. Onge and Seira Ramchandani	
**Owner Product Lead:** Seira Ramchandani	
**Peer Stakeholder POs:** Mike Kimmell and Dylan Ray
**Instructor / Sponsor:** Lucas Cordova (`LucasCordova` on GitHub)
**GitHub repo:**  [`Capstone2026`](https://github.com/Data-Science-Capstone-Project-2026/Public_Reposistory) 
**Discord category:** Project 10
**Studio Session:** 3
**Studio formed:** 5/25/2026

## Vision

Willamette University Undergraduate Admissions Office and enrollment management team will be able to identify, at the point of application, where a non-enrolled admitted student is likely to enroll instead. This will enable the Admissions Office to tailor materials and enable more targeted and effective recruitment strategies.

## Mission

The owner team will utilize student information, including demographics and the school where a student attended, to develop a classification and clustering model to predict what type of school (Willamette, private NW5 institution, or large university) an admitted applicant to Willamette University is likely to attend. The final deliverable will also include a pipeline that appends a predicted application type to each record in Slate.

## Context

- **Users / affected parties:** who benefits, who is at risk, who might use the result.
  - Primary Beneficiary (Stakeholder): William Mullen, VP for Enrollment Management and the Admissions team
  - Indirect Beneficiary: Willamette Marketing team and prospective students who may receive more relevant communication
  
- **Data sources (proposed):** named sources, access status, license / ethics notes.
  - Clarity and Google Analytics (G4) for aggregate level data on website traffic. Both provided access by JR Tarabocchia
  - Slate CRM data for row level data on student records, Would need access to Slate data without personally identifiable information, and would need to work with Mike Kimmell for that. Access Pending
  - National Student Clearinghouse data (NSC). Enrollment destination data for non-enrolled admits. We are in the process of getting access to this data. Ethics note: There may be PII present in this data, which would require more care to ensure that none of that information makes it through to the final product.
- **Constraints:** time, compute, access, skills, scope. Data accessibility
  - Data accessibility: Data access approval is pending for Slate and NSC; meetings with William Mullen and formal data agreements not yet finalized.
  - Scope: Limited to admitted students over the past 3 years; enrollment destinations grouped into currently three defined categories but needs to be solidified.
  - Skills: Owner team is proficient in R and Python, using SQL for data extraction as well.
- **Ethics risks:** consent, retention, PII, fairness, deployment risk.
  - PII and Confidentiality is our primary ethics risk. Slate records contain sensitive information, and there is a chance that we need to join datasets on SSN. This will require a formal confidentiality agreement and a documented deletion protocol post-join.
  - Fairness: Model predictions should be evaluated for bias across demographic groups to avoid reinforcing inequities in recruitment.

## Success criteria by milestone

- **M1, proposal (W4):** Project charter completed with clear research question, mission, and data sources. Meeting with primary stakeholder scheduled.
- **M2, data summary (W7):** Data access approved and initial datasets assembled through database pull project. Datasets removed of PII and exploratory data analysis completed.
- **M3, poster rough draft (W10):** Models developed and evaluated. Key predictive features identified. A rough draft of the final poster is submitted.
- **M4, write-up rough draft (W12):** Full analysis complete.
- **M5, final write-up and poster (W14):** Final report and poster submitted. Deliverable to primary stakeholders completed.


## Stakeholder alignment memo (one-page summary)

### Why we exist
We exist to offer the Willamette Admissions Office a new targeted strategy for recruitment outreach through the implementation of a predicted application type to each record in Slate. 


### How to reach us
- Discord category: `#10-general` (day-to-day), `#10-studio` (Briefs and Critiques), `#10-blockers` (impediments)
- Google Chat
- GitHub repo: [`Github Repo`](https://github.com/Data-Science-Capstone-Project-2026/Public_Repository)
