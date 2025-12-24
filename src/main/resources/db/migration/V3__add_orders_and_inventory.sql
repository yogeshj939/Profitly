-- ================================
-- V3: Orders & Inventory refactor
-- ================================

CREATE TYPE inventory_movement_type AS ENUM ('SALE', 'RETURN', 'ADJUSTMENT');

CREATE TYPE order_status AS ENUM ('DRAFT', 'CONFIRMED', 'CANCELLED', 'COMPLETED');

-- Orders table
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    customer_id BIGINT NOT NULL REFERENCES customer(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_date DATE NOT NULL,
    status order_status NOT NULL,
    subtotal_amount NUMERIC(15,2) NOT NULL,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    discount_amount NUMERIC(15,2) DEFAULT 0,
    total_amount NUMERIC(15,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Modify invoice to reference order
ALTER TABLE invoice
ADD COLUMN order_id BIGINT REFERENCES orders(id) ON DELETE SET NULL;

-- Remove monetary fields from invoice
ALTER TABLE invoice
DROP COLUMN total_amount,
DROP COLUMN tax_amount,
DROP COLUMN discount_amount;

-- Inventory table
CREATE TABLE inventory (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES product(id),
    order_id BIGINT REFERENCES orders(id),
    quantity_change NUMERIC(15,2) NOT NULL,
    movement_type inventory_movement_type NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Triggers
CREATE TRIGGER trg_orders_last_updated BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_inventory_last_updated BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION set_last_updated();