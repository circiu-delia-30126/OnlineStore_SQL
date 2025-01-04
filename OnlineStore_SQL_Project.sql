USE master;
GO
DROP DATABASE IF EXISTS OnlineStore;
GO

-- Create database OnlineStore
CREATE DATABASE OnlineStore;
GO

-- Use the OnlineStore database
USE OnlineStore;
GO

-- Create table Suppliers
CREATE TABLE [dbo].[Suppliers] (
    [supplier_id] INT IDENTITY(1,1) PRIMARY KEY,
    [supplier_name] VARCHAR(50),
    [city] VARCHAR(50)
);
GO

-- Create table Products
CREATE TABLE [dbo].[Products] (
    [product_id] INT IDENTITY(1,1) PRIMARY KEY,
    [product_name] VARCHAR(50),
    [unit_measure] VARCHAR(20)
);
GO

-- Create table Offers
CREATE TABLE [dbo].[Offers] (
    [supplier_id] INT,
    [product_id] INT,
    [price] MONEY,
    [quantity] INT,
    PRIMARY KEY (supplier_id, product_id),
    FOREIGN KEY (supplier_id) REFERENCES [dbo].[Suppliers](supplier_id),
    FOREIGN KEY (product_id) REFERENCES [dbo].[Products](product_id)
);
GO

-- Create table Customers
CREATE TABLE [dbo].[Customers] (
    [customer_id] INT IDENTITY(1,1) PRIMARY KEY,
    [customer_name] VARCHAR(50),
    [city] VARCHAR(50)
);
GO

-- Create table Orders
CREATE TABLE [dbo].[Orders] (
    [customer_id] INT,
    [product_id] INT,
    [price] MONEY,
    [quantity] INT,
    [order_date] DATE, -- Add column for order date
    PRIMARY KEY (customer_id, product_id),
    FOREIGN KEY (customer_id) REFERENCES [dbo].[Customers](customer_id),
    FOREIGN KEY (product_id) REFERENCES [dbo].[Products](product_id)
);
GO

-- Drop table Orders
DROP TABLE [dbo].[Orders];

-- Create table Transactions
CREATE TABLE [dbo].[Transactions] (
    [transaction_id] INT IDENTITY(1,1) PRIMARY KEY,
    [customer_id] INT,
    [supplier_id] INT,
    [product_id] INT,
    [price] MONEY,
    [quantity] INT,
    [transaction_date] DATE,
    FOREIGN KEY (customer_id) REFERENCES [dbo].[Customers](customer_id),
    FOREIGN KEY (supplier_id) REFERENCES [dbo].[Suppliers](supplier_id),
    FOREIGN KEY (product_id) REFERENCES [dbo].[Products](product_id)
);
GO

-- Add test data to tables

-- Suppliers
INSERT INTO [dbo].[Suppliers] (supplier_name, city) VALUES ('Supplier1', 'Bucharest');
INSERT INTO [dbo].[Suppliers] (supplier_name, city) VALUES ('Supplier2', 'Cluj');
INSERT INTO [dbo].[Suppliers] (supplier_name, city) VALUES ('Supplier3', 'Timisoara');
INSERT INTO [dbo].[Suppliers] (supplier_name, city) VALUES ('Supplier6', 'Brasov');
INSERT INTO [dbo].[Suppliers] (supplier_name, city) VALUES ('Supplier7', 'Constanta');
INSERT INTO [dbo].[Suppliers] (supplier_name, city) VALUES ('Supplier8', 'Ploiesti');

-- Products
INSERT INTO [dbo].[Products] (product_name, unit_measure) VALUES ('Laptop', 'pcs');
INSERT INTO [dbo].[Products] (product_name, unit_measure) VALUES ('Phone', 'pcs');
INSERT INTO [dbo].[Products] (product_name, unit_measure) VALUES ('TV', 'pcs');
INSERT INTO [dbo].[Products] (product_name, unit_measure) VALUES ('Chair', 'pcs');
INSERT INTO [dbo].[Products] (product_name, unit_measure) VALUES ('Desk', 'pcs');
INSERT INTO [dbo].[Products] (product_name, unit_measure) VALUES ('Lamp', 'pcs');

