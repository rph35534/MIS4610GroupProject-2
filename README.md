# MIST 4610 – Group Project #2  
## Northline Outfitters: Data Cleaning, Modeling, and SQL Analysis

### Members and Roles
- Ryan Hooper – Group Leader  
- Tyler Oneacre – Conceptual Modeler  
- Antwone Guerrero – Database Designer  
- Shruthi Vikram – Data Wrangler  
- Emma Stefan – SQL Writer  

---

## Case Summary

Northline Outfitters is a small online retail company that sells student-focused lifestyle and technology accessories. The company currently stores much of its operational data in Excel spreadsheets, resulting in inconsistencies, duplication, and formatting issues.

The goal of this project was to transform messy, unstructured spreadsheet data into a clean, normalized relational database. This involved identifying data quality issues, cleaning and standardizing the data, designing a conceptual model, and writing SQL queries to answer key business questions.

---

## Conceptual Model

### ERD Diagram
<img width="688" height="667" alt="DM3" src="https://github.com/user-attachments/assets/a6cb0046-a011-4966-a057-26392b423dd1" />


### Explanation

The database was designed to represent the core operations of a retail business, including customers, orders, employees, and products.

### Key Entities

**Customer**
- Stores customer information such as name and loyalty status
- Eliminates repeated customer data across orders

**Employee**
- Stores employees who process orders
- Includes a self-referencing relationship to represent managers

**Order**
- Represents each transaction
- Linked to both a customer and an employee

**Order_Line**
- Bridge table between Order and Product
- Stores quantity, price, and transaction-level details

**Product**
- Stores product details such as SKU and category
- Supports product tracking and analysis

**Vendor**
- Stores supplier information
- Links vendors to products

---

### Relationships

- One Customer → Many Orders  
- One Employee → Many Orders  
- One Manager → Many Employees (recursive)  
- One Order → Many Order Lines  
- One Product → Many Order Lines  
- One Vendor → Many Products  

---
## Queries
---

### SQL Queries
### Query 1: Highest Revenue Products by Country

**Business Question:**  
Which products generate the highest total sales revenue in each country?

**Business Justification:**  
This helps Northline Outfitters identify top-performing products in the United States and Canada, allowing for better inventory planning and targeted marketing strategies.

SELECT ... 
    o.order_nation,
    p.product_description,
    SUM(ol.line_total) AS total_sales_revenue
FROM Order_Line ol
JOIN Product p ON ol.sku = p.sku
JOIN Orders o ON ol.order_id = o.order_id
GROUP BY o.order_nation, p.product_description
ORDER BY o.order_nation, total_sales_revenue DESC;
This query aggregates total revenue by product and country, showing which products contribute the most to sales in each region.

### Query 2
Business Question:
Which employees handle the most orders within each manager’s team?

Business Justification:
This helps evaluate employee productivity and compare performance within teams managed by the same supervisor.
SELECT ... 
    e.manager_id,
    e.employee_id,
    COUNT(DISTINCT o.order_id) AS orders_handled
FROM Employee e
JOIN Orders o ON e.employee_id = o.employee_id
GROUP BY e.manager_id, e.employee_id
ORDER BY e.manager_id, orders_handled DESC;
This query counts the number of unique orders handled by each employee and compares them within their manager group.

### Query 3
Business Question:
Which vendors supply products across more than one category?

Business Justification:
This helps identify vendors with diverse product offerings, which may be valuable for expanding inventory or strengthening supplier relationships.
SELECT ... 
    v.vendor_name,
    COUNT(DISTINCT p.category) AS category_count
FROM Vendor v
JOIN Product p ON v.vendor_id = p.vendor_id
GROUP BY v.vendor_name
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY category_count DESC;

### Additional Query 1 — Return Rate by Category

Business Question: Which product categories have the highest return rates?
Justification: High return rates in a category signal quality problems or misleading descriptions. Linking through the new normalized Category table gives cleaner grouping than the old free-text field.

SELECT ...
    cat.category_name,
    COUNT(DISTINCT o.order_id)                                          AS total_orders,
    SUM(CASE WHEN o.return_flag = 'Y' THEN 1 ELSE 0 END)               AS returned_orders,
    ROUND(
        SUM(CASE WHEN o.return_flag = 'Y' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0), 2
    )                                                                   AS return_rate_pct
FROM Category cat
JOIN Product     p   ON cat.category_id     = p.category_id
JOIN Order_Line  ol  ON p.sku               = ol.Product_sku
JOIN `Order`     o   ON ol.Order_order_id   = o.order_id
GROUP BY cat.category_id, cat.category_name
ORDER BY return_rate_pct DESC;

