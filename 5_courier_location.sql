------------ Courier location
CREATE TABLE distance_to_restaurant AS
SELECT order_id
    ,  vehicle_type
    ,  order_stage
    ,  CASE WHEN order_stage = 'order_proposed_to_courier' THEN distance_courier_to_restaurant_address END AS distance_from_restaurant
 FROM order_stages os
WHERE order_stage IN ('order_proposed_to_courier');


CREATE TABLE distance_to_customer AS
SELECT order_id
    ,  vehicle_type
    ,  order_stage
    ,  CASE WHEN order_stage = 'courier_picked_up_order' THEN distance_courier_to_customer_address END AS distance_from_customer
 FROM order_stages os
WHERE order_stage IN ('courier_picked_up_order');

SELECT r.vehicle_type
     , ROUND(AVG(distance_from_restaurant), 2) AS avg_distance_to_restaurant
     , ROUND(AVG(distance_from_customer), 2)   AS avg_distance_to_customer
  FROM distance_to_restaurant AS r
INNER JOIN distance_to_customer AS c 
       ON r.order_id = c.order_id
--WHERE order_id IN (SELECT order_id FROM distance_to_customer)
GROUP BY 1;
-- AVG distances from restaurant/customer per vehicle type
-- Car is being sent furthest to the restaurant, spending the longest between pickup/arrival to customer with the furthest distance