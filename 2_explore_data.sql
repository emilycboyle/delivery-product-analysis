------------- Basic queries for looking into the data

SELECT * FROM orders 
WHERE order_state  = 'delivered'
LIMIT 10;
-- Examining the data for delivered orders, <1% are failed, so we can discount them



SELECT COUNT(DISTINCT order_id)  
     , vehicle_type 
FROM order_stages o 
GROUP BY 2
ORDER BY 1 DESC;
-- Split of orders per vehicle - checking how even the sample is 


SELECT COUNT(DISTINCT order_id) AS orders 
    ,  order_state
FROM orders
GROUP BY 2;


SELECT ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_stage_start DESC) AS order_state_ranked
    ,  *
FROM order_stages os 
LIMIT 100;
-- Rank stages of the order process
-- Use this to work out the MIN, MAX, AVG time spent at each stage - identify inefficiencies 



SELECT COUNT(*) AS orders
      ,  CASE WHEN delivered_at < promised_delivery THEN 'delivered_on_time'
            WHEN delivered_at >  promised_delivery  THEN 'delivered_late' END AS delivery_status
   FROM delivery_differences 
   GROUP BY delivery_status;
-- High level lookup of % delivered on time or late 


SELECT vehicle_type
    ,  order_stage
    ,  CASE WHEN order_stage = 'order_proposed_to_courier' THEN AVG(distance_courier_to_restaurant_address) END AS distance_from_restaurant
 FROM order_stages os
WHERE order_stage IN ('order_proposed_to_courier', 'courier_accepts_order')
    -- Similar distance, just use one 
GROUP BY 1, 2
LIMIT 200;
-- Distance to customer NULL until order_stage = 'courier_arrived_at_customer', 'courier_delivered_order', 'courier_picked_up_order'
-- Unable to compare starting distances 


----- Rate of successful deliveries, not used 
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
    ,  ROUND(CAST(delivered_orders AS FLOAT)/CAST(orders AS FLOAT), 2) AS delivery_success
 FROM frequency 
 GROUP BY 1, 2
  ;
-- Rate of successful deliveries 