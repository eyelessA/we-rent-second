DROP TABLE IF EXISTS categories, products, statistics, orders;

CREATE TABLE categories
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255)   NOT NULL,
    description TEXT,
    price       NUMERIC(10, 2) NOT NULL,
    quantity    INTEGER        NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories (id),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE statistics
(
    id          SERIAL PRIMARY KEY,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories (id),
    count       INT,
    created_at  TIMESTAMP DEFAULT CURRENT_DATE,
    updated_at  TIMESTAMP DEFAULT CURRENT_DATE,
    CONSTRAINT unique_category_date UNIQUE (category_id, created_at)
);

CREATE TABLE orders
(
    id         SERIAL PRIMARY KEY,
    product_id INT,
    FOREIGN KEY (product_id) REFERENCES products (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION add_statistic_row()
    RETURNS trigger AS
$$
DECLARE
    product_category_id INT;
BEGIN
    SELECT category_id
    INTO product_category_id
    FROM products
    WHERE id = NEW.product_id;

    INSERT INTO statistics (category_id, count, created_at)
    VALUES (product_category_id, 1, CURRENT_DATE)
    ON CONFLICT (category_id, created_at)
        DO UPDATE SET count = statistics.count + 1;
    RETURN NEW;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER order_insert_trigger
    AFTER INSERT
    ON orders
    FOR EACH ROW
EXECUTE PROCEDURE add_statistic_row();


INSERT INTO categories (name)
VALUES ('Овощи'),
       ('Фрукты');

INSERT INTO products (name, description, price, quantity, category_id)
VALUES ('Картошка', 'Молодая', 100, 100, 1),
       ('Банан', 'Желтый', 50, 30, 2);