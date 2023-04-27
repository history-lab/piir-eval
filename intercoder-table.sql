drop table if exists piir_eval.intercoder;
create table piir_eval.intercoder (
    task_id              integer,
    start_idx            integer,
    jules_start_idx      integer,
    jules_end_idx        integer,
    jules_entity_code    text,
    jules_entity_text    text,
    jules_completed      timestamp with time zone,
    jules_id             integer,
    isobel_start_idx     integer,
    isobel_end_idx       integer,
    isobel_entity_code   text,
    isobel_entity_text   text,
    isobel_completed     timestamp with time zone,
    isobel_id            integer,
    natalie_start_idx    integer,
    natalie_end_idx      integer,
    natalie_entity_code  text,
    natalie_entity_text  text,
    natalie_completed    timestamp with time zone,
    natalie_id           integer,
    doc_id               text,
    doc_url              text,
    primary key (task_id, start_idx)
);
insert into piir_eval.intercoder (task_id, start_idx,
    jules_start_idx, jules_end_idx, jules_entity_code, jules_entity_text, 
    jules_completed, jules_id, doc_id, doc_url) 
select task_id, start_idx,
    start_idx, end_idx, entity_code, entity_text, 
    completed, ground_truth_id,doc_id, doc_url
from piir_eval.jules_ground_truth j
where completed = (select max(completed)
                            from piir_eval.jules_ground_truth mj
                            where mj.task_id = j.task_id and
                                  mj.start_idx = j.start_idx and
                                  mj.end_idx = j.end_idx);

update piir_eval.intercoder i
   set (jules_start_idx, jules_end_idx, jules_entity_code, jules_entity_text, 
    jules_completed, jules_id),
   
   
   (tool, t_entity_code, t_entity_text, t_start_idx, t_end_idx) =
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

update comparisons
    set redaction_result = case when gt_start_idx is not null and 
                                      t_start_idx is not null then 'TP'
                                when gt_start_idx is null and
                                      t_start_idx is not null then 'FP'
                                when gt_start_idx is not null and
                                      t_start_idx is null     then 'FN'
                           end,
        entity_result = case when gt_entity_code = t_entity_code 
                                                              then 'TP'
                             when gt_entity_code != t_entity_code or
                                  gt_entity_code is null      then 'FP'                                  
                             when gt_entity_code is not null and 
                                  t_entity_code  is null      then 'FN'  
                        end;

\copy (select * from comparisons order by doc_id, start_idx) to 'comparisons.csv' csv header

\i scores-table.sql
\i scores-calc.sql
\copy (select * from scores order by score_id) to 'scores.csv' csv header