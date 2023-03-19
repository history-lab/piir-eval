create view piir_eval.results_view as
select r.method_code, r.run_id, tr.start_time, tr.task_id, 
       tr.taskrun_id, t.doc_id, t.corpus,
       'http://history-lab.org/documents/' || t.doc_id docurl,
       res.result_id, res.entity_code, res.entity_text, 
       '(' || entity_code || ', ' || entity_text || ')' entity_pair,
       res.start_idx, res.end_idx
   from piir_eval.runs r join piir_eval.taskruns tr 
                              on (r.run_id = tr.run_id)
                         join piir_eval.tasks t
                              on (tr.task_id = t.task_id)
                         left join piir_eval.results res
                              on (tr.taskrun_id = res.taskrun_id)
   where r.run_id = (select max(run_id)
                      from piir_eval.runs
                      where method_code = r.method_code);

create view piir_eval.cm_compare as
with muckrock (task_id, muckrock_cnt, muckrock_redactions) as 
              (select task_id, count(result_id), 
                      string_agg(entity_pair, ',' order by result_id)
                  from piir_eval.results_view
                  where method_code = 'muckrock'
                  group by task_id),
     capone   (task_id, capone_cnt, capone_redactions, drivers_license) as 
              (select task_id, count(result_id), 
                      string_agg(entity_pair, ',' order by result_id),
                      max(case when entity_code = 'drivers_license' then 'Y'
                               else 'N'
                          end) 
                  from piir_eval.results_view
                  where method_code = 'capone'
                  group by task_id),
     tasks    (task_id, corpus, doc_id, doc_url) as
              (select t.task_id, t.corpus, t.doc_id,
                      'http://history-lab.org/documents/' || 
                      t.doc_id doc_url
                  from piir_eval.tasks t 
                     join piir_eval.tasksets ts 
                        on (t.taskset_id = ts.taskset_id)
                  where ts.name = 'cables-ssn')
select t.task_id, 
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
   from tasks t left join capone c on (t.task_id = c.task_id)
                left join muckrock m on (t.task_id = m.task_id);

create or replace view piir_eval.capone_eval as
with capone (task_id, start_idx, end_idx, entity_code, entity_text, 
             start_time, doc_id, docurl) as 
            (select task_id, start_idx, end_idx, entity_code, entity_text, 
                    start_time, doc_id, docurl
               from piir_eval.results_view 
               where method_code = 'capone' and 
                     start_idx is not null)
select coalesce(gt.task_id, c.task_id) task_id, 
       gt.start_idx gt_start, gt.end_idx gt_end,
       c.start_idx co_start, c.end_idx co_end,
       gt.entity_code gt_entity, c.entity_code co_entity, 
       c.entity_text co_entity_text, 
       case when c.start_idx = gt.start_idx then 'TP'
            when gt.start_idx is null       then 'FP'
            when gt.start_idx is not null   then 'FN'
       end redaction_result,
       case when gt.entity_code = c.entity_code and
                 gt.start_idx = c.start_idx then 'TP'
            when gt.start_idx is null       then 'FP'
            when gt.start_idx is not null   then 'FN'
       end entity_result,
       start_time, doc_id, docurl
   from piir_eval.ground_truth gt full outer join capone c
     on (gt.task_id = c.task_id and gt.start_idx = c.start_idx)
   order by c.task_id, c.start_idx, gt.start_idx;

create or replace view piir_eval.muckrock_eval as
with muckrock (task_id, start_idx, end_idx, entity_code, entity_text, 
             start_time, doc_id, docurl) as 
            (select task_id, start_idx, end_idx, entity_code, entity_text, 
                    start_time, doc_id, docurl
               from piir_eval.results_view 
               where method_code = 'muckrock' and 
                     start_idx is not null)
select coalesce(gt.task_id, c.task_id) task_id, 
       gt.start_idx gt_start, gt.end_idx gt_end,
       c.start_idx mu_start, c.end_idx mu_end,
       gt.entity_code gt_entity, c.entity_code mu_entity, 
       c.entity_text mu_entity_text, 
       case when c.start_idx = gt.start_idx then 'TP'
            when gt.start_idx is null       then 'FP'
            when gt.start_idx is not null   then 'FN'
       end redaction_result,
       case when gt.entity_code = c.entity_code and
                 gt.start_idx = c.start_idx then 'TP'
            when gt.start_idx is null       then 'FP'
            when gt.start_idx is not null   then 'FN'
       end entity_result,
       start_time, doc_id, docurl
   from piir_eval.ground_truth gt full outer join muckrock c
     on (gt.task_id = c.task_id and gt.start_idx = c.start_idx)
   order by c.task_id, c.start_idx, gt.start_idx;

create or replace view piir_eval.ground_truth_view as
select gt.task_id task_id, gt.start_idx, gt.end_idx,
       gt.entity_code, gt.entity_text, t.doc_id, 
       'http://history-lab.org/documents/' || t.doc_id doc_url, 
       gt.label_studio_id, gt.creator, gt.completed,
       gt.ground_truth_id
     from piir_eval.ground_truth gt join piir_eval.tasks t
          on (gt.task_id = t.task_id);