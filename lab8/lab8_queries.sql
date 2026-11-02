-- Запрос 1 
select
	first_name || ' ' || middle_name || '' || last_name as sname,
	career_start_year
	from medical_staff
group by sname, career_start_year
order by career_start_year desc

-- Запрос 2
select
	department_speciality_id,
    count(department_speciality_id) as dsc
from
    public.medical_staff
group by department_speciality_id
order by department_speciality_id  desc;


-- Запрос 3
select
	first_name,
	middle_name,
	last_name,
	career_start_year
from medical_staff
where first_name in ('Елена','Максим')
and career_start_year > 2008
order by  first_name asc, career_start_year desc
limit 5;

-- Запрос 4
select
    appeal.staff_id as sti,
    medical_card_id,
    first_name,
    last_name
from
    public.appeal
    left join medical_staff on medical_staff.staff_id = appeal.staff_id
    where medical_card_id = 1
    order by sti asc