-- Offers
INSERT INTO [dbo].[Offers] (supplier_id, product_id, price, quantity) VALUES (1, 7, 2000.00, 15);
INSERT INTO [dbo].[Offers] (supplier_id, product_id, price, quantity) VALUES (2, 2, 1500.00, 20);
INSERT INTO [dbo].[Offers] (supplier_id, product_id, price, quantity) VALUES (3, 1, 3000.00, 10);
INSERT INTO [dbo].[Offers] (supplier_id, product_id, price, quantity) VALUES (4, 5, 550.00, 5);
INSERT INTO [dbo].[Offers] (supplier_id, product_id, price, quantity) VALUES (5, 6, 600.00, 3);
INSERT INTO [dbo].[Offers] (supplier_id, product_id, price, quantity) VALUES (6, 7, 700.00, 2);

-- Customers
INSERT INTO [dbo].[Customers] (customer_name, city) VALUES ('Andrew Popa', 'Iasi');
INSERT INTO [dbo].[Customers] (customer_name, city) VALUES ('Luca Rusu', 'Constanta');
INSERT INTO [dbo].[Customers] (customer_name, city) VALUES ('Vlad Popovici', 'Brasov');
INSERT INTO [dbo].[Customers] (customer_name, city) VALUES ('Maria Ioana', 'Iasi');
INSERT INTO [dbo].[Customers] (customer_name, city) VALUES ('Paula Sos', 'Timisoara');
INSERT INTO [dbo].[Customers] (customer_name, city) VALUES ('Adina Mihai', 'Cluj');

-- Orders
INSERT INTO [dbo].[Orders] (customer_id, product_id, price, quantity, order_date) VALUES (1, 1, 3000.00, 1, '2024-05-29');
INSERT INTO [dbo].[Orders] (customer_id, product_id, price, quantity, order_date) VALUES (2, 2, 1500.00, 2, '2024-05-29');

-- Transactions
INSERT INTO [dbo].[Transactions] (customer_id, supplier_id, product_id, price, quantity, transaction_date) VALUES (1, 1, 1, 3000.00, 1, '2023-05-01');
INSERT INTO [dbo].[Transactions] (customer_id, supplier_id, product_id, price, quantity, transaction_date) VALUES (2, 1, 2, 1500.00, 2, '2023-05-02');

-- View AvailableOffers
CREATE VIEW [dbo].[AvailableOffers]
AS
SELECT o.supplier_id, s.supplier_name, o.product_id, p.product_name, o.price, o.quantity
FROM Offers o
INNER JOIN Suppliers s ON o.supplier_id = s.supplier_id
INNER JOIN Products p ON o.product_id = p.product_id;
GO

-- Stored Procedure AddOrder
CREATE PROCEDURE AddOrder
    @customer_id INT,
    @product_id INT,
    @price MONEY,
    @quantity INT
AS
BEGIN
    INSERT INTO Orders (customer_id, product_id, price, quantity, order_date)
    VALUES (@customer_id, @product_id, @price, @quantity, GETDATE())
END;
GO

-- Trigger AddTransaction
CREATE TRIGGER trg_AddTransaction
ON Orders
AFTER INSERT
AS
BEGIN
    INSERT INTO Transactions (customer_id, product_id, price, quantity, transaction_date)
    SELECT customer_id, product_id, price, quantity, GETDATE()
    FROM inserted;
END;
GO

-- Stored Procedure TotalOrderSummary
CREATE PROCEDURE TotalOrderSummary
    @customer_id INT,
    @product_id INT
AS
BEGIN
    SELECT 
        customer_id,
        product_id,
        SUM(quantity) AS total_quantity,
        SUM(price * quantity) AS total_value
    FROM Orders
    WHERE customer_id = @customer_id AND product_id = @product_id
    GROUP BY customer_id, product_id;
END;
GO