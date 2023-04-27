drop view if exists piir_eval.comparisons2;
create view piir_eval.comparisons2 as
with ru(task_id, start_idx, doc_id, doc_url) as (
    select task_id, start_idx, doc_id, doc_url 
        from piir_eval.ground_truth_view
        union
    select task_id, start_idx, doc_id, doc_url 
        from piir_eval.tool_detected_pii t
        where exists (select 1 
                         from piir_eval.ground_truth_view gt
                         where gt.task_id = t.task_id)
)
select ru.task_id, ru.start_idx, t.tool, 
       case when t.start_idx = gt.start_idx then 'TP'
             when gt.start_idx is null and
                  t.start_idx is not null   then 'FP'
             when gt.start_idx is not null and
                  t.start_idx is null       then 'FN'
       end t_redaction_result,
       case when gt.entity_code = t.entity_code and
                 gt.start_idx = t.start_idx then 'TP'
            when gt.entity_code != t.entity_code and
                 gt.start_idx = t.start_idx then 'FP'
            when gt.start_idx is null and
                 t.start_idx is not null    then 'FP'
            when gt.start_idx is not null and
                 t.start_idx is null        then 'FN'
       end t_entity_result,
       gt.entity_code gt_entity_code,
       t.entity_code t_entity_code,
       gt.entity_text gt_entity_text,
       t.entity_text t_entity_text,
       gt.start_idx   gt_start_idx,
       t.start_idx   t_start_idx,
       gt.end_idx     gt_end_idx,
       t.end_idx     t_end_idx,
       gt.creator gt_creator, gt.completed gt_completed,
       gt.label_studio_id, ru.doc_id, ru.doc_url  
    from ru left join piir_eval.ground_truth_view gt
                on (ru.task_id = gt.task_id and 
                    ru.start_idx = gt.start_idx)
            left join piir_eval.tool_detected_pii t
                on (ru.task_id = t.task_id and 
                    ru.start_idx = t.start_idx)
    order by ru.task_id, ru.start_idx;
\copy (select * from comparisons2) to 'comparisons2_full.csv' csv header