-- Creating Database if does not exists
CREATE DATABASE IF NOT EXISTS PharmacyClaimsDB;
USE PharmacyClaimsDB;

-- Designate Primary Keys
ALTER TABLE dim_member
CHANGE COLUMN ï»¿member_id member_id INT(250) NOT NULL;

ALTER TABLE dim_member
ADD PRIMARY KEY (member_id);

ALTER TABLE dim_drug
CHANGE COLUMN ï»¿drug_ndc drug_ndc INT(250) NOT NULL;

ALTER TABLE dim_drug
ADD PRIMARY KEY (drug_ndc);

-- Designate Foreign Keys
ALTER TABLE fact_claims
ADD PRIMARY KEY (claim_id);

ALTER TABLE fact_claims MODIFY COLUMN member_id INT;

ALTER TABLE fact_claims
ADD FOREIGN KEY (member_id) REFERENCES dim_member(member_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE fact_claims
ADD FOREIGN KEY (drug_ndc) REFERENCES dim_drug(drug_ndc) ON DELETE CASCADE ON UPDATE CASCADE;

# Part 4 - Analytics and Reporting
# Number of Prescriptions by Drug Name
SELECT drug_name, COUNT(*) AS num_prescriptions
FROM fact_claims
JOIN dim_drug ON fact_claims.drug_ndc = dim_drug.drug_ndc
GROUP BY drug_name;

# Total Prescriptions and Unique Members by Age Group
SELECT 
  CASE 
    WHEN member_age >= 65 THEN 'age 65+'
    ELSE '< 65'
  END AS age_group,
  COUNT(DISTINCT dim_member.member_id) AS unique_members,
  COUNT(*) AS total_prescriptions,
  SUM(copay) AS total_copay,
  SUM(insurancepaid) AS total_insurance
FROM fact_claims
JOIN dim_member ON fact_claims.member_id = dim_member.member_id
GROUP BY age_group;

# Most Recent Prescription Fill Date and Insurance Paid
SELECT DISTINCT
  dim_member.member_id,
  member_first_name,
  member_last_name,
  drug_name,
  FIRST_VALUE(fill_date) OVER(PARTITION BY member_id ORDER BY fill_date DESC) AS most_recent_fill_date,
  FIRST_VALUE(insurancepaid) OVER(PARTITION BY member_id ORDER BY fill_date DESC) AS most_recent_insurance_paid
FROM fact_claims
JOIN dim_member ON fact_claims.member_id = dim_member.member_id
JOIN dim_drug ON fact_claims.drug_ndc = dim_drug.drug_ndc;