### Additional Query 2- Revenue by currency and by country

Business Question: How does revenue break down between USD and CAD orders, and does it align with ship country?
Justification: The original data had mixed currencies with no way to track them. The new currencyType field on Order makes this possible. This query helps management understand whether CAD revenue is being correctly attributed to Canadian orders, and flags any mismatches that survived cleaning.

SELECT ...
    o.ship_country,
    o.currencyType,
    COUNT(DISTINCT o.order_id)              AS num_orders,
    ROUND(SUM(ol.line_total), 2)            AS total_revenue,
    ROUND(AVG(ol.line_total), 2)            AS avg_line_value
FROM `Order` o
JOIN Order_Line ol ON o.order_id = ol.Order_order_id
WHERE o.ship_country IS NOT NULL
GROUP BY o.ship_country, o.currencyType
ORDER BY o.ship_country, o.currencyType;

### Additional Query 3 — Payment Method Popularity by Customer Type

Business Question: Do different customer types (loyalty, student, guest) prefer different payment methods?
Justification: The new Payment table separates payment data into its own entity, and Customer carries customer_type. This query uses both new structures and gives the marketing team insight into whether student customers skew toward debit/prepaid while loyalty customers use credit — useful for targeted promotions or checkout flow design.

SELECT ...
    c.customer_type,
    pay.payment_method,
    COUNT(DISTINCT o.order_id)              AS num_orders,
    ROUND(SUM(pay.payment_amount), 2)       AS total_paid
FROM Customer c
JOIN `Order`   o    ON c.customer_id        = o.Customer_customer_id
JOIN Payment   pay  ON o.order_id           = pay.order_id
GROUP BY c.customer_type, pay.payment_method
ORDER BY c.customer_type, num_orders DESC;


## Data Quality Assessment

The dataset contained several data quality issues:

- Trailing spaces in fields (e.g., "USA   ")
- Duplicate records (same order appearing multiple times)
- Repeated customer names with no unique identifier
- Orders appearing across multiple rows (line-level data)
- Embedded meaning in IDs (e.g., EM-202, EM-M03)
- Inconsistent categorical values (Loyal vs Not Loyal)

These issues made the data unsuitable for direct database use and required cleaning.

---

## Data Cleaning Process

The original data set contains several issues in the Sales Dump sheet, as well as the Product Supplier sheet. Before any analysis could be done, our team had to assess and clean the inconsistencies within the data. 

1. Missing Data
Several key fields (ie; customer_email, discount, tax, and line_total) are missing information. Additional fields like size_or_weight also show moderate levels of missingness.
Missing information about consumers or order totals hinders the ability to accurately calculate revenue, profitability, market segmentation and insights. Additionally, incomplete data about returns restricts the ability to evaluate product performance and customer satisfaction.
2. Inconsistent Data Formats 
The dataset contains multiple formatting errors and inconsistencies across several columns. The sale_date field includes multiple formats (ie; January 1, 2005, 01-01-2005, 2005-01-01, 01/01/05), which makes it difficult to standardize and analyze purchasing trends according to time or seasons. 
Pricing-related fields such as unit_price and line_total mix currency symbols and codes (USD, CAD) within the same column. Similarly, the discount field includes percentages, numeric values, and text-based promotions (10% vs 5 vs promo5). The tax values are represented in a similarly inconsistent manner.
Categorical fields like payment_method are also missing consistent capitalization and formatting, (ie; VISA and Visa, MC as Mastercard, etc), further complicating aggregation and analysis. SQL will treat each of these formats as an entirely different value, so filtering and grouping will not be executed properly.
3. Incorrect Data Types 
All variables in the dataset are stored as text rather than their appropriate data types. Numeric fields such as quantity, unit_price, discount, tax, and line_total are not formatted as numbers.
4. Multiple Attribute Fields (Structural Issues)
Certain fields contain multiple pieces of information within a single column. This goes against the first normal form rule. For example, the customer_info field includes names, loyalty status, and sometimes student or country information, separated by inconsistent delimiters such as semicolons or vertical bars.
The size_or_weight field contains mixed units and formats (ie; inches, text descriptions like “one size”). These inconsistencies make it difficult to extract, categorize, and analyze the data efficiently.
The fields order_id, manager_ref, employee_ref, and sku contain country identifiers within the data (ie; C or U to represent USA or CAN). 
The fields unit_price, cost, and list_price also contain the currency within the field, instead of as a separate column. This is another multi attribute field, and it also prevents the monetary columns from being represented as text fields. 
Vendor_rep contains inconsistent names for the representatives (sometimes naming middle names, sometimes omitting them), and the field states whether their email is missing or not. 
5. Spelling Errors and Text Errors 
Some fields (pack_size, product_description, vendor_name) had incorrectly spelled values, or all-caps text. These inconsistencies will prevent proper aggregation and filtering in SQL queries. 

