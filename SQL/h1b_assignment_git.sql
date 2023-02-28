-- School projects from the MBAN program at Hult

/* In the h1b project data regarding foreigners applying for a work
visa in the United States is used. The data is taken from the U.S. 
Citizenship and Immigration Services.

The idea behind the project was to modify and analyze the data to 
write a recommendation for a fictional client looking to get employed 
in the US. Before any data analysis, a profile was created for the 
client, age, professional background, education level, and which 
industry the individual would like to enter. Knowing the client, 
the necessary queries could be written and an appropriate recommendation 
could be written based on the data analyzed from the queries outputs.

However, before the data could be analysed in SQL the dataset was 
cleaned in power query and later uploaded to a Microsoft Azure. 
*/

USE h1b_team_20;


/*
Data Management & SQL - DAT-5486 - BMBAND1
A2: H1B Visas [Pair/Trio - Timed]
Authors: Axel Gripenlöf Karlberg, Stine Wincentsen, Ximena Hamón Díaz
*/
/*
QUESTION: Are there certain types of jobs concentrated in certain geographical areas?
Geographical areas, East coast & West Coast
Records for all years, until 2022
*/
 

/*
Extracting the concentration of job titles on the east and west coast. By filtering 
for the states on the east and west coast and grouping by the occupation id, occupation
title, and geographical area and counting occupation id it’s possible to extract the 
job concentration.
*/
SELECT 
    oc.occupation_title,
    COUNT(oc.occupation_id) AS job_concentration,
    CASE
        WHEN worksite_state = 'MA' THEN 'east coast'
        WHEN worksite_state = 'ME' THEN 'east coast'
        WHEN worksite_state = 'NH' THEN 'east coast'
        WHEN worksite_state = 'RI' THEN 'east coast'
        WHEN worksite_state = 'CT' THEN 'east coast'
        WHEN worksite_state = 'NY' THEN 'east coast'
        WHEN worksite_state = 'NJ' THEN 'east coast'
        WHEN worksite_state = 'DE' THEN 'east coast'
        WHEN worksite_state = 'MD' THEN 'east coast'
        WHEN worksite_state = 'VA' THEN 'east coast'
        WHEN worksite_state = 'NC' THEN 'east coast'
        WHEN worksite_state = 'SC' THEN 'east coast'
        WHEN worksite_state = 'GA' THEN 'east coast'
        WHEN worksite_state = 'FL' THEN 'east coast'
        WHEN worksite_state = 'AK' THEN 'west coast'
        WHEN worksite_state = 'CA' THEN 'west coast'
        WHEN worksite_state = 'HI' THEN 'west coast'
        WHEN worksite_state = 'OR' THEN 'west coast'
        WHEN worksite_state = 'WA' THEN 'west coast'
        ELSE 'rest of usa'
    END AS geographical_areas
FROM
    case_applications AS ca
        INNER JOIN
    occupations AS oc USING (occupation_id)
WHERE
    ca.worksite_state IN ('MA' , 'ME', 'NH','RI','CT','NY','NJ','DE','MD','VA',
        'NC','SC','GA','FL','AK','CA','HI','OR','WA')
        
GROUP BY oc.occupation_id , occupation_title , geographical_areas
ORDER BY job_concentration DESC
LIMIT 10
;

/*
QUESTION: Are there certain types of jobs concentrated in certain geographical areas?
The variation of this question is focused in analyze the concentration of jobs into the 
west & east cost, specifically within the Health Care, Tech & finance industries, for 
the years between 2021 and 2022. This to get specific information according to customer requirements
*/
 
SELECT 
    oc.occupation_title,
    COUNT(oc.occupation_id) AS job_concentration,
    CASE
        WHEN worksite_state = 'MA' THEN 'east coast'
        WHEN worksite_state = 'ME' THEN 'east coast'
        WHEN worksite_state = 'NH' THEN 'east coast'
        WHEN worksite_state = 'RI' THEN 'east coast'
        WHEN worksite_state = 'CT' THEN 'east coast'
        WHEN worksite_state = 'NY' THEN 'east coast'
        WHEN worksite_state = 'NJ' THEN 'east coast'
        WHEN worksite_state = 'DE' THEN 'east coast'
        WHEN worksite_state = 'MD' THEN 'east coast'
        WHEN worksite_state = 'VA' THEN 'east coast'
        WHEN worksite_state = 'NC' THEN 'east coast'
        WHEN worksite_state = 'SC' THEN 'east coast'
        WHEN worksite_state = 'GA' THEN 'east coast'
        WHEN worksite_state = 'FL' THEN 'east coast'
        WHEN worksite_state = 'AK' THEN 'west coast'
        WHEN worksite_state = 'CA' THEN 'west coast'
        WHEN worksite_state = 'HI' THEN 'west coast'
        WHEN worksite_state = 'OR' THEN 'west coast'
        WHEN worksite_state = 'WA' THEN 'west coast'
        ELSE 'rest of usa'
    END AS geographical_areas
