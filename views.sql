create view piir_eval.tasks_view as
select t.task_id, t.taskset_id, ts.name taskset_name, t.corpus,
       t.doc_id, dt.canonical_url doc_url
   from piir_eval.tasks t join piir_eval.tasksets ts
                              on (t.taskset_id = ts.taskset_id)
                          join covid19.dcml_training dt
                              on (t.doc_id = dt.item_id::text);

create view piir_eval.results_view as
select t.taskset_name, r.method_code, r.run_id, tr.start_time, tr.task_id, 
       tr.taskrun_id, t.doc_id, t.corpus, t.doc_url,
       res.result_id, res.entity_code, res.entity_text, 
       res.start_idx, res.end_idx,
       case when start_idx = lag(start_idx, 1) 
               over (order by tr.task_id, start_idx) + 1 
                    then start_idx - 1
                    else start_idx
       end join_idx
   from piir_eval.runs r join piir_eval.taskruns tr 
                              on (r.run_id = tr.run_id)
                         join piir_eval.tasks_view t
                              on (tr.task_id = t.task_id)
                         left join piir_eval.results res
                              on (tr.taskrun_id = res.taskrun_id)
   where r.run_id = (select max(run_id)
                      from piir_eval.runs
                      where method_code = r.method_code);

create or replace view piir_eval.ground_truth_view as
select gt.task_id task_id, gt.start_idx, gt.end_idx,
       gt.entity_code, gt.entity_text, t.doc_id, t.doc_url, 
       gt.label_studio_id, gt.creator, gt.completed,
       gt.ground_truth_id
     from piir_eval.ground_truth gt join piir_eval.tasks_view t
          on (gt.task_id = t.task_id);