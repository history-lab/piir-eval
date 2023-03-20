drop view if exists piir_eval.tool_comparisons;
create view piir_eval.tool_comparisons as
with ru(task_id, join_idx, doc_id, doc_url) as (
    select task_id, join_idx, doc_id, doc_url 
        from piir_eval.results_view
        where method_code = 'capone' and 
              start_idx is not null
        union
    select task_id, join_idx, doc_id, doc_url 
        from piir_eval.results_view
        where method_code = 'muckrock' and 
              start_idx is not null
)
select ru.task_id, ru.join_idx,
       case when co.entity_text is not null and
                 mu.entity_text is not null then 'Y' else 'N'
       end redact_agree,
       case when co.entity_code = mu.entity_code then 'Y' else 'N'
       end entity_agree,
       co.entity_code co_entity_code,
       mu.entity_code mu_entity_code, 
       co.entity_text co_entity_text,
       mu.entity_text mu_entity_text,
       co.start_idx   co_start_idx,
       mu.start_idx   mu_start_idx,
       co.end_idx     co_end_idx,
       mu.end_idx     mu_end_idx, 
       co.start_time co_run, mu.start_time mu_run,
       ru.doc_id, ru.doc_url  
    from ru left join piir_eval.results_view co
                on (ru.task_id = co.task_id and 
                    ru.join_idx = co.join_idx and 
                    co.method_code = 'capone')
            left join piir_eval.results_view mu
                on (ru.task_id = mu.task_id and 
                    ru.join_idx = mu.join_idx and 
                    mu.method_code = 'muckrock')
    order by ru.task_id, ru.join_idx;