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
