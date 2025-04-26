 CREATE DATABASE pizzahut;
 
-- 1.Retrieve the total number of orders placed.

   SELECT COUNT(order_id) AS total_order FROM orders;

-- 2.Calculate the total revenue generated from pizza sales.

   SELECT ROUND((SUM(o.quantity*p.price)),2) AS total_revenue
   FROM order_details o
   LEFT JOIN pizzas p
   ON o.pizza_id= p.pizza_id;
   
-- 3.Identify the highest-priced pizza.
 
   SELECT x.name , y.price 
   FROM pizza_types x 
   LEFT JOIN pizzas y
   ON x.pizza_type_id = y.pizza_type_id
   ORDER BY y.price DESC LIMIT 1;
   
-- 4.Identify the most common pizza size ordered.
   
   SELECT  y.size, COUNT(size) AS size_count
   FROM order_details x
   LEFT JOIN pizzas y
   ON x.pizza_id = y.pizza_id
   GROUP BY  y.size 
   ORDER BY size_count DESC ;
   
   
-- 5.List the top 5 most ordered pizza types along with their quantities.

   SELECT B.name , A.total_count
   FROM 
   (SELECT x.pizza_type_id , SUM(y.quantity) AS total_count
   FROM order_details y
   LEFT JOIN pizzas x
   ON y.pizza_id=x.pizza_id
   GROUP BY pizza_type_id) AS A
   
   LEFT JOIN pizza_types B
   ON B.pizza_type_id=A.pizza_type_id
   ORDER BY total_count DESC LIMIT 5;
   
-- 6.Join the necessary tables to find the total quantity of each pizza category ordered.
   
   SELECT B.category , SUM(total_count)
   FROM 
   (SELECT x.pizza_type_id , SUM(y.quantity) AS total_count
   FROM order_details y
   LEFT JOIN pizzas x
   ON y.pizza_id=x.pizza_id
   GROUP BY pizza_type_id) AS A
   
   LEFT JOIN pizza_types B
   ON B.pizza_type_id=A.pizza_type_id
   GROUP BY B.category;
   
   
-- 7.Determine the distribution of orders by hour of the day.
    
   SELECT HOUR(order_time) AS hour , COUNT(order_id) AS order_count
   FROM orders
   GROUP BY HOUR(order_time);
   
-- 8.Join relevant tables to find the category-wise distribution of pizzas.
   
    SELECT category ,COUNT(name) pizza_type
    FROM pizza_types
    GROUP BY  category;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.
   
    SELECT AVG(total_quantity) AS avg_quantity
    FROM
    (SELECT x.order_date , SUM(y.quantity) AS total_quantity
    FROM order_details y
    LEFT JOIN orders x
    ON y.order_id=x.order_id
    GROUP BY order_date) AS a;
    
-- 10.Determine the top 3 most ordered pizza types based on revenue.
    
    SELECT x.pizza_type_id , SUM(x.price*y.quantity) AS revenue
    FROM order_details y
    LEFT JOIN pizzas x
    ON y.pizza_id=x.pizza_id
    GROUP BY pizza_type_id
    ORDER BY revenue DESC LIMIT 3;
 
-- 11.Calculate the percentage contribution of each category to total revenue.
    
    -- finding total revenue genrated then  revenue/total_revenue *100
	
    WITH total_revenue AS
	(SELECT ROUND(SUM(p.quantity*q.price),2) AS total
    FROM order_details p
    LEFT JOIN pizzas q
    ON p.pizza_id=q.pizza_id)
    
    SELECT a.category , ROUND(SUM(a.price*z.quantity),2)/(SELECT total FROM total_revenue)*100 AS revenue
    FROM order_details z
    LEFT JOIN
    (SELECT y.pizza_id , y.price , x.category
    FROM pizzas y
    LEFT JOIN pizza_types x
    ON y.pizza_type_id= x.pizza_type_id) AS a
    
    ON z.pizza_id=a.pizza_id
    GROUP BY category;
	
-- Analyze the cumulative revenue generated over time.
	
    SELECT order_date, SUM(day_revenue) OVER(ORDER BY order_date) AS cumulative_revenue
    FROM
    
    (SELECT b.order_date ,SUM(a.price) AS day_revenue
    FROM orders b
    LEFT JOIN 
    (SELECT y.order_id , SUM(y.quantity*x.price) AS price
    FROM order_details y
    LEFT JOIN pizzas x
    ON y.pizza_id= x.pizza_id
    GROUP BY y.order_id) AS a
    
    ON b.order_id = a.order_id
    GROUP BY b.order_date ) AS sub_query;
    
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
    
    SELECT category , revenue , rank_no
    FROM
    
    (SELECT name , category , revenue, RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rank_no
    FROM
    
	(SELECT a.category ,a.name , ROUND(SUM(a.price*z.quantity),2) AS revenue
    FROM order_details z
    LEFT JOIN
    (SELECT y.pizza_id , y.price , x.category , x.name
    FROM pizzas y
    LEFT JOIN pizza_types x
    ON y.pizza_type_id= x.pizza_type_id) AS a
    
    ON z.pizza_id=a.pizza_id
    GROUP BY a.category, a.name) AS ranked_revenue) AS alias
    WHERE rank_no <=3;