
-- Create users
CREATE TABLE users (
  user_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  phone_number VARCHAR(20),
  mail_id VARCHAR(150),
  billing_address TEXT
);

-- Create bookings
CREATE TABLE bookings (
  booking_id VARCHAR(50) PRIMARY KEY,
  booking_date DATETIME,
  room_no VARCHAR(50),
  user_id VARCHAR(50),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Create booking_commercials (line items / bills)
CREATE TABLE booking_commercials (
  id VARCHAR(50) PRIMARY KEY,
  booking_id VARCHAR(50),
  bill_id VARCHAR(50),
  bill_date DATETIME,
  item_id VARCHAR(50),
  item_quantity DECIMAL(10,2),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- Create items
CREATE TABLE items (
  item_id VARCHAR(50) PRIMARY KEY,
  item_name VARCHAR(150),
  item_rate DECIMAL(10,2)
);

-- Sample inserts (from your example rows)
INSERT INTO users VALUES ('21wrcxuy-67erfn','John Doe','97XXXXXXXX','john.doe@example.com','XX, Street Y, ABC City');

INSERT INTO bookings VALUES
('bk-09f3e-95hj','2021-09-23 07:36:48','rm-bhf9-aerjn','21wrcxuy-67erfn');

INSERT INTO items VALUES
('itm-a9e8-q8fu','Tawa Paratha',18.00),
('itm-a07vh-aer8','Mix Veg',89.00),
('itm-w978-23u4','Some Item',0.50);

INSERT INTO booking_commercials VALUES
('q34r-3q4o8-q34u','bk-09f3e-95hj','bl-0a87y-q340','2021-09-23 12:03:22','itm-a9e8-q8fu',3),
('q3o4-ahf32-o2u4','bk-09f3e-95hj','bl-0a87y-q340','2021-09-23 12:03:22','itm-a07vh-aer8',1),
('134lr-oyfo8-3qk4','bk-q034-q4o','bl-34qhd-r7h8','2021-09-23 12:05:37','itm-w978-23u4',0.5);