Data Cleaning Process: Sales Dump
Created separate columns for order_nation, employee_nation, manager_nation, and product_nation 
Since the country identifiers were embedded within the identifying numbers for these values (order_id, employee_ref, manager_ref, sku), we created separate columns to denote this information for each value. 
Standardized dates 
Dates were previously in mixed format (ie; January 1, 2005, 01-01-2005, 2005-01-01, 01/01/05). In the data cleaning process, we converted all dates into the YYYY-MM-DD so that SQL could properly aggregate, analyze and filter without ambiguity. 
Separated customer_info into customer_name, customer_loyalty, customer_student, and customer_guest
Since customer_info was a multi-attribute column, in the data cleaning process we separated the information into 4 columns. This denotes the customer’s name, whether or not they are part of the loyalty program, whether they are student status, or a guest customer. 
Standardized payment_method 
UPDATE Sales_Dump
SET payment_method = 'Visa'
WHERE payment_method = 'VISA';
Payment method contained mixed formats (abbreviations, capitalization inconsistencies, etc). We found and replaced any instances of “VISA” with “Visa” and “MC” with “Mastercard” to maintain consistency.
Standardized product_description
Some product descriptions were in all-caps, while others followed standard capitalization. To absolve this formatting issue, we converted all product descriptions to follow standard capitalization. 
Separated category into category_primary and category_secondary
Category listed several products with a main category and a subcategory separated by a slash. To absolve this formatting error, we created a category_primary and category_secondary to allow each column to only contain one attribute. 
Standardized quantity (from mixed numeric and text values to all numerical
Originally, the quantity values were in mixed format (“2” vs “2 units). To absolve this, all quantities were changed to numerical values. 
Separated unit_price into unit_currency and unit_price 
unit_price was created as a numerical value column, and unit_currency shows whether the unit price is listed in CAD or USD
Standardized discount 
All discount values were converted to numerical values following the XX% format. 
Standardized tax 
All tax values were converted to numerical values following the X.XX format. 
Recalculated line_total using the following formula 
Since unit price, quantity, tax and discount were previously text values, following their conversion to numerical values, we were able to use a formula to recalculate accurate line totals. 
Formula: (quantity * unit_price) * (1-discount) * (1+tax)
Created a “one_size” column to note whether an item falls into the one-size category or not 
Separated size_or_weight into size_inches and weight_kg
Numerical values were manually converted into either inches or kilograms. 

Data Cleaning Process: Product Supplier Master
Separated country identifier from sku and alt_sku
Since the country identifiers were embedded within the identifying codes for these sku and alt_sku, we created separate columns to denote sku_nation and alt_sku_nation.
Separated category into category and subcategory 
Category listed several products with a main category and a subcategory separated by a slash. To absolve this formatting error, we created a category and subcategory to allow each column to only contain one attribute. 
Standardized vendor_name (fixed spelling errors) 
Vendor_name previously contained misspellings of several vendors. We manually replaced each misspelled vendor name to fix this data inconsistency. 
Standardized vendor_phone 
Vendor_phone was previously in mixed format ((xxx)xxx-xxx, xxx-xxx-xxx, etc). In order to maintain consistency across all phone numbers, they were all converted to match the 012-345-6789 format. 
Separated vendor_rep into vendor_rep and email_missing 
Originally, vendor_rep contained varied information, including some vendor representative middle names, and whether or not their email was on file. To maintain consistency, we created vendor_rep to hold the representative’s first and last name, as well as email_missing to note whether the database has an email on file or not. 
Created separate columns identifying currency for cost and list_price   
The original values of unit_price and cost contained the currency within them, preventing these values from being represented as numerical values. To fix this, we created a separate column to note whether the unit is in USD or CAD. cost and list_price were then converted to only contain numerical values. 
Standardized reorder_level 
Reorder_level was originally in mixed format (“12” or “ten”). To create consistency across the column data, all text values were converted to their numerical values. 
Standardized pack_size 
pack_size was originally in mixed format (“case of 6” or “1 each” or “2/pack”). To create consistency across the column data, all text values were converted to their numerical values. 
Converted weight and length into common units 
To eliminate variance in the data, all weight values were converted to kilograms, and all lengths were converted to inches. These calculations were done manually.




