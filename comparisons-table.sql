drop table if exists piir_eval.comparisons;
create table piir_eval.comparisons (
    task_id          integer,
    start_idx        integer,
    tool             text,
    redaction_result text,
    entity_result    text,
    gt_entity_code   text,
    t_entity_code    text,
    gt_entity_text   text,
    t_entity_text    text,
    gt_start_idx     integer,
    t_start_idx      integer,
    gt_end_idx       integer,
    t_end_idx        integer,
    gt_creator       text,
    gt_completed     timestamp with time zone,
    gt_id            integer,
    label_studio_id  integer,
    doc_id           text,
    doc_url          text,
    primary key (task_id, start_idx)
);
insert into piir_eval.comparisons (task_id, start_idx, 
   gt_entity_code, gt_entity_text, gt_start_idx, gt_end_idx, gt_creator,
   gt_completed, label_studio_id, gt_id, doc_id, doc_url) 
select task_id, start_idx, 
   entity_code, entity_text, start_idx, end_idx, creator,
   completed, label_studio_id, ground_truth_id, doc_id, doc_url
from piir_eval.ground_truth_view tv
where completed = (select max(completed)
                        from piir_eval.ground_truth x
                        where x.start_idx = tv.start_idx and
                              x.end_idx = tv.end_idx);

update piir_eval.comparisons c
   set (tool, t_entity_code, t_entity_text, t_start_idx, t_end_idx) =
       (select tool, entity_code, entity_text, start_idx, end_idx
           from piir_eval.tool_detected_pii t
           where t.task_id = c.task_id and
                 abs(t.start_idx - c.start_idx) <= 1);

insert into comparisons(task_id, start_idx, tool, 
    t_entity_code, t_entity_text, t_start_idx, t_end_idx, 
    doc_id, doc_url)
select task_id, start_idx, tool, entity_code, entity_text, 
       start_idx, end_idx, doc_id, doc_url
    from piir_eval.tool_detected_pii t
    where not exists (select 1
                        from piir_eval.comparisons c
                        where c.task_id = t.task_id and 
                              c.t_start_idx = t.start_idx) and
          exists (select 1
                    from piir_eval.comparisons c 
                    where c.task_id = t.task_id) and 
          end_idx = (select max(end_idx)
                        from piir_eval.tool_detected_pii d
                        where d.task_id = t.task_id    and 
                              d.start_idx = t.start_idx);