FROM
    case_applications AS ca
        INNER JOIN
    occupations AS oc USING (occupation_id)
        INNER JOIN
    industries AS ind USING (industry_id)
WHERE
    ca.worksite_state IN ('MA' , 'ME','NH','RI','CT','NY','NJ','DE','MD','VA',
        'NC','SC','GA','FL','AK','CA','HI','OR','WA')
        AND ind.definition IN ('Finance and Insurance' , 'Professional, Scientific, and Technical Services',
        'Health Care and Social Assistance')
        AND application_year IN (2021 , 2022)
GROUP BY oc.occupation_id , occupation_title , geographical_areas
ORDER BY job_concentration DESC
LIMIT 10
;

/*
Is there an outlier within the salary range of Healthcare Practitioners and 
Technical Occupations between states?
*/
SELECT 
    MAX(yearly_wage) AS max_range,
    MIN(yearly_wage) AS min_range,
    (MAX(yearly_wage) - MIN(yearly_wage)) AS salary_range,
    worksite_state,
    COUNT(case_id) number_of_people_employed,
    occupation_title
FROM
    case_applications
        LEFT JOIN
    occupations USING (occupation_id)
        LEFT JOIN
    employers USING (employer_id)
WHERE
    occupation_title = 'Healthcare Practitioners and Technical Occupations'
        AND application_year = 2022
GROUP BY worksite_state , occupation_title
ORDER BY (MAX(yearly_wage) - MIN(yearly_wage)) DESC , worksite_state
LIMIT 10
;

/*
Which functions have historically paid the most within the Health Care and Social Assistance industry?
What is the number of people employed with a H1B visa under that function? 
Looking at the years 2022.
*/

SELECT 
    application_year,
    AVG(yearly_wage) AS average_yearly_salary_per_title,
    COUNT(occupation_title) AS number_of_individuals_under_title,
    occupation_title
FROM
    case_applications
        LEFT JOIN
    occupations ON case_applications.occupation_id = occupations.occupation_id
        LEFT JOIN
    application_status ON case_applications.status_id = application_status.status_id
        LEFT JOIN
    industries ON case_applications.industry_id = industries.industry_id
WHERE
    case_status LIKE 'Certified'
        AND occupation_title IS NOT NULL
        AND application_year = 2022
        AND industries.definition LIKE 'Health Care and Social Assistance'
GROUP BY occupation_title , application_year
ORDER BY AVG(yearly_wage) DESC , COUNT(occupation_title)
LIMIT 10
;

/*
Which job title has the highest rate of certifying H1B's?
Looking at  years and broken into statutory basis. 
Limited to the top 10 number of cases approved.
 */

SELECT 
    application_year,
    case_status,
    COUNT(case_status) cases_approved,
    occupation_title
FROM
    case_applications
        LEFT JOIN
    application_status USING (status_id)
        LEFT JOIN
    occupations USING (occupation_id)
WHERE
    case_status LIKE 'Certified'
        AND application_year = 2021
GROUP BY case_status , occupation_title , application_year
ORDER BY COUNT(case_status) DESC
LIMIT 10
;

/* 
Top employers in Massachusetts within the Health Care and Social Assistance as of 2022.
Top employers are determined by looking at two measures 1) The number of sponsorships offered and 2) The average wage.
*/

SELECT 
    COUNT(case_id) AS number_of_sponsorships,
    FORMAT(AVG(yearly_wage), '#,##0') AS average_wage_per_employee,
    application_year,
    employer_name,
    industries.definition
FROM
    case_applications
        LEFT JOIN
    employers ON case_applications.employer_id = employers.employer_id
        LEFT JOIN
    application_status ON case_applications.status_id = application_status.status_id
        LEFT JOIN
    industries ON case_applications.industry_id = industries.industry_id
WHERE
    application_year = 2022
        AND worksite_state LIKE 'MA'
        AND case_status LIKE 'Certified'
        AND industries.definition LIKE 'Health Care and Social Assistance'
GROUP BY application_year , employer_name , industries.definition
ORDER BY COUNT(case_id) DESC , AVG(yearly_wage) DESC
LIMIT 10
;

