-- name: get_all_tasks
-- Get all tasks
select t.task_id, t.doc_id, t.corpus, t.body
   from piir_eval.tasks t join piir_eval.ls_dcml_data d on (t.task_id = d.task_id)
   where t.task_id = d.task_id
   order by t.task_id;
-- name: add_run<!
insert into piir_eval.runs(method_code) 
   values (:method_code)
   returning run_id;
-- name: add_taskrun<!
insert into piir_eval.taskruns(run_id, task_id) 
   values (:run_id, :task_id)
   returning taskrun_id;
-- name: add_result!
insert into piir_eval.results(taskrun_id, entity_code, entity_text,
                              start_idx, end_idx)
   values (:taskrun_id, :entity_code, :entity_text,
           :start_idx, :end_idx);
-- name: add_result_noidx!
insert into piir_eval.results(taskrun_id, entity_code, entity_text)
   values (:taskrun_id, :entity_code, :entity_text);
