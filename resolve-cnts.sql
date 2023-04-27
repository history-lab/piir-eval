-- 167 docs
select doc_id from jules_ground_truth
union                                                                                                                       select doc_id from isobel_ground_truth                                                                                      union                                                                                                     
select doc_id from natalie_ground_truth
union
select doc_id from isobel_ground_truth;

-- 167
select task_id from jules_ground_truth
union
select task_id from natalie_ground_truth
union
select task_id from isobel_ground_truth;

