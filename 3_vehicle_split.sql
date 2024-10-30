CREATE TABLE emily.public.delivery_differences AS 
WITH stages AS (
SELECT ord.order_id
    ,  vehicle_type
    ,  order_promised_delivery AS promised_delivery
    ,  CASE WHEN order_stage = 'courier_delivered_order' THEN order_stage_start END AS delivered_at
    ,  order_stage_start 
FROM orders AS ord 
INNER JOIN order_stages AS sta 
        ON ord.order_id = sta.order_id 
WHERE order_state  = 'delivered'
  AND order_stage = 'courier_delivered_order'
)
, deliveries AS (
SELECT order_id
    ,  vehicle_type
    ,  delivered_at
    ,  promised_delivery
    ,  EXTRACT(EPOCH FROM (delivered_at - promised_delivery)) AS seconds_diff
FROM stages 
)

SELECT *
    ,  ROUND(seconds_diff / 60, 2) AS minutes_diff
FROM deliveries
;
-- Time in seconds/minutes between promised delivery/actual delivery per vehicle 



SELECT ROUND(AVG(minutes_diff), 2) AS avg_minutes_between
    ,  vehicle_type
FROM delivery_differences 
GROUP BY 2;
-- Car is the most inefficient, motorbike is most efficient 
-- Fig. 1.1

-- Adding in review data would help us to know whether car orders remain warmer or if the time impacts the heat