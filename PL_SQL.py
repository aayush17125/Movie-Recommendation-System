import pandas as pd
import mysql.connector
mydb=mysql.connector.connect(host='localhost',user='root',password='',database='project')
cur=mydb.cursor()
#cur.execute("CREATE DATABASE db1") #create a new database (use mydb=mysql.connector.connect(host='localhost',user='root',password='sachinnandal'))
"""
#create a table
s="CREATE TABLE book(bookid integer(4),title varchar(20), price float(5,2))"
cur.execute(s)
"""

#%%
# Schema of the database:
# List of tables in database: 
pd.read_sql_query("SHOW TABLES", mydb)

#%%
#USER/BUYER
#adding a new buyer (Add auto increment of buyer_id and addr_id if you want)
#inserting data into a table
s="INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (%s,%s,%s,%s)"
s1="(SELECT MAX(addr_id) FROM addr ad)"
cur.execute(s1)
result=cur.fetchone()
lsid=result[0]+1
#inserting a single record
ad1=(lsid,'561 RICHMOND','94016','9876543210')
cur.execute(s,ad1)
mydb.commit()
#%%
s1="(SELECT MAX(buyer_id) FROM buyer)"
cur.execute(s1)
result=cur.fetchone()
lsid1=result[0]+1
s="INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (%s,%s,%s,%s,%s,%s)"
b1=(lsid1,'MIA','WATANABE','MIA.WATANABE@gmail.com',lsid,'2006-02-14 22:04:37')
cur.execute(s,b1)
mydb.commit()

#%%

#Search by movie name
s="""SELECT * 
	FROM movie 
	WHERE title='Blanket Beverly'"""
pd.read_sql_query(s,mydb)

s="""SELECT * 
	FROM movie 
	WHERE release_year=2006"""
pd.read_sql_query(s,mydb)

#%%
#Search movies by actor name
s="""SELECT *
FROM movie 
WHERE movie_id IN 
		(SELECT movie_id
			FROM movie_actor
			WHERE actor_id IN 
         		(SELECT actor_id
				  FROM actor
				  WHERE first_name='Gina' OR last_name='Degeneres'))"""
cur.execute(s)
result=cur.fetchall() #result contains a list of tuples (every tuple is a row)
for rec in result:
	print(rec)

#%%
#Search movies by genre
s="""SELECT *
FROM movie 
WHERE movie_id IN
	(SELECT movie_id 
		FROM movie_category
		WHERE category_id IN 
			(SELECT category_id
				FROM category
                WHERE name='Sci-Fi'))"""
pd.read_sql_query(s,mydb)

#%%
#Search a movie by rating
s="""SELECT *
FROM movie 
WHERE rating='G'"""
pd.read_sql_query(s,mydb)

#%%
#Update first name of a buyer using email 
s="UPDATE buyer SET first_name='MARIA' WHERE email='MARY.SMITH@gmail.com'"
cur.execute(s)
mydb.commit()
#%%
#Update first name of a buyer using buyer id
s="UPDATE buyer SET first_name='MARIA' WHERE buyer_id=1"
cur.execute(s)
mydb.commit()

#%%
#rent a movie for a user specified period
s1="(SELECT MAX(rental_id) FROM rental)"
cur.execute(s1)
result=cur.fetchone()
lsid1=result[0]+1
print(lsid1)
#%%
s="INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (lsid1,'2005-05-25 04:06:21',230,'2005-05-25 23:55:21',1,1)"
cur.execute(s)
mydb.commit()

#%%
#pay for a rental
s="INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (608,7,2,1,5.99,'2005-05-25 06:04:00')"
cur.execute(s)
mydb.commit()

#%%
#top 10 recently released movies added to the database
s="""SELECT *
FROM movie
ORDER BY release_year desc
LIMIT 10"""
pd.read_sql_query(s,mydb)

#%%
#Which movies have I(user) watched?
s="""SELECT r.buyer_id,m.movie_id,m.title
FROM rental r JOIN movie m ON r.movie_id=m.movie_id
WHERE buyer_id=19"""
pd.read_sql_query(s,mydb)


