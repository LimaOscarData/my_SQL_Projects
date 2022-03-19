-- #####################################################################################################################

-- ################################ CREATING DATABASEs, TABLEs AND SCHEMAs #############################################

-- #####################################################################################################################

CREATE DATABASE LibDatabase;

USE LibDatabase;

CREATE SCHEMA Book;
CREATE SCHEMA Person;

-- we create PRIMARY KEY, Book_ID INT PRIMARY KEY NOT NULL, inside the column description.
CREATE TABLE Book.Book(
                        Book_ID INT PRIMARY KEY NOT NULL,
                        Book_Name nvarchar(50) NOT NULL,
                        Author_ID INT NOT NULL,
                        Publisher_ID INT NOT NULL
                        )

-- we didn't set the PRIMARY KEY, we describe it ADD CONSTRAINT section.
-- be carefull we didn't set NOT NULL to our PRIMARY KEY, (important point !)
-- it is important we will talk it at ADD CONSTRAINT section.
CREATE TABLE Book.Author(
                        Author_ID INT,
                        Author_FirstName NVARCHAR(50) NOT NULL,
                        Author_LastName NVARCHAR(50) NOT NULL
                        );

CREATE TABLE Book.Publisher(
                            Publisher_ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
                            Publisher_Name NVARCHAR(100) NULL
                            )

CREATE TABLE Person.Person (
                            SSN BIGINT PRIMARY KEY NOT NULL,
                            Person_FirstName NVARCHAR(50) NULL,
                            Person_LastName NVARCHAR(50) NULL
                            )

--  we set PRIMARY KEY(SSN, Book_ID) after we creates columns
CREATE TABLE Person.Loan(
                        SSN BIGINT NOT NULL,
                        Book_ID INT NOT NULL,
                        PRIMARY KEY(SSN, Book_ID)
                        )

CREATE TABLE Person.Person_Phone(
                                Phone_Number BIGINT PRIMARY KEY NOT NULL,
                                SSN BIGINT NOT NULL
                                )

CREATE TABLE Person.Person_Mail(
                                Mail_ID INT PRIMARY KEY IDENTITY(1,1),
                                Mail NVARCHAR(MAX) NOT NULL,
                                SSN BIGINT UNIQUE NOT NULL
                                )


-- #####################################################################################################################

-- ################################ BURDEN SECTION, INSERT VALUEs TO TABLES ############################################

-- #####################################################################################################################

INSERT Person.Person VALUES
                    (75056659595,'Zehra','Tekin'),
                    (78962212466,'Kerem',NULL),
                    (15078893526, 'Mert','Yetis'),
                    (55556698752, 'Esra',NULL),
                    (35532888963,'Ali','Tekin'),
                    (88232556264,'Metin','Sakin')

INSERT Person.Person_Mail VALUES
                        ('zehtek@gmail.com',75056659595),
                        ('meyet@gmail.com', 15078893526),
                        ('metsak@gmail.com', 35532558963)

-- ##############################
-- you can use a created and filled table to make a new table with this way
SELECT * INTO Person.Person_2 FROM Person.Person

-- adding new entries by filtering (using WHERE)
INSERT Person.Person_2
SELECT * FROM Person.Person WHERE Person_FirstName LIKE 'M%'

-- ##############################
-- inserting entry with DEFAULT values
INSERT Book.Publisher
DEFAULT VALUES

-- ##############################
-- UPDATE all columns

UPDATE Person.Person_2 SET Person_FirstName = 'DefaultOOOO'

-- UPDATE all columns by filtering (using WHERE)
UPDATE Person.Person_2 SET Person_FirstName = 'CANN'
WHERE SSN = 78962212466 ; 

-- UPDATE all columns by JOINs (using WHERE)
UPDATE Person.Person_2 SET Person_FirstName = B.Person_FirstName
FROM Person.Person_2 as A 
JOIN person.person as B ON A.SSN = B.SSN 
WHERE B.SSN = 78962212466


UPDATE Person.Person_2 SET Person_LastName = p1.Person_LastName, Person_FirstName = p1.Person_FirstName
FROM Person.person_2 as p2 
JOIN person.person as p1 ON p1.SSN = p2.SSN 
WHERE p1.SSN = p2.SSN

-- If you use IDENTITY, you just need to write one value (because you have two column, you don't need to write auto increment(IDENTITY) column's value)
INSERT Book.Publisher VALUES 
                            ('Is bankasi kultur yayinlari'),
                            ('Can yayincilik'),
                            ('iletisim yayincilik')

-- ##############################
-- DELETE values from a table,(just values not TABLE)

DELETE FROM Book.Publisher

-- lets insert values again by one by
INSERT Book.Publisher VALUES ('iletisim')
INSERT Book.Publisher VALUES ('vooooo')

-- if there is a auto increment option(IDENTITY), it continues from previous incrementation number,
-- if you want to reset numbering to zero, you need to use codes below
USE LibDatabase;
GO
DBCC CHECKIDENT  ('Book.Publisher', RESEED, 0)
GO

-- ##############################
-- DROP a table (with table and also its values)
DROP TABLE Book.Publisher

-- ##############################
-- TRUNCATE a table 
-- Removes all rows from a table
TRUNCATE TABLE Person.Person_mail
TRUNCATE TABLE person.person
TRUNCATE TABLE Book.Publisher

-- IMPORTANT NOTE about the differences between DELETE and TRUNCATE;
-- DELETE:
-- DELETE is a SQL command that removes one or multiple rows from a table using conditions.
-- It is a DML(Data Manipulation Language) command.
-- It does not reset the table identity

-- 	TRUNCATE:
-- TRUNCATE is a SQL command that removes all the rows from a table without using any condition.
-- It is a DDL(Data Definition Language) command.
-- It resets the table identity to its seed value.


-- #####################################################################################################################

-- ################################   ALTER TABLEs   ###################################################################

-- #####################################################################################################################

-- ##############################
-- ADD CONSTRAINT

ALTER TABLE Book.book ADD CONSTRAINT FK_Publisher FOREIGN KEY (Publisher_ID)
REFERENCES book.publisher (Publisher_ID)

-- RESTRICTIONS:
-- If we dont have PK, Initially you must have PK then you can add FK.
-- first we must make column as not null, if it is null we cant add PK 

-- SUMMARY;
-- (1) make column NOT NULL, 
-- (2)add PK  
-- (3)add a FK.

-- EXAMPLES
-- we SET NOT NULL
ALTER TABLE book.author ALTER COLUMN Author_ID INT NOT NULL
-- we set PK
ALTER TABLE Book.Author ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)
-- we add a FK
ALTER TABLE Book.Book ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID)
REFERENCES Book.Author (Author_ID)

-- adding a value seperation with ADD CONSTRAINT
ALTER TABLE person.person ADD CONSTRAINT fk_personelID_check
CHECK (SSN between 9999999999 and 99999999999)

