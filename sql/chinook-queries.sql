USE Chinook;

-- 1) Customers not in the US (id, names, country)
SELECT c.CustomerId,
       c.FirstName,
       c.LastName,
       c.Country
FROM Customer c
WHERE c.Country <> 'USA'
ORDER BY c.Country, c.FirstName, c.LastName;

-- 2) Customers from Brazil
SELECT c.CustomerId,
       c.FirstName,
       c.LastName,
       c.Country
FROM Customer c
WHERE c.Country = 'Brazil'
ORDER BY c.FirstName, c.LastName;

-- 3) Invoices of customers from Brazil (names, invoice id/date, billing country)
SELECT c.FirstName,
       c.LastName,
       i.InvoiceId,
       i.InvoiceDate,
       i.BillingCountry
FROM Customer c
JOIN Invoice  i ON i.CustomerId = c.CustomerId
WHERE c.Country = 'Brazil'
ORDER BY i.InvoiceDate, i.InvoiceId;

-- 4) Employees who are Sales Agents
SELECT e.EmployeeId,
       e.FirstName,
       e.LastName,
       e.Title
FROM Employee e
WHERE e.Title = 'Sales Support Agent'
ORDER BY e.FirstName, e.LastName;

-- 5) Distinct billing countries
SELECT DISTINCT BillingCountry
FROM Invoice
ORDER BY BillingCountry;

-- 6) All invoice rows for customers from Brazil
SELECT i.*
FROM Customer c
JOIN Invoice  i ON i.CustomerId = c.CustomerId
WHERE c.Country = 'Brazil'
ORDER BY i.InvoiceDate, i.InvoiceId;

-- 7) Invoices associated with each sales agent (include agent names)
SELECT e.EmployeeId,
       e.FirstName AS AgentFirstName,
       e.LastName  AS AgentLastName,
       i.InvoiceId,
       i.InvoiceDate,
       i.BillingCountry,
       i.Total
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice  i ON i.CustomerId  = c.CustomerId
WHERE e.Title = 'Sales Support Agent'
ORDER BY e.EmployeeId, i.InvoiceDate, i.InvoiceId;

-- 8) Invoice total + customer name/country + sales agent names
SELECT i.Total,
       c.FirstName AS CustomerFirstName,
       c.LastName  AS CustomerLastName,
       c.Country,
       e.FirstName AS AgentFirstName,
       e.LastName  AS AgentLastName
FROM Invoice i
JOIN Customer c ON c.CustomerId = i.CustomerId
LEFT JOIN Employee e ON e.EmployeeId = c.SupportRepId
ORDER BY i.InvoiceDate, i.InvoiceId;

-- 9) Invoices & total sales in 2009 and 2011 (one result table)
SELECT YEAR(i.InvoiceDate)   AS Year,
       COUNT(*)              AS InvoiceCount,
       ROUND(SUM(i.Total),2) AS TotalSales
FROM Invoice i
WHERE YEAR(i.InvoiceDate) IN (2009, 2011)
GROUP BY YEAR(i.InvoiceDate)
ORDER BY Year;

-- 10) # line items for InvoiceId = 37
SELECT COUNT(*) AS LineItemCount
FROM InvoiceLine
WHERE InvoiceId = 37;

-- 11) # line items per invoice
SELECT InvoiceId,
       COUNT(*) AS LineItemCount
FROM InvoiceLine
GROUP BY InvoiceId
ORDER BY InvoiceId;

-- 12) Each invoice line with its track name
SELECT il.InvoiceLineId,
       il.InvoiceId,
       t.Name AS Track
FROM InvoiceLine il
JOIN Track t ON t.TrackId = il.TrackId
ORDER BY il.InvoiceId, il.InvoiceLineId;

-- 13) Each invoice line with track name AND artist name
SELECT il.InvoiceLineId,
       il.InvoiceId,
       t.Name  AS Track,
       ar.Name AS Artist
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId  = il.TrackId
JOIN Album  al ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
ORDER BY il.InvoiceId, il.InvoiceLineId;

-- 14) # of invoices per billing country
SELECT i.BillingCountry,
       COUNT(*) AS InvoiceCount
FROM Invoice i
GROUP BY i.BillingCountry
ORDER BY InvoiceCount DESC, i.BillingCountry;

-- 15) Total tracks in each playlist (include playlist name)
SELECT p.PlaylistId,
       p.Name AS Playlist,
       COUNT(pt.TrackId) AS TrackCount
FROM Playlist p
LEFT JOIN PlaylistTrack pt ON pt.PlaylistId = p.PlaylistId
GROUP BY p.PlaylistId, p.Name
ORDER BY TrackCount DESC, p.Name;

-- 16) All tracks, no ID columns; include Album, MediaType, Genre
SELECT t.Name        AS Track,
       t.Composer,
       t.Milliseconds,
       t.Bytes,
       t.UnitPrice,
       a.Title       AS Album,
       m.Name        AS MediaType,
       g.Name        AS Genre
FROM Track t
JOIN Album    a ON a.AlbumId     = t.AlbumId
JOIN MediaType m ON m.MediaTypeId = t.MediaTypeId
JOIN Genre     g ON g.GenreId     = t.GenreId
ORDER BY Track;

