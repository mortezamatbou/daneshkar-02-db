-- ---------------------------------------
CREATE TABLE Categories
(
    CategoryID   INTEGER PRIMARY KEY,
    CategoryName VARCHAR(25),
    Description  VARCHAR(255)
);

-- ---------------------------------------
CREATE TABLE Customers
(
    CustomerID   INTEGER PRIMARY KEY,
    CustomerName VARCHAR(50),
    ContactName  VARCHAR(50),
    Address      VARCHAR(50),
    City         VARCHAR(20),
    PostalCode   VARCHAR(10),
    Country      VARCHAR(15)
);

-- ---------------------------------------
CREATE TABLE Employees
(
    EmployeeID INTEGER PRIMARY KEY,
    LastName   VARCHAR(15),
    FirstName  VARCHAR(15),
    BirthDate  DATE,
    Photo      VARCHAR(25),
    Notes      VARCHAR(1024)
);

-- ---------------------------------------
CREATE TABLE Shippers
(
    ShipperID   INTEGER PRIMARY KEY,
    ShipperName VARCHAR(25),
    Phone       VARCHAR(15)
);

-- ---------------------------------------
CREATE TABLE Suppliers
(
    SupplierID   INTEGER PRIMARY KEY,
    SupplierName VARCHAR(50),
    ContactName  VARCHAR(50),
    Address      VARCHAR(50),
    City         VARCHAR(20),
    PostalCode   VARCHAR(10),
    Country      VARCHAR(15),
    Phone        VARCHAR(15)
);

-- ---------------------------------------
CREATE TABLE Products
(
    ProductID   INTEGER PRIMARY KEY,
    ProductName VARCHAR(50),
    SupplierID  INTEGER,
    CategoryID  INTEGER,
    Unit        VARCHAR(25),
    Price       INTEGER,
    CONSTRAINT fk_category FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID),
    CONSTRAINT fk_supplier FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID)
);

-- ---------------------------------------
CREATE TABLE Orders
(
    OrderID    INTEGER PRIMARY KEY,
    CustomerID INTEGER,
    EmployeeID INTEGER,
    OrderDate  DATE,
    ShipperID  INTEGER,
    CONSTRAINT fk_employee FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID),
    CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
    CONSTRAINT fk_shipper FOREIGN KEY (ShipperID) REFERENCES Shippers (ShipperID)
);

-- ---------------------------------------
CREATE TABLE OrderDetails
(
    OrderDetailID INTEGER PRIMARY KEY,
    OrderID       INTEGER,
    ProductID     INTEGER,
    Quantity      INTEGER,
    CONSTRAINT fk_order FOREIGN KEY (OrderID) REFERENCES Orders (OrderID),
    CONSTRAINT fk_product FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);
-- ---------------------------------------