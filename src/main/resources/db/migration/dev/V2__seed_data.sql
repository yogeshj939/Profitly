-- ================================
-- Flyway Seed Data - Dev Purposes
-- ================================

-- Insert test User
INSERT INTO users (name, email, password_hash, role)
VALUES (
  'Dev Owner',
  'owner@profitly.dev',
  -- bcrypt hash for password "admin123"
  '$2a$10$7QeojkX1hC6ax6t82ViTeeZjFNT0H2gCeUDBXzDN2t7x6/xXcKc0u',
  'OWNER'
)
ON CONFLICT (email) DO NOTHING;

-- Insert Business for the user
INSERT INTO business (user_id, name, address, gstin, currency, timezone)
SELECT id, 'Dev Business', '123 Dev Street, Test City', '22AAAAA0000A1Z5', 'INR', 'Asia/Kolkata'
FROM users WHERE email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;

-- Insert a Customer
INSERT INTO customer (business_id, name, mobile, email, billing_address, gstin, opening_balance)
SELECT b.id, 'Acme Corp', '9999999999', 'acme@example.com',
       '42 Market Street, Metropolis', '29BBBBB1111B2Z6', 5000
FROM business b
JOIN users u ON b.user_id = u.id
WHERE u.email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;

-- Insert a Product
INSERT INTO product (business_id, name, sku, unit, unit_price, tax_rate_percent, stock_qty)
SELECT b.id, 'Dev Product', 'SKU-001', 'pcs', 100.00, 18.0, 50
FROM business b
JOIN users u ON b.user_id = u.id
WHERE u.email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;

-- Insert an Invoice
INSERT INTO invoice (business_id, invoice_number, customer_id, date_issued, due_date, status, total_amount, tax_amount, discount_amount)
SELECT b.id, 'INV-1001', c.id, CURRENT_DATE, CURRENT_DATE + INTERVAL '15 days', 'DRAFT', 1180.00, 180.00, 0.00
FROM business b
JOIN users u ON b.user_id = u.id
JOIN customer c ON c.business_id = b.id
WHERE u.email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;

-- Insert an Invoice Item
INSERT INTO invoice_item (invoice_id, product_id, description, qty, unit_price, tax_rate, line_total)
SELECT i.id, p.id, 'Sample product line item', 10, 100.00, 18.0, 1180.00
FROM invoice i
JOIN business b ON i.business_id = b.id
JOIN users u ON b.user_id = u.id
JOIN product p ON p.business_id = b.id
WHERE u.email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;

-- Insert an Expense
INSERT INTO expense (business_id, category, vendor, date, amount, tax_amount, payment_method, notes)
SELECT b.id, 'Office Supplies', 'Stationery Vendor', CURRENT_DATE, 500.00, 50.00, 'CASH', 'Printer paper and pens'
FROM business b
JOIN users u ON b.user_id = u.id
WHERE u.email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;

-- Insert a Payment (linked to invoice)
INSERT INTO payment (business_id, payment_date, amount, method, reference, invoice_id)
SELECT b.id, CURRENT_DATE, 500.00, 'BANK', 'NEFT12345', i.id
FROM business b
JOIN users u ON b.user_id = u.id
JOIN invoice i ON i.business_id = b.id
WHERE u.email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;

-- Insert a Journal Entry
INSERT INTO journal_entry (business_id, entry_date, description, debit_account, credit_account, amount, reference_id)
SELECT b.id, CURRENT_DATE, 'Invoice Payment - INV-1001', 'Cash', 'Accounts Receivable', 500.00, i.id
FROM business b
JOIN users u ON b.user_id = u.id
JOIN invoice i ON i.business_id = b.id
WHERE u.email = 'owner@profitly.dev'
ON CONFLICT DO NOTHING;
