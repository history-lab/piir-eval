create view piir_eval.results_view as
select r.method_code, r.run_id, tr.start_time, tr.test_id, 
       tr.testrun_id, t.doc_id, t.corpus,
       'http://history-lab.org/documents/' || t.doc_id docurl,
       res.result_id, res.entity_code, res.entity_text, 
       '(' || entity_code || ', ' || entity_text || ')' entity_pair,
       res.start_idx, res.end_idx
   from piir_eval.runs r join piir_eval.testruns tr 
                              on (r.run_id = tr.run_id)
                         join piir_eval.tests t
                              on (tr.test_id = t.test_id)
                         left join piir_eval.results res
                              on (tr.testrun_id = res.testrun_id)
   where r.run_id = (select max(run_id)
                      from piir_eval.runs
                      where method_code = r.method_code);
