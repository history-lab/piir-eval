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

--
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
   set (isobel_start_idx, isobel_end_idx, isobel_entity_code, isobel_entity_text, 
        isobel_completed, isobel_id)=
       (select start_idx, end_idx, entity_code, entity_text, 
               completed, ground_truth_id
            from piir_eval.isobel_ground_truth gt
            where i.task_id = gt.task_id and
                  abs(i.start_idx - gt.start_idx) <= 1 and
                  gt.completed = (select max(completed)
                                    from piir_eval.isobel_ground_truth mgt
                                    where mgt.task_id = gt.task_id and
                                          mgt.start_idx = gt.start_idx and
                                          mgt.end_idx = gt.end_idx))
 ;

insert into piir_eval.intercoder (task_id, start_idx,
    isobel_start_idx, isobel_end_idx, isobel_entity_code, isobel_entity_text, 
    isobel_completed, isobel_id, doc_id, doc_url) 
select task_id, start_idx,
    start_idx, end_idx, entity_code, entity_text, 
    completed, ground_truth_id,doc_id, doc_url
from piir_eval.isobel_ground_truth gt
where gt.completed = (select max(completed)
                            from piir_eval.isobel_ground_truth mgt
                            where gt.task_id = mgt.task_id and
                                  gt.start_idx = mgt.start_idx and
                                  gt.end_idx = mgt.end_idx) and
      not exists (select 1 from piir_eval.intercoder i
                     where i.task_id = gt.task_id and
                           i.start_idx = gt.start_idx);


update piir_eval.intercoder i
   set (natalie_start_idx, natalie_end_idx, natalie_entity_code, natalie_entity_text, 
        natalie_completed, natalie_id)=
       (select start_idx, end_idx, entity_code, entity_text, 
               completed, ground_truth_id
            from piir_eval.natalie_ground_truth gt
            where i.task_id = gt.task_id and
                  abs(i.start_idx - gt.start_idx) <= 1 and
                  gt.completed = (select max(completed)
                                    from piir_eval.natalie_ground_truth mgt
                                    where mgt.task_id = gt.task_id and
                                          mgt.start_idx = gt.start_idx and
                                          mgt.end_idx = gt.end_idx))
 ;

insert into piir_eval.intercoder (task_id, start_idx,
    natalie_start_idx, natalie_end_idx, natalie_entity_code, natalie_entity_text, 
    natalie_completed, natalie_id, doc_id, doc_url) 
select task_id, start_idx,
    start_idx, end_idx, entity_code, entity_text, 
    completed, ground_truth_id,doc_id, doc_url
from piir_eval.natalie_ground_truth gt
where gt.completed = (select max(completed)
                            from piir_eval.natalie_ground_truth mgt
                            where gt.task_id = mgt.task_id and
                                  gt.start_idx = mgt.start_idx and
                                  gt.end_idx = mgt.end_idx) and
      not exists (select 1 from piir_eval.intercoder i
                     where i.task_id = gt.task_id and
                           i.start_idx = gt.start_idx);

\copy (select * from intercoder order by task_id) to 'intercoder.csv' csv header