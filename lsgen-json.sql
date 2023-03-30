select jsonb_agg(
        jsonb_build_object('id', t.task_id,  
                           'data', jsonb_build_object('ref_id', t.doc_id,
                                                      'text', t.body),
                           'predictions', json_build_object('model_version', 'models/combindednlp',
                                                            'results', (select jsonb_agg(
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
   where r.task_id = t.task_id and r.method_code = 'muckrock'
))
                          )
                )
    from piir_eval.tasks t
    where exists (select 1 
                    from piir_eval.results_view 
                    where task_id = t.task_id and
                          start_idx is not null)
    group by t.task_id
    order by t.task_id
    limit 3;
    