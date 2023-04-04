drop view if exists piir_eval.tool_detected_pii;
create view piir_eval.tool_detected_pii as
select task_id, doc_id, doc_url, join_idx start_idx,
       coalesce(mu_end_idx, co_end_idx) end_idx,
       coalesce(mu_entity_code, co_entity_code) entity_code,
       coalesce(mu_entity_text, co_entity_text) entity_text,
       case when mu_entity_code is null then 'co'
            when co_entity_code is null then 'mu'
            else 'both'
       end tool 
    from piir_eval.tool_comparisons;