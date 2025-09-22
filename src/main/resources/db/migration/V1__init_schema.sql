-- ================================
-- Flyway Init Script - Profitly DB
-- ================================

-- Enums
CREATE TYPE user_role AS ENUM ('OWNER', 'ACCOUNTANT');
CREATE TYPE invoice_status AS ENUM ('DRAFT', 'SENT', 'PAID', 'OVERDUE');
CREATE TYPE payment_method AS ENUM ('CASH', 'BANK', 'UPI');

-- Trigger function for last_updated
CREATE OR REPLACE FUNCTION set_last_updated()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_updated = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- USERS
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- BUSINESS
CREATE TABLE business (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    address TEXT,
    gstin VARCHAR(50),
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    timezone VARCHAR(50) NOT NULL DEFAULT 'Asia/Kolkata',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- CUSTOMER
CREATE TABLE customer (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    mobile VARCHAR(20),
    email VARCHAR(150),
    billing_address TEXT,
    gstin VARCHAR(50),
    opening_balance NUMERIC(15,2) DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- PRODUCT
CREATE TABLE product (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    sku VARCHAR(100) UNIQUE,
    unit VARCHAR(50),
    unit_price NUMERIC(15,2) NOT NULL,
    tax_rate_percent NUMERIC(5,2) DEFAULT 0,
    stock_qty NUMERIC(15,2) DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- INVOICE
CREATE TABLE invoice (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    date_issued DATE NOT NULL,
    due_date DATE,
    status invoice_status NOT NULL,
    total_amount NUMERIC(15,2) NOT NULL,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    discount_amount NUMERIC(15,2) DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- INVOICE ITEM
CREATE TABLE invoice_item (
    id BIGSERIAL PRIMARY KEY,
    invoice_id BIGINT NOT NULL REFERENCES invoice(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES product(id),
    description TEXT,
    qty NUMERIC(15,2) NOT NULL,
    unit_price NUMERIC(15,2) NOT NULL,
    tax_rate NUMERIC(5,2) DEFAULT 0,
    line_total NUMERIC(15,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- EXPENSE
CREATE TABLE expense (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    category VARCHAR(100) NOT NULL,
    vendor VARCHAR(150),
    date DATE NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- PAYMENT
CREATE TABLE payment (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    method payment_method NOT NULL,
    reference VARCHAR(100),
    invoice_id BIGINT REFERENCES invoice(id) ON DELETE SET NULL,
    expense_id BIGINT REFERENCES expense(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_payment_target CHECK (
        (invoice_id IS NOT NULL AND expense_id IS NULL)
        OR (invoice_id IS NULL AND expense_id IS NOT NULL)
    )
);

-- JOURNAL ENTRY
CREATE TABLE journal_entry (
    id BIGSERIAL PRIMARY KEY,
    business_id BIGINT NOT NULL REFERENCES business(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    description TEXT,
    debit_account VARCHAR(100) NOT NULL,
    credit_account VARCHAR(100) NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    reference_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Attach last_updated triggers
CREATE TRIGGER trg_users_last_updated BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_business_last_updated BEFORE UPDATE ON business FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_customer_last_updated BEFORE UPDATE ON customer FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_product_last_updated BEFORE UPDATE ON product FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_invoice_last_updated BEFORE UPDATE ON invoice FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_invoice_item_last_updated BEFORE UPDATE ON invoice_item FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_expense_last_updated BEFORE UPDATE ON expense FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_payment_last_updated BEFORE UPDATE ON payment FOR EACH ROW EXECUTE FUNCTION set_last_updated();
CREATE TRIGGER trg_journal_entry_last_updated BEFORE UPDATE ON journal_entry FOR EACH ROW EXECUTE FUNCTION set_last_updated();
