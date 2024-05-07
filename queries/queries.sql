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

SELECT o.id, o.ProductID, o.CategoryID, MAX(max_price)
FROM (SELECT ROW_NUMBER() OVER (ORDER BY p.ProductID) AS id,
             c.CategoryID,
             p.ProductID,
             p.ProductName,
             SUM(d.Quantity * p.Price)                AS max_price
      FROM OrderDetails AS d
               JOIN Products AS p ON p.ProductID = d.ProductID
               JOIN Categories AS c ON c.CategoryID = p.CategoryID
      GROUP BY d.ProductID) AS o
GROUP BY o.CategoryID;

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



-- 14
-- گران‌ترین دسته‌بندی کدام است؟ (به همراه نام دسته گزارش کنید)

-- G ---------------------------------------------------------------
-- روند سفارشات ----------------------------------------------------

-- 15
-- طی سال 1996 هر ماه چند سفارش ثبت شده است؟

-- 16
-- میانگین فاصله‌ی زمانی بین سفارشات هر مشتری چقدر بوده است؟ (به همراه نام مشتری و به صورت نزولی نشان دهید)

-- 17
-- در هر فصل جمع سفارشات چقدر بوده است؟ (به نزولی نشان دهید)


-- I ---------------------------------------------------------------
-- تحلیل عملکرد تامین کنندگان --------------------------------------

-- 18
-- کدام تامین کننده بیشترین تعداد کالا را تامین کرده است؟ (به همراه نام و ID گزارش کنید)

-- 19
-- میانگین قیمت کالای تامین شده توسط هر تامین‌کننده چقدر بوده؟ (به همراه نام و ID و به صورت نزولی گزارش کنید)
