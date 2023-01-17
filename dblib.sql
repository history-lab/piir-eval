-- name: get_all_tests
-- Get all tests
select test_id, doc_id, corpus, body
   from piir_eval.tests
   order by test_id;
-- name: add_run<!
insert into piir_eval.runs(method_code) 
   values (:method_code)
   returning run_id;
-- name: add_testrun<!
insert into piir_eval.testruns(run_id, test_id) 
   values (:run_id, :test_id)
   returning testrun_id;
-- name: add_result!
insert into piir_eval.results(testrun_id, entity_code, entity_text,
                              start_idx, end_idx)
   values (:testrun_id, :entity_code, :entity_text,
           :start_idx, :end_idx);
-- name: add_result_noidx!
insert into piir_eval.results(testrun_id, entity_code, entity_text)
   values (:testrun_id, :entity_code, :entity_text);
