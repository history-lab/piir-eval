--
set search_path=piir_eval;
-- how many tests had no results?
select count(*) from tests t 
   where not exists (select 1 from results r where r.test_id = t.test_id);
-- how many results detected by each method
select method_code, count(method_code)
   from results
   group by method_code;
-- how many results detected by each method by doc
select test_id, 
       count(test_id) filter (where method_code = 'capone')  capone,
       count(test_id) filter (where method_code = 'muckrock') muckrock 
   from results
   group by test_id;
-- TODO: results count equal & not equal   
-- how many complete concurrences? differences but detection
with capone as (select * from results where method_code = 'capone'),
     muckrock as (select * from results where method_code = 'muckrock')
     select count(*) from capone c join muckrock m on (
        c.test_id = m.test_id and
        c.start_idx = m.start_idx and
        c.end_idx = m.end_idx
     );