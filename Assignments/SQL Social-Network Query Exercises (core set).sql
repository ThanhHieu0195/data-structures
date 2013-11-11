/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);



-- Question 1
-- Find the names of all students who are friends with someone named Gabriel. 
select name from Highschooler
where id in (
  select ID1 from friend where id1 = id and
  id2 IN (select id from Highschooler where name="Gabriel")
)


-- Question 2
-- For every student who likes someone 2 or more grades younger than themselves, 
-- return that student's name and grade, and the name and grade of the student they like. 
select h1.name, h1.grade, h2.name, h2.grade
from highschooler as h1
join likes as l on l.id1 = h1.id
join highschooler as h2 on h2.id = l.id2
where h2.grade <= h1.grade - 2


-- Question 3
-- For every pair of students who both like each other, return the name and grade of both students. 
-- Include each pair only once, with the two names in alphabetical order.
select n2, g2, n1, g1 from
( select h1.id+h2.id as mult, h1.name as n1, h1.grade as g1, h2.name as n2, h2.grade as g2
  from likes as l
  join highschooler as h1 on h1.id = l.id1
  join highschooler as h2 on h2.id = l.id2
  where exists (select * from likes where id1=h2.id and id2=h1.id)
  order by  mult asc , h1.name < h2.name desc
) as t
group by mult


-- Question 4
-- Find all students who do not appear in the Likes table (as a student who likes or is liked) 
-- and return their names and grades. Sort by grade, then by name within each grade.
select name, grade from highschooler where id not in (select id1 from likes union select id2 from likes)


-- Question 5
-- For every situation where student A likes student B, but we have no information about whom B likes 
-- (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 
select h1.name, h1.grade, h2.name, h2.grade from
likes L join highschooler H1 on l.id1=h1.id
join highschooler H2 on l.id2=h2.id
where not exists (select 1 from friend F where (F.id1=L.id1 and f.id2=L.id2) or (F.id2=L.id1 and f.id1=L.id2))


-- Question 6
-- Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 
select  h1.name, h1.grade
from highschooler as h1
join friend as f on f.id1=h1.id
join highschooler as h2 on h2.id = f.id2
where h1.grade=h2.grade
and not exists (select id from highschooler where id in (
  select id2 from friend where id1=h1.id) and grade <> h1.grade)
group by h1.name
order by h1.grade, h1.name


-- Question 7
-- For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!).
-- For all such trios, return the name and grade of A, B, and C. 
select h1.name, h1.grade, h2.name, h2.grade from
likes L join highschooler H1 on l.id1=h1.id
join highschooler H2 on l.id2=h2.id
where not exists (select 1 from friend F where (F.id1=L.id1 and f.id2=L.id2) or (F.id2=L.id1 and f.id1=L.id2))


-- Question 8
-- Find the difference between the number of students in the school and the number of different first names. 
select (select count(id) from Highschooler)-(select count(distinct name) from Highschooler)


-- Question 9
-- Find the name and grade of all students who are liked by more than one other student. 
select name, grade from highschooler
where id in (
select id2
from likes
group by id2
having count(id1) > 1
)
