-- 1a. Display the first and last names of all actors from the table actor.

USE sakila;
SELECT first_name,last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT (first_name,' ',last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id,first_name,last_name
	FROM actor
  WHERE first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id,first_name,last_name
	FROM actor
    HAVING last_name LIKE '%GEN';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name,first_name
	FROM actor
    HAVING last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,country
	FROM country
    WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD COLUMN
	description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
	DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*)
	FROM actor
    GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*)
	FROM actor
    GROUP BY last_name
    HAVING COUNT(*)>2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor SET
first_name='HARPO' WHERE
first_name ='GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET
first_name='GROUCHO' WHERE
first_name ='HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
--
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
--
--
--
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT address.address_id, staff.first_name, staff.last_name
FROM address
INNER JOIN staff ON address.address_id=staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT payment.staff_id,
staff.first_name,
staff.last_name,
SUM(payment.amount)
FROM payment
INNER JOIN staff ON payment.staff_id=staff.staff_id
WHERE payment_date BETWEEN '2005-08-01' AND '2005-09-01'
GROUP BY staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title,
film_actor.actor_id,
film_actor.film_id,
COUNT(film_actor.actor_id)
FROM film_actor
INNER JOIN film ON film.film_id=film_actor.film_id
GROUP BY film.title, film_actor.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title,
inventory.film_id,
COUNT(inventory.inventory_id)
FROM inventory
INNER JOIN film ON film.film_id=inventory.film_id
WHERE film.title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY film.title;


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.last_name,
customer.first_name,
SUM(payment.amount)
FROM customer
JOIN payment ON payment.customer_id=customer.customer_id
GROUP BY customer.customer_id;
--
--     ![Total amount paid](Images/total_payment.png)
--
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE (language_id=1 AND title LIKE 'K%')
OR (language_id=1 AND title LIKE 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
CREATE TABLE alone (
SELECT film.title,
film_actor.actor_id
FROM film_actor
INNER JOIN film ON film.film_id=film_actor.film_id
WHERE title='Alone Trip');

SELECT alone.title,
actor.first_name,
actor.last_name
FROM actor
INNER JOIN alone ON alone.actor_id=actor.actor_id;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
CREATE TABLE cust1 (
SELECT customer.first_name,
customer.last_name,
customer.address_id,
address.address,
address.city_id
FROM customer
INNER JOIN address ON customer.address_id=address.address_id);

SELECT cust1.first_name,cust1.last_name,cust1.address,cust1.city_id,city.country_id
FROM cust1
INNER JOIN city ON city.city_id=cust1.city_id
WHERE country_id=20;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
CREATE TABLE promo (
SELECT film.film_id,
film.title,
film_category.category_id
FROM film
INNER JOIN film_category ON film.film_id=film_category.film_id);

SELECT promo.title,
category.name
FROM promo
INNER JOIN category ON category.category_id=promo.category_id
WHERE name='Family';

-- 7e. Display the most frequently rented movies in descending order.
CREATE TABLE rents (
SELECT film.film_id,
film.title,
inventory.inventory_id
FROM film
INNER JOIN inventory ON inventory.film_id=film.film_id);

SELECT rents.title,
COUNT(rents.inventory_id)
FROM rents
INNER JOIN rental ON rental.inventory_id=rents.inventory_id
GROUP BY rents.title
ORDER BY COUNT(rents.inventory_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
CREATE TABLE totals (
SELECT customer.customer_id,
customer.store_id,
rental.rental_id
FROM rental
INNER JOIN customer ON rental.customer_id=customer.customer_id);

SELECT totals.store_id,
SUM(payment.amount)
FROM totals
INNER JOIN payment ON payment.rental_id=totals.rental_id
GROUP BY totals.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
CREATE TABLE store1 (
SELECT store.store_id,
store.address_id,
address.city_id
FROM store
INNER JOIN address ON store.address_id=address.address_id);

CREATE TABLE store2 (
SELECT store1.store_id,city.city,store1.city_id, city.country_id
FROM store1
INNER JOIN city ON store1.city_id=city.city_id);

SELECT store2.store_id,store2.city,country.country
FROM store2
INNER JOIN country ON store2.country_id=country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
CREATE TABLE 5G_1 (
SELECT rental.customer_id,
rental.inventory_id,
rental.rental_id,
payment.amount
FROM rental
INNER JOIN payment ON rental.customer_id=payment.customer_id);

CREATE TABLE 5G_2(
SELECT 5G_1.customer_id,
5G_1.rental_id,
5G_1.amount,inventory.inventory_id,
inventory.film_id
FROM 5G_1
INNER JOIN inventory ON 5G_1.inventory_id=inventory.inventory_id);

CREATE TABLE 5G_3(
SELECT 5G_2.customer_id,
5G_2.inventory_id,
5G_2.rental_id,
5G_2.amount,
5G_2.film_id,
film_category.category_id
FROM 5G_2
INNER JOIN film_category ON 5G_2.film_id=film_category.film_id);

CREATE TABLE 5G_4(
SELECT 5G_3.customer_id,
5G_3.inventory_id,
5G_3.amount,
5G_3.film_id,
5G_3.category_id,
rental.rental_id
FROM 5G_3
INNER JOIN rental ON 5G_3.inventory_id=rental.inventory_id);

	CREATE TABLE 5G_5(
	SELECT 5G_4.customer_id,
	5G_4.inventory_id,
	5G_4.amount,
	5G_4.film_id,
	5G_4.category_id,
	5G_4.rental_id,
	category.name
	FROM 5G_4
	INNER JOIN category ON 5G_4.category_id=category.category_id);

	SELECT name,SUM(amount)
	FROM 5G_5
	GROUP BY name
	DESC LIMIT 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
CREATE VIEW top_5 AS SELECT name,SUM(amount)
FROM 5G_5
GROUP BY name
DESC LIMIT 5;
--Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_5;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_5;
