-- A ---------------------------------------------------------------
-- بررسی پایه‌ای فروش -----------------------------------------------

-- 01
-- چند سفارش در مجموع ثبت شده است؟
SELECT COUNT(OrderID) AS total_count_orders
FROM Orders;


-- 02
-- درآمد حاصل از این سفارش‌ها چقدر بوده است؟

SELECT SUM((d.Quantity * p.Price)) AS total_income
FROM Orders AS o
         LEFT JOIN OrderDetails AS d ON o.OrderID = d.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID;


-- B ---------------------------------------------------------------
--  تحلیل مشتریان --------------------------------------------------

-- 03
-- 5 مشتری برتر را بر اساس مقداری که خرج کرده‌اند را پیدا کنید (ID نام و مقدار خرج شده هریک را گزارش کنید)
SELECT o.CustomerID, c.CustomerName, SUM((d.Quantity * p.Price)) AS total_spend
FROM Orders AS o
         LEFT JOIN OrderDetails AS d ON o.OrderID = d.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
         LEFT JOIN Customers AS c ON c.CustomerID = o.CustomerID
GROUP BY o.CustomerID
ORDER BY SUM((d.Quantity * p.Price)) DESC
LIMIT 5;


-- 04
-- میانگین هزینه سفارشات هر مشتری را به همراه ID و نام او گزارش کنید (به ترتیب نزولی نشان دهید)
SELECT o.OrderID, o.CustomerID, c.CustomerName, AVG((d.Quantity * p.Price)) AS avg_price
FROM Orders AS o
         LEFT JOIN OrderDetails AS d ON o.OrderID = d.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
         LEFT JOIN Customers AS c ON c.CustomerID = o.CustomerID
GROUP BY o.CustomerID
ORDER BY avg_price DESC;


-- 05
-- مشتریان را بر اساس مقدار کل هزینه‌ی سفارشات رتبه‌بندی کنید، اما فقط مشتریانی را در نظر بگیرید که بیشتر از 5 سفارش داده‌اند
SELECT CustomerID, COUNT(OrderID) AS count_of_orders
FROM Orders
GROUP BY CustomerID
HAVING count_of_orders > 5
ORDER BY count_of_orders DESC;

SELECT o.OrderID, o.CustomerID, c.CustomerName, SUM((d.Quantity * p.Price)) AS total_spend
FROM Orders AS o
         LEFT JOIN OrderDetails AS d ON o.OrderID = d.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
         LEFT JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IN (SELECT CustomerID
                       FROM Orders
                       GROUP BY CustomerID
                       HAVING COUNT(OrderID) > 5
                       ORDER BY COUNT(OrderID) DESC)
GROUP BY o.CustomerID
ORDER BY total_spend DESC;


-- C ---------------------------------------------------------------
-- تحلیل محصولات ----------------------------------------------------

-- 06
-- کدام محصول در کل سفارشات ثبت شده بیشترین درآمد را ایجاد کرده است؟ (به همراه ID و نام گزارش کنید)
# SELECT p.ProductName, (SUM(d.Quantity * p.Price)) AS total_price
# FROM OrderDetails AS d
#          LEFT JOIN Products AS p ON p.ProductID = d.ProductID
# GROUP BY d.ProductID
# ORDER BY total_price
# LIMIT 1;
#
# SELECT d.ProductID,
#        p.ProductName,
#        SUM(d.Quantity)             AS Quantities,
#        p.Price,
#        (SUM(d.Quantity) * p.Price) AS total_price
# FROM OrderDetails AS d
#          LEFT JOIN Products AS p ON p.ProductID = d.ProductID
# GROUP BY d.ProductID
# ORDER BY total_price DESC;

SELECT d.ProductID,
       p.ProductName,
       SUM(d.Quantity)             AS Quantities,
       p.Price,
       (SUM(d.Quantity) * p.Price) AS total_price
FROM OrderDetails AS d
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
GROUP BY d.ProductID
ORDER BY total_price DESC
LIMIT 1;


-- 07
-- هر دسته (Category) چند محصول دارد؟ (به ترتیب نزولی نشان دهید)
SELECT p.CategoryID, c.CategoryName, COUNT(p.ProductID) AS num_of_products
FROM Products AS p
         LEFT JOIN Categories AS c ON c.CategoryID = p.CategoryID
GROUP BY p.CategoryID
ORDER BY num_of_products DESC;

-- 08
-- محصول پر فروش در هر دسته بر اساس درآمد را تعیین کنید

--
SELECT o.*
FROM (SELECT ProductID, SUM(Quantity) AS qty FROM OrderDetails GROUP BY ProductID ORDER BY qty DESC) AS o
         LEFT JOIN Products AS p ON p.ProductID = o.ProductID
WHERE o.ProductID = 24;

