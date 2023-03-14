drop view if exists piir_eval.comparisons;
create view piir_eval.comparisons as
with ru(task_id, start_idx, doc_id, doc_url) as (
    select task_id, start_idx, doc_id, doc_url 
        from piir_eval.ground_truth_view
        union
    select test_id, start_idx, doc_id, docurl 
        from piir_eval.results_view
        where method_code = 'capone' and 
              start_idx is not null
        union
    select test_id, start_idx, doc_id, docurl 
        from piir_eval.results_view
        where method_code = 'muckrock' and 
              start_idx is not null
)
select ru.task_id, ru.start_idx, 
       case when co.start_idx = gt.start_idx then 'TP'
             when gt.start_idx is null and
                  co.start_idx is not null   then 'FP'
             when gt.start_idx is not null and
                  co.start_idx is null       then 'FN'
       end co_redaction_result,
       case when gt.entity_code = co.entity_code and
                 gt.start_idx = co.start_idx then 'TP'
            when gt.entity_code != co.entity_code and
                 gt.start_idx = co.start_idx then 'FP'
            when gt.start_idx is null and
                 co.start_idx is not null    then 'FP'
            when gt.start_idx is not null and
                 co.start_idx is null        then 'FN'
       end co_entity_result,
       case when gt.start_idx = mu.start_idx then 'TP'
            when gt.start_idx is null and
                 mu.start_idx is not null    then 'FP'
            when gt.start_idx is not null and
                 mu.start_idx is null        then 'FN'
       end mu_redaction_result,
       case when gt.entity_code = mu.entity_code and
                 gt.start_idx = mu.start_idx then 'TP'
            when gt.entity_code != mu.entity_code and
                 gt.start_idx = mu.start_idx then 'FP'
            when gt.start_idx is null and
                 mu.start_idx is not null    then 'FP'
            when gt.start_idx is not null and
                 mu.start_idx is null        then 'FN'
       end mu_entity_result,
       gt.entity_code gt_entity_code,
       co.entity_code co_entity_code,
       mu.entity_code mu_entity_code, 
       gt.entity_text gt_entity_text,
       co.entity_text co_entity_text,
       mu.entity_text mu_entity_text,
       gt.start_idx   gt_start_idx,
       co.start_idx   co_start_idx,
       mu.start_idx   mu_start_idx,
       gt.end_idx     gt_end_idx,
       co.end_idx     co_end_idx,
       mu.end_idx     mu_end_idx, 
       gt.creator gt_creator, gt.completed gt_completed,
       co.start_time co_run, mu.start_time mu_run,
       gt.label_studio_id, ru.doc_id, ru.doc_url  
    from ru left join piir_eval.ground_truth_view gt
                on (ru.task_id = gt.task_id and 
                    ru.start_idx = gt.start_idx)
            left join piir_eval.results_view co
                on (ru.task_id = co.test_id and 
                    ru.start_idx = co.start_idx and 
                    co.method_code = 'capone')
            left join piir_eval.results_view mu
                on (ru.task_id = mu.test_id and 
                    ru.start_idx = mu.start_idx and 
                    mu.method_code = 'muckrock')
    order by ru.task_id, ru.start_idx;