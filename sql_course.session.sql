select 
    job_title_short as title,
    job_location as location,
    job_posted_date at time zone 'UTC' at time zone 'EST' as date 
FROM job_postings_fact
limit 5; 

CREATE table january_jobs as 
    SELECT *
    from job_postings_fact
    WHERE
        EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE table february_jobs as 
    SELECT *
    from job_postings_fact
    WHERE
        EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE table march_jobs as 
    SELECT *
    from job_postings_fact
    WHERE
        EXTRACT(MONTH FROM job_posted_date) = 3;

select *
from march_jobs;

select 
    count(job_id) as banyak_job,
    CASE
        when job_location = 'New York, NY' THEN 'Local'
        WHEN job_location = 'Anywhere' THEN 'Remote'
        else 'Onsite'
    END as job_category
from job_postings_fact
where job_title_short = 'Data Analyst'
group by job_category;


select 
    job_id,
    job_title_short,
    job_location,
    job_posted_date
from job_postings_fact
where extract(MONTH from job_posted_date) = 1;


-- subquery
select 
    company_id,
    name as company_name
from 
    company_dim
where company_id in(
    select 
        company_id
    FROM
        job_postings_fact
    where job_no_degree_mention = true
);

-- CTE Common Table Expression
with company_job_count as (
    SELECT 
        company_id,
        count(*) as total_jobs
    from 
        job_postings_fact
    GROUP BY
        company_id
)

select 
    company_dim.name as company_name,
    company_job_count.total_jobs
from 
    company_dim
left JOIN
    company_job_count on company_job_count.company_id = company_dim.company_id
    order by company_job_count.total_jobs DESC;

/*
Find the count of the number of remote job postings per skill
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID, name, and count of postings requiring the skill
*/
with remote_job_skills as(
    select 
        skill_id,
        count(*) as skill_count
    from 
        skills_job_dim
    inner JOIN
        job_postings_fact on job_postings_fact.job_id = skills_job_dim.job_id
    where 
        job_postings_fact.job_title_short = 'Data Analyst' 
    group BY
        skill_id
)

select 
    skill.skill_id,
    skill.skills,
    remote_job_skills.skill_count
from remote_job_skills
inner join skills_dim as skill on skill.skill_id = remote_job_skills.skill_id
order BY
    skill_count desc
limit 5;

/*
    Union = combines two or more tables
    have the same amount of columns and the data type must match
*/

select *
from 
    january_jobs

union all

select *
from 
    february_jobs

UNION all

select *
from
    march_jobs;

/*
Practice Problem 8

Get the correspending skill and skill type for each job posting in q1
Includes those without any skills, too
Why? Look at the skills and the type for each job in the first quarter that
has a salary >
$70,000

*/

-- 

select 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_posted_date::DATE,
    quarter1_job_postings.job_via,
    quarter1_job_postings.salary_year_avg
from (

        select *
        from 
        january_jobs

        union ALL

        SELECT *
        from february_jobs

        union ALL
        select *
        from march_jobs
) as quarter1_job_postings
where 
    quarter1_job_postings.salary_year_avg > 70000
ORDER BY
    quarter1_job_postings.salary_year_avg desc;

