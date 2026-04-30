CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(150),
    customer_type VARCHAR(50),
    customer_loyalty VARCHAR(20),
    customer_student BOOLEAN,
    customer_guest BOOLEAN
);

CREATE TABLE Employee (
    employee_id VARCHAR(20) PRIMARY KEY,
    employee_nation VARCHAR(20),
    manager_id VARCHAR(20),
    manager_nation VARCHAR(20),
    FOREIGN KEY (manager_id) REFERENCES Employee(employee_id)
);

CREATE TABLE Vendor (
    vendor_id INT PRIMARY KEY,
    vendor_name VARCHAR(150) NOT NULL,
    vendor_phone VARCHAR(20),
    vendor_rep VARCHAR(100),
    email_missing BOOLEAN
);

CREATE TABLE Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100)
);

CREATE TABLE Product (
    sku VARCHAR(30) PRIMARY KEY,
    alt_sku VARCHAR(30),
    product_description VARCHAR(255),
    category_id INT,
    vendor_id INT,
    cost DECIMAL(10,2),
    cost_currency VARCHAR(10),
    list_price DECIMAL(10,2),
    list_price_currency VARCHAR(10),
    reorder_level INT,
    pack_size INT,
    weight_kg DECIMAL(10,2),
    length_inches DECIMAL(10,2),
    discontinued BOOLEAN,
    parent_sku VARCHAR(30),
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (vendor_id) REFERENCES Vendor(vendor_id),
    FOREIGN KEY (parent_sku) REFERENCES Product(sku)
);

CREATE TABLE `Order` (
    order_id VARCHAR(30) PRIMARY KEY,
    order_nation VARCHAR(20),
    sale_date DATE,
    customer_id INT,
    employee_id VARCHAR(20),
    ship_country VARCHAR(50),
    ship_to VARCHAR(150),
    currencyType VARCHAR(10),
    return_flag CHAR(1),
    notes VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

CREATE TABLE Order_Line (
    line_id VARCHAR(30) PRIMARY KEY,
    order_id VARCHAR(30),
    sku VARCHAR(30),
    quantity INT,
    unit_price DECIMAL(10,2),
    unit_currency VARCHAR(10),
    discount DECIMAL(5,2),
    tax DECIMAL(5,2),
    line_total DECIMAL(10,2),
    one_size BOOLEAN,
    size_inches DECIMAL(10,2),
    weight_kg DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY (sku) REFERENCES Product(sku)
);

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY,
    order_id VARCHAR(30),
    payment_method VARCHAR(50),
    payment_amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id)
);
