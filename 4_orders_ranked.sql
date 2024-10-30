CREATE TABLE emily.public.stages_ranked AS 
SELECT ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_stage_start DESC) AS order_state_ranked
    ,  *
FROM order_stages os;
-- Rank stages of the order process, last stage is 6
-- Not all orders will have all 6 stages, we can quickly check how many have <6 below


WITH ranked_stages AS (
SELECT ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_stage_start DESC) AS order_state_ranked
    ,  *
FROM order_stages os
)
, count_check AS (
SELECT COUNT(order_state_ranked) AS no_stages
    ,  order_id
  FROM ranked_stages 
  GROUP BY order_id
  ORDER BY no_stages ASC
 )
SELECT COUNT(order_id)
FROM count_check
WHERE no_stages <6
;
-- Only 81 orders have less than 6 stages, so we can exclude this from workaround logic

CREATE TABLE emily.public.stage_dates AS
WITH stages AS (
SELECT *   
    ,  CASE WHEN order_stage = 'order_proposed_to_courier'     THEN order_stage_start END AS proposed_to_courier_at
    ,  CASE WHEN order_stage = 'courier_accepts_order'         THEN order_stage_start END AS courier_accepts_at
    ,  CASE WHEN order_stage = 'courier_arrived_at_restaurant' THEN order_stage_start END AS restaurant_arrival_at
    ,  CASE WHEN order_stage = 'courier_picked_up_order'       THEN order_stage_start END AS courier_picks_up_at
    ,  CASE WHEN order_stage = 'courier_arrived_at_customer'   THEN order_stage_start END AS customer_arrival_at
    ,  CASE WHEN order_stage = 'courier_delivered_order'       THEN order_stage_start END AS delivered_at
FROM stages_ranked 
)

SELECT order_id
    ,  vehicle_type
    ,  MAX(proposed_to_courier_at) AS proposed_to_courier_at
    ,  MAX(courier_accepts_at)     AS courier_accepts_at
    ,  MAX(restaurant_arrival_at)  AS restaurant_arrival_at
    ,  MAX(courier_picks_up_at)    AS courier_picks_up_at
    ,  MAX(customer_arrival_at)    AS customer_arrival_at
    ,  MAX(delivered_at)           AS delivered_at
FROM stages
GROUP BY order_id, vehicle_type
;
-- Final times for each stage using MAX


WITH stage_times AS (
SELECT order_id
    ,  vehicle_type
    ,  EXTRACT(EPOCH FROM (proposed_to_courier_at - courier_accepts_at)) AS stage_1_time
    ,  EXTRACT(EPOCH FROM (courier_accepts_at - restaurant_arrival_at))  AS stage_2_time
    ,  EXTRACT(EPOCH FROM (restaurant_arrival_at - courier_picks_up_at)) AS stage_3_time
    ,  EXTRACT(EPOCH FROM (courier_picks_up_at - customer_arrival_at))   AS stage_4_time
    ,  EXTRACT(EPOCH FROM (customer_arrival_at - delivered_at))          AS stage_5_time
FROM stage_dates
-- Shows how much time we're LOSING at each stage
)
SELECT vehicle_type
    ,  ROUND(AVG(stage_1_time / 60), 2) AS minutes_stage_1
    ,  ROUND(AVG(stage_2_time / 60), 2) AS minutes_stage_2
    ,  ROUND(AVG(stage_3_time / 60), 2) AS minutes_stage_3
    ,  ROUND(AVG(stage_4_time / 60), 2) AS minutes_stage_4
    ,  ROUND(AVG(stage_5_time / 60), 2) AS minutes_stage_5
FROM stage_times
GROUP BY vehicle_type
;
-- Avg. number of minutes spent at each stage of the order process 
-- Fig. 1.2
-- Query is a little bulky, could use LAG() function instead of MAX/CASE if more time was available 
-- Idea: group multiple orders together for cars (similar residential areas) due to the avg. order process time being longer

