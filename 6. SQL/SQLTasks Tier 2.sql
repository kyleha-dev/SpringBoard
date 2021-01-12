/* 
The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. 
*/


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name
FROM Facilities 
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT Count(name) 
FROM Facilities
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost != 0
    AND membercost < 0.20 * monthlymaintenance 

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * 
FROM Facilities
WHERE facid 
    IN('1',  '5')

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance <= 100 THEN 'Cheap'
     WHEN monthlymaintenance > 100 THEN 'Expensive'
	 END AS label
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM Members
WHERE joindate 
    IN(
        SELECT MAX(joindate) 
        FROM Members
    )
/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT concat(m.firstname, " ", m.surname)AS member,
	f.name AS facility
FROM Members AS m 
	INNER JOIN Bookings AS b
	  ON m.memid = b.memid
	INNER JOIN Facilities AS f
	  ON f.facid = b.facid
WHERE f.facid IN('0', '1')

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT 
  DISTINCT concat(m.firstname," ", m.surname) AS member, 
  f.name, f.membercost, f.guestcost,
  CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
        ELSE f.membercost * b.slots END AS cost 
FROM Members AS m 
INNER JOIN Bookings AS b
ON m.memid = b.memid
INNER JOIN Facilities AS f
ON f.facid = b.facid
WHERE date(b.starttime) = '2012-09-14' 
    AND (CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
              ELSE f.membercost * b.slots END) > 30
Order BY cost desc

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT *
FROM(
  SELECT 
    DISTINCT concat(m.firstname," ", m.surname) AS member, 
    f.name, f.membercost, f.guestcost,
    CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
          ELSE f.membercost * b.slots END AS cost 
  FROM Members AS m 
  INNER JOIN Bookings AS b
  ON m.memid = b.memid
  INNER JOIN Facilities AS f
  ON f.facid = b.facid
  WHERE date(b.starttime) = '2012-09-14') AS a
WHERE a.cost > 30
Order By a.cost desc

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT x.name, Sum(Total_Cost) AS Revenue
FROM (SELECT f.name,
CASE WHEN b.memid = 0 THEN f.guestcost * (b.slots/2)
     WHEN b.memid != 0 THEN f.membercost * (b.slots/2)
	 END AS Total_Cost 
FROM Members m INNER JOIN Bookings b
ON m.memid = b.memid
INNER JOIN Facilities f
ON f.facid = b.facid) x
GROUP BY x.name having Sum(Total_Cost) < 1000

