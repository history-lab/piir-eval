-- select r.result_id, r.entity_code, r.entity_text, r.start_idx, r.end_idx
--    from piir_eval.results_view r
--    where r.task_id = 1 and r.method_code = 'muckrock';
-- with result(json_fragment) as (
select jsonb_agg(
        jsonb_build_object('from_name', 'label',
                           'to_name', 'text',
                           'type', 'labels',
                           'value', json_build_object('start', r.start_idx,
                                                      'end', r.end_idx,
                                                      'text', r.entity_text,
                                                      'labels', json_build_array(r.entity_code)
                                                     )
                          )
                ) 
   from piir_eval.results_view r
   where r.task_id = 1 and r.method_code = 'muckrock';
