-- where (gt_entity_code not in ('zipcode', 'social_media') or
--        gt_entity_code is null) and (tool='both' or tool is null))
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where (gt_entity_code is null or 
           gt_entity_code not in ('zipcode','social_media')) and
          (tool is null or tool in ('both'))  
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'excludes zipcode and social media, both tools',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe,0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne,0)::decimal, 4) recall_entity
    from cnts;
-- excludes at least one
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where (gt_entity_code is null or 
           gt_entity_code not in ('zipcode','social_media'))  
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'excludes zipcode and social media, at least one tool',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe,0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne,0)::decimal, 4) recall_entity
    from cnts;
-- excludes, capone
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where (gt_entity_code is null or 
           gt_entity_code not in ('zipcode','social_media')) and
          (tool is null or tool in ('both','co'))   
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'excludes zipcode and social media, capone',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe,0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne,0)::decimal, 4) recall_entity
    from cnts;
-- excludes, muckrock
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where (gt_entity_code is null or 
           gt_entity_code not in ('zipcode','social_media')) and
          (tool is null or tool in ('both','mu'))   
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'excludes zipcode and social media, muckrock',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe,0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne,0)::decimal, 4) recall_entity
    from cnts;
-- emails, both tools
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where coalesce(gt_entity_code, t_entity_code) = 'email_address' and
          coalesce(tool,'both') = 'both'   
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'email_addresses, both tools',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe,0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne,0)::decimal, 4) recall_entity
    from cnts;

-- phone numbers, both tools
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where coalesce(gt_entity_code, t_entity_code) = 'phone_number' and
          coalesce(tool,'both')  = 'both'   
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'phone numbers, both tools',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe,0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne,0)::decimal, 4) recall_entity
    from cnts;
-- bank account numbers, both tools
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where coalesce(gt_entity_code, t_entity_code) = 'ban' and
          coalesce(tool, 'both') = 'both'   
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'bank account numbers, both tools',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe,0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne,0)::decimal, 4) recall_entity
    from cnts;
-- credit card numbers, both tools
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where coalesce(gt_entity_code, t_entity_code) = 'credit_card' and
          coalesce(tool, 'both') = 'both'   
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'credit card numbers, both tools',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe, 0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne, 0)::decimal, 4) recall_entity
    from cnts;
-- drivers license, both tools
with cnts(tpr, fpr, fnr, tpe, fpe, fne) as (
select count(*) filter(where redaction_result = 'TP'),
       count(*) filter(where redaction_result = 'FP'),
       count(*) filter(where redaction_result = 'FN'),
       count(*) filter(where entity_result = 'TP'),
       count(*) filter(where entity_result = 'FP'),
       count(*) filter(where entity_result = 'FN'),
       count(*) total
    from comparisons
    where coalesce(gt_entity_code, t_entity_code) = 'drivers_license' and
          coalesce(tool, 'both') = 'both'   
)
insert into piir_eval.scores(description,
    tpr, fpr, fnr, precision_redact, recall_redact,
    tpe, fpe, fne, precision_entity, recall_entity)
select 'drivers license, both tools',
       tpr, fpr, fnr, 
       round(tpr::decimal/nullif(tpr+fpr,0)::decimal, 4) precision_redact, 
       round(tpr::decimal/nullif(tpr+fnr,0)::decimal, 4) recall_redact,
       tpe, fpe, fne, 
       round(tpe::decimal/nullif(tpe+fpe, 0)::decimal, 4) precision_entity, 
       round(tpe::decimal/nullif(tpe+fne, 0)::decimal, 4) recall_entity
    from cnts;