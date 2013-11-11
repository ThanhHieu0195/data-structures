/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');



-- Question 1
-- Find the titles of all movies directed by Steven Spielberg. 
-- Note: Your queries are executed using SQLite, so you must conform to the SQL constructs supported by SQLite.
select title
from Movie
where director = 'Steven Spielberg';

-- Question 2
-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
select year
from Movie
where mID in (select mID from Rating where stars=4 or stars=5)
order by year ASC;

-- Question 3
-- Find the titles of all movies that have no ratings. 
select title
from Movie
where mID not in (select mID from Rating);

-- Question 4
-- Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
select name
from Reviewer
where rID in (select rID from Rating where ratingDate is NULL);

-- Question 5
-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, 
-- and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
select distinct name, title, stars, ratingDate
from Reviewer natural join Movie natural join Rating
order by name, title, stars

-- Question 6
-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
select name, title from Reviewer, Movie, Rating, Rating r2
where Rating.mID=Movie.mID and Reviewer.rID=Rating.rID 
  and Rating.rID = r2.rID and r2.mID = Movie.mID
  and Rating.stars < r2.stars and Rating.ratingDate < r2.ratingDate;

-- Question 7
-- For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
select title, max(stars)
from Movie, Rating
where Movie.mID = Rating.mID
group by Rating.mID
order by title;

-- Question 8
-- For each movie, return the title and the 'rating spread', that is, the difference between highest and 
-- lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
select M.title, MAX(stars) - MIN(stars) as Diff
from Movie as M, Rating as R
where M.mID = R.mID
group by M.title
order by Diff DESC;

-- Question 9
-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
-- (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
-- Don't just calculate the overall average rating before and after 1980.) 
select max(a1)-min(a1) from
(select avg(av1) a1 from
(select avg(stars) av1 from rating r join movie m on r.mid=m.mid where m.year < 1980
group by r.mid)
union
select avg(av2) a1 from
(select avg(stars) av2 from rating r join movie m on r.mid=m.mid where m.year > 1980
group by r.mid))

-- Q1: Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into Reviewer
values(209, 'Roger Ebert');

-- Q2: Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL.
insert into Rating
select Reviewer.rID, Movie.mID, 5, null from Reviewer, Movie
where Reviewer.name = 'James Cameron';

-- Q3: For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)
update Movie set year=year+25
where Movie.mID in (select Rating.mID from Rating
                                   group by Rating.mID
                               having avg(stars)>=4);

-- Q4: Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
delete 
from Rating
where mID in (select Movie.mID from Movie where year < 1970 or year > 2000)
           and stars < 4;





















