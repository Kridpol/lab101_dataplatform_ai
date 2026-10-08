-- Sample data generated inside Postgres (random, so each fresh volume differs).
-- Remove this file to start with empty tables.
SET search_path TO shop;

INSERT INTO customers (name, email, country, created_at, updated_at)
SELECT 'Customer ' || g, 'customer' || g || '@example.com',
       (ARRAY['TH', 'SG', 'MY', 'VN'])[1 + floor(random() * 4)::int],
       ts, ts
FROM (
    SELECT g, now() - make_interval(days => floor(random() * 180)::int) AS ts
    FROM generate_series(1, 100) AS g
) AS s;

INSERT INTO products (name, category, price)
SELECT 'Product ' || g,
       (ARRAY['Electronics', 'Home', 'Books', 'Sports'])[1 + g % 4],
       round((5 + random() * 195)::numeric, 2)
FROM generate_series(1, 20) AS g;

INSERT INTO orders (customer_id, product_id, quantity, amount, status, created_at, updated_at)
SELECT 1 + floor(random() * 100)::int,
       p.product_id,
       q.quantity,
       p.price * q.quantity,
       (ARRAY['pending', 'paid', 'shipped', 'delivered', 'cancelled'])[1 + floor(random() * 5)::int],
       q.ts, q.ts
FROM (
    SELECT g,
           1 + floor(random() * 20)::int AS product_id,
           1 + floor(random() * 3)::int  AS quantity,
           now() - make_interval(days => floor(random() * 90)::int,
                                 hours => floor(random() * 24)::int) AS ts
    FROM generate_series(1, 500) AS g
) AS q
JOIN products AS p ON p.product_id = q.product_id;