#%%
#OWNER/SUPER ADMIN
#Total gross of the store lifetime
s="SELECT SUM(amount) FROM payment"
pd.read_sql_query(s,mydb)

#%%
#Total gross of the store for a particular month
s="SELECT SUM(amount) FROM payment WHERE payment_date LIKE '2005-08%'"
pd.read_sql_query(s,mydb)

#%%
#Total gross of the store by a particular employee
s="SELECT SUM(amount) FROM payment WHERE employee_id=1"
pd.read_sql_query(s,mydb)

#%%
#Total gross of the store by each employee
s="""SELECT employee_id, SUM(amount)
FROM payment 
GROUP BY employee_id"""
pd.read_sql_query(s,mydb)

#%%
#remove employee
s="UPDATE employee SET active=FALSE WHERE username='aayush'"
cur.execute(s)
mydb.commit()


#%%
#top 5 movies which have been rented the most
s="""SELECT title,count(*) times_rented,ct.name genre
FROM rental r JOIN movie m ON r.movie_id=m.movie_id JOIN movie_category mc ON m.movie_id=mc.movie_id JOIN category ct ON ct.category_id=mc.category_id
GROUP BY r.movie_id
ORDER BY times_rented desc 
LIMIT 5"""
pd.read_sql_query(s,mydb)

#%%
#add new employee
s="INSERT INTO addr(addr_id,address,postal_code,phone) VALUES ((SELECT MAX(addr_id)+1 FROM addr ad),'56 RICHMOND',94016,NULL)"
cur.execute(s)
mydb.commit()
s="INSERT INTO employee(employee_id,first_name,last_name,addr_id,email,active,username,password) VALUES (6,'Mikel','Hiyer',(SELECT MAX(addr_id) FROM addr ad),'Mikel.Hiyer@gmail.com',TRUE,'Mikel','8cb2237d0679ca88db6464eac60da96345513964')"
cur.execute(s)
mydb.commit()

#%%
#Update details of an employee
s="UPDATE employee SET username='Mickie' WHERE employee_id=5"
cur.execute(s)
mydb.commit()

#%%
#how many employees are currently working in the store
s="""SELECT COUNT(*)
FROM employee
WHERE active=TRUE"""
pd.read_sql_query(s,mydb)


#%%

#employee/admin
#%%

#search movie all filters
s="""SELECT DISTINCT movie.movie_id,title
FROM movie JOIN movie_actor ma ON movie.movie_id=ma.movie_id JOIN actor ON ma.actor_id=actor.actor_id 
JOIN movie_category mc ON movie.movie_id=mc.movie_id JOIN category ON mc.category_id=category.category_id 
WHERE movie.title LIKE '' OR movie.release_year LIKE '2005' OR movie.rental_duration BETWEEN 4.5 AND 5
OR movie.rental_rate BETWEEN 4.5 AND 5 OR movie.length BETWEEN 80 AND 90 OR movie.rating LIKE 'PG%' 
OR actor.first_name LIKE 'Joe' OR actor.last_name LIKE 'Chase' OR category.name='Action' OR category.name='Travel'
ORDER BY movie.rental_rate,movie.release_year desc"""
pd.read_sql_query(s,mydb)

#%%
#add a new movie to the system
s="INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (51,'JOhn  Wick',2006,6,4.99,63,'NC-17',NULL)"
cur.execute(s)
mydb.commit()

#%%
#add a new user
s="INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (609,'56 RICHMOND',94016,NULL)"
cur.execute(s)
mydb.commit()
s="INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (601,'MIA','WATANABE','MIA.WATANaABE@gmail.com',609,'2006-02-14 22:04:37')"
cur.execute(s)
mydb.commit()

#%%
#view rental records based on rental date,return date, buyer id, employee id
s="""SELECT *
FROM rental
WHERE rental_date LIKE '2005-05-24%' AND return_date LIKE '2005-05-%' OR (buyer_id=54 AND employee_id=1)"""
pd.read_sql_query(s,mydb)


#%%

#DVD distributor
# top 5 most popular film category
s="""SELECT c.name Category,COUNT(*) 'No of times rented' 
FROM rental r JOIN  movie_category mc ON r.movie_id=mc.movie_id JOIN category c ON mc.category_id=c.category_id 
GROUP BY mc.category_id
ORDER BY COUNT(*) desc
LIMIT 5"""
pd.read_sql_query(s,mydb)