-- 17) All invoices + # of line items
SELECT i.InvoiceId,
       i.CustomerId,
       i.InvoiceDate,
       i.BillingCountry,
       i.Total,
       COUNT(il.InvoiceLineId) AS LineItemCount
FROM Invoice i
LEFT JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
GROUP BY i.InvoiceId, i.CustomerId, i.InvoiceDate, i.BillingCountry, i.Total
ORDER BY i.InvoiceId;

-- 18) Total sales by each sales agent
SELECT e.EmployeeId,
       e.FirstName AS AgentFirstName,
       e.LastName  AS AgentLastName,
       ROUND(SUM(i.Total),2) AS TotalSales
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice  i ON i.CustomerId   = c.CustomerId
WHERE e.Title = 'Sales Support Agent'
GROUP BY e.EmployeeId, AgentFirstName, AgentLastName
ORDER BY TotalSales DESC;

-- 19) Which sales agent made the most sales in 2009?
SELECT s.EmployeeId,
       s.FirstName AS AgentFirstName,
       s.LastName  AS AgentLastName,
       s.TotalSales
FROM (
  SELECT e.EmployeeId, e.FirstName, e.LastName,
         SUM(i.Total) AS TotalSales
  FROM Employee e
  JOIN Customer c ON c.SupportRepId = e.EmployeeId
  JOIN Invoice  i ON i.CustomerId   = c.CustomerId
  WHERE e.Title = 'Sales Support Agent'
    AND YEAR(i.InvoiceDate) = 2009
  GROUP BY e.EmployeeId, e.FirstName, e.LastName
) AS s
ORDER BY s.TotalSales DESC
LIMIT 1;

-- 20) Which sales agent made the most sales in 2010?
SELECT s.EmployeeId,
       s.FirstName AS AgentFirstName,
       s.LastName  AS AgentLastName,
       s.TotalSales
FROM (
  SELECT e.EmployeeId, e.FirstName, e.LastName,
         SUM(i.Total) AS TotalSales
  FROM Employee e
  JOIN Customer c ON c.SupportRepId = e.EmployeeId
  JOIN Invoice  i ON i.CustomerId   = c.CustomerId
  WHERE e.Title = 'Sales Support Agent'
    AND YEAR(i.InvoiceDate) = 2010
  GROUP BY e.EmployeeId, e.FirstName, e.LastName
) AS s
ORDER BY s.TotalSales DESC
LIMIT 1;

-- 21) Which sales agent made the most sales overall?
SELECT s.EmployeeId,
       s.FirstName AS AgentFirstName,
       s.LastName  AS AgentLastName,
       s.TotalSales
FROM (
  SELECT e.EmployeeId, e.FirstName, e.LastName,
         SUM(i.Total) AS TotalSales
  FROM Employee e
  JOIN Customer c ON c.SupportRepId = e.EmployeeId
  JOIN Invoice  i ON i.CustomerId   = c.CustomerId
  WHERE e.Title = 'Sales Support Agent'
  GROUP BY e.EmployeeId, e.FirstName, e.LastName
) AS s
ORDER BY s.TotalSales DESC
LIMIT 1;

-- 22) # of customers assigned to each sales agent
SELECT e.EmployeeId,
       e.FirstName AS AgentFirstName,
       e.LastName  AS AgentLastName,
       COUNT(c.CustomerId) AS CustomerCount
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId
WHERE e.Title = 'Sales Support Agent'
GROUP BY e.EmployeeId, AgentFirstName, AgentLastName
ORDER BY CustomerCount DESC;

-- 23) Total sales per country (highest at top)
SELECT i.BillingCountry,
       ROUND(SUM(i.Total),2) AS TotalSales
FROM Invoice i
GROUP BY i.BillingCountry
ORDER BY TotalSales DESC;

-- 24) Most purchased track of 2013 (by quantity)
SELECT t.TrackId,
       t.Name AS Track,
       SUM(il.Quantity) AS Units
FROM Invoice i
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
JOIN Track t        ON t.TrackId    = il.TrackId
WHERE YEAR(i.InvoiceDate) = 2013
GROUP BY t.TrackId, t.Name
ORDER BY Units DESC
LIMIT 1;

-- 25) Top 5 most purchased tracks overall (by quantity)
SELECT t.TrackId,
       t.Name AS Track,
       ar.Name AS Artist,
       SUM(il.Quantity) AS Units
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId  = il.TrackId
JOIN Album  al ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY t.TrackId, t.Name, ar.Name
ORDER BY Units DESC
LIMIT 5;

-- 26) Top 3 best-selling artists (by total units)
SELECT ar.ArtistId,
       ar.Name AS Artist,
       SUM(il.Quantity) AS Units
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId  = il.TrackId
JOIN Album  al ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY Units DESC
LIMIT 3;

-- 27) Most purchased media type (by total units)
SELECT m.MediaTypeId,
       m.Name AS MediaType,
       SUM(il.Quantity) AS Units
FROM InvoiceLine il
JOIN Track    t ON t.TrackId     = il.TrackId
JOIN MediaType m ON m.MediaTypeId = t.MediaTypeId
GROUP BY m.MediaTypeId, m.Name
ORDER BY Units DESC
LIMIT 1;
