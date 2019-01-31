#Using the chinook database, 
#find out who were the top 3 most purchased artist in CA each year.
#Hint: account for quantity purchased
#TIPs: 
#Identify steps you need to take to answer question 
#Identify the tables and columns you need to to answer each step in (i) above
#Write separate queries to check your work
#Iteratively combine results into one query
#Note: it can be composed of CTEs


##used https://dba.stackexchange.com/questions/84157/how-to-select-top-10-records-from-each-category?rq=1
## create a row counter and then limit on that row counter later on

# get schema
# .schema invoices

#get CA invoices

#SELECT InvoiceId from invoices where BillingState ='CA'

#SELECT TrackId from invoice_items where InvoiceId = (SELECT InvoiceId from invoices where BillingState ='CA')

SELECT
year,
artist,
sum(r) as amt

FROM 
(

SELECT
year,
artist,
SUM(rev) as r,
row_number() over(partition by year order by rev desc) as rn

FROM(
SELECT
year,
artist,
SUM (tot_rev) as rev

FROM
(

SELECT 
DISTINCT (a.Name) as artist,
strftime('%Y',i.invoicedate) as year,
SUM (ii.Quantity) as units,
SUM(ii.Quantity*ii.UnitPrice) as tot_rev
FROM 
artists a
LEFT JOIN albums aa on a.ArtistId=aa.ArtistId
LEFT JOIN tracks t on aa.AlbumId=t.AlbumId
LEFT JOIN invoice_items ii on t.TrackId=ii.TrackId
LEFT JOIN invoices i on ii.InvoiceId=i.InvoiceId
Where
i.BillingState ='CA'
Group By a.Name
)
GROUP BY year, artist 
ORDER BY Year asc, rev desc

)
Group by year, artist
ORDER BY r desc
)
where rn <=3
Group by year, artist
ORDER BY year asc, amt desc


## ok that seems to get what i wanted. now to test the amounts
## 2013 Metallica $5.94

#SELECT 
#DISTINCT (a.Name) as artist,
#i.invoiceId,
#strftime('%Y',i.invoicedate) as year,
#SUM (ii.Quantity) as units,
#SUM(ii.Quantity*ii.UnitPrice) as tot_rev
#FROM 
#artists a
#LEFT JOIN albums aa on a.ArtistId=aa.ArtistId
#LEFT JOIN tracks t on aa.AlbumId=t.AlbumId
#LEFT JOIN invoice_items ii on t.TrackId=ii.TrackId
#LEFT JOIN invoices i on ii.InvoiceId=i.InvoiceId
#Where
#i.BillingState ='CA'
#and
#a.Name='Metallica'
#and strftime('%Y',i.invoicedate) ='2013'
#Group By a.Name,i.invoiceId

# SELECT
#   ...> DISTINCT (a.Name) as artist,
#   ...> i.invoiceId,
#   ...> strftime('%Y',i.invoicedate) as year,
#   ...> SUM (ii.Quantity) as units,
 #  ...> SUM(ii.Quantity*ii.UnitPrice) as tot_rev
 #  ...> FROM
 #  ...> artists a
 #  ...> LEFT JOIN albums aa on a.ArtistId=aa.ArtistId
  # ...> LEFT JOIN tracks t on aa.AlbumId=t.AlbumId
   #...> LEFT JOIN invoice_items ii on t.TrackId=ii.TrackId
   #...> LEFT JOIN invoices i on ii.InvoiceId=i.InvoiceId
 #  ...> Where
 #  ...> i.BillingState ='CA'
 #  ...> and
 #  ...> a.Name='Metallica'
 #  ...> and strftime('%Y',i.invoicedate) ='2013'
 #  ...> Group By a.Name,i.invoiceId;
#Metallica|374|2013|6|5.94

#sqlite> select BillingState from invoices where InvoiceId='374';
#CA
#sqlite> select UnitPrice,Quantity from invoice_items where InvoiceId='374';
#0.99|1
#0.99|1
#0.99|1
#0.99|1
#0.99|1
#0.99|1
