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

select method_code, max(start_time)

group by method_code

-- most recent runs
select method_code, run_id, start_time
   from piir_eval.runs r
   where run_id = (select max(run_id)
                      from piir_eval.runs
                      where method_code = r.method_code);
-- most recent results

select test_id, method_code, count(*)
   from piir_eval.results_view
   group by test_id, method_code
   order by test_id, method_code;

# with muckrock(test_id, entity_code, entity_string)  
# with capone(test_id, entity_code, entity_string)
#select count(*)

create view piir_eval.cm_compare as
select test_id, corpus, doc_id, docurl,
       count(*) filter (where method_code = 'capone') capone_cnt,
       count(*) filter (where method_code = 'muckrock') muckrock_cnt,
       string_agg(entity_code, ',' order by result_id)
         filter (where method_code = 'capone') capone_redactions,
       string_agg(entity_pair, ',' order by result_id)
         filter (where method_code = 'muckrock') muckrock_redactions 
   from piir_eval.results_view
   group by test_id
   order by test_id;


select test_id, corpus, doc_id, docurl,
       count(*) filter (where method_code = 'capone') capone_cnt,
       count(*) filter (where method_code = 'muckrock') muckrock_cnt,
       string_agg(entity_code, ',' order by result_id)
         filter (where method_code = 'capone') capone_redactions,
       string_agg(entity_pair, ',' order by result_id)
         filter (where method_code = 'muckrock') muckrock_redactions 
   from piir_eval.results_view
   group by test_id
   order by test_id;

create view piir_eval.cm_compare as
with muckrock (test_id, muckrock_cnt, muckrock_redactions) as 
              (select test_id, count(result_id), 
                      string_agg(entity_pair, ',' order by result_id)
                  from piir_eval.results_view
                  where method_code = 'muckrock'
                  group by test_id),
     capone   (test_id, capone_cnt, capone_redactions, drivers_license) as 
              (select test_id, count(result_id), 
                      string_agg(entity_pair, ',' order by result_id),
                      max(case when entity_code = 'drivers_license' then 'Y'
                               else 'N'
                          end) 
                  from piir_eval.results_view
                  where method_code = 'capone'
                  group by test_id),
     tests    (test_id, corpus, doc_id, doc_url) as
              (select t.test_id, t.corpus, t.doc_id,
                      'http://history-lab.org/documents/' || 
                      t.doc_id doc_url
                  from piir_eval.tests t 
                     join piir_eval.testsets ts 
                        on (t.testset_id = ts.testset_id)
                  where ts.name = 'cables-ssn')
select t.test_id, 
       case when capone_redactions = muckrock_redactions then 'Y'
            else 'N'
       end redactions_match,
       case when capone_cnt = muckrock_cnt then 'Y'
            else 'N'
       end cnts_match, 
       drivers_license, 
       capone_cnt, muckrock_cnt, 
       capone_redactions, muckrock_redactions,
       t.corpus, t.doc_id, 
       'http://history-lab.org/documents/' || t.doc_id doc_url
   from tests t left join capone c on (t.test_id = c.test_id)
                left join muckrock m on (t.test_id = m.test_id);

\copy (select * from piir_eval.cm_compare) to 'cm_compare.csv' with format csv header 
\copy (select * from piir_eval.results_view) to 'results.csv' csv header 