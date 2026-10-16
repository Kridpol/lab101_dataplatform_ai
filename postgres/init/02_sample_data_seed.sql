-- Loads /seed/{customers,products,orders}.csv when present; a missing file is skipped (tables stay empty).
-- To use your own data, drop CSVs with the same header into postgres/seed/ before the first start.
DO $$
DECLARE
    t text;
    cols text;
BEGIN
    -- Parents first: orders references customers and products.
    FOR t, cols IN VALUES
        ('customers', 'customer_id, name, email, country, created_at, updated_at'),
        ('products',  'product_id, name, category, price, created_at, updated_at'),
        ('orders',    'order_id, customer_id, product_id, quantity, amount, status, created_at, updated_at')
    LOOP
        IF (pg_stat_file('/seed/' || t || '.csv', true)).size IS NOT NULL THEN
            EXECUTE format('COPY shop.%I (%s) FROM %L WITH (FORMAT csv, HEADER true)', t, cols, '/seed/' || t || '.csv');
        END IF;
    END LOOP;
END $$;

-- Explicit ids bypass the sequences: move them past the loaded rows.
SELECT setval(pg_get_serial_sequence('shop.customers', 'customer_id'), coalesce(max(customer_id), 1), max(customer_id) IS NOT NULL) FROM shop.customers;
SELECT setval(pg_get_serial_sequence('shop.products',  'product_id'),  coalesce(max(product_id), 1),  max(product_id)  IS NOT NULL) FROM shop.products;
SELECT setval(pg_get_serial_sequence('shop.orders',    'order_id'),    coalesce(max(order_id), 1),    max(order_id)    IS NOT NULL) FROM shop.orders;
