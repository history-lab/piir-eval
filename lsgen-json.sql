-- "data": {"url": "s3://history-lab-labeled-data/pii-cfpf-redaction/source/1977STATE161504.txt"}
select jsonb_pretty(jsonb_agg(jsonb_build_object(
      'id', t.task_id, 
      'data', jsonb_build_object(
            'ref_id', t.doc_id,
            'url', 'https://history-lab-labeled-data.s3.amazonaws.com/pii-dcml-redaction/source/' || 
                    t.doc_id || '.txt'),
      'predictions', jsonb_build_array(jsonb_build_object(
            'model_version', 'models/combindednlp',
            'result', (
                  select coalesce(jsonb_agg(jsonb_build_object(
                  'from_name', 'label',
                  'to_name', 'text',
                  'type', 'labels',
                  'value', jsonb_build_object(
                        'start', r.start_idx,
                        'end', r.end_idx,
                        'text', r.entity_text,
                        'labels', json_build_array(r.entity_code)))),
                  jsonb_build_array()) 
                  from piir_eval.tool_detected_pii r 
                  where r.task_id = t.task_id))))))
from piir_eval.tasks t 
      join piir_eval.ls_dcml_data d on (t.task_id = d.task_id)
      join piir_eval.ls_dcml_annotation_assignments s on (s.data_id = d.data_id)
      join piir_eval.ls_dcml_annotators a on (s.annotator_id =  a.annotator_id)
where a.name = :'st';