SELECT o.*, (o.qty * p.Price) AS total_price
FROM (SELECT ProductID, SUM(Quantity) AS qty FROM OrderDetails GROUP BY ProductID) AS o
         LEFT JOIN Products AS p ON p.ProductID = o.ProductID
ORDER BY total_price DESC;

SELECT o.ProductID, p.CategoryID, o.qty, (o.qty * p.Price) AS total_price
FROM (SELECT ProductID, SUM(Quantity) AS qty FROM OrderDetails GROUP BY ProductID) AS o
         LEFT JOIN Products AS p ON p.ProductID = o.ProductID
ORDER BY p.CategoryID DESC;

SELECT o.*
FROM (SELECT d.ProductID, c.CategoryID, c.CategoryName, d.Quantity, p.Price, SUM(d.Quantity * p.Price) AS total_price
      FROM OrderDetails AS d
               LEFT JOIN Products AS p ON p.ProductID = d.ProductID
               LEFT JOIN Categories AS c ON c.CategoryID = p.CategoryID
      GROUP BY c.CategoryID, d.ProductID) AS o;

SELECT o.id, o.ProductID, o.CategoryID, MAX(max_price) AS max_price
FROM (SELECT ROW_NUMBER() OVER (ORDER BY p.ProductID) AS id,
             c.CategoryID,
             p.ProductID,
             p.ProductName,
             SUM(d.Quantity * p.Price)                AS max_price
      FROM OrderDetails AS d
               JOIN Products AS p ON p.ProductID = d.ProductID
               JOIN Categories AS c ON c.CategoryID = p.CategoryID
      GROUP BY d.ProductID) AS o
GROUP BY o.CategoryID
ORDER BY max_price DESC;

SELECT o.ProductID, o.ProductName, o.CategoryID, o.CategoryName, MAX(o.total_price) AS highest_price
FROM (SELECT p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, (SUM(d.Quantity) * p.Price) AS total_price
      FROM OrderDetails AS d
               LEFT JOIN Products AS p ON p.ProductID = d.ProductID
               LEFT JOIN Categories AS c ON c.CategoryID = p.CategoryID
      GROUP BY d.ProductID
      ORDER BY c.CategoryID ASC, total_price DESC) AS o
GROUP BY o.CategoryID
ORDER BY highest_price DESC;

-- ----*******---- ----*******---- ----*******---- ----*******---- ----*******---- ----*******---- ----*******----


-- D ---------------------------------------------------------------
-- تحلیل عملکرد کارمندان -------------------------------------------

-- 09
-- 5 کارمند برتر که بالاترین درآمد را ایجاد کردند به همراه ID و نام + " " + نام خانوادگی گزارش کنید
SELECT SUM(d.Quantity * p.Price)
FROM Orders AS o
         LEFT JOIN OrderDetails AS d ON d.OrderID = o.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
WHERE o.EmployeeID = 1;

SELECT e.EmployeeID, CONCAT(e.FirstName, " ", e.LastName) AS full_name, SUM(d.Quantity * p.Price) AS income
FROM Orders AS o
         LEFT JOIN Employees AS e ON e.EmployeeID = o.EmployeeID
         LEFT JOIN OrderDetails AS d ON d.OrderID = o.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
GROUP BY o.EmployeeID
ORDER BY income DESC
LIMIT 5;

-- 10
-- میانگین درآمد هر کارمند به ازای هر سفارش چقدر بوده است؟ (به ترتیب نزولی نشان دهید)

SELECT e.EmployeeID, CONCAT(e.FirstName, " ", e.LastName) AS full_name, AVG(d.Quantity * p.Price) AS avg_income
FROM Orders AS o
         LEFT JOIN Employees AS e ON e.EmployeeID = o.EmployeeID
         LEFT JOIN OrderDetails AS d ON d.OrderID = o.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
GROUP BY o.EmployeeID
ORDER BY avg_income DESC;

-- E ---------------------------------------------------------------
-- تحلیل‌های جغرافیایی ----------------------------------------------

-- 11
-- کدام کشور بیشترین تعداد سفارشات را ثبت کرده است؟ (نام کشور را به همراه تعداد سفارشات گزارش دهید)
SELECT c.Country, o.*
FROM Orders AS o
         LEFT JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE c.Country = 'USA';

SELECT c.Country, COUNT(o.OrderID) AS num_of_orders
FROM Orders AS o
         LEFT JOIN Customers AS c ON c.CustomerID = o.CustomerID
GROUP BY c.Country
ORDER BY num_of_orders DESC;

-- 12
-- مجموع درآمد از سفارشات هر کشور چقدر بوده؟ (به همراه نام کشور و به ترتیب نزولی نشان دهید)
SELECT s.Country, SUM(d.Quantity * p.Price) AS total_income
FROM Orders AS o
         JOIN OrderDetails AS d ON d.OrderID = o.OrderID
         JOIN Products AS p ON p.ProductID = d.ProductID
         JOIN Suppliers AS s ON s.SupplierID = p.SupplierID
GROUP BY s.Country
ORDER BY total_income DESC;

-- F ---------------------------------------------------------------
-- مقایسه‌ی دسته‌بندی‌ها ----------------------------------------------

-- 13
-- میانگین قیمت هر دسته چقدر است؟ (به همراه نام دسته و به ترتیب نزولی گزارش کنید)
SELECT p.CategoryID, p.ProductID, p.ProductName, d.Quantity, p.Price, (d.Quantity * p.Price) AS total_price
FROM OrderDetails AS d
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
WHERE d.ProductID IN (SELECT ProductID FROM Products WHERE CategoryID = 8);

SELECT d.*, p.CategoryID
FROM `OrderDetails` AS d
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
WHERE d.ProductID IN (SELECT ProductID FROM Products WHERE CategoryID = 8);

SELECT c.CategoryID, c.CategoryName, AVG(d.Quantity * p.Price) AS avg_price
FROM Products AS p
         LEFT JOIN OrderDetails AS d ON d.ProductID = p.ProductID
         LEFT JOIN Categories AS c ON c.CategoryID = p.CategoryID
GROUP BY p.CategoryID
ORDER BY avg_price DESC;

-- 14
-- گران‌ترین دسته‌بندی کدام است؟ (به همراه نام دسته گزارش کنید)
SELECT c.CategoryID,
       c.CategoryName,
       COUNT(p.ProductID) AS num_of_products,
       AVG(p.Price),
       SUM(p.Price)       AS total_price
FROM Categories AS c
         LEFT JOIN Products AS p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID
ORDER BY total_price DESC;

SELECT c.CategoryID, c.CategoryName, COUNT(p.ProductID) AS num_of_products, SUM(p.Price) AS total_price
FROM Categories AS c
         LEFT JOIN Products AS p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID
ORDER BY total_price DESC
LIMIT 1;


-- G ---------------------------------------------------------------
-- روند سفارشات ----------------------------------------------------

-- 15
-- طی سال 1996 هر ماه چند سفارش ثبت شده است؟

-- All Orders in 1996
SELECT *
FROM Orders
WHERE YEAR(OrderDate) = '1996'
  AND MONTH(OrderDate) BETWEEN '01' AND '12';

-- Count of orders per month
SELECT CONCAT(YEAR(OrderDate), "-", MONTH(OrderDate)) AS order_date, COUNT(*) AS num_of_orders
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate) ASC, MONTH(OrderDate) ASC;

-- Count of orders per month in 1996
SELECT CONCAT(YEAR(OrderDate), "-", MONTH(OrderDate)) AS order_date, COUNT(*) AS num_of_orders
FROM Orders
WHERE YEAR(OrderDate) = '1996'
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate) ASC;


-- 16
-- میانگین فاصله‌ی زمانی بین سفارشات هر مشتری چقدر بوده است؟ (به همراه نام مشتری و به صورت نزولی نشان دهید)

SELECT CustomerID, (MAX(OrderDate) - MIN(OrderDate)) / (COUNT(*) - 1) AS avg_period_orders
FROM Orders
WHERE CustomerId = 14
GROUP BY CustomerID
HAVING COUNT(*) > 1;

SELECT ABS(DATEDIFF("1996-12-27", "1997-02-03"));

SELECT CustomerID, COUNT(OrderID) AS o
FROM Orders
GROUP BY CustomerID
HAVING o > 1;

SELECT o.CustomerID, o.OrderDate, LAG(o.OrderDate) OVER (ORDER BY o.OrderDate ASC) AS LagOrderDate
FROM Orders AS o
WHERE o.CustomerID = 60
ORDER BY o.OrderDate ASC;

SELECT o.CustomerID,
       c.CustomerName,
       o.OrderDate,
       LAG(o.OrderDate) OVER (ORDER BY o.OrderDate ASC) AS PreviousOrderDate
FROM Orders AS o
         LEFT JOIN Customers AS c ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IN (68)
GROUP BY o.OrderID
ORDER BY o.OrderDate ASC;

SELECT *
FROM (SELECT o.CustomerID, o.OrderDate, LAG(o.OrderDate) OVER (ORDER BY o.OrderDate ASC) AS NextOrderDate
      FROM Orders AS o
      WHERE o.CustomerID = 60
      GROUP BY o.OrderID
      ORDER BY o.OrderDate ASC) AS o2;

SELECT o2.CustomerID,
       o2.OrderDate,
       o2.PreviousOrderDate,
       ABS(DATEDIFF(o2.OrderDate, PreviousOrderDate)) AS DayDiff

