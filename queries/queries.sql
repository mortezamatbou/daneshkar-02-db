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
--


-- 07
-- ---


-- 08
-- ---


-- 0X
-- ---



