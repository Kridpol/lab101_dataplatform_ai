CREATE SCHEMA shop;
SET search_path TO shop;

CREATE TABLE customers (
    customer_id  SERIAL PRIMARY KEY,
    name         TEXT      NOT NULL,
    email        TEXT      NOT NULL UNIQUE,
    country      CHAR(2)   NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    name         TEXT          NOT NULL,
    category     TEXT          NOT NULL,
    price        NUMERIC(10,2) NOT NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP     NOT NULL DEFAULT now()
);

-- One product per order, to keep the model simple. created_at is the order time.
CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INT           NOT NULL REFERENCES customers (customer_id),
    product_id   INT           NOT NULL REFERENCES products (product_id),
    quantity     INT           NOT NULL,
    amount       NUMERIC(10,2) NOT NULL,
    status       TEXT          NOT NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP     NOT NULL DEFAULT now()
);

-- Refresh updated_at on every UPDATE, as the application would.
-- Without it, incremental sync would not notice changed rows.
CREATE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER products_updated_at  BEFORE UPDATE ON products  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER orders_updated_at    BEFORE UPDATE ON orders    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