FROM (SELECT o.CustomerID, o.OrderDate, LAG(o.OrderDate) OVER (ORDER BY o.OrderDate ASC) AS PreviousOrderDate
      FROM Orders AS o
      WHERE o.CustomerID = 60
      GROUP BY o.OrderID
      ORDER BY o.OrderDate ASC) AS o2
WHERE o2.PreviousOrderDate IS NOT NULL;


-- Final Query
SELECT o2.CustomerID,
       o2.CustomerName,
       o2.OrderDate,
       o2.PreviousOrderDate,
       AVG(ABS(DATEDIFF(o2.OrderDate, PreviousOrderDate))) AS AvgDay
FROM (SELECT o.CustomerID,
             c.CustomerName,
             o.OrderDate,
             LAG(o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderDate ASC) AS PreviousOrderDate
      FROM Orders AS o
               LEFT JOIN Customers AS c ON c.CustomerID = o.CustomerID
      GROUP BY o.OrderID
      ORDER BY o.CustomerID ASC, o.OrderDate ASC) AS o2
WHERE o2.PreviousOrderDate IS NOT NULL
GROUP BY o2.CustomerID
ORDER BY AvgDay DESC;

-- 17
-- در هر فصل جمع سفارشات چقدر بوده است؟ (به نزولی نشان دهید)

select T.date_time, SUM(T.amount)
from (select *
      from TEST_TABLE
      where date_time >= DATE_ADD(CURDATE(), INTERVAL -3 MONTH)
        and date_time <= CURDATE())
         as T
GROUP BY MONTH(T.date_time);

SELECT *
FROM (SELECT DATE_FORMAT(MIN(o.OrderDate), '%Y-%m-01') AS first_date, LAST_DAY(MAX(o.OrderDate)) AS last_date
      FROM Orders AS o) AS days;

SELECT *
FROM Orders
WHERE (month(d) BETWEEN start_month AND end_month)
   OR (start_month > end_month AND (month(d) >= start_month OR month(d) <= end_month));

-- helper sql --
SELECT quantity, FLOOR((MONTH(date_field) % 12) / 3) as season
FROM tbl
GROUP BY season;
-- ------------

SELECT *
FROM (SELECT *, FLOOR((MONTH(OrderDate) % 12) / 3) as season_id FROM Orders ORDER BY OrderDate ASC) AS O;


SELECT YEAR(OrderDate)                            AS year,
       CASE
           WHEN O.season_id = 0 THEN "Spring"
           WHEN O.season_id = 1 THEN "Summer"
           WHEN O.season_id = 2 THEN "Autumn"
           WHEN O.season_id = 3 THEN "Winter" END AS season,
       SUM(d.Quantity * p.Price)                  AS total_price
FROM (SELECT *, FLOOR((MONTH(OrderDate) % 12) / 3) as season_id FROM Orders ORDER BY OrderDate ASC) AS O
         LEFT JOIN OrderDetails AS d ON d.OrderID = O.OrderID
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
GROUP BY YEAR(O.OrderDate), O.season_id
ORDER BY total_price DESC;


-- I ---------------------------------------------------------------
-- تحلیل عملکرد تامین کنندگان --------------------------------------

-- 18
-- کدام تامین کننده بیشترین تعداد کالا را تامین کرده است؟ (به همراه نام و ID گزارش کنید)

-- Numbers of suppliers products
SELECT p.SupplierID, s.SupplierName, COUNT(p.ProductID) AS num_of_products
FROM Products AS p
         LEFT JOIN Suppliers AS s ON s.SupplierID = p.SupplierID
GROUP BY p.SupplierID
ORDER BY num_of_products DESC;

SELECT COUNT(*)
FROM OrderDetails AS d
WHERE d.ProductID IN (SELECT ProductID FROM Products WHERE SupplierID = 12);

SELECT s.SupplierID, s.SupplierName, COUNT(d.ProductID) AS num_of_supplied
FROM OrderDetails AS d
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
         LEFT JOIN Suppliers AS s ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID
ORDER BY num_of_supplied DESC;


-- 19
-- میانگین قیمت کالای تامین شده توسط هر تامین‌کننده چقدر بوده؟ (به همراه نام و ID و به صورت نزولی گزارش کنید)

-- Average supplied price for single supplier
SELECT s.SupplierID, s.SupplierName, AVG(d.Quantity * p.Price) AS avg_supplied_price
FROM OrderDetails AS d
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
         LEFT JOIN Suppliers AS s ON s.SupplierID = p.SupplierID
WHERE d.ProductID IN (SELECT ProductID FROM Products WHERE SupplierID = 18);

-- Average supplied price for all suppliers
SELECT s.SupplierID, s.SupplierName, AVG(d.Quantity * p.Price) AS avg_supplied_price
FROM OrderDetails AS d
         LEFT JOIN Products AS p ON p.ProductID = d.ProductID
         LEFT JOIN Suppliers AS s ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID
ORDER BY avg_supplied_price DESC;
