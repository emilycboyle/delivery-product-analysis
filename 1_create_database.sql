-- ORDERS TABLE
-- Table: public.orders

-- DROP TABLE IF EXISTS public.orders;

CREATE TABLE IF NOT EXISTS public.orders
(
    task_id integer,
    order_id integer NOT NULL,
    customer_id integer,
    restaurant_id integer,
    city character varying(255) COLLATE pg_catalog."default",
    restaurant_address_lng numeric,
    restaurant_address_lat numeric,
    delivery_address_lng numeric,
    delivery_address_lat numeric,
    order_state character varying(255) COLLATE pg_catalog."default",
    order_promised_delivery timestamp without time zone,
    restaurant_finished_preparation timestamp without time zone,
    CONSTRAINT orders_pkey PRIMARY KEY (order_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.orders
    OWNER to emily;
    
 
-------- ORDER_STAGES TABLE
-- Table: public.order_stages

-- DROP TABLE IF EXISTS public.order_stages;

CREATE TABLE IF NOT EXISTS public.order_stages
(
    log_id integer NOT NULL,
    city character varying(255) COLLATE pg_catalog."default",
    order_id integer,
    courier_id integer,
    vehicle_type character varying(255) COLLATE pg_catalog."default",
    order_stage character varying(255) COLLATE pg_catalog."default",
    order_stage_start timestamp without time zone,
    courier_location_lng_at_start numeric,
    courier_location_lat_at_start numeric,
    estimated_travel_seconds_to_restaurant numeric,
    estimated_travel_seconds_to_customer numeric,
    distance_courier_to_restaurant_address numeric,
    distance_courier_to_customer_address numeric,
    updated_expected_delivery_time timestamp without time zone,
    task_id integer,
    CONSTRAINT order_stages_pkey PRIMARY KEY (log_id),
    CONSTRAINT order_id FOREIGN KEY (order_id)
        REFERENCES public.orders (order_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.order_stages
    OWNER to emily;
    