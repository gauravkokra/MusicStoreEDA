# 1. Who is the senior most employee in the organization?
    
	SELECT * 
	FROM employee;

		# Since the table is small we can see the the General Manager is the highest position to which the employees are reporting to.
        # If the list was big:
        
	SELECT * 
	FROM employee
	ORDER BY reports_to;
        
# 2. Which countries have the most invoices?
    
	SELECT billing_country,count(invoice_id) AS No_Of_Invoices
	FROM invoice
	GROUP BY billing_country
	ORDER BY No_Of_Invoices DESC;
        
        # USA has the maximum number of invoices
        
# 3. What are the top 3 values of total invoice?
    
	SELECT * 
	FROM invoice
	ORDER BY total DESC
	LIMIT 3;
        
# 4. The company wants to throw a promotional music festival in the city which made the most money.
#	 Which city has the best customers? 
#	 Write a query that returns one city that has the highest sum of invoice totals. Return both the city name and sum of all invoice totals
        
        # basically we want that city that has generated the maximum sales(total sales)
        
	SELECT billing_city, sum(total) AS Total_Sales 
	FROM invoice
	GROUP BY billing_city
	ORDER BY Total_Sales DESC
	LIMIT 1;
    
# 5. Who is the best customer? The customer who has spent the most money will be declared the best customer
#	 Write a query that returns the person who has spent the most money

	SELECT i.customer_id, sum(total) AS Revenue_Generated 
	FROM invoice i
	INNER JOIN customer c
	ON i.customer_id = c.customer_id
	GROUP BY i.customer_id
	ORDER BY Revenue_Generated DESC;
    
    # Here we are getting the customer ID only. Hence we need to create a join where we can have the whole name of the customer as well. 
    
    SELECT i.customer_id, c.first_name, c.last_name, SUM(total) AS Revenue_Generated 
	FROM invoice i
	INNER JOIN customer c ON i.customer_id = c.customer_id
	GROUP BY i.customer_id 
	ORDER BY Revenue_Generated DESC;
    
    
    # On executing the above query I am getting an error because first_name and last name is a non aggregated column.
    # Error Code: 1055. Expression #1 of SELECT list is not in GROUP BY clause
    # contains nonaggregated column 'musicstore.c.first_name' which is not functionally dependent on columns in GROUP BY clause; 
    # this is incompatible with sql_mode=only_full_group_by

    # The settings can be changed in MySQL by " SET sql_mode = '' " but disabling the same might lead to different result sets in different scenarios. 
    
    SET sql_mode = ''; 
    
    SELECT i.customer_id, c.first_name, c.last_name, SUM(total) AS Revenue_Generated 
	FROM invoice i
	INNER JOIN customer c ON i.customer_id = c.customer_id
	GROUP BY i.customer_id 
	ORDER BY Revenue_Generated DESC
    LIMIT 1;
    
    SET sql_mode=only_full_group_by;
    
    SELECT i.customer_id, c.first_name, c.last_name, SUM(total) AS Revenue_Generated 
	FROM invoice i
	INNER JOIN customer c ON i.customer_id = c.customer_id
	GROUP BY i.customer_id, c.first_name, c.last_name
	ORDER BY Revenue_Generated DESC
    LIMIT 1;
    
    # Therefore, when the SQL mode is set by only full group by and when we set SQL mode  is set without the same, we are getting the same results.
    # it is just that we need to include those non aggregated columns in the group by clause as well
    
# 6. Write a query to return the mail, first name,last name and Genre of all ROCK MUSIC LISTENERS. 
#	 Return your list ordered alphabetically by email starting with A

-- Since this requires more than 2 tables, checking the schema diagram . 

	SELECT c.email, c.first_name, c.last_name 
    FROM customer c
    INNER JOIN invoice i ON c.customer_id = i.customer_id
    INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
    INNER JOIN track t ON il.track_id = t.track_id
    INNER JOIN genre g ON t.genre_id = g.genre_id
    WHERE g.name = 'Rock'
    ORDER BY c.email;
    
    # Second Method is where we are only select the track IDs which have rock genre and only those track IDs will be returned to invoice line table
    
    SELECT c.email,c.first_name,c.last_name
    FROM customer c
    INNER JOIN invoice i ON c.customer_id = i.customer_id
    INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
    WHERE track_id IN (
		SELECT t.track_id 
        FROM track t
        INNER JOIN genre g ON t.genre_id = g.genre_id
		WHERE g.name = 'Rock')
	ORDER BY c.email;
    
# 7. Let us invite the artists who have written the most rock music in our dataset.
#	 Write a query that returns the artist name and the total track count of the top 10 rock bands
		
	-- We want the top 10 ROCK bands so our genre will be rock
    -- We want the artist who wrote the maximum songs therefore, 
    -- the artist who has the maximum number of track ids shall have written the maximum number of songs. 
    
    SELECT * 
    FROM track t
    INNER JOIN genre g ON t.genre_id = g.genre_id
    INNER JOIN album2 al ON t.album_id = al.album_id
    INNER JOIN artist a ON al.artist_id = a.artist_id;
    
    -- We have got all the tracks against their artists. 
    -- Grouping on the basis of artist_id and the count will be done on track ids so that we can get the total number of tracks made by each artist_id
    
    SELECT a.artist_id, a.name, count(t.track_id) AS No_Of_Songs
    FROM track t
    INNER JOIN genre g ON t.genre_id = g.genre_id
    INNER JOIN album2 al ON t.album_id = al.album_id
    INNER JOIN artist a ON al.artist_id = a.artist_id
    WHERE g.name = 'Rock'
    GROUP BY a.artist_id
    ORDER BY No_Of_Songs DESC;
    
    -- Setting SQL mode to nothing as we are getting the group by error as faced previously
    
    SET sql_mode=''; -- now running the above query again
    
# 8. Return all the track names that have a song length longer than the average song length.
#	 Return the name and milliseconds for each track.
#    Order by the song length with the longest songs lister first.

	SELECT name,milliseconds 
    FROM track
    WHERE milliseconds > (
		SELECT avg(milliseconds)
        FROM track
        )
    ORDER BY milliseconds DESC;

# 9. Find how much amount spent by each customer on artists. 
# 	 Write a query to return the customer name, artist anme and total spent

	-- Basically we need to know how much business/revenue has each customer given to each artist
    
    SET sql_mode=only_full_group_by;
    
    SET sql_mode='';
    
    SELECT c.customer_id,c.first_name, a.artist_id, a.name, sum(i.total) AS Business_Given
    FROM invoice i
    INNER JOIN customer c ON i.customer_id = c.customer_id
    INNER JOIN invoice_line il ON il.invoice_id = i.invoice_id
    INNER JOIN track t ON il.track_id = t.track_id
    INNER JOIN album2 al ON t.album_id = al.album_id
    INNER JOIN artist a ON al.artist_id = a.artist_id
    GROUP BY c.customer_id,a.artist_id
    ORDER BY c.customer_id ;
    
    -- Also finding which artist has generated how much money through the music store
    
    

	

# 10. We want to find the most popular music genre for each country. 
# 	  We determine the most popular genre as the genre with the highest amount of purchases
# 	  Write a query that returns each country alongwith the top genre. For countries where the maximum number of purchases is shared return all genres.

	  SELECT i.billing_country, g.name, SUM(i.total) AS Total_Purchased
      FROM invoice i
      INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
      INNER JOIN track t ON il.track_id = t.track_id
      INNER JOIN genre g ON t.genre_id = g.genre_id
      GROUP BY 1,2
      ORDER BY 1,3 DESC;
      
      -- The above query is returning all the genre purchases in decreasing order according to sales.
      -- We want according to number of purchases 
      
      SELECT i.billing_country, g.name, count(il.invoice_line_id) AS Total_Purchased
      FROM invoice i
      INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
      INNER JOIN track t ON il.track_id = t.track_id
      INNER JOIN genre g ON t.genre_id = g.genre_id
      GROUP BY 1,2
      ORDER BY 1,3 DESC;
	  

# 11. Write a query to that determines the customer that has spent the most on music for each country.
#     Write a query that returns the country along with the top customer and how much they spent. 
# 	  For countries where the top amount spent is shared, provide all customers who spent this amount. 
     


    
    