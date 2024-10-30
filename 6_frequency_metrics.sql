---- Delivery frequency 
WITH frequency AS (
SELECT vehicle_type
    ,  DATE_PART('HOUR', order_stage_start)                                       AS delivery_hour
    ,  COUNT(CASE WHEN order_stage = 'courier_delivered_order' THEN order_id END) AS delivered_orders
    ,  COUNT(DISTINCT order_id) AS orders
  FROM order_stages os 
  GROUP BY 1, 2
  ORDER BY 1 ASC, 2)
  
SELECT vehicle_type
    ,  delivery_hour
    ,  AVG(delivered_orders)/60 AS avg_deliveries
 FROM frequency 
 GROUP BY 1, 2
  ;
-- Avg. number of deliveries made per hour / 60 gives us the avg. number of deliveries per minute
-- Delta between start time and end time, get the avg. of that delta, group by delivery hour and vehicle type 


CREATE TABLE courier_times AS 
WITH courier_accepts AS (
SELECT order_id
    ,  vehicle_type
    ,  order_stage
    ,  CASE WHEN order_stage = 'courier_accepts_order' THEN order_stage_start END AS courier_accepts_at
 FROM order_stages os
WHERE order_stage IN ('courier_accepts_order'))

, courier_delivers AS (
SELECT order_id
    ,  vehicle_type
    ,  order_stage
    ,  CASE WHEN order_stage = 'courier_delivered_order' THEN order_stage_start END AS courier_delivers_at
 FROM order_stages os
WHERE order_stage IN ('courier_delivered_order'))

SELECT a.order_id
    ,  a.vehicle_type
    ,  a.courier_accepts_at
    ,  d.courier_delivers_at
  FROM courier_accepts AS a
INNER JOIN courier_delivers AS d 
       ON a.order_id = d.order_id
GROUP BY 1, 2, 3, 4;


WITH order_delta AS (
SELECT order_id
    ,  vehicle_type
    ,  DATE_PART('hour', courier_accepts_at) AS acceptance_hour
    ,  ROUND(EXTRACT(EPOCH FROM (courier_delivers_at - courier_accepts_at))/60, 2) AS time_between_acceptance_delivery
FROM courier_times)

SELECT acceptance_hour
    ,  vehicle_type
    ,  AVG(time_between_acceptance_delivery) AS avg_time_per_order
FROM order_delta
GROUP BY 1, 2
ORDER BY 1 ASC, 2
;
-- Fig. 1.3



-------- Alternate query
CREATE TEMP TABLE stages AS
WITH ranked_stages AS (
SELECT ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_stage_start DESC) AS order_state_ranked
    ,  *
FROM order_stages os
)

SELECT CASE WHEN order_state_ranked = 6 THEN order_stage_start END AS start_time
    ,  CASE WHEN order_state_ranked = 1 THEN order_stage_start END AS end_time
    ,  *
  FROM ranked_stages
  ORDER BY order_id;
 
 SELECT COALESCE(start_time, end_time) AS stage_time 
     ,  order_id
     ,  order_stage 
 FROM stages 
 WHERE start_time IS NOT NULL
    OR end_time IS NOT NULL;
-- Not used in final analysis