#%%
#total sale by each movie sorted in decreasing order
s="""SELECT m.title,SUM(m.rental_rate) Revenue
FROM rental r JOIN movie m ON r.movie_id=m.movie_id
GROUP BY r.movie_id
ORDER BY Revenue desc"""
pd.read_sql_query(s,mydb)

#%%
#total sale by each genre in decreasing order
s="""SELECT c.name Genre,SUM(m.rental_rate) Revenue
FROM rental r JOIN movie m ON r.movie_id=m.movie_id JOIN movie_category mc ON m.movie_id=mc.movie_id JOIN category c ON c.category_id=mc.category_id
GROUP BY mc.category_id
ORDER BY Revenue desc"""
cur.execute(s)
result=cur.fetchall() #result contains a list of tuples (every tuple is a row)
for rec in result:
	print(rec)

#%%
#actor having highest viewership/top actor worked in maximum movies
s="""SELECT CONCAT(a.first_name,' ',a.last_name) 'Actor having highest viewership'
FROM rental r JOIN movie m ON r.movie_id=m.movie_id JOIN movie_actor ma ON m.movie_id=ma.movie_id JOIN actor a ON ma.actor_id=a.actor_id
GROUP BY a.actor_id
ORDER BY COUNT(a.actor_id) desc
LIMIT 1"""
pd.read_sql_query(s,mydb)


#%%
#profit made per customer in decreasing order
s="""SELECT b.buyer_id,CONCAT(b.first_name,' ',b.last_name) AS Name, SUM(t.amount) Revenue
FROM rental r JOIN buyer b ON r.buyer_id=b.buyer_id JOIN payment t ON t.rental_id=r.rental_id
GROUP BY r.buyer_id 
ORDER BY Revenue desc"""
cur.execute(s)
result=cur.fetchall() #result contains a list of tuples (every tuple is a row)
for rec in result:
	print(rec)

#%%
#top selling movies of each category
s="""
SELECT it.rm movie_ID,m.title movie_name,it.ctr category_ID,c.name category_name,it.cr num_movie_watched
FROM (
SELECT r.movie_id rm,mc.category_id ctr,COUNT(r.movie_id) cr
FROM rental r JOIN movie_category mc ON r.movie_id=mc.movie_id
GROUP BY r.movie_id
ORDER BY mc.category_id,COUNT(r.movie_id) desc) as it JOIN category c ON it.ctr=c.category_id JOIN movie m ON m.movie_id=rm
GROUP BY it.ctr
ORDER BY it.cr desc"""
pd.read_sql_query(s,mydb)

#%%
#name of actors of most selling movie
s="""SELECT CONCAT(a.first_name,' ',a.last_name) 'Actor Name'
FROM (
SELECT r.movie_id mid,COUNT(*) cmid
FROM rental r 
GROUP BY r.movie_id
ORDER BY COUNT(*) desc
LIMIT 1) AS tb1 JOIN movie m ON m.movie_id=tb1.mid JOIN movie_actor ma ON ma.movie_id=tb1.mid JOIN actor a ON a.actor_id=ma.actor_id JOIN movie_category mc2 ON mc2.movie_id=m.movie_id JOIN category c ON c.category_id=mc2.category_id"""
pd.read_sql_query(s,mydb)

#%%
#name of categories of top 3 most selling movies
s="""SELECT DISTINCT m.title 'movie name',mc2.category_id 'category id',c.name 'category name'
FROM (
SELECT r.movie_id mid,COUNT(*) cmid
FROM rental r 
GROUP BY r.movie_id
ORDER BY COUNT(*) desc
LIMIT 3) AS tb1 JOIN movie m ON m.movie_id=tb1.mid JOIN movie_actor ma ON ma.movie_id=tb1.mid JOIN actor a ON a.actor_id=ma.actor_id JOIN movie_category mc2 ON mc2.movie_id=m.movie_id JOIN category c ON c.category_id=mc2.category_id"""
cur.execute(s)
result=cur.fetchall() #result contains a list of tuples (every tuple is a row)
for rec in result:
	print(rec)