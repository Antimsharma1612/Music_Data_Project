
use music

--Q1 The senior most employee based on title?

Select first_name+' ' +last_name as [Employee_Name], title , levels From employee$
Where title Like 'Senior%'

--Q2 Which country have the most Invoices?

select top 1 (billing_country) , COUNT(*) as [total_invoices] from invoice$
group by billing_country
order by [total_invoices] desc

--Q3 What are top 3 values of Total Inovices?

select top 3 (billing_country) , count(*) as [total_invoices] from invoice$
group by billing_country 
order by [total_invoices] desc

-- Q4 City wise total money made in Music Festival

select billing_city ,SUM(total) as [Invoices_total] from invoice$
group by billing_city
order by [Invoices_total] desc	

/* Q5 Who is the best cutomer? The customer who has spent the most money
   will be declared the best customer. write a
 query that returns the person who has spent the most money?*/

select top 1(C.customer_id) ,sum(I.total) as Total from customer$ C
join invoice$ I
on C.customer_id = I.customer_id
group by C.customer_id
order by Total desc


 /* Q6 A Query to return the email, first name , last name , & Genre of all Rock Music listners. Return your list 
 ordered alphabetically by email starting with A */

select distinct (C.email) , C.first_name + ' ' + C.last_name as [Customer_Name] , G.name  from customer$ C
join invoice$ I on I.customer_id = C.customer_id
join invoice_line$ IL on IL.invoice_id = I.invoice_id
join track$ T on T.track_id = IL.track_id
join genre$ G on G.genre_id = T.genre_id
where G.name = 'Rock'
and C.email like 'A%'

----Or----

select distinct(C.email), C.first_name, C.last_name  from customer$ C
join invoice$ I on I.customer_id = C.customer_id
join invoice_line$ IL on IL.invoice_id = I.invoice_id
where track_id in ( select T.track_id from track$ T
join genre$ G on G.genre_id = T.genre_id
where G.name = 'Rock') and C.email like 'A%'
order by email

/*Q7 Let's invite the artists who have written the most Rock music in our dataset. 
 total track count of the top 10 rock bands */

select top 10(AR.name) , COUNT(AR.artist_id) as [Number_of_Songs]  , G.name as [Name] From track$ T
join album2$ AL on AL.album_id =T.album_id
join artist$ AR on AR.artist_id = AL.artist_id
join genre$ G on G.genre_id= T.genre_id
where G.name = 'Rock'
group by AR.name , G.name
Order by Number_of_Songs desc


/* Q8 Return all the track names that have a song length longer than the average song lenght. Return the name and miliseconds 
for each track. order by the song length with the longest songs listed first */

select name, milliseconds from track$
where  milliseconds > all(select AVG(milliseconds) as [Avg_milliseconds] from track$)
order by milliseconds desc

/*Q9 How much amount spent by each customer on artists? 
 Write a Query to return customer name, artist name and total spent */

select C.customer_id ,C.first_name , C.last_name , A.name,
SUM(IL.quantity * IL.unit_price) as Total_Amount from customer$ C
join invoice$ I on I.customer_id = C.customer_id
join invoice_line$ IL on IL.invoice_id= I.invoice_id
join track$ T on T.track_id = IL.track_id
join album2$ AL on AL.album_id = T.album_id
join artist$ A on A.artist_id = AL.artist_id
group by C.customer_id,c.first_name,c.last_name,A.name
order by Total_Amount DESC

/* Q10 find out the most popular music genre for each country. 
we determine the most popular genre as the genre with the highest amount of purchases */

With Popular_Genre as (select C.country,G.genre_id,count(IL.quantity) as purchase , 
Rank () over (partition by C.country order by count(IL.quantity)desc) as Row_No from customer$ C
join invoice$ I on I.customer_id = C.customer_id
join invoice_line$ IL on IL.invoice_id = I.invoice_id
join track$ T on T.track_id = IL.track_id 
join album2$ AL on AL.album_id = T.album_id
join artist$ A on A.artist_id = AL.artist_id
join genre$ G on G.genre_id= T.genre_id
group by C.country, G.genre_id )

select * from Popular_Genre 
where Row_No <=1

-- Q11 Catogries customer on the behalf of amount spent on Artist 

select C.customer_id, C.first_name , C.last_name , SUM(IL.quantity * IL.unit_price) as Total_Amount 
,case 
when SUM(IL.quantity * IL.unit_price) > =100  then 'Gold Level'
when SUM(IL.quantity * IL.unit_price) >=50  then 'Silver Level'
else 'Bronze Level'
end as [Level] 
from customer$ C
join invoice$ I on I.customer_id = C.customer_id
join invoice_line$ IL on IL.invoice_id = I.invoice_id
group by C.customer_id, C.first_name, C.last_name
order by Total_Amount desc
