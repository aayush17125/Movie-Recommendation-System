 drop database project;
 create database project;
use project;

CREATE TABLE actor (
  actor_id INTEGER AUTO_INCREMENT NOT NULL,
  first_name varchar(45) NOT NULL,
  last_name varchar(45) NOT NULL,
  PRIMARY KEY (actor_id) 
  );
CREATE TABLE addr (
  addr_id int AUTO_INCREMENT NOT NULL,
  address varchar(150) NOT NULL,
  postal_code varchar(10) DEFAULT NULL,
  phone varchar(20) ,
  PRIMARY KEY  (addr_id)
);

CREATE TABLE category (
  category_id int NOT NULL,
  name varchar(25) NOT NULL,
  PRIMARY KEY  (category_id)
);

CREATE TABLE buyer (
  buyer_id int AUTO_INCREMENT NOT NULL,
  first_name varchar(45) NOT NULL,
  last_name varchar(45) NOT NULL,
  email varchar(50) DEFAULT NULL,
  addr_id int NOT NULL,
  create_date TIMESTAMP NOT NULL,
  PRIMARY KEY  (buyer_id),
  UNIQUE KEY unique_email (email),
  CONSTRAINT fk_buyer_address FOREIGN KEY (addr_id) REFERENCES addr(addr_id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE movie (
  movie_id int AUTO_INCREMENT NOT NULL,
  title varchar(255) NOT NULL,
  release_year varchar(4) DEFAULT NULL,
  rental_duration int  DEFAULT 3 NOT NULL,
  rental_rate DECIMAL(6,2) DEFAULT 4.99 NOT NULL,
  length int DEFAULT NULL,
  rating varchar(10) DEFAULT 'G',
  last_update TIMESTAMP,
  PRIMARY KEY  (movie_id),
  CONSTRAINT CHECK_special_rating CHECK(rating in ('G','PG','PG-13','R','NC-17'))
);

CREATE TABLE movie_actor (
  actor_id int NOT NULL,
  movie_id  int NOT NULL,
  PRIMARY KEY  (actor_id,movie_id),
  CONSTRAINT fk_movie_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT fk_movie_actor_movie FOREIGN KEY (movie_id) REFERENCES movie (movie_id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE movie_category (
  movie_id int NOT NULL,
  category_id int  NOT NULL,
  PRIMARY KEY (movie_id, category_id),
  CONSTRAINT fk_movie_category_movie FOREIGN KEY (movie_id) REFERENCES movie (movie_id) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT fk_movie_category_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE employee (
  employee_id int AUTO_INCREMENT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  addr_id INT NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  active boolean NOT NULL,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(500) DEFAULT NULL,
  PRIMARY KEY  (employee_id),
  CONSTRAINT fk_employee_address FOREIGN KEY (addr_id) REFERENCES addr (addr_id) ON DELETE NO ACTION ON UPDATE CASCADE
);



CREATE TABLE rental (
  rental_id INT AUTO_INCREMENT NOT NULL,
  rental_date TIMESTAMP NOT NULL,
  buyer_id INT  NOT NULL,
  return_date TIMESTAMP DEFAULT NULL,
  employee_id int  NOT NULL,
  movie_id INT  NOT NULL,
  PRIMARY KEY (rental_id),
  CONSTRAINT fk_rental_employee FOREIGN KEY (employee_id) REFERENCES employee (employee_id) ,
  CONSTRAINT fk_rental_movie FOREIGN KEY (movie_id) REFERENCES movie (movie_id) ,
  CONSTRAINT fk_rental_buyer FOREIGN KEY (buyer_id) REFERENCES buyer (buyer_id)
);

CREATE TABLE investor (
  investor_id int NOT NULL auto_increment,
  first_name varchar(45) NOT NULL,
  initial_investment int not null,
  last_name varchar(45) NOT NULL,
  email varchar(50) DEFAULT NULL,
  password varchar(500) not null,
  addr_id int NOT NULL,
  create_date TIMESTAMP NOT NULL,
  PRIMARY KEY  (investor_id),
  UNIQUE KEY unique_email (email),
  CONSTRAINT fk_investor_address FOREIGN KEY (addr_id) REFERENCES addr(addr_id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE investment (
  investment_id int NOT NULL auto_increment,
  investor_id int  NOT NULL,
  amount DECIMAL(50,2) NOT NULL,
  payment_date TIMESTAMP NOT NULL,
  PRIMARY KEY  (investment_id),
  CONSTRAINT fk_payment_investor FOREIGN KEY (investor_id) REFERENCES investor (investor_id) 
);

CREATE TABLE payment (
  payment_id int AUTO_INCREMENT NOT NULL,
  buyer_id int  NOT NULL,
  employee_id int NOT NULL,
  rental_id int DEFAULT NULL,
  amount DECIMAL(6,2) NOT NULL,
  payment_date TIMESTAMP NOT NULL,
  PRIMARY KEY  (payment_id),
  CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_payment_buyer FOREIGN KEY (buyer_id) REFERENCES buyer (buyer_id) ,
  CONSTRAINT fk_payment_employee FOREIGN KEY (employee_id) REFERENCES employee (employee_id)
);

-- INDEX
CREATE INDEX idx_actor_last_name ON actor(last_name)
;
CREATE INDEX idx_buyer_fk_address_id ON buyer(addr_id)
;
CREATE INDEX idx_buyer_last_name ON buyer(last_name)
;
CREATE INDEX idx_fk_buyer_id ON payment(buyer_id)
;
CREATE INDEX idx_fk_movie_actor_actor ON movie_actor(actor_id) 
;
CREATE INDEX idx_fk_movie_actor_movie ON movie_actor(movie_id)
;
CREATE INDEX idx_fk_movie_category_category ON movie_category(category_id)
;
CREATE INDEX idx_fk_movie_category_movie ON movie_category(movie_id)
;
CREATE INDEX idx_fk_movie_id ON movie(movie_id)
;
CREATE INDEX idx_fk_employee_address_id ON employee(addr_id)
;
CREATE INDEX idx_fk_employee_id ON payment(employee_id)
;
CREATE INDEX idx_rental_fk_buyer_id ON rental(buyer_id)
;
CREATE INDEX idx_rental_fk_movie_id ON rental(movie_id)
;
CREATE INDEX idx_rental_fk_employee_id ON rental(employee_id)
;
CREATE UNIQUE INDEX idx_rental_uq  ON rental (rental_date,movie_id,buyer_id)
;



-- -- TRIGGERs
DELIMITER ;;
 CREATE TRIGGER buyer_trigger_ai
 BEFORE INSERT ON buyer FOR EACH ROW
 BEGIN
  -- UPDATE buyer 
  SET NEW.create_date = NOW();
  END;;
  

CREATE TRIGGER movie_trigger_ai BEFORE INSERT ON movie for each row
 BEGIN
 SET NEW.last_update = NOW();
END;;
--  
CREATE TRIGGER movie_trigger_au BEFORE UPDATE ON movie for each row
  BEGIN
   SET NEW.last_update = NOW(); 
  END;;


CREATE TRIGGER payment_trigger_ai BEFORE INSERT ON payment for each row
  BEGIN
    SET NEW.payment_date = NOW();
  END;;
--  
CREATE TRIGGER payment_trigger_au BEFORE UPDATE ON payment  for each row
  BEGIN
   SET NEW.payment_date = NOW();
  END;;

DELIMITER ;

 
-- VIEWS
CREATE VIEW buyer_list
AS
SELECT cu.buyer_id AS ID,
      CONCAT(cu.first_name,' ',cu.last_name) AS name,
       a.address AS addr,
       a.postal_code AS zip_code,
       a.phone AS phone
      
FROM buyer AS cu JOIN addr AS a ON cu.addr_id = a.addr_id;


CREATE VIEW movie_list
AS
SELECT movie.movie_id AS FID,
       movie.title AS title,
       category.name AS category,
       movie.rental_rate AS price,
       movie.length AS length,
       movie.rating AS rating,
       CONCAT (actor.first_name,' ',actor.last_name) AS actors
FROM category LEFT JOIN movie_category ON category.category_id = movie_category.category_id LEFT JOIN movie ON ((movie_category.movie_id = movie.movie_id))
        JOIN movie_actor ON ((movie.movie_id = movie_actor.movie_id))
    JOIN actor ON ((movie_actor.actor_id = actor.actor_id)) group by movie.movie_id,category.name;

create table admin_pass(
	passwd varchar(500)
);
insert into admin_pass values("21232f297a57a5a743894a0e4a801fc3");




use project;
INSERT INTO actor(actor_id,first_name,last_name) VALUES (1,'Penelope','Guiness');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (2,'Nick','Wahlberg');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (3,'Ed','Chase');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (4,'Jennifer','Davis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (5,'Johnny','Lollobrigida');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (6,'Bette','Nicholson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (7,'Grace','Mostel');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (8,'Matthew','Johansson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (9,'Joe','Swank');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (10,'Christian','Gable');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (11,'Zero','Cage');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (12,'Karl','Berry');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (13,'Uma','Wood');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (14,'Vivien','Bergen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (15,'Cuba','Olivier');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (16,'Fred','Costner');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (17,'Helen','Voight');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (18,'Dan','Torn');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (19,'Bob','Fawcett');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (20,'Lucille','Tracy');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (21,'Kirsten','Paltrow');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (22,'Elvis','Marx');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (23,'Sandra','Kilmer');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (24,'Cameron','Streep');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (25,'Kevin','Bloom');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (26,'Rip','Crawford');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (27,'Julia','Mcqueen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (28,'Woody','Hoffman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (29,'Alec','Wayne');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (30,'Sandra','Peck');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (31,'Sissy','Sobieski');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (32,'Tim','Hackman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (33,'Milla','Peck');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (34,'Audrey','Olivier');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (35,'Judy','Dean');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (36,'Burt','Dukakis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (37,'Val','Bolger');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (38,'Tom','Mckellen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (39,'Goldie','Brody');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (40,'Johnny','Cage');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (41,'Jodie','Degeneres');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (42,'Tom','Miranda');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (43,'Kirk','Jovovich');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (44,'Nick','Stallone');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (45,'Reese','Kilmer');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (46,'Parker','Goldberg');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (47,'Julia','Barrymore');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (48,'Frances','Day-Lewis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (49,'Anne','Cronyn');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (50,'Natalie','Hopkins');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (51,'Gary','Phoenix');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (52,'Carmen','Hunt');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (53,'Mena','Temple');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (54,'Penelope','Pinkett');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (55,'Fay','Kilmer');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (56,'Dan','Harris');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (57,'Jude','Cruise');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (58,'Christian','Akroyd');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (59,'Dustin','Tautou');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (60,'Henry','Berry');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (61,'Christian','Neeson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (62,'Jayne','Neeson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (63,'Cameron','Wray');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (64,'Ray','Johansson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (65,'Angela','Hudson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (66,'Mary','Tandy');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (67,'Jessica','Bailey');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (68,'Rip','Winslet');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (69,'Kenneth','Paltrow');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (70,'Michelle','Mcconaughey');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (71,'Adam','Grant');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (72,'Sean','Williams');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (73,'Gary','Penn');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (74,'Milla','Keitel');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (75,'Burt','Posey');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (76,'Angelina','Astaire');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (77,'Cary','Mcconaughey');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (78,'Groucho','Sinatra');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (79,'Mae','Hoffman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (80,'Ralph','Cruz');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (81,'Scarlett','Damon');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (82,'Woody','Jolie');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (83,'Ben','Willis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (84,'James','Pitt');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (85,'Minnie','Zellweger');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (143,'River','Dean');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (86,'Greg','Chaplin');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (87,'Spencer','Peck');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (88,'Kenneth','Pesci');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (89,'Charlize','Dench');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (90,'Sean','Guiness');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (91,'Christopher','Berry');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (92,'Kirsten','Akroyd');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (93,'Ellen','Presley');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (94,'Kenneth','Torn');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (95,'Daryl','Wahlberg');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (96,'Gene','Willis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (97,'Meg','Hawke');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (98,'Chris','Bridges');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (99,'Jim','Mostel');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (100,'Spencer','Depp');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (101,'Susan','Davis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (102,'Walter','Torn');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (103,'Matthew','Leigh');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (104,'Penelope','Cronyn');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (105,'Sidney','Crowe');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (106,'Groucho','Dunst');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (107,'Gina','Degeneres');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (108,'Warren','Nolte');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (109,'Sylvester','Dern');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (110,'Susan','Davis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (111,'Cameron','Zellweger');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (112,'Russell','Bacall');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (113,'Morgan','Hopkins');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (114,'Morgan','Mcdormand');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (115,'Harrison','Bale');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (116,'Dan','Streep');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (117,'Renee','Tracy');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (118,'Cuba','Allen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (119,'Warren','Jackman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (120,'Penelope','Monroe');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (121,'Liza','Bergman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (122,'Salma','Nolte');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (123,'Julianne','Dench');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (124,'Scarlett','Bening');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (125,'Albert','Nolte');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (126,'Frances','Tomei');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (127,'Kevin','Garland');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (128,'Cate','Mcqueen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (129,'Daryl','Crawford');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (130,'Greta','Keitel');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (131,'Jane','Jackman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (132,'Adam','Hopper');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (133,'Richard','Penn');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (134,'Gene','Hopkins');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (135,'Rita','Reynolds');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (136,'Ed','Mansfield');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (137,'Morgan','Williams');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (138,'Lucille','Dee');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (139,'Ewan','Gooding');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (140,'Whoopi','Hurt');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (141,'Cate','Harris');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (142,'Jada','Ryder');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (144,'Angela','Witherspoon');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (145,'Kim','Allen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (146,'Albert','Johansson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (147,'Fay','Winslet');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (148,'Emily','Dee');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (149,'Russell','Temple');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (150,'Jayne','Nolte');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (151,'Geoffrey','Heston');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (152,'Ben','Harris');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (153,'Minnie','Kilmer');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (154,'Meryl','Gibson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (155,'Ian','Tandy');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (156,'Fay','Wood');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (157,'Greta','Malden');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (158,'Vivien','Basinger');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (159,'Laura','Brody');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (160,'Chris','Depp');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (161,'Harvey','Hope');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (162,'Oprah','Kilmer');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (163,'Christopher','West');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (164,'Humphrey','Willis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (165,'Al','Garland');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (166,'Nick','Degeneres');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (167,'Laurence','Bullock');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (168,'Will','Wilson');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (169,'Kenneth','Hoffman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (170,'Mena','Hopper');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (171,'Olympia','Pfeiffer');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (172,'Groucho','Williams');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (173,'Alan','Dreyfuss');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (174,'Michael','Bening');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (175,'William','Hackman');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (176,'Jon','Chase');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (177,'Gene','Mckellen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (178,'Lisa','Monroe');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (179,'Ed','Guiness');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (180,'Jeff','Silverstone');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (181,'Matthew','Carrey');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (182,'Debbie','Akroyd');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (183,'Russell','Close');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (184,'Humphrey','Garland');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (185,'Michael','Bolger');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (186,'Julia','Zellweger');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (187,'Renee','Ball');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (188,'Rock','Dukakis');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (189,'Cuba','Birch');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (190,'Audrey','Bailey');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (191,'Gregory','Gooding');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (192,'John','Suvari');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (193,'Burt','Temple');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (194,'Meryl','Allen');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (195,'Jayne','Silverstone');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (196,'Bela','Walken');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (197,'Reese','West');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (198,'Mary','Keitel');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (199,'Julia','Fawcett');
INSERT INTO actor(actor_id,first_name,last_name) VALUES (200,'Thora','Temple');


INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (5,'Baked Cleopatra',2006,3,2.99,182,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (6,'Beast Hunchback',2006,3,4.99,89,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (9,'Boulevard Mob',2006,3,0.99,63,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (12,'Caribbean Liberty',2006,3,4.99,92,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (21,'Darko Dorado',2006,3,4.99,130,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (26,'Dude Blindness',2006,3,4.99,132,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (35,'Garden Island',2006,3,4.99,80,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (46,'Innocent Usual',2006,3,4.99,178,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (48,'Jeepers Wedding',2006,3,2.99,84,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (2,'Amelie Hellfighters',2006,4,4.99,79,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (3,'Anything Savannah',2006,4,2.99,82,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (4,'Army Flintstones',2006,4,0.99,148,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (11,'Cabin Flash',2006,4,0.99,53,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (16,'Club Graffiti',2006,4,0.99,65,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (18,'Conspiracy Spirit',2006,4,2.99,184,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (25,'Dragon Squad',2006,4,0.99,170,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (29,'Everyone Craft',2006,4,0.99,163,'PG',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (32,'Flamingos Connecticut',2006,4,4.99,80,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (36,'Glass Dying',2006,4,0.99,103,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (37,'Gorgeous Bingo',2006,4,2.99,108,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (39,'Guys Falcon',2006,4,4.99,84,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (47,'Ishtar Rocketeer',2006,4,4.99,79,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (49,'Jumanji Blade',2006,4,2.99,121,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (17,'Command Darling',2006,5,4.99,120,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (19,'Creepers Kane',2006,5,4.99,172,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (30,'Falcon Volume',2006,5,4.99,102,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (31,'Fever Empire',2006,5,4.99,158,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (45,'Idols Snatchers',2006,5,2.99,84,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (50,'Kiss Glory',2006,5,4.99,163,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (1,'Aladdin Calendar',2006,6,4.99,63,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (14,'Cheaper Clyde',2006,6,0.99,87,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (34,'Frontier Cabin',2006,6,4.99,183,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (44,'Hunger Roof',2006,6,0.99,105,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (7,'Bikini Borrowers',2006,7,4.99,142,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (8,'Blanket Beverly',2006,7,2.99,148,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (10,'Brooklyn Desert',2006,7,4.99,161,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (13,'Celebrity Horn',2006,7,0.99,110,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (15,'Cider Desire',2006,7,2.99,101,'PG',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (20,'Curtain Videotape',2006,7,0.99,133,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (22,'Deer Virginian',2006,7,2.99,106,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (23,'Diary Panic',2006,7,2.99,107,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (24,'Dolls Rage',2006,7,2.99,120,'PG-13',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (27,'Earth Vision',2006,7,0.99,85,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (28,'Empire Malkovich',2006,7,0.99,177,'G',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (33,'Forrester Comancheros',2006,7,4.99,112,'NC-17',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (38,'Greek Everyone',2006,7,2.99,176,'PG',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (40,'Hardly Robbers',2006,7,2.99,72,'R',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (41,'Heaven Freedom',2006,7,2.99,48,'PG',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (42,'Holes Brannigan',2006,7,4.99,128,'PG',NULL);
INSERT INTO movie(movie_id,title,release_year,rental_duration,rental_rate,length,rating,last_update) VALUES (43,'Hook Chariots',2006,7,0.99,49,'G',NULL);


INSERT INTO category(category_id,name) VALUES (1,'Action');
INSERT INTO category(category_id,name) VALUES (2,'Animation');
INSERT INTO category(category_id,name) VALUES (3,'Children');
INSERT INTO category(category_id,name) VALUES (4,'Classics');
INSERT INTO category(category_id,name) VALUES (5,'Comedy');
INSERT INTO category(category_id,name) VALUES (6,'Documentary');
INSERT INTO category(category_id,name) VALUES (7,'Drama');
INSERT INTO category(category_id,name) VALUES (8,'Family');
INSERT INTO category(category_id,name) VALUES (9,'Foreign');
INSERT INTO category(category_id,name) VALUES (10,'Games');
INSERT INTO category(category_id,name) VALUES (11,'Horror');
INSERT INTO category(category_id,name) VALUES (12,'Music');
INSERT INTO category(category_id,name) VALUES (13,'New');
INSERT INTO category(category_id,name) VALUES (14,'Sci-Fi');
INSERT INTO category(category_id,name) VALUES (15,'Sports');
INSERT INTO category(category_id,name) VALUES (16,'Travel');


INSERT INTO movie_category(movie_id,category_id) VALUES (1,15);
INSERT INTO movie_category(movie_id,category_id) VALUES (2,12);
INSERT INTO movie_category(movie_id,category_id) VALUES (3,11);
INSERT INTO movie_category(movie_id,category_id) VALUES (4,6);
INSERT INTO movie_category(movie_id,category_id) VALUES (5,8);
INSERT INTO movie_category(movie_id,category_id) VALUES (6,4);
INSERT INTO movie_category(movie_id,category_id) VALUES (7,2);
INSERT INTO movie_category(movie_id,category_id) VALUES (8,8);
INSERT INTO movie_category(movie_id,category_id) VALUES (9,13);
INSERT INTO movie_category(movie_id,category_id) VALUES (10,9);
INSERT INTO movie_category(movie_id,category_id) VALUES (11,3);
INSERT INTO movie_category(movie_id,category_id) VALUES (12,15);
INSERT INTO movie_category(movie_id,category_id) VALUES (13,1);
INSERT INTO movie_category(movie_id,category_id) VALUES (14,14);
INSERT INTO movie_category(movie_id,category_id) VALUES (15,6);
INSERT INTO movie_category(movie_id,category_id) VALUES (16,2);
INSERT INTO movie_category(movie_id,category_id) VALUES (17,9);
INSERT INTO movie_category(movie_id,category_id) VALUES (18,4);
INSERT INTO movie_category(movie_id,category_id) VALUES (19,4);
INSERT INTO movie_category(movie_id,category_id) VALUES (20,10);
INSERT INTO movie_category(movie_id,category_id) VALUES (21,1);
INSERT INTO movie_category(movie_id,category_id) VALUES (22,12);
INSERT INTO movie_category(movie_id,category_id) VALUES (23,7);
INSERT INTO movie_category(movie_id,category_id) VALUES (24,14);
INSERT INTO movie_category(movie_id,category_id) VALUES (25,1);
INSERT INTO movie_category(movie_id,category_id) VALUES (26,15);
INSERT INTO movie_category(movie_id,category_id) VALUES (27,13);
INSERT INTO movie_category(movie_id,category_id) VALUES (28,3);
INSERT INTO movie_category(movie_id,category_id) VALUES (29,9);
INSERT INTO movie_category(movie_id,category_id) VALUES (30,2);
INSERT INTO movie_category(movie_id,category_id) VALUES (31,10);
INSERT INTO movie_category(movie_id,category_id) VALUES (32,13);
INSERT INTO movie_category(movie_id,category_id) VALUES (33,2);
INSERT INTO movie_category(movie_id,category_id) VALUES (34,13);
INSERT INTO movie_category(movie_id,category_id) VALUES (35,14);
INSERT INTO movie_category(movie_id,category_id) VALUES (36,1);
INSERT INTO movie_category(movie_id,category_id) VALUES (37,3);
INSERT INTO movie_category(movie_id,category_id) VALUES (38,9);
INSERT INTO movie_category(movie_id,category_id) VALUES (39,14);
INSERT INTO movie_category(movie_id,category_id) VALUES (40,6);
INSERT INTO movie_category(movie_id,category_id) VALUES (41,5);
INSERT INTO movie_category(movie_id,category_id) VALUES (42,15);
INSERT INTO movie_category(movie_id,category_id) VALUES (43,2);
INSERT INTO movie_category(movie_id,category_id) VALUES (44,9);
INSERT INTO movie_category(movie_id,category_id) VALUES (45,3);
INSERT INTO movie_category(movie_id,category_id) VALUES (46,9);
INSERT INTO movie_category(movie_id,category_id) VALUES (47,2);
INSERT INTO movie_category(movie_id,category_id) VALUES (48,4);
INSERT INTO movie_category(movie_id,category_id) VALUES (49,13);
INSERT INTO movie_category(movie_id,category_id) VALUES (50,9);


INSERT INTO movie_actor(actor_id,movie_id) VALUES (29,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (35,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (37,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (64,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (117,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (142,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (157,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (188,1);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (52,2);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (102,2);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (136,2);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (139,2);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (155,2);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (159,2);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (9,3);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (163,3);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (178,3);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (3,4);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (77,4);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (79,4);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (96,4);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (104,4);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (181,4);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (183,4);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (70,5);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (6,6);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (41,6);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (76,6);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (94,6);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (101,6);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (6,7);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (104,7);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (16,8);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (173,8);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (193,8);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (200,8);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (26,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (34,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (92,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (114,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (116,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (139,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (144,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (161,9);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (41,10);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (62,10);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (90,10);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (125,10);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (172,10);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (13,11);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (29,11);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (83,11);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (187,11);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (83,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (93,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (98,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (110,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (131,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (145,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (161,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (167,12);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (59,13);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (103,13);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (144,13);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (195,13);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (1,14);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (20,14);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (27,15);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (41,15);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (48,15);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (54,15);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (176,15);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (38,16);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (137,16);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (178,16);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (182,16);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (7,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (75,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (88,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (121,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (135,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (139,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (151,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (154,17);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (43,18);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (153,18);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (163,18);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (170,18);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (91,19);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (109,19);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (117,19);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (124,19);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (150,19);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (175,19);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (9,20);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (102,20);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (139,20);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (59,21);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (114,21);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (133,21);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (157,21);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (107,22);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (121,22);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (155,22);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (41,23);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (66,23);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (79,23);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (129,23);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (77,24);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (49,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (87,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (99,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (100,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (101,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (125,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (134,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (179,25);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (30,26);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (37,26);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (78,26);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (80,26);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (81,26);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (124,26);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (144,26);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (94,27);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (133,27);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (150,27);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (15,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (16,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (17,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (18,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (64,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (80,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (93,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (105,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (133,28);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (39,29);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (70,29);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (82,29);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (84,29);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (85,29);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (66,30);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (69,30);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (122,30);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (136,30);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (17,31);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (147,31);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (190,31);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (39,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (42,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (55,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (94,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (96,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (131,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (135,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (146,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (176,32);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (43,33);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (45,33);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (90,33);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (5,34);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (26,34);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (55,34);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (57,34);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (83,34);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (161,34);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (66,35);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (108,35);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (142,35);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (103,36);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (110,36);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (165,36);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (185,36);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (14,37);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (23,37);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (97,37);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (126,37);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (140,37);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (151,37);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (197,37);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (31,38);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (36,38);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (68,38);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (141,38);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (26,39);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (36,39);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (133,39);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (137,39);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (183,39);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (12,40);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (49,40);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (157,40);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (36,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (43,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (89,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (132,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (133,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (137,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (146,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (147,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (162,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (191,41);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (12,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (25,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (44,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (50,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (51,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (95,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (114,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (116,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (136,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (181,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (191,42);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (22,43);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (79,43);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (96,43);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (107,43);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (154,44);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (38,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (71,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (72,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (112,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (125,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (131,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (171,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (198,45);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (18,46);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (58,46);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (84,46);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (92,47);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (122,47);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (142,47);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (192,47);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (3,48);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (10,48);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (82,48);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (91,48);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (123,48);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (153,48);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (4,49);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (19,49);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (44,49);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (51,49);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (53,49);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (99,49);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (15,50);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (17,50);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (27,50);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (42,50);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (106,50);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (162,50);
INSERT INTO movie_actor(actor_id,movie_id) VALUES (184,50);



INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (1,'47 Hot Drive',5444,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (2,'28 Park Boulevard',45445,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (3,'23 Workhaven Lane',99819,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (4,'1411 Lillydale Drive',97889,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (5,'1913 Hanoi Way',35200,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (6,'1121 Loja Avenue',17886,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (7,'692 Joliet Street',83579,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (8,'1566 Inegl Manor',53561,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (9,'53 Idfu Parkway',42399,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (10,'1795 Santiago de Compostela Way',18743,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (11,'900 Santiago de Compostela Parkway',93896,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (12,'478 Joliet Way',77948,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (13,'613 Korolev Drive',45844,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (14,'1531 Sal Drive',53628,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (15,'1542 Tarlac Parkway',1027,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (16,'808 Bhopal Manor',10672,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (17,'270 Amroha Parkway',29610,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (18,'770 Bydgoszcz Avenue',16266,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (19,'419 Iligan Lane',72878,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (20,'360 Toulouse Parkway',54308,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (21,'270 Toulon Boulevard',81766,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (22,'320 Brest Avenue',43331,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (23,'1417 Lancaster Avenue',72192,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (24,'1688 Okara Way',21954,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (25,'262 A Corua (La Corua) Parkway',34418,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (26,'28 Charlotte Amalie Street',37551,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (27,'1780 Hino Boulevard',7716,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (28,'96 Tafuna Way',99865,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (29,'934 San Felipe de Puerto Plata Street',99780,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (30,'18 Duisburg Boulevard',58327,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (31,'217 Botshabelo Place',49521,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (32,'1425 Shikarpur Manor',65599,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (33,'786 Aurora Avenue',65750,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (34,'1668 Anpolis Street',50199,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (35,'33 Gorontalo Way',30348,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (36,'176 Mandaluyong Place',65213,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (37,'127 Purnea (Purnia) Manor',79388,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (38,'61 Tama Street',94065,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (39,'391 Callao Drive',34021,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (40,'334 Munger (Monghyr) Lane',38145,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (41,'1440 Fukuyama Loop',47929,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (42,'269 Cam Ranh Parkway',34689,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (43,'306 Antofagasta Place',3989,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (44,'671 Graz Street',94399,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (45,'42 Brindisi Place',16744,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (46,'1632 Bislig Avenue',61117,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (47,'1447 Imus Way',48942,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (48,'1998 Halifax Drive',76022,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (49,'1718 Valencia Street',37359,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (50,'46 Pjatigorsk Lane',23616,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (51,'686 Garland Manor',52535,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (52,'909 Garland Manor',69367,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (53,'725 Isesaki Place',74428,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (54,'115 Hidalgo Parkway',80168,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (55,'1135 Izumisano Parkway',48150,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (56,'939 Probolinggo Loop',4166,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (57,'17 Kabul Boulevard',38594,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (58,'1964 Allappuzha (Alleppey) Street',48980,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (59,'1697 Kowloon and New Kowloon Loop',57807,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (60,'1668 Saint Louis Place',39072,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (61,'943 Tokat Street',45428,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (62,'1114 Liepaja Street',69226,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (63,'1213 Ranchi Parkway',94352,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (64,'81 Hodeida Way',55561,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (65,'915 Ponce Place',83980,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (66,'1717 Guadalajara Lane',85505,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (67,'1214 Hanoi Way',67055,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (68,'1966 Amroha Avenue',70385,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (69,'698 Otsu Street',71110,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (70,'1150 Kimchon Manor',96109,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (71,'1586 Guaruj Place',5135,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (72,'57 Arlington Manor',48960,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (73,'1031 Daugavpils Parkway',59025,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (74,'1124 Buenaventura Drive',6856,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (75,'492 Cam Ranh Street',50805,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (76,'89 Allappuzha (Alleppey) Manor',75444,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (77,'1947 Poos de Caldas Boulevard',60951,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (78,'1206 Dos Quebradas Place',20207,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (79,'1551 Rampur Lane',72394,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (80,'602 Paarl Street',98889,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (81,'1692 Ede Loop',9223,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (82,'936 Salzburg Lane',96709,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (83,'586 Tete Way',1079,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (84,'1888 Kabul Drive',20936,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (85,'320 Baiyin Parkway',37307,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (86,'927 Baha Blanca Parkway',9495,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (87,'929 Tallahassee Loop',74671,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (88,'125 Citt del Vaticano Boulevard',67912,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (89,'1557 Ktahya Boulevard',88002,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (90,'870 Ashqelon Loop',84931,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (91,'1740 Portoviejo Avenue',29932,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (92,'1942 Ciparay Parkway',82624,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (93,'1926 El Alto Avenue',75543,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (94,'1952 Chatsworth Drive',25958,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (95,'1370 Le Mans Avenue',52163,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (96,'984 Effon-Alaiye Avenue',17119,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (97,'832 Nakhon Sawan Manor',49021,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (98,'152 Kitwe Parkway',53182,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (99,'1697 Tanauan Lane',22870,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (100,'1308 Arecibo Way',30695,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (101,'1599 Plock Drive',71986,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (102,'669 Firozabad Loop',92265,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (103,'588 Vila Velha Manor',51540,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (104,'1913 Kamakura Place',97287,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (105,'733 Mandaluyong Place',77459,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (106,'659 Vaduz Drive',49708,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (107,'1177 Jelets Way',3305,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (108,'1386 Yangor Avenue',80720,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (109,'454 Nakhon Sawan Boulevard',76383,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (110,'1867 San Juan Bautista Tuxtepec Avenue',78311,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (111,'1532 Dzerzinsk Way',9599,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (112,'1002 Ahmadnagar Manor',93026,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (113,'682 Junan Way',30418,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (114,'804 Elista Drive',61069,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (115,'1378 Alvorada Avenue',75834,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (116,'793 Cam Ranh Avenue',87057,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (117,'1079 Tel Aviv-Jaffa Boulevard',10885,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (118,'442 Rae Bareli Place',24321,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (119,'1107 Nakhon Sawan Avenue',75149,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (120,'544 Malm Parkway',63502,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (121,'1967 Sincelejo Place',73644,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (122,'333 Goinia Way',78625,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (123,'1987 Coacalco de Berriozbal Loop',96065,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (124,'241 Mosul Lane',76157,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (125,'211 Chiayi Drive',58186,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (126,'1175 Tanauan Way',64615,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (127,'117 Boa Vista Way',6804,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (128,'848 Tafuna Manor',45142,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (129,'569 Baicheng Lane',60304,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (130,'1666 Qomsheh Drive',66255,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (131,'801 Hagonoy Drive',8439,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (132,'1050 Garden Grove Avenue',4999,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (133,'1854 Tieli Street',15819,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (134,'758 Junan Lane',82639,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (135,'1752 So Leopoldo Parkway',14014,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (136,'898 Belm Manor',49757,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (137,'261 Saint Louis Way',83401,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (138,'765 Southampton Drive',4285,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (139,'943 Johannesburg Avenue',5892,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (140,'788 Atinsk Street',81691,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (141,'1749 Daxian Place',11044,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (142,'1587 Sullana Lane',85769,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (143,'1029 Dzerzinsk Manor',57519,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (144,'1666 Beni-Mellal Place',13377,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (145,'928 Jaffna Loop',93762,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (146,'483 Ljubertsy Parkway',60562,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (147,'374 Bat Yam Boulevard',97700,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (148,'1027 Songkhla Manor',30861,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (149,'999 Sanaa Loop',3439,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (150,'879 Newcastle Way',90732,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (151,'1337 Lincoln Parkway',99457,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (152,'1952 Pune Lane',92150,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (153,'782 Mosul Street',25545,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (154,'781 Shimonoseki Drive',95444,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (155,'1560 Jelets Boulevard',77777,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (156,'1963 Moscow Place',64863,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (157,'456 Escobar Way',36061,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (158,'798 Cianjur Avenue',76990,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (159,'185 Novi Sad Place',41778,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (160,'1367 Yantai Manor',21294,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (161,'1386 Nakhon Sawan Boulevard',53502,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (162,'369 Papeete Way',66639,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (163,'1440 Compton Place',81037,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (164,'1623 Baha Blanca Manor',81511,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (165,'97 Shimoga Avenue',44660,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (166,'1740 Le Mans Loop',22853,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (167,'1287 Xiangfan Boulevard',57844,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (168,'842 Salzburg Lane',3313,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (169,'154 Tallahassee Loop',62250,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (170,'710 San Felipe del Progreso Avenue',76901,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (171,'1540 Wroclaw Drive',62686,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (172,'475 Atinsk Way',59571,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (173,'1294 Firozabad Drive',70618,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (174,'1877 Ezhou Lane',63337,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (175,'316 Uruapan Street',58194,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (176,'29 Pyongyang Loop',47753,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (177,'1010 Klerksdorp Way',6802,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (178,'1848 Salala Boulevard',25220,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (179,'431 Xiangtan Avenue',4854,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (180,'757 Rustenburg Avenue',89668,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (181,'146 Johannesburg Way',54132,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (182,'1891 Rizhao Boulevard',47288,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (183,'1089 Iwatsuki Avenue',35109,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (184,'1410 Benin City Parkway',29747,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (185,'682 Garden Grove Place',67497,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (186,'533 al-Ayn Boulevard',8862,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (187,'1839 Szkesfehrvr Parkway',55709,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (188,'741 Ambattur Manor',43310,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (189,'927 Barcelona Street',65121,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (190,'435 0 Way',74750,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (191,'140 Chiayi Parkway',38982,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (192,'1166 Changhwa Street',58852,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (193,'891 Novi Sad Manor',5379,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (194,'605 Rio Claro Parkway',49348,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (195,'1077 San Felipe de Puerto Plata Place',65387,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (196,'9 San Miguel de Tucumn Manor',90845,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (197,'447 Surakarta Loop',10428,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (198,'345 Oshawa Boulevard',32114,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (199,'1792 Valle de la Pascua Place',15540,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (200,'1074 Binzhou Manor',36490,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (201,'817 Bradford Loop',89459,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (202,'955 Bamenda Way',1545,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (203,'1149 A Corua (La Corua) Boulevard',95824,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (204,'387 Mwene-Ditu Drive',8073,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (205,'68 Molodetno Manor',4662,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (206,'642 Nador Drive',3924,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (207,'1688 Nador Lane',61613,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (208,'1215 Pyongyang Parkway',25238,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (209,'1679 Antofagasta Street',86599,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (210,'1304 s-Hertogenbosch Way',10925,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (211,'850 Salala Loop',10800,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (212,'624 Oshawa Boulevard',89959,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (213,'43 Dadu Avenue',4855,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (214,'751 Lima Loop',99405,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (215,'1333 Haldia Street',82161,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (216,'660 Jedda Boulevard',25053,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (217,'1001 Miyakonojo Lane',67924,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (218,'226 Brest Manor',2299,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (219,'1229 Valencia Parkway',99124,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (220,'1201 Qomsheh Manor',21464,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (221,'866 Shivapuri Manor',22474,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (222,'1168 Najafabad Parkway',40301,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (223,'1244 Allappuzha (Alleppey) Place',20657,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (224,'1842 Luzinia Boulevard',94420,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (225,'1926 Gingoog Street',22824,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (226,'810 Palghat (Palakkad) Boulevard',73431,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (227,'1820 Maring Parkway',88307,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (228,'60 Poos de Caldas Street',82338,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (229,'1014 Loja Manor',66851,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (230,'201 Effon-Alaiye Way',64344,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (231,'430 Alessandria Loop',47446,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (232,'754 Valencia Place',87911,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (233,'356 Olomouc Manor',93323,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (234,'1256 Bislig Boulevard',50598,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (235,'954 Kimchon Place',42420,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (236,'885 Yingkou Manor',31390,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (237,'1736 Cavite Place',98775,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (238,'346 Skikda Parkway',90628,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (239,'98 Stara Zagora Boulevard',76448,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (240,'1479 Rustenburg Boulevard',18727,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (241,'647 A Corua (La Corua) Street',36971,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (242,'1964 Gijn Manor',14408,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (243,'47 Syktyvkar Lane',22236,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (244,'1148 Saarbrcken Parkway',1921,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (245,'1103 Bilbays Parkway',87660,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (246,'1246 Boksburg Parkway',28349,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (247,'1483 Pathankot Street',37288,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (248,'582 Papeete Loop',27722,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (249,'300 Junan Street',81314,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (250,'829 Grand Prairie Way',6461,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (251,'1473 Changhwa Parkway',75933,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (252,'1309 Weifang Street',57338,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (253,'1760 Oshawa Manor',38140,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (254,'786 Stara Zagora Way',98332,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (255,'1966 Tonghae Street',36481,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (256,'1497 Yuzhou Drive',3433,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (258,'752 Ondo Loop',32474,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (259,'1338 Zalantun Lane',45403,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (260,'127 Iwakuni Boulevard',20777,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (261,'51 Laredo Avenue',68146,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (262,'771 Yaound Manor',86768,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (263,'532 Toulon Street',69517,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (264,'1027 Banjul Place',50390,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (265,'1158 Mandi Bahauddin Parkway',98484,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (266,'862 Xintai Lane',30065,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (267,'816 Cayenne Parkway',93629,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (268,'1831 Nam Dinh Loop',51990,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (269,'446 Kirovo-Tepetsk Lane',19428,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (270,'682 Halisahar Place',20536,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (271,'1587 Loja Manor',5410,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (272,'1762 Paarl Parkway',53928,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (273,'1519 Ilorin Place',49298,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (274,'920 Kumbakonam Loop',75090,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (275,'906 Goinia Way',83565,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (276,'1675 Xiangfan Manor',11763,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (277,'85 San Felipe de Puerto Plata Drive',46063,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (278,'144 South Hill Loop',2012,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (279,'1884 Shikarpur Avenue',85548,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (280,'1980 Kamjanets-Podilskyi Street',89502,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (281,'1944 Bamenda Way',24645,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (282,'556 Baybay Manor',55802,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (283,'457 Tongliao Loop',56254,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (284,'600 Bradford Street',96204,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (285,'1006 Santa Brbara dOeste Manor',36229,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (286,'1308 Sumy Loop',30657,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (287,'1405 Chisinau Place',8160,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (288,'226 Halifax Street',58492,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (289,'1279 Udine Parkway',75860,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (290,'1336 Benin City Drive',46044,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (291,'1155 Liaocheng Place',22650,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (292,'1993 Tabuk Lane',64221,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (293,'86 Higashiosaka Lane',33768,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (294,'1912 Allende Manor',58124,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (295,'544 Tarsus Boulevard',53145,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (296,'1936 Cuman Avenue',61195,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (297,'1192 Tongliao Street',19065,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (298,'44 Najafabad Way',61391,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (299,'32 Pudukkottai Lane',38834,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (300,'661 Chisinau Lane',8856,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (301,'951 Stara Zagora Manor',98573,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (302,'922 Vila Velha Loop',4085,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (303,'898 Jining Lane',40070,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (304,'1635 Kuwana Boulevard',52137,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (305,'41 El Alto Parkway',56883,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (306,'1883 Maikop Lane',68469,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (307,'1908 Gaziantep Place',58979,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (308,'687 Alessandria Parkway',57587,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (309,'827 Yuncheng Drive',79047,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (310,'913 Coacalco de Berriozbal Loop',42141,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (311,'715 So Bernardo do Campo Lane',84804,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (312,'1354 Siegen Street',80184,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (313,'1191 Sungai Petani Boulevard',9668,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (314,'1224 Huejutla de Reyes Boulevard',70923,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (315,'543 Bergamo Avenue',59686,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (316,'746 Joliet Lane',94878,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (317,'780 Kimberley Way',17032,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (318,'1774 Yaound Place',91400,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (319,'1957 Yantai Lane',59255,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (320,'1542 Lubumbashi Boulevard',62472,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (321,'651 Pathankot Loop',59811,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (322,'1359 Zhoushan Parkway',29763,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (323,'1769 Iwaki Lane',25787,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (324,'1145 Vilnius Manor',73170,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (325,'1892 Nabereznyje Telny Lane',28396,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (326,'470 Boksburg Street',97960,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (327,'1427 A Corua (La Corua) Place',85799,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (328,'479 San Felipe del Progreso Avenue',54949,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (329,'867 Benin City Avenue',78543,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (330,'981 Kumbakonam Place',87611,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (331,'1016 Iwakuni Street',49833,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (332,'663 Baha Blanca Parkway',33463,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (333,'1860 Taguig Loop',59550,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (334,'1816 Bydgoszcz Loop',64308,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (335,'587 Benguela Manor',91590,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (336,'430 Kumbakonam Drive',28814,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (337,'1838 Tabriz Lane',1195,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (338,'431 Szkesfehrvr Avenue',57828,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (339,'503 Sogamoso Loop',49812,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (340,'507 Smolensk Loop',22971,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (341,'1920 Weifang Avenue',15643,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (342,'124 al-Manama Way',52368,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (343,'1443 Mardan Street',31483,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (344,'1909 Benguela Lane',19913,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (345,'68 Ponce Parkway',85926,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (346,'1217 Konotop Avenue',504,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (347,'1293 Nam Dinh Way',71583,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (348,'785 Vaduz Street',36170,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (349,'1516 Escobar Drive',46069,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (350,'1628 Nagareyama Lane',60079,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (351,'1157 Nyeri Loop',56380,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (352,'1673 Tangail Drive',26857,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (353,'381 Kabul Way',87272,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (354,'953 Hodeida Street',18841,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (355,'469 Nakhon Sawan Street',58866,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (356,'1378 Beira Loop',40792,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (357,'1641 Changhwa Place',37636,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (358,'1698 Southport Loop',49009,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (359,'519 Nyeri Manor',37650,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (360,'619 Hunuco Avenue',81508,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (361,'45 Aparecida de Goinia Place',7431,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (362,'482 Kowloon and New Kowloon Manor',97056,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (363,'604 Bern Place',5373,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (364,'1623 Kingstown Drive',91299,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (365,'1009 Zanzibar Lane',64875,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (366,'114 Jalib al-Shuyukh Manor',60440,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (367,'1163 London Parkway',6066,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (368,'1658 Jastrzebie-Zdrj Loop',96584,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (369,'817 Laredo Avenue',77449,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (370,'1565 Tangail Manor',45750,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (371,'1912 Emeishan Drive',33050,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (372,'230 Urawa Drive',2738,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (373,'1922 Miraj Way',13203,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (374,'433 Florencia Street',91330,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (375,'1049 Matamoros Parkway',69640,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (376,'1061 Ede Avenue',57810,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (377,'154 Oshawa Manor',72771,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (378,'1191 Tandil Drive',6362,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (379,'1133 Rizhao Avenue',2800,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (380,'1519 Santiago de los Caballeros Loop',22025,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (381,'1618 Olomouc Manor',26385,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (382,'220 Hidalgo Drive',45298,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (383,'686 Donostia-San Sebastin Lane',97390,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (384,'97 Mogiljov Lane',89294,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (385,'1642 Charlotte Amalie Drive',75442,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (386,'1368 Maracabo Boulevard',32716,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (387,'401 Sucre Boulevard',25007,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (388,'368 Hunuco Boulevard',17165,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (389,'500 Lincoln Parkway',95509,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (390,'102 Chapra Drive',14073,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (391,'1793 Meixian Place',33535,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (392,'514 Ife Way',69973,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (393,'717 Changzhou Lane',21615,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (394,'753 Ilorin Avenue',3656,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (395,'1337 Mit Ghamr Avenue',29810,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (396,'767 Pyongyang Drive',83536,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (397,'614 Pak Kret Street',27796,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (398,'954 Lapu-Lapu Way',8816,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (399,'331 Bydgoszcz Parkway',966,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (400,'1152 Citrus Heights Manor',5239,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (401,'168 Cianjur Manor',73824,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (402,'616 Hagonoy Avenue',46043,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (403,'1190 0 Place',10417,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (404,'734 Bchar Place',30586,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (405,'530 Lausanne Lane',11067,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (406,'454 Patiala Lane',13496,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (407,'1346 Mysore Drive',61507,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (408,'990 Etawah Loop',79940,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (409,'1266 Laredo Parkway',7664,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (410,'88 Nagaon Manor',86868,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (411,'264 Bhimavaram Manor',54749,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (412,'1639 Saarbrcken Drive',9827,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (413,'692 Amroha Drive',35575,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (414,'1936 Lapu-Lapu Parkway',7122,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (415,'432 Garden Grove Street',65630,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (416,'1445 Carmen Parkway',70809,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (417,'791 Salinas Street',40509,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (418,'126 Acua Parkway',58888,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (419,'397 Sunnyvale Avenue',55566,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (420,'992 Klerksdorp Loop',33711,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (421,'966 Arecibo Loop',94018,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (422,'289 Santo Andr Manor',72410,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (423,'437 Chungho Drive',59489,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (424,'1948 Bayugan Parkway',60622,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (425,'1866 al-Qatif Avenue',89420,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (426,'1661 Abha Drive',14400,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (427,'1557 Cape Coral Parkway',46875,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (428,'1727 Matamoros Place',78813,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (429,'1269 Botosani Manor',47394,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (430,'355 Vitria de Santo Anto Way',81758,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (431,'1596 Acua Parkway',70425,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (432,'259 Ipoh Drive',64964,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (433,'1823 Hoshiarpur Lane',33191,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (434,'1404 Taguig Drive',87212,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (435,'740 Udaipur Lane',33505,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (436,'287 Cuautla Boulevard',72736,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (437,'1766 Almirante Brown Street',63104,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (438,'596 Huixquilucan Place',65892,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (439,'1351 Aparecida de Goinia Parkway',41775,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (440,'722 Bradford Lane',90920,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (441,'983 Santa F Way',47472,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (442,'1245 Ibirit Way',40926,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (443,'1836 Korla Parkway',55405,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (444,'231 Kaliningrad Place',57833,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (445,'495 Bhimavaram Lane',3,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (446,'1924 Shimonoseki Drive',52625,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (447,'105 Dzerzinsk Manor',48570,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (448,'614 Denizli Parkway',29444,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (449,'1289 Belm Boulevard',88306,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (450,'203 Tambaram Street',73942,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (451,'1704 Tambaram Manor',2834,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (452,'207 Cuernavaca Loop',52671,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (453,'319 Springs Loop',99552,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (454,'956 Nam Dinh Manor',21872,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (455,'1947 Paarl Way',23636,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (456,'814 Simferopol Loop',48745,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (457,'535 Ahmadnagar Manor',41136,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (458,'138 Caracas Boulevard',16790,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (459,'251 Florencia Drive',16119,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (460,'659 Gatineau Boulevard',28587,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (461,'1889 Valparai Way',75559,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (462,'1485 Bratislava Place',83183,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (463,'935 Aden Boulevard',64709,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (464,'76 Kermanshah Manor',23343,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (465,'734 Tanshui Avenue',70664,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (466,'118 Jaffna Loop',10447,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (467,'1621 Tongliao Avenue',22173,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (468,'1844 Usak Avenue',84461,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (469,'1872 Toulon Loop',7939,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (470,'1088 Ibirit Place',88502,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (471,'1322 Mosul Parkway',95400,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (472,'1447 Chatsworth Place',41545,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (473,'1257 Guadalajara Street',33599,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (474,'1469 Plock Lane',95835,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (475,'434 Ourense (Orense) Manor',14122,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (476,'270 Tambaram Parkway',9668,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (477,'1786 Salinas Place',66546,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (478,'1078 Stara Zagora Drive',69221,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (479,'1854 Okara Boulevard',42123,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (480,'421 Yaound Street',11363,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (481,'1153 Allende Way',20336,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (482,'808 Naala-Porto Parkway',41060,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (483,'632 Usolje-Sibirskoje Parkway',73085,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (484,'98 Pyongyang Boulevard',88749,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (485,'984 Novoterkassk Loop',28165,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (486,'64 Korla Street',25145,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (487,'1785 So Bernardo do Campo Street',71182,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (488,'698 Jelets Boulevard',2596,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (489,'1297 Alvorada Parkway',11839,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (490,'1909 Dayton Avenue',88513,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (491,'1789 Saint-Denis Parkway',8268,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (492,'185 Mannheim Lane',23661,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (493,'184 Mandaluyong Street',94239,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (494,'591 Sungai Petani Drive',46400,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (495,'656 Matamoros Drive',19489,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (496,'775 ostka Drive',22358,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (497,'1013 Tabuk Boulevard',96203,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (498,'319 Plock Parkway',26101,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (499,'1954 Kowloon and New Kowloon Way',63667,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (500,'362 Rajkot Lane',98030,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (501,'1060 Tandil Lane',72349,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (502,'1515 Korla Way',57197,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (503,'1416 San Juan Bautista Tuxtepec Avenue',50592,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (504,'1 Valle de Santiago Avenue',86208,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (505,'519 Brescia Parkway',69504,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (506,'414 Mandaluyong Street',16370,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (507,'1197 Sokoto Boulevard',87687,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (508,'496 Celaya Drive',90797,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (509,'786 Matsue Way',37469,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (510,'48 Maracabo Place',1570,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (511,'1152 al-Qatif Lane',44816,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (512,'1269 Ipoh Avenue',54674,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (513,'758 Korolev Parkway',75474,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (514,'1747 Rustenburg Place',51369,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (515,'886 Tonghae Place',19450,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (516,'1574 Goinia Boulevard',39529,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (517,'548 Uruapan Street',35653,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (519,'962 Tama Loop',65952,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (520,'1778 Gijn Manor',35156,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (521,'568 Dhule (Dhulia) Loop',92568,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (522,'1768 Udine Loop',32347,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (523,'608 Birgunj Parkway',400,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (524,'680 A Corua (La Corua) Manor',49806,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (525,'1949 Sanya Street',61244,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (526,'617 Klerksdorp Place',94707,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (527,'1993 0 Loop',41214,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (528,'1176 Southend-on-Sea Manor',81651,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (529,'600 Purnea (Purnia) Avenue',18043,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (530,'1003 Qinhuangdao Street',25972,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (531,'1986 Sivas Place',95775,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (532,'1427 Tabuk Place',31342,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (533,'556 Asuncin Way',35364,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (534,'486 Ondo Parkway',35202,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (535,'635 Brest Manor',40899,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (536,'166 Jinchang Street',86760,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (537,'958 Sagamihara Lane',88408,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (538,'1817 Livorno Way',79401,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (539,'1332 Gaziantep Lane',22813,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (540,'949 Allende Lane',67521,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (541,'195 Ilorin Street',49250,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (542,'193 Bhusawal Place',9750,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (543,'43 Vilnius Manor',79814,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (544,'183 Haiphong Street',69953,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (545,'163 Augusta-Richmond County Loop',33030,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (546,'191 Jos Azueta Parkway',13629,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (547,'379 Lublin Parkway',74568,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (548,'1658 Cuman Loop',51309,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (549,'454 Qinhuangdao Drive',25866,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (550,'1715 Okayama Street',55676,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (551,'182 Nukualofa Drive',15414,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (552,'390 Wroclaw Way',5753,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (553,'1421 Quilmes Lane',19151,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (554,'947 Trshavn Place',841,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (555,'1764 Jalib al-Shuyukh Parkway',77642,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (556,'346 Cam Ranh Avenue',39976,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (557,'1407 Pachuca de Soto Place',26284,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (558,'904 Clarksville Drive',52234,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (559,'1917 Kumbakonam Parkway',11892,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (560,'1447 Imus Place',12905,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (561,'1497 Fengshan Drive',63022,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (562,'869 Shikarpur Way',57380,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (563,'1059 Yuncheng Avenue',47498,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (564,'505 Madiun Boulevard',97271,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (565,'1741 Hoshiarpur Boulevard',22372,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (566,'1229 Varanasi (Benares) Manor',40195,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (567,'1894 Boa Vista Way',77464,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (568,'1342 Sharja Way',93655,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (569,'1342 Abha Boulevard',10714,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (570,'415 Pune Avenue',44274,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (571,'1746 Faaa Way',32515,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (572,'539 Hami Way',52196,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (573,'1407 Surakarta Manor',33224,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (574,'502 Mandi Bahauddin Parkway',15992,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (575,'1052 Pathankot Avenue',77397,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (576,'1351 Sousse Lane',37815,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (577,'1501 Pangkal Pinang Avenue',943,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (578,'1405 Hagonoy Avenue',86587,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (579,'521 San Juan Bautista Tuxtepec Place',95093,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (580,'923 Tangail Boulevard',33384,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (581,'186 Skikda Lane',89422,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (582,'1568 Celaya Parkway',34750,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (583,'1489 Kakamigahara Lane',98883,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (584,'1819 Alessandria Loop',53829,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (585,'1208 Tama Loop',73605,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (586,'951 Springs Lane',96115,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (587,'760 Miyakonojo Drive',64682,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (588,'966 Asuncin Way',62703,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (589,'1584 Ljubertsy Lane',22954,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (590,'247 Jining Parkway',53446,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (591,'773 Dallas Manor',12664,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (592,'1923 Stara Zagora Lane',95179,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (593,'1402 Zanzibar Boulevard',71102,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (594,'1464 Kursk Parkway',17381,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (595,'1074 Sanaa Parkway',22474,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (596,'1759 Niznekamsk Avenue',39414,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (597,'32 Liaocheng Way',1944,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (598,'42 Fontana Avenue',14684,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (599,'1895 Zhezqazghan Drive',36693,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (600,'1837 Kaduna Parkway',82580,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (601,'844 Bucuresti Place',36603,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (602,'1101 Bucuresti Boulevard',97661,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (603,'1103 Quilmes Boulevard',52137,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (604,'1331 Usak Boulevard',61960,NULL);
INSERT INTO addr(addr_id,address,postal_code,phone) VALUES (605,'1325 Fukuyama Street',27107,NULL);





INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (1,'MARY','SMITH','MARY.SMITH@gmail.com',5,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (2,'PATRICIA','JOHNSON','PATRICIA.JOHNSON@gmail.com',6,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (3,'LINDA','WILLIAMS','LINDA.WILLIAMS@gmail.com',7,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (4,'BARBARA','JONES','BARBARA.JONES@gmail.com',8,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (5,'ELIZABETH','BROWN','ELIZABETH.BROWN@gmail.com',9,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (6,'JENNIFER','DAVIS','JENNIFER.DAVIS@gmail.com',10,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (7,'MARIA','MILLER','MARIA.MILLER@gmail.com',11,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (8,'SUSAN','WILSON','SUSAN.WILSON@gmail.com',12,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (9,'MARGARET','MOORE','MARGARET.MOORE@gmail.com',13,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (10,'DOROTHY','TAYLOR','DOROTHY.TAYLOR@gmail.com',14,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (11,'LISA','ANDERSON','LISA.ANDERSON@gmail.com',15,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (12,'NANCY','THOMAS','NANCY.THOMAS@gmail.com',16,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (13,'KAREN','JACKSON','KAREN.JACKSON@gmail.com',17,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (14,'BETTY','WHITE','BETTY.WHITE@gmail.com',18,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (15,'HELEN','HARRIS','HELEN.HARRIS@gmail.com',19,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (16,'SANDRA','MARTIN','SANDRA.MARTIN@gmail.com',20,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (17,'DONNA','THOMPSON','DONNA.THOMPSON@gmail.com',21,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (18,'CAROL','GARCIA','CAROL.GARCIA@gmail.com',22,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (19,'RUTH','MARTINEZ','RUTH.MARTINEZ@gmail.com',23,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (20,'SHARON','ROBINSON','SHARON.ROBINSON@gmail.com',24,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (21,'MICHELLE','CLARK','MICHELLE.CLARK@gmail.com',25,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (22,'LAURA','RODRIGUEZ','LAURA.RODRIGUEZ@gmail.com',26,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (23,'SARAH','LEWIS','SARAH.LEWIS@gmail.com',27,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (24,'KIMBERLY','LEE','KIMBERLY.LEE@gmail.com',28,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (25,'DEBORAH','WALKER','DEBORAH.WALKER@gmail.com',29,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (26,'JESSICA','HALL','JESSICA.HALL@gmail.com',30,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (27,'SHIRLEY','ALLEN','SHIRLEY.ALLEN@gmail.com',31,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (28,'CYNTHIA','YOUNG','CYNTHIA.YOUNG@gmail.com',32,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (29,'ANGELA','HERNANDEZ','ANGELA.HERNANDEZ@gmail.com',33,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (30,'MELISSA','KING','MELISSA.KING@gmail.com',34,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (31,'BRENDA','WRIGHT','BRENDA.WRIGHT@gmail.com',35,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (32,'AMY','LOPEZ','AMY.LOPEZ@gmail.com',36,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (33,'ANNA','HILL','ANNA.HILL@gmail.com',37,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (34,'REBECCA','SCOTT','REBECCA.SCOTT@gmail.com',38,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (35,'VIRGINIA','GREEN','VIRGINIA.GREEN@gmail.com',39,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (36,'KATHLEEN','ADAMS','KATHLEEN.ADAMS@gmail.com',40,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (37,'PAMELA','BAKER','PAMELA.BAKER@gmail.com',41,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (38,'MARTHA','GONZALEZ','MARTHA.GONZALEZ@gmail.com',42,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (39,'DEBRA','NELSON','DEBRA.NELSON@gmail.com',43,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (40,'AMANDA','CARTER','AMANDA.CARTER@gmail.com',44,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (41,'STEPHANIE','MITCHELL','STEPHANIE.MITCHELL@gmail.com',45,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (42,'CAROLYN','PEREZ','CAROLYN.PEREZ@gmail.com',46,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (43,'CHRISTINE','ROBERTS','CHRISTINE.ROBERTS@gmail.com',47,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (44,'MARIE','TURNER','MARIE.TURNER@gmail.com',48,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (45,'JANET','PHILLIPS','JANET.PHILLIPS@gmail.com',49,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (46,'CATHERINE','CAMPBELL','CATHERINE.CAMPBELL@gmail.com',50,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (47,'FRANCES','PARKER','FRANCES.PARKER@gmail.com',51,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (48,'ANN','EVANS','ANN.EVANS@gmail.com',52,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (49,'JOYCE','EDWARDS','JOYCE.EDWARDS@gmail.com',53,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (50,'DIANE','COLLINS','DIANE.COLLINS@gmail.com',54,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (51,'ALICE','STEWART','ALICE.STEWART@gmail.com',55,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (52,'JULIE','SANCHEZ','JULIE.SANCHEZ@gmail.com',56,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (53,'HEATHER','MORRIS','HEATHER.MORRIS@gmail.com',57,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (54,'TERESA','ROGERS','TERESA.ROGERS@gmail.com',58,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (55,'DORIS','REED','DORIS.REED@gmail.com',59,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (56,'GLORIA','COOK','GLORIA.COOK@gmail.com',60,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (57,'EVELYN','MORGAN','EVELYN.MORGAN@gmail.com',61,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (58,'JEAN','BELL','JEAN.BELL@gmail.com',62,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (59,'CHERYL','MURPHY','CHERYL.MURPHY@gmail.com',63,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (60,'MILDRED','BAILEY','MILDRED.BAILEY@gmail.com',64,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (61,'KATHERINE','RIVERA','KATHERINE.RIVERA@gmail.com',65,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (62,'JOAN','COOPER','JOAN.COOPER@gmail.com',66,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (63,'ASHLEY','RICHARDSON','ASHLEY.RICHARDSON@gmail.com',67,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (64,'JUDITH','COX','JUDITH.COX@gmail.com',68,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (65,'ROSE','HOWARD','ROSE.HOWARD@gmail.com',69,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (66,'JANICE','WARD','JANICE.WARD@gmail.com',70,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (67,'KELLY','TORRES','KELLY.TORRES@gmail.com',71,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (68,'NICOLE','PETERSON','NICOLE.PETERSON@gmail.com',72,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (69,'JUDY','GRAY','JUDY.GRAY@gmail.com',73,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (70,'CHRISTINA','RAMIREZ','CHRISTINA.RAMIREZ@gmail.com',74,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (71,'KATHY','JAMES','KATHY.JAMES@gmail.com',75,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (72,'THERESA','WATSON','THERESA.WATSON@gmail.com',76,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (73,'BEVERLY','BROOKS','BEVERLY.BROOKS@gmail.com',77,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (74,'DENISE','KELLY','DENISE.KELLY@gmail.com',78,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (75,'TAMMY','SANDERS','TAMMY.SANDERS@gmail.com',79,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (76,'IRENE','PRICE','IRENE.PRICE@gmail.com',80,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (77,'JANE','BENNETT','JANE.BENNETT@gmail.com',81,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (78,'LORI','WOOD','LORI.WOOD@gmail.com',82,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (79,'RACHEL','BARNES','RACHEL.BARNES@gmail.com',83,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (80,'MARILYN','ROSS','MARILYN.ROSS@gmail.com',84,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (81,'ANDREA','HENDERSON','ANDREA.HENDERSON@gmail.com',85,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (82,'KATHRYN','COLEMAN','KATHRYN.COLEMAN@gmail.com',86,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (83,'LOUISE','JENKINS','LOUISE.JENKINS@gmail.com',87,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (84,'SARA','PERRY','SARA.PERRY@gmail.com',88,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (85,'ANNE','POWELL','ANNE.POWELL@gmail.com',89,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (86,'JACQUELINE','LONG','JACQUELINE.LONG@gmail.com',90,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (87,'WANDA','PATTERSON','WANDA.PATTERSON@gmail.com',91,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (88,'BONNIE','HUGHES','BONNIE.HUGHES@gmail.com',92,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (89,'JULIA','FLORES','JULIA.FLORES@gmail.com',93,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (90,'RUBY','WASHINGTON','RUBY.WASHINGTON@gmail.com',94,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (91,'LOIS','BUTLER','LOIS.BUTLER@gmail.com',95,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (92,'TINA','SIMMONS','TINA.SIMMONS@gmail.com',96,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (93,'PHYLLIS','FOSTER','PHYLLIS.FOSTER@gmail.com',97,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (94,'NORMA','GONZALES','NORMA.GONZALES@gmail.com',98,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (95,'PAULA','BRYANT','PAULA.BRYANT@gmail.com',99,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (96,'DIANA','ALEXANDER','DIANA.ALEXANDER@gmail.com',100,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (97,'ANNIE','RUSSELL','ANNIE.RUSSELL@gmail.com',101,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (98,'LILLIAN','GRIFFIN','LILLIAN.GRIFFIN@gmail.com',102,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (99,'EMILY','DIAZ','EMILY.DIAZ@gmail.com',103,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (100,'ROBIN','HAYES','ROBIN.HAYES@gmail.com',104,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (101,'PEGGY','MYERS','PEGGY.MYERS@gmail.com',105,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (102,'CRYSTAL','FORD','CRYSTAL.FORD@gmail.com',106,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (103,'GLADYS','HAMILTON','GLADYS.HAMILTON@gmail.com',107,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (104,'RITA','GRAHAM','RITA.GRAHAM@gmail.com',108,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (105,'DAWN','SULLIVAN','DAWN.SULLIVAN@gmail.com',109,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (106,'CONNIE','WALLACE','CONNIE.WALLACE@gmail.com',110,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (107,'FLORENCE','WOODS','FLORENCE.WOODS@gmail.com',111,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (108,'TRACY','COLE','TRACY.COLE@gmail.com',112,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (109,'EDNA','WEST','EDNA.WEST@gmail.com',113,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (110,'TIFFANY','JORDAN','TIFFANY.JORDAN@gmail.com',114,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (111,'CARMEN','OWENS','CARMEN.OWENS@gmail.com',115,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (112,'ROSA','REYNOLDS','ROSA.REYNOLDS@gmail.com',116,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (113,'CINDY','FISHER','CINDY.FISHER@gmail.com',117,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (114,'GRACE','ELLIS','GRACE.ELLIS@gmail.com',118,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (115,'WENDY','HARRISON','WENDY.HARRISON@gmail.com',119,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (116,'VICTORIA','GIBSON','VICTORIA.GIBSON@gmail.com',120,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (117,'EDITH','MCDONALD','EDITH.MCDONALD@gmail.com',121,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (118,'KIM','CRUZ','KIM.CRUZ@gmail.com',122,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (119,'SHERRY','MARSHALL','SHERRY.MARSHALL@gmail.com',123,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (120,'SYLVIA','ORTIZ','SYLVIA.ORTIZ@gmail.com',124,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (121,'JOSEPHINE','GOMEZ','JOSEPHINE.GOMEZ@gmail.com',125,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (122,'THELMA','MURRAY','THELMA.MURRAY@gmail.com',126,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (123,'SHANNON','FREEMAN','SHANNON.FREEMAN@gmail.com',127,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (124,'SHEILA','WELLS','SHEILA.WELLS@gmail.com',128,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (125,'ETHEL','WEBB','ETHEL.WEBB@gmail.com',129,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (126,'ELLEN','SIMPSON','ELLEN.SIMPSON@gmail.com',130,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (127,'ELAINE','STEVENS','ELAINE.STEVENS@gmail.com',131,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (128,'MARJORIE','TUCKER','MARJORIE.TUCKER@gmail.com',132,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (129,'CARRIE','PORTER','CARRIE.PORTER@gmail.com',133,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (130,'CHARLOTTE','HUNTER','CHARLOTTE.HUNTER@gmail.com',134,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (131,'MONICA','HICKS','MONICA.HICKS@gmail.com',135,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (132,'ESTHER','CRAWFORD','ESTHER.CRAWFORD@gmail.com',136,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (133,'PAULINE','HENRY','PAULINE.HENRY@gmail.com',137,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (134,'EMMA','BOYD','EMMA.BOYD@gmail.com',138,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (135,'JUANITA','MASON','JUANITA.MASON@gmail.com',139,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (136,'ANITA','MORALES','ANITA.MORALES@gmail.com',140,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (137,'RHONDA','KENNEDY','RHONDA.KENNEDY@gmail.com',141,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (138,'HAZEL','WARREN','HAZEL.WARREN@gmail.com',142,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (139,'AMBER','DIXON','AMBER.DIXON@gmail.com',143,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (140,'EVA','RAMOS','EVA.RAMOS@gmail.com',144,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (141,'DEBBIE','REYES','DEBBIE.REYES@gmail.com',145,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (142,'APRIL','BURNS','APRIL.BURNS@gmail.com',146,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (143,'LESLIE','GORDON','LESLIE.GORDON@gmail.com',147,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (144,'CLARA','SHAW','CLARA.SHAW@gmail.com',148,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (145,'LUCILLE','HOLMES','LUCILLE.HOLMES@gmail.com',149,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (146,'JAMIE','RICE','JAMIE.RICE@gmail.com',150,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (147,'JOANNE','ROBERTSON','JOANNE.ROBERTSON@gmail.com',151,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (148,'ELEANOR','HUNT','ELEANOR.HUNT@gmail.com',152,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (149,'VALERIE','BLACK','VALERIE.BLACK@gmail.com',153,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (150,'DANIELLE','DANIELS','DANIELLE.DANIELS@gmail.com',154,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (151,'MEGAN','PALMER','MEGAN.PALMER@gmail.com',155,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (152,'ALICIA','MILLS','ALICIA.MILLS@gmail.com',156,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (153,'SUZANNE','NICHOLS','SUZANNE.NICHOLS@gmail.com',157,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (154,'MICHELE','GRANT','MICHELE.GRANT@gmail.com',158,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (155,'GAIL','KNIGHT','GAIL.KNIGHT@gmail.com',159,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (156,'BERTHA','FERGUSON','BERTHA.FERGUSON@gmail.com',160,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (157,'DARLENE','ROSE','DARLENE.ROSE@gmail.com',161,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (158,'VERONICA','STONE','VERONICA.STONE@gmail.com',162,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (159,'JILL','HAWKINS','JILL.HAWKINS@gmail.com',163,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (160,'ERIN','DUNN','ERIN.DUNN@gmail.com',164,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (161,'GERALDINE','PERKINS','GERALDINE.PERKINS@gmail.com',165,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (162,'LAUREN','HUDSON','LAUREN.HUDSON@gmail.com',166,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (163,'CATHY','SPENCER','CATHY.SPENCER@gmail.com',167,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (164,'JOANN','GARDNER','JOANN.GARDNER@gmail.com',168,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (165,'LORRAINE','STEPHENS','LORRAINE.STEPHENS@gmail.com',169,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (166,'LYNN','PAYNE','LYNN.PAYNE@gmail.com',170,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (167,'SALLY','PIERCE','SALLY.PIERCE@gmail.com',171,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (168,'REGINA','BERRY','REGINA.BERRY@gmail.com',172,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (169,'ERICA','MATTHEWS','ERICA.MATTHEWS@gmail.com',173,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (170,'BEATRICE','ARNOLD','BEATRICE.ARNOLD@gmail.com',174,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (171,'DOLORES','WAGNER','DOLORES.WAGNER@gmail.com',175,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (172,'BERNICE','WILLIS','BERNICE.WILLIS@gmail.com',176,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (173,'AUDREY','RAY','AUDREY.RAY@gmail.com',177,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (174,'YVONNE','WATKINS','YVONNE.WATKINS@gmail.com',178,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (175,'ANNETTE','OLSON','ANNETTE.OLSON@gmail.com',179,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (176,'JUNE','CARROLL','JUNE.CARROLL@gmail.com',180,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (177,'SAMANTHA','DUNCAN','SAMANTHA.DUNCAN@gmail.com',181,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (178,'MARION','SNYDER','MARION.SNYDER@gmail.com',182,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (179,'DANA','HART','DANA.HART@gmail.com',183,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (180,'STACY','CUNNINGHAM','STACY.CUNNINGHAM@gmail.com',184,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (181,'ANA','BRADLEY','ANA.BRADLEY@gmail.com',185,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (182,'RENEE','LANE','RENEE.LANE@gmail.com',186,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (183,'IDA','ANDREWS','IDA.ANDREWS@gmail.com',187,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (184,'VIVIAN','RUIZ','VIVIAN.RUIZ@gmail.com',188,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (185,'ROBERTA','HARPER','ROBERTA.HARPER@gmail.com',189,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (186,'HOLLY','FOX','HOLLY.FOX@gmail.com',190,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (187,'BRITTANY','RILEY','BRITTANY.RILEY@gmail.com',191,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (188,'MELANIE','ARMSTRONG','MELANIE.ARMSTRONG@gmail.com',192,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (189,'LORETTA','CARPENTER','LORETTA.CARPENTER@gmail.com',193,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (190,'YOLANDA','WEAVER','YOLANDA.WEAVER@gmail.com',194,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (191,'JEANETTE','GREENE','JEANETTE.GREENE@gmail.com',195,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (192,'LAURIE','LAWRENCE','LAURIE.LAWRENCE@gmail.com',196,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (193,'KATIE','ELLIOTT','KATIE.ELLIOTT@gmail.com',197,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (194,'KRISTEN','CHAVEZ','KRISTEN.CHAVEZ@gmail.com',198,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (195,'VANESSA','SIMS','VANESSA.SIMS@gmail.com',199,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (196,'ALMA','AUSTIN','ALMA.AUSTIN@gmail.com',200,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (197,'SUE','PETERS','SUE.PETERS@gmail.com',201,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (198,'ELSIE','KELLEY','ELSIE.KELLEY@gmail.com',202,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (199,'BETH','FRANKLIN','BETH.FRANKLIN@gmail.com',203,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (200,'JEANNE','LAWSON','JEANNE.LAWSON@gmail.com',204,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (201,'VICKI','FIELDS','VICKI.FIELDS@gmail.com',205,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (202,'CARLA','GUTIERREZ','CARLA.GUTIERREZ@gmail.com',206,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (203,'TARA','RYAN','TARA.RYAN@gmail.com',207,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (204,'ROSEMARY','SCHMIDT','ROSEMARY.SCHMIDT@gmail.com',208,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (205,'EILEEN','CARR','EILEEN.CARR@gmail.com',209,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (206,'TERRI','VASQUEZ','TERRI.VASQUEZ@gmail.com',210,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (207,'GERTRUDE','CASTILLO','GERTRUDE.CASTILLO@gmail.com',211,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (208,'LUCY','WHEELER','LUCY.WHEELER@gmail.com',212,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (209,'TONYA','CHAPMAN','TONYA.CHAPMAN@gmail.com',213,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (210,'ELLA','OLIVER','ELLA.OLIVER@gmail.com',214,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (211,'STACEY','MONTGOMERY','STACEY.MONTGOMERY@gmail.com',215,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (212,'WILMA','RICHARDS','WILMA.RICHARDS@gmail.com',216,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (213,'GINA','WILLIAMSON','GINA.WILLIAMSON@gmail.com',217,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (214,'KRISTIN','JOHNSTON','KRISTIN.JOHNSTON@gmail.com',218,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (215,'JESSIE','BANKS','JESSIE.BANKS@gmail.com',219,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (216,'NATALIE','MEYER','NATALIE.MEYER@gmail.com',220,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (217,'AGNES','BISHOP','AGNES.BISHOP@gmail.com',221,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (218,'VERA','MCCOY','VERA.MCCOY@gmail.com',222,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (219,'WILLIE','HOWELL','WILLIE.HOWELL@gmail.com',223,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (220,'CHARLENE','ALVAREZ','CHARLENE.ALVAREZ@gmail.com',224,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (221,'BESSIE','MORRISON','BESSIE.MORRISON@gmail.com',225,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (222,'DELORES','HANSEN','DELORES.HANSEN@gmail.com',226,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (223,'MELINDA','FERNANDEZ','MELINDA.FERNANDEZ@gmail.com',227,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (224,'PEARL','GARZA','PEARL.GARZA@gmail.com',228,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (225,'ARLENE','HARVEY','ARLENE.HARVEY@gmail.com',229,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (226,'MAUREEN','LITTLE','MAUREEN.LITTLE@gmail.com',230,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (227,'COLLEEN','BURTON','COLLEEN.BURTON@gmail.com',231,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (228,'ALLISON','STANLEY','ALLISON.STANLEY@gmail.com',232,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (229,'TAMARA','NGUYEN','TAMARA.NGUYEN@gmail.com',233,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (230,'JOY','GEORGE','JOY.GEORGE@gmail.com',234,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (231,'GEORGIA','JACOBS','GEORGIA.JACOBS@gmail.com',235,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (232,'CONSTANCE','REID','CONSTANCE.REID@gmail.com',236,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (233,'LILLIE','KIM','LILLIE.KIM@gmail.com',237,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (234,'CLAUDIA','FULLER','CLAUDIA.FULLER@gmail.com',238,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (235,'JACKIE','LYNCH','JACKIE.LYNCH@gmail.com',239,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (236,'MARCIA','DEAN','MARCIA.DEAN@gmail.com',240,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (237,'TANYA','GILBERT','TANYA.GILBERT@gmail.com',241,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (238,'NELLIE','GARRETT','NELLIE.GARRETT@gmail.com',242,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (239,'MINNIE','ROMERO','MINNIE.ROMERO@gmail.com',243,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (240,'MARLENE','WELCH','MARLENE.WELCH@gmail.com',244,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (241,'HEIDI','LARSON','HEIDI.LARSON@gmail.com',245,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (242,'GLENDA','FRAZIER','GLENDA.FRAZIER@gmail.com',246,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (243,'LYDIA','BURKE','LYDIA.BURKE@gmail.com',247,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (244,'VIOLA','HANSON','VIOLA.HANSON@gmail.com',248,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (245,'COURTNEY','DAY','COURTNEY.DAY@gmail.com',249,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (246,'MARIAN','MENDOZA','MARIAN.MENDOZA@gmail.com',250,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (247,'STELLA','MORENO','STELLA.MORENO@gmail.com',251,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (248,'CAROLINE','BOWMAN','CAROLINE.BOWMAN@gmail.com',252,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (249,'DORA','MEDINA','DORA.MEDINA@gmail.com',253,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (250,'JO','FOWLER','JO.FOWLER@gmail.com',254,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (251,'VICKIE','BREWER','VICKIE.BREWER@gmail.com',255,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (252,'MATTIE','HOFFMAN','MATTIE.HOFFMAN@gmail.com',256,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (253,'TERRY','CARLSON','TERRY.CARLSON@gmail.com',258,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (254,'MAXINE','SILVA','MAXINE.SILVA@gmail.com',259,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (255,'IRMA','PEARSON','IRMA.PEARSON@gmail.com',260,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (256,'MABEL','HOLLAND','MABEL.HOLLAND@gmail.com',261,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (257,'MARSHA','DOUGLAS','MARSHA.DOUGLAS@gmail.com',262,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (258,'MYRTLE','FLEMING','MYRTLE.FLEMING@gmail.com',263,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (259,'LENA','JENSEN','LENA.JENSEN@gmail.com',264,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (260,'CHRISTY','VARGAS','CHRISTY.VARGAS@gmail.com',265,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (261,'DEANNA','BYRD','DEANNA.BYRD@gmail.com',266,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (262,'PATSY','DAVIDSON','PATSY.DAVIDSON@gmail.com',267,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (263,'HILDA','HOPKINS','HILDA.HOPKINS@gmail.com',268,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (264,'GWENDOLYN','MAY','GWENDOLYN.MAY@gmail.com',269,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (265,'JENNIE','TERRY','JENNIE.TERRY@gmail.com',270,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (266,'NORA','HERRERA','NORA.HERRERA@gmail.com',271,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (267,'MARGIE','WADE','MARGIE.WADE@gmail.com',272,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (268,'NINA','SOTO','NINA.SOTO@gmail.com',273,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (269,'CASSANDRA','WALTERS','CASSANDRA.WALTERS@gmail.com',274,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (270,'LEAH','CURTIS','LEAH.CURTIS@gmail.com',275,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (271,'PENNY','NEAL','PENNY.NEAL@gmail.com',276,'2006-02-14 22:04:36');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (272,'KAY','CALDWELL','KAY.CALDWELL@gmail.com',277,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (273,'PRISCILLA','LOWE','PRISCILLA.LOWE@gmail.com',278,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (274,'NAOMI','JENNINGS','NAOMI.JENNINGS@gmail.com',279,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (275,'CAROLE','BARNETT','CAROLE.BARNETT@gmail.com',280,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (276,'BRANDY','GRAVES','BRANDY.GRAVES@gmail.com',281,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (277,'OLGA','JIMENEZ','OLGA.JIMENEZ@gmail.com',282,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (278,'BILLIE','HORTON','BILLIE.HORTON@gmail.com',283,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (279,'DIANNE','SHELTON','DIANNE.SHELTON@gmail.com',284,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (280,'TRACEY','BARRETT','TRACEY.BARRETT@gmail.com',285,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (281,'LEONA','OBRIEN','LEONA.OBRIEN@gmail.com',286,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (282,'JENNY','CASTRO','JENNY.CASTRO@gmail.com',287,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (283,'FELICIA','SUTTON','FELICIA.SUTTON@gmail.com',288,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (284,'SONIA','GREGORY','SONIA.GREGORY@gmail.com',289,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (285,'MIRIAM','MCKINNEY','MIRIAM.MCKINNEY@gmail.com',290,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (286,'VELMA','LUCAS','VELMA.LUCAS@gmail.com',291,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (287,'BECKY','MILES','BECKY.MILES@gmail.com',292,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (288,'BOBBIE','CRAIG','BOBBIE.CRAIG@gmail.com',293,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (289,'VIOLET','RODRIQUEZ','VIOLET.RODRIQUEZ@gmail.com',294,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (290,'KRISTINA','CHAMBERS','KRISTINA.CHAMBERS@gmail.com',295,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (291,'TONI','HOLT','TONI.HOLT@gmail.com',296,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (292,'MISTY','LAMBERT','MISTY.LAMBERT@gmail.com',297,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (293,'MAE','FLETCHER','MAE.FLETCHER@gmail.com',298,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (294,'SHELLY','WATTS','SHELLY.WATTS@gmail.com',299,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (295,'DAISY','BATES','DAISY.BATES@gmail.com',300,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (296,'RAMONA','HALE','RAMONA.HALE@gmail.com',301,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (297,'SHERRI','RHODES','SHERRI.RHODES@gmail.com',302,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (298,'ERIKA','PENA','ERIKA.PENA@gmail.com',303,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (299,'JAMES','GANNON','JAMES.GANNON@gmail.com',304,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (300,'JOHN','FARNSWORTH','JOHN.FARNSWORTH@gmail.com',305,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (301,'ROBERT','BAUGHMAN','ROBERT.BAUGHMAN@gmail.com',306,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (302,'MICHAEL','SILVERMAN','MICHAEL.SILVERMAN@gmail.com',307,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (303,'WILLIAM','SATTERFIELD','WILLIAM.SATTERFIELD@gmail.com',308,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (304,'DAVID','ROYAL','DAVID.ROYAL@gmail.com',309,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (305,'RICHARD','MCCRARY','RICHARD.MCCRARY@gmail.com',310,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (306,'CHARLES','KOWALSKI','CHARLES.KOWALSKI@gmail.com',311,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (307,'JOSEPH','JOY','JOSEPH.JOY@gmail.com',312,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (308,'THOMAS','GRIGSBY','THOMAS.GRIGSBY@gmail.com',313,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (309,'CHRISTOPHER','GRECO','CHRISTOPHER.GRECO@gmail.com',314,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (310,'DANIEL','CABRAL','DANIEL.CABRAL@gmail.com',315,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (311,'PAUL','TROUT','PAUL.TROUT@gmail.com',316,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (312,'MARK','RINEHART','MARK.RINEHART@gmail.com',317,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (313,'DONALD','MAHON','DONALD.MAHON@gmail.com',318,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (314,'GEORGE','LINTON','GEORGE.LINTON@gmail.com',319,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (315,'KENNETH','GOODEN','KENNETH.GOODEN@gmail.com',320,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (316,'STEVEN','CURLEY','STEVEN.CURLEY@gmail.com',321,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (317,'EDWARD','BAUGH','EDWARD.BAUGH@gmail.com',322,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (318,'BRIAN','WYMAN','BRIAN.WYMAN@gmail.com',323,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (319,'RONALD','WEINER','RONALD.WEINER@gmail.com',324,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (320,'ANTHONY','SCHWAB','ANTHONY.SCHWAB@gmail.com',325,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (321,'KEVIN','SCHULER','KEVIN.SCHULER@gmail.com',326,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (322,'JASON','MORRISSEY','JASON.MORRISSEY@gmail.com',327,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (323,'MATTHEW','MAHAN','MATTHEW.MAHAN@gmail.com',328,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (324,'GARY','COY','GARY.COY@gmail.com',329,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (325,'TIMOTHY','BUNN','TIMOTHY.BUNN@gmail.com',330,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (326,'JOSE','ANDREW','JOSE.ANDREW@gmail.com',331,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (327,'LARRY','THRASHER','LARRY.THRASHER@gmail.com',332,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (328,'JEFFREY','SPEAR','JEFFREY.SPEAR@gmail.com',333,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (329,'FRANK','WAGGONER','FRANK.WAGGONER@gmail.com',334,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (330,'SCOTT','SHELLEY','SCOTT.SHELLEY@gmail.com',335,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (331,'ERIC','ROBERT','ERIC.ROBERT@gmail.com',336,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (332,'STEPHEN','QUALLS','STEPHEN.QUALLS@gmail.com',337,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (333,'ANDREW','PURDY','ANDREW.PURDY@gmail.com',338,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (334,'RAYMOND','MCWHORTER','RAYMOND.MCWHORTER@gmail.com',339,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (335,'GREGORY','MAULDIN','GREGORY.MAULDIN@gmail.com',340,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (336,'JOSHUA','MARK','JOSHUA.MARK@gmail.com',341,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (337,'JERRY','JORDON','JERRY.JORDON@gmail.com',342,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (338,'DENNIS','GILMAN','DENNIS.GILMAN@gmail.com',343,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (339,'WALTER','PERRYMAN','WALTER.PERRYMAN@gmail.com',344,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (340,'PATRICK','NEWSOM','PATRICK.NEWSOM@gmail.com',345,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (341,'PETER','MENARD','PETER.MENARD@gmail.com',346,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (342,'HAROLD','MARTINO','HAROLD.MARTINO@gmail.com',347,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (343,'DOUGLAS','GRAF','DOUGLAS.GRAF@gmail.com',348,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (344,'HENRY','BILLINGSLEY','HENRY.BILLINGSLEY@gmail.com',349,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (345,'CARL','ARTIS','CARL.ARTIS@gmail.com',350,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (346,'ARTHUR','SIMPKINS','ARTHUR.SIMPKINS@gmail.com',351,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (347,'RYAN','SALISBURY','RYAN.SALISBURY@gmail.com',352,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (348,'ROGER','QUINTANILLA','ROGER.QUINTANILLA@gmail.com',353,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (349,'JOE','GILLILAND','JOE.GILLILAND@gmail.com',354,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (350,'JUAN','FRALEY','JUAN.FRALEY@gmail.com',355,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (351,'JACK','FOUST','JACK.FOUST@gmail.com',356,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (352,'ALBERT','CROUSE','ALBERT.CROUSE@gmail.com',357,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (353,'JONATHAN','SCARBOROUGH','JONATHAN.SCARBOROUGH@gmail.com',358,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (354,'JUSTIN','NGO','JUSTIN.NGO@gmail.com',359,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (355,'TERRY','GRISSOM','TERRY.GRISSOM@gmail.com',360,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (356,'GERALD','FULTZ','GERALD.FULTZ@gmail.com',361,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (357,'KEITH','RICO','KEITH.RICO@gmail.com',362,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (358,'SAMUEL','MARLOW','SAMUEL.MARLOW@gmail.com',363,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (359,'WILLIE','MARKHAM','WILLIE.MARKHAM@gmail.com',364,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (360,'RALPH','MADRIGAL','RALPH.MADRIGAL@gmail.com',365,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (361,'LAWRENCE','LAWTON','LAWRENCE.LAWTON@gmail.com',366,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (362,'NICHOLAS','BARFIELD','NICHOLAS.BARFIELD@gmail.com',367,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (363,'ROY','WHITING','ROY.WHITING@gmail.com',368,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (364,'BENJAMIN','VARNEY','BENJAMIN.VARNEY@gmail.com',369,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (365,'BRUCE','SCHWARZ','BRUCE.SCHWARZ@gmail.com',370,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (366,'BRANDON','HUEY','BRANDON.HUEY@gmail.com',371,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (367,'ADAM','GOOCH','ADAM.GOOCH@gmail.com',372,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (368,'HARRY','ARCE','HARRY.ARCE@gmail.com',373,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (369,'FRED','WHEAT','FRED.WHEAT@gmail.com',374,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (370,'WAYNE','TRUONG','WAYNE.TRUONG@gmail.com',375,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (371,'BILLY','POULIN','BILLY.POULIN@gmail.com',376,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (372,'STEVE','MACKENZIE','STEVE.MACKENZIE@gmail.com',377,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (373,'LOUIS','LEONE','LOUIS.LEONE@gmail.com',378,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (374,'JEREMY','HURTADO','JEREMY.HURTADO@gmail.com',379,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (375,'AARON','SELBY','AARON.SELBY@gmail.com',380,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (376,'RANDY','GAITHER','RANDY.GAITHER@gmail.com',381,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (377,'HOWARD','FORTNER','HOWARD.FORTNER@gmail.com',382,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (378,'EUGENE','CULPEPPER','EUGENE.CULPEPPER@gmail.com',383,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (379,'CARLOS','COUGHLIN','CARLOS.COUGHLIN@gmail.com',384,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (380,'RUSSELL','BRINSON','RUSSELL.BRINSON@gmail.com',385,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (381,'BOBBY','BOUDREAU','BOBBY.BOUDREAU@gmail.com',386,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (382,'VICTOR','BARKLEY','VICTOR.BARKLEY@gmail.com',387,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (383,'MARTIN','BALES','MARTIN.BALES@gmail.com',388,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (384,'ERNEST','STEPP','ERNEST.STEPP@gmail.com',389,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (385,'PHILLIP','HOLM','PHILLIP.HOLM@gmail.com',390,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (386,'TODD','TAN','TODD.TAN@gmail.com',391,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (387,'JESSE','SCHILLING','JESSE.SCHILLING@gmail.com',392,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (388,'CRAIG','MORRELL','CRAIG.MORRELL@gmail.com',393,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (389,'ALAN','KAHN','ALAN.KAHN@gmail.com',394,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (390,'SHAWN','HEATON','SHAWN.HEATON@gmail.com',395,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (391,'CLARENCE','GAMEZ','CLARENCE.GAMEZ@gmail.com',396,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (392,'SEAN','DOUGLASS','SEAN.DOUGLASS@gmail.com',397,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (393,'PHILIP','CAUSEY','PHILIP.CAUSEY@gmail.com',398,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (394,'CHRIS','BROTHERS','CHRIS.BROTHERS@gmail.com',399,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (395,'JOHNNY','TURPIN','JOHNNY.TURPIN@gmail.com',400,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (396,'EARL','SHANKS','EARL.SHANKS@gmail.com',401,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (397,'JIMMY','SCHRADER','JIMMY.SCHRADER@gmail.com',402,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (398,'ANTONIO','MEEK','ANTONIO.MEEK@gmail.com',403,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (399,'DANNY','ISOM','DANNY.ISOM@gmail.com',404,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (400,'BRYAN','HARDISON','BRYAN.HARDISON@gmail.com',405,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (401,'TONY','CARRANZA','TONY.CARRANZA@gmail.com',406,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (402,'LUIS','YANEZ','LUIS.YANEZ@gmail.com',407,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (403,'MIKE','WAY','MIKE.WAY@gmail.com',408,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (404,'STANLEY','SCROGGINS','STANLEY.SCROGGINS@gmail.com',409,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (405,'LEONARD','SCHOFIELD','LEONARD.SCHOFIELD@gmail.com',410,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (406,'NATHAN','RUNYON','NATHAN.RUNYON@gmail.com',411,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (407,'DALE','RATCLIFF','DALE.RATCLIFF@gmail.com',412,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (408,'MANUEL','MURRELL','MANUEL.MURRELL@gmail.com',413,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (409,'RODNEY','MOELLER','RODNEY.MOELLER@gmail.com',414,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (410,'CURTIS','IRBY','CURTIS.IRBY@gmail.com',415,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (411,'NORMAN','CURRIER','NORMAN.CURRIER@gmail.com',416,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (412,'ALLEN','BUTTERFIELD','ALLEN.BUTTERFIELD@gmail.com',417,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (413,'MARVIN','YEE','MARVIN.YEE@gmail.com',418,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (414,'VINCENT','RALSTON','VINCENT.RALSTON@gmail.com',419,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (415,'GLENN','PULLEN','GLENN.PULLEN@gmail.com',420,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (416,'JEFFERY','PINSON','JEFFERY.PINSON@gmail.com',421,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (417,'TRAVIS','ESTEP','TRAVIS.ESTEP@gmail.com',422,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (418,'JEFF','EAST','JEFF.EAST@gmail.com',423,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (419,'CHAD','CARBONE','CHAD.CARBONE@gmail.com',424,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (420,'JACOB','LANCE','JACOB.LANCE@gmail.com',425,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (421,'LEE','HAWKS','LEE.HAWKS@gmail.com',426,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (422,'MELVIN','ELLINGTON','MELVIN.ELLINGTON@gmail.com',427,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (423,'ALFRED','CASILLAS','ALFRED.CASILLAS@gmail.com',428,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (424,'KYLE','SPURLOCK','KYLE.SPURLOCK@gmail.com',429,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (425,'FRANCIS','SIKES','FRANCIS.SIKES@gmail.com',430,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (426,'BRADLEY','MOTLEY','BRADLEY.MOTLEY@gmail.com',431,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (427,'JESUS','MCCARTNEY','JESUS.MCCARTNEY@gmail.com',432,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (428,'HERBERT','KRUGER','HERBERT.KRUGER@gmail.com',433,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (429,'FREDERICK','ISBELL','FREDERICK.ISBELL@gmail.com',434,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (430,'RAY','HOULE','RAY.HOULE@gmail.com',435,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (431,'JOEL','FRANCISCO','JOEL.FRANCISCO@gmail.com',436,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (432,'EDWIN','BURK','EDWIN.BURK@gmail.com',437,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (433,'DON','BONE','DON.BONE@gmail.com',438,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (434,'EDDIE','TOMLIN','EDDIE.TOMLIN@gmail.com',439,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (435,'RICKY','SHELBY','RICKY.SHELBY@gmail.com',440,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (436,'TROY','QUIGLEY','TROY.QUIGLEY@gmail.com',441,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (437,'RANDALL','NEUMANN','RANDALL.NEUMANN@gmail.com',442,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (438,'BARRY','LOVELACE','BARRY.LOVELACE@gmail.com',443,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (439,'ALEXANDER','FENNELL','ALEXANDER.FENNELL@gmail.com',444,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (440,'BERNARD','COLBY','BERNARD.COLBY@gmail.com',445,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (441,'MARIO','CHEATHAM','MARIO.CHEATHAM@gmail.com',446,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (442,'LEROY','BUSTAMANTE','LEROY.BUSTAMANTE@gmail.com',447,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (443,'FRANCISCO','SKIDMORE','FRANCISCO.SKIDMORE@gmail.com',448,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (444,'MARCUS','HIDALGO','MARCUS.HIDALGO@gmail.com',449,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (445,'MICHEAL','FORMAN','MICHEAL.FORMAN@gmail.com',450,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (446,'THEODORE','CULP','THEODORE.CULP@gmail.com',451,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (447,'CLIFFORD','BOWENS','CLIFFORD.BOWENS@gmail.com',452,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (448,'MIGUEL','BETANCOURT','MIGUEL.BETANCOURT@gmail.com',453,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (449,'OSCAR','AQUINO','OSCAR.AQUINO@gmail.com',454,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (450,'JAY','ROBB','JAY.ROBB@gmail.com',455,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (451,'JIM','REA','JIM.REA@gmail.com',456,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (452,'TOM','MILNER','TOM.MILNER@gmail.com',457,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (453,'CALVIN','MARTEL','CALVIN.MARTEL@gmail.com',458,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (454,'ALEX','GRESHAM','ALEX.GRESHAM@gmail.com',459,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (455,'JON','WILES','JON.WILES@gmail.com',460,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (456,'RONNIE','RICKETTS','RONNIE.RICKETTS@gmail.com',461,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (457,'BILL','GAVIN','BILL.GAVIN@gmail.com',462,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (458,'LLOYD','DOWD','LLOYD.DOWD@gmail.com',463,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (459,'TOMMY','COLLAZO','TOMMY.COLLAZO@gmail.com',464,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (460,'LEON','BOSTIC','LEON.BOSTIC@gmail.com',465,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (461,'DEREK','BLAKELY','DEREK.BLAKELY@gmail.com',466,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (462,'WARREN','SHERROD','WARREN.SHERROD@gmail.com',467,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (463,'DARRELL','POWER','DARRELL.POWER@gmail.com',468,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (464,'JEROME','KENYON','JEROME.KENYON@gmail.com',469,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (465,'FLOYD','GANDY','FLOYD.GANDY@gmail.com',470,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (466,'LEO','EBERT','LEO.EBERT@gmail.com',471,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (467,'ALVIN','DELOACH','ALVIN.DELOACH@gmail.com',472,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (468,'TIM','CARY','TIM.CARY@gmail.com',473,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (469,'WESLEY','BULL','WESLEY.BULL@gmail.com',474,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (470,'GORDON','ALLARD','GORDON.ALLARD@gmail.com',475,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (471,'DEAN','SAUER','DEAN.SAUER@gmail.com',476,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (472,'GREG','ROBINS','GREG.ROBINS@gmail.com',477,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (473,'JORGE','OLIVARES','JORGE.OLIVARES@gmail.com',478,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (474,'DUSTIN','GILLETTE','DUSTIN.GILLETTE@gmail.com',479,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (475,'PEDRO','CHESTNUT','PEDRO.CHESTNUT@gmail.com',480,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (476,'DERRICK','BOURQUE','DERRICK.BOURQUE@gmail.com',481,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (477,'DAN','PAINE','DAN.PAINE@gmail.com',482,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (478,'LEWIS','LYMAN','LEWIS.LYMAN@gmail.com',483,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (479,'ZACHARY','HITE','ZACHARY.HITE@gmail.com',484,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (480,'COREY','HAUSER','COREY.HAUSER@gmail.com',485,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (481,'HERMAN','DEVORE','HERMAN.DEVORE@gmail.com',486,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (482,'MAURICE','CRAWLEY','MAURICE.CRAWLEY@gmail.com',487,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (483,'VERNON','CHAPA','VERNON.CHAPA@gmail.com',488,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (484,'ROBERTO','VU','ROBERTO.VU@gmail.com',489,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (485,'CLYDE','TOBIAS','CLYDE.TOBIAS@gmail.com',490,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (486,'GLEN','TALBERT','GLEN.TALBERT@gmail.com',491,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (487,'HECTOR','POINDEXTER','HECTOR.POINDEXTER@gmail.com',492,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (488,'SHANE','MILLARD','SHANE.MILLARD@gmail.com',493,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (489,'RICARDO','MEADOR','RICARDO.MEADOR@gmail.com',494,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (490,'SAM','MCDUFFIE','SAM.MCDUFFIE@gmail.com',495,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (491,'RICK','MATTOX','RICK.MATTOX@gmail.com',496,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (492,'LESTER','KRAUS','LESTER.KRAUS@gmail.com',497,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (493,'BRENT','HARKINS','BRENT.HARKINS@gmail.com',498,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (494,'RAMON','CHOATE','RAMON.CHOATE@gmail.com',499,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (495,'CHARLIE','BESS','CHARLIE.BESS@gmail.com',500,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (496,'TYLER','WREN','TYLER.WREN@gmail.com',501,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (497,'GILBERT','SLEDGE','GILBERT.SLEDGE@gmail.com',502,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (498,'GENE','SANBORN','GENE.SANBORN@gmail.com',503,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (499,'MARC','OUTLAW','MARC.OUTLAW@gmail.com',504,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (500,'REGINALD','KINDER','REGINALD.KINDER@gmail.com',505,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (501,'RUBEN','GEARY','RUBEN.GEARY@gmail.com',506,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (502,'BRETT','CORNWELL','BRETT.CORNWELL@gmail.com',507,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (503,'ANGEL','BARCLAY','ANGEL.BARCLAY@gmail.com',508,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (504,'NATHANIEL','ADAM','NATHANIEL.ADAM@gmail.com',509,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (505,'RAFAEL','ABNEY','RAFAEL.ABNEY@gmail.com',510,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (506,'LESLIE','SEWARD','LESLIE.SEWARD@gmail.com',511,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (507,'EDGAR','RHOADS','EDGAR.RHOADS@gmail.com',512,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (508,'MILTON','HOWLAND','MILTON.HOWLAND@gmail.com',513,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (509,'RAUL','FORTIER','RAUL.FORTIER@gmail.com',514,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (510,'BEN','EASTER','BEN.EASTER@gmail.com',515,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (511,'CHESTER','BENNER','CHESTER.BENNER@gmail.com',516,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (512,'CECIL','VINES','CECIL.VINES@gmail.com',517,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (513,'DUANE','TUBBS','DUANE.TUBBS@gmail.com',519,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (514,'FRANKLIN','TROUTMAN','FRANKLIN.TROUTMAN@gmail.com',520,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (515,'ANDRE','RAPP','ANDRE.RAPP@gmail.com',521,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (516,'ELMER','NOE','ELMER.NOE@gmail.com',522,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (517,'BRAD','MCCURDY','BRAD.MCCURDY@gmail.com',523,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (518,'GABRIEL','HARDER','GABRIEL.HARDER@gmail.com',524,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (519,'RON','DELUCA','RON.DELUCA@gmail.com',525,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (520,'MITCHELL','WESTMORELAND','MITCHELL.WESTMORELAND@gmail.com',526,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (521,'ROLAND','SOUTH','ROLAND.SOUTH@gmail.com',527,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (522,'ARNOLD','HAVENS','ARNOLD.HAVENS@gmail.com',528,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (523,'HARVEY','GUAJARDO','HARVEY.GUAJARDO@gmail.com',529,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (524,'JARED','ELY','JARED.ELY@gmail.com',530,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (525,'ADRIAN','CLARY','ADRIAN.CLARY@gmail.com',531,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (526,'KARL','SEAL','KARL.SEAL@gmail.com',532,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (527,'CORY','MEEHAN','CORY.MEEHAN@gmail.com',533,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (528,'CLAUDE','HERZOG','CLAUDE.HERZOG@gmail.com',534,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (529,'ERIK','GUILLEN','ERIK.GUILLEN@gmail.com',535,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (530,'DARRYL','ASHCRAFT','DARRYL.ASHCRAFT@gmail.com',536,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (531,'JAMIE','WAUGH','JAMIE.WAUGH@gmail.com',537,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (532,'NEIL','RENNER','NEIL.RENNER@gmail.com',538,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (533,'JESSIE','MILAM','JESSIE.MILAM@gmail.com',539,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (534,'CHRISTIAN','JUNG','CHRISTIAN.JUNG@gmail.com',540,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (535,'JAVIER','ELROD','JAVIER.ELROD@gmail.com',541,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (536,'FERNANDO','CHURCHILL','FERNANDO.CHURCHILL@gmail.com',542,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (537,'CLINTON','BUFORD','CLINTON.BUFORD@gmail.com',543,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (538,'TED','BREAUX','TED.BREAUX@gmail.com',544,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (539,'MATHEW','BOLIN','MATHEW.BOLIN@gmail.com',545,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (540,'TYRONE','ASHER','TYRONE.ASHER@gmail.com',546,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (541,'DARREN','WINDHAM','DARREN.WINDHAM@gmail.com',547,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (542,'LONNIE','TIRADO','LONNIE.TIRADO@gmail.com',548,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (543,'LANCE','PEMBERTON','LANCE.PEMBERTON@gmail.com',549,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (544,'CODY','NOLEN','CODY.NOLEN@gmail.com',550,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (545,'JULIO','NOLAND','JULIO.NOLAND@gmail.com',551,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (546,'KELLY','KNOTT','KELLY.KNOTT@gmail.com',552,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (547,'KURT','EMMONS','KURT.EMMONS@gmail.com',553,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (548,'ALLAN','CORNISH','ALLAN.CORNISH@gmail.com',554,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (549,'NELSON','CHRISTENSON','NELSON.CHRISTENSON@gmail.com',555,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (550,'GUY','BROWNLEE','GUY.BROWNLEE@gmail.com',556,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (551,'CLAYTON','BARBEE','CLAYTON.BARBEE@gmail.com',557,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (552,'HUGH','WALDROP','HUGH.WALDROP@gmail.com',558,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (553,'MAX','PITT','MAX.PITT@gmail.com',559,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (554,'DWAYNE','OLVERA','DWAYNE.OLVERA@gmail.com',560,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (555,'DWIGHT','LOMBARDI','DWIGHT.LOMBARDI@gmail.com',561,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (556,'ARMANDO','GRUBER','ARMANDO.GRUBER@gmail.com',562,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (557,'FELIX','GAFFNEY','FELIX.GAFFNEY@gmail.com',563,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (558,'JIMMIE','EGGLESTON','JIMMIE.EGGLESTON@gmail.com',564,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (559,'EVERETT','BANDA','EVERETT.BANDA@gmail.com',565,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (560,'JORDAN','ARCHULETA','JORDAN.ARCHULETA@gmail.com',566,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (561,'IAN','STILL','IAN.STILL@gmail.com',567,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (562,'WALLACE','SLONE','WALLACE.SLONE@gmail.com',568,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (563,'KEN','PREWITT','KEN.PREWITT@gmail.com',569,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (564,'BOB','PFEIFFER','BOB.PFEIFFER@gmail.com',570,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (565,'JAIME','NETTLES','JAIME.NETTLES@gmail.com',571,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (566,'CASEY','MENA','CASEY.MENA@gmail.com',572,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (567,'ALFREDO','MCADAMS','ALFREDO.MCADAMS@gmail.com',573,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (568,'ALBERTO','HENNING','ALBERTO.HENNING@gmail.com',574,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (569,'DAVE','GARDINER','DAVE.GARDINER@gmail.com',575,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (570,'IVAN','CROMWELL','IVAN.CROMWELL@gmail.com',576,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (571,'JOHNNIE','CHISHOLM','JOHNNIE.CHISHOLM@gmail.com',577,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (572,'SIDNEY','BURLESON','SIDNEY.BURLESON@gmail.com',578,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (573,'BYRON','BOX','BYRON.BOX@gmail.com',579,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (574,'JULIAN','VEST','JULIAN.VEST@gmail.com',580,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (575,'ISAAC','OGLESBY','ISAAC.OGLESBY@gmail.com',581,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (576,'MORRIS','MCCARTER','MORRIS.MCCARTER@gmail.com',582,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (577,'CLIFTON','MALCOLM','CLIFTON.MALCOLM@gmail.com',583,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (578,'WILLARD','LUMPKIN','WILLARD.LUMPKIN@gmail.com',584,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (579,'DARYL','LARUE','DARYL.LARUE@gmail.com',585,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (580,'ROSS','GREY','ROSS.GREY@gmail.com',586,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (581,'VIRGIL','WOFFORD','VIRGIL.WOFFORD@gmail.com',587,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (582,'ANDY','VANHORN','ANDY.VANHORN@gmail.com',588,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (583,'MARSHALL','THORN','MARSHALL.THORN@gmail.com',589,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (584,'SALVADOR','TEEL','SALVADOR.TEEL@gmail.com',590,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (585,'PERRY','SWAFFORD','PERRY.SWAFFORD@gmail.com',591,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (586,'KIRK','STCLAIR','KIRK.STCLAIR@gmail.com',592,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (587,'SERGIO','STANFIELD','SERGIO.STANFIELD@gmail.com',593,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (588,'MARION','OCAMPO','MARION.OCAMPO@gmail.com',594,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (589,'TRACY','HERRMANN','TRACY.HERRMANN@gmail.com',595,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (590,'SETH','HANNON','SETH.HANNON@gmail.com',596,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (591,'KENT','ARSENAULT','KENT.ARSENAULT@gmail.com',597,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (592,'TERRANCE','ROUSH','TERRANCE.ROUSH@gmail.com',598,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (593,'RENE','MCALISTER','RENE.MCALISTER@gmail.com',599,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (594,'EDUARDO','HIATT','EDUARDO.HIATT@gmail.com',600,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (595,'TERRENCE','GUNDERSON','TERRENCE.GUNDERSON@gmail.com',601,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (596,'ENRIQUE','FORSYTHE','ENRIQUE.FORSYTHE@gmail.com',602,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (597,'FREDDIE','DUGGAN','FREDDIE.DUGGAN@gmail.com',603,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (598,'WADE','DELVALLE','WADE.DELVALLE@gmail.com',604,'2006-02-14 22:04:37');
INSERT INTO buyer(buyer_id,first_name,last_name,email,addr_id,create_date) VALUES (599,'AUSTIN','CINTRON','AUSTIN.CINTRON@gmail.com',605,'2006-02-14 22:04:37');



INSERT INTO employee(employee_id,first_name,last_name,addr_id,email,active,username,password) VALUES (1,'Mike','Hillyer',3,'Mike.Hillyer@gmail.com',TRUE,'Mike','1b83d5da74032b6a750ef12210642eea');
INSERT INTO employee(employee_id,first_name,last_name,addr_id,email,active,username,password) VALUES (2,'Jon','Stephens',4,'Jon.Stephens@gmail.com',TRUE,'Jon','48bc893fcbc0a33ed3ad2cf2d5d57cfe');
INSERT INTO employee(employee_id,first_name,last_name,addr_id,email,active,username,password) VALUES (3,'Aayush','G',1,'aayush@gmail.com',TRUE,'aayush','cdac31f8cea6e3e74c29c0c956857cd2');
INSERT INTO employee(employee_id,first_name,last_name,addr_id,email,active,username,password) VALUES (4,'Sachin','N',1,'sachin@gmail.com',FALSE,'Sachin','da06872edafe1ffa430603666e5fe8db');
INSERT INTO employee(employee_id,first_name,last_name,addr_id,email,active,username,password) VALUES (5,'Aarush','T',3,'aarush@gmail.com',TRUE,'Aarush','b7bf94d0dfc54742feb1c720515d067e');




INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (32,'2005-05-25 04:06:21',230,'2005-05-25 23:55:21',1,1);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (21,'2005-05-25 01:59:46',388,'2005-05-26 01:01:46',2,2);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (14,'2005-05-25 00:31:15',446,'2005-05-26 02:56:15',1,3);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (16,'2005-05-25 00:43:11',316,'2005-05-26 04:42:11',2,4);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (22,'2005-05-25 02:19:23',509,'2005-05-26 04:52:23',2,5);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (51,'2005-05-25 06:49:10',256,'2005-05-26 06:42:10',1,6);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (43,'2005-05-25 05:39:25',532,'2005-05-26 06:54:25',2,7);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (28,'2005-05-25 03:42:37',232,'2005-05-26 09:26:37',2,8);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (74,'2005-05-25 11:09:48',265,'2005-05-26 12:23:48',2,9);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (56,'2005-05-25 08:28:11',511,'2005-05-26 14:21:11',1,10);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (116,'2005-05-25 19:27:51',18,'2005-05-26 16:23:51',1,11);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (77,'2005-05-25 11:31:59',451,'2005-05-26 16:53:59',2,12);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (123,'2005-05-25 20:26:42',43,'2005-05-26 19:41:42',1,13);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (157,'2005-05-26 01:25:21',344,'2005-05-26 21:17:21',2,14);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (1,'2005-05-24 22:53:30',130,'2005-05-26 22:04:30',1,15);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (188,'2005-05-26 05:47:12',243,'2005-05-26 23:48:12',1,16);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (17,'2005-05-25 01:06:36',575,'2005-05-27 00:43:36',1,17);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (140,'2005-05-25 23:34:22',354,'2005-05-27 01:10:22',1,18);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (24,'2005-05-25 02:53:02',350,'2005-05-27 01:15:02',1,19);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (6,'2005-05-24 23:08:07',549,'2005-05-27 01:32:07',1,20);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (169,'2005-05-26 03:09:30',381,'2005-05-27 01:37:30',2,21);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (20,'2005-05-25 01:48:41',185,'2005-05-27 02:20:41',2,22);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (167,'2005-05-26 02:50:31',401,'2005-05-27 03:07:31',1,23);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (162,'2005-05-26 02:02:05',296,'2005-05-27 03:38:05',2,24);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (33,'2005-05-25 04:18:51',272,'2005-05-27 03:58:51',1,25);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (63,'2005-05-25 09:19:16',383,'2005-05-27 04:24:16',1,26);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (53,'2005-05-25 07:19:16',569,'2005-05-27 05:19:16',2,27);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (161,'2005-05-26 01:51:48',182,'2005-05-27 05:42:48',1,28);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (70,'2005-05-25 10:15:23',73,'2005-05-27 05:56:23',2,29);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (189,'2005-05-26 06:01:41',247,'2005-05-27 06:11:41',1,30);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (35,'2005-05-25 04:24:36',484,'2005-05-27 07:02:36',2,31);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (196,'2005-05-26 06:55:58',184,'2005-05-27 10:54:58',1,32);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (98,'2005-05-25 16:48:24',269,'2005-05-27 11:29:24',2,33);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (67,'2005-05-25 09:41:01',119,'2005-05-27 13:46:01',2,34);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (69,'2005-05-25 10:10:14',305,'2005-05-27 14:02:14',2,35);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (104,'2005-05-25 17:46:33',310,'2005-05-27 15:20:33',1,36);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (83,'2005-05-25 12:30:15',131,'2005-05-27 15:40:15',1,37);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (25,'2005-05-25 03:21:20',37,'2005-05-27 21:25:20',2,38);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (153,'2005-05-26 00:47:47',348,'2005-05-27 21:28:47',1,39);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (143,'2005-05-25 23:45:52',297,'2005-05-27 21:41:52',2,40);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (113,'2005-05-25 19:07:40',93,'2005-05-27 22:16:40',2,41);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (40,'2005-05-25 05:09:04',413,'2005-05-27 23:12:04',1,42);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (8,'2005-05-24 23:31:46',239,'2005-05-27 23:33:46',2,43);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (156,'2005-05-26 01:19:05',462,'2005-05-27 23:43:05',1,44);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (9,'2005-05-25 00:00:40',126,'2005-05-28 00:22:40',1,45);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (164,'2005-05-26 02:26:49',151,'2005-05-28 00:32:49',1,46);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (173,'2005-05-26 03:42:10',533,'2005-05-28 01:37:10',2,47);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (71,'2005-05-25 10:26:39',100,'2005-05-28 04:59:39',1,48);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (191,'2005-05-26 06:14:06',412,'2005-05-28 05:33:06',1,49);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (72,'2005-05-25 10:52:13',48,'2005-05-28 05:52:13',2,1);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (174,'2005-05-26 03:44:10',552,'2005-05-28 07:13:10',2,2);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (199,'2005-05-26 07:11:58',71,'2005-05-28 09:06:58',1,3);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (184,'2005-05-26 05:29:49',556,'2005-05-28 10:10:49',1,4);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (50,'2005-05-25 06:44:53',18,'2005-05-28 11:28:53',2,5);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (97,'2005-05-25 16:34:24',263,'2005-05-28 12:13:24',2,6);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (58,'2005-05-25 08:53:14',323,'2005-05-28 14:40:14',1,7);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (111,'2005-05-25 18:45:19',227,'2005-05-28 17:18:19',1,8);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (126,'2005-05-25 21:07:59',439,'2005-05-28 18:51:59',1,9);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (99,'2005-05-25 16:50:20',44,'2005-05-28 18:52:20',1,10);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (2,'2005-05-24 22:54:33',459,'2005-05-28 19:40:33',1,11);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (34,'2005-05-25 04:19:28',597,'2005-05-29 00:10:28',2,12);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (36,'2005-05-25 04:36:26',88,'2005-05-29 00:31:26',1,13);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (142,'2005-05-25 23:43:47',472,'2005-05-29 00:46:47',2,14);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (37,'2005-05-25 04:44:31',535,'2005-05-29 01:03:31',1,15);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (159,'2005-05-26 01:34:28',505,'2005-05-29 04:00:28',1,16);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (172,'2005-05-26 03:17:42',176,'2005-05-29 04:11:42',2,17);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (66,'2005-05-25 09:35:12',86,'2005-05-29 04:16:12',2,18);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (181,'2005-05-26 04:47:06',587,'2005-05-29 06:34:06',2,19);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (23,'2005-05-25 02:40:21',438,'2005-05-29 06:34:21',1,20);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (57,'2005-05-25 08:43:32',6,'2005-05-29 06:42:32',2,21);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (88,'2005-05-25 14:13:54',53,'2005-05-29 09:32:54',2,22);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (44,'2005-05-25 05:53:23',207,'2005-05-29 10:56:23',2,23);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (87,'2005-05-25 13:52:43',331,'2005-05-29 11:12:43',2,24);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (65,'2005-05-25 09:32:03',346,'2005-05-29 14:21:03',1,25);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (89,'2005-05-25 14:28:29',499,'2005-05-29 14:33:29',1,26);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (85,'2005-05-25 13:05:34',414,'2005-05-29 16:53:34',1,27);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (139,'2005-05-25 23:00:21',257,'2005-05-29 17:12:21',1,28);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (84,'2005-05-25 12:36:30',492,'2005-05-29 18:33:30',1,29);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (115,'2005-05-25 19:13:25',455,'2005-05-29 20:17:25',1,30);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (138,'2005-05-25 22:48:22',586,'2005-05-29 20:21:22',2,31);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (7,'2005-05-24 23:11:53',269,'2005-05-29 20:34:53',2,32);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (109,'2005-05-25 18:40:20',503,'2005-05-29 20:39:20',2,33);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (121,'2005-05-25 19:41:29',405,'2005-05-29 21:31:29',1,34);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (154,'2005-05-26 00:55:56',185,'2005-05-29 23:18:56',2,35);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (147,'2005-05-26 00:17:50',274,'2005-05-29 23:21:50',2,36);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (128,'2005-05-25 21:19:53',40,'2005-05-29 23:34:53',1,37);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (119,'2005-05-25 19:37:02',51,'2005-05-29 23:51:02',2,38);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (133,'2005-05-25 21:48:30',237,'2005-05-30 00:26:30',2,39);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (29,'2005-05-25 03:47:12',44,'2005-05-30 00:31:12',2,40);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (124,'2005-05-25 20:46:11',246,'2005-05-30 00:47:11',2,41);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (27,'2005-05-25 03:41:50',301,'2005-05-30 01:13:50',2,42);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (47,'2005-05-25 06:05:20',35,'2005-05-30 03:04:20',1,43);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (30,'2005-05-25 04:01:32',430,'2005-05-30 03:12:32',1,44);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (194,'2005-05-26 06:52:33',29,'2005-05-30 04:08:33',2,45);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (13,'2005-05-25 00:22:55',334,'2005-05-30 04:28:55',1,46);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (12,'2005-05-25 00:19:27',261,'2005-05-30 05:44:27',2,47);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (193,'2005-05-26 06:41:48',270,'2005-05-30 06:21:48',2,48);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (151,'2005-05-26 00:37:28',14,'2005-05-30 06:28:28',1,49);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (31,'2005-05-25 04:05:17',369,'2005-05-30 07:15:17',1,50);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (49,'2005-05-25 06:39:35',498,'2005-05-30 10:12:35',2,1);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (96,'2005-05-25 16:32:19',49,'2005-05-30 10:47:19',2,2);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (62,'2005-05-25 09:18:52',419,'2005-05-30 10:55:52',1,3);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (55,'2005-05-25 08:26:13',131,'2005-05-30 10:57:13',1,4);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (105,'2005-05-25 17:54:12',108,'2005-05-30 12:03:12',2,5);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (60,'2005-05-25 08:58:25',470,'2005-05-30 14:14:25',1,6);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (94,'2005-05-25 16:03:42',197,'2005-05-30 14:23:42',1,7);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (86,'2005-05-25 13:36:12',266,'2005-05-30 14:53:12',1,8);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (108,'2005-05-25 18:30:05',242,'2005-05-30 19:40:05',1,9);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (130,'2005-05-25 21:21:56',56,'2005-05-30 22:41:56',2,10);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (131,'2005-05-25 21:42:46',325,'2005-05-30 23:25:46',2,11);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (26,'2005-05-25 03:36:50',371,'2005-05-31 00:34:50',1,12);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (52,'2005-05-25 06:51:29',507,'2005-05-31 01:27:29',2,13);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (166,'2005-05-26 02:49:11',322,'2005-05-31 01:28:11',1,14);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (195,'2005-05-26 06:52:36',564,'2005-05-31 02:47:36',2,15);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (42,'2005-05-25 05:24:58',523,'2005-05-31 02:47:58',2,16);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (145,'2005-05-25 23:59:03',82,'2005-05-31 02:56:03',1,17);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (39,'2005-05-25 04:51:46',207,'2005-05-31 03:14:46',2,18);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (19,'2005-05-25 01:17:24',456,'2005-05-31 06:00:24',1,19);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (18,'2005-05-25 01:10:47',19,'2005-05-31 06:35:47',2,20);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (68,'2005-05-25 09:47:31',120,'2005-05-31 10:20:31',2,21);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (200,'2005-05-26 07:12:21',321,'2005-05-31 12:07:21',1,22);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (78,'2005-05-25 11:35:18',135,'2005-05-31 12:48:18',2,23);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (92,'2005-05-25 15:38:46',302,'2005-05-31 13:40:46',2,24);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (118,'2005-05-25 19:31:18',524,'2005-05-31 15:00:18',1,25);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (80,'2005-05-25 12:12:07',314,'2005-05-31 17:46:07',2,26);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (136,'2005-05-25 22:02:30',504,'2005-05-31 18:06:30',1,27);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (101,'2005-05-25 17:17:04',468,'2005-05-31 19:47:04',1,28);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (102,'2005-05-25 17:22:10',343,'2005-05-31 19:47:10',1,29);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (132,'2005-05-25 21:46:54',479,'2005-05-31 21:02:54',1,30);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (10,'2005-05-25 00:02:21',399,'2005-05-31 22:44:21',2,31);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (117,'2005-05-25 19:30:46',7,'2005-05-31 23:59:46',2,32);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (155,'2005-05-26 01:15:05',551,'2005-06-01 00:03:05',1,33);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (38,'2005-05-25 04:47:44',302,'2005-06-01 00:58:44',1,34);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (150,'2005-05-26 00:28:39',429,'2005-06-01 02:10:39',2,35);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (137,'2005-05-25 22:25:18',560,'2005-06-01 02:30:18',2,36);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (176,'2005-05-26 03:47:39',250,'2005-06-01 02:36:39',2,37);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (54,'2005-05-25 07:23:25',291,'2005-06-01 05:05:25',2,38);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (182,'2005-05-26 04:49:17',237,'2005-06-01 05:43:17',2,39);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (160,'2005-05-26 01:46:20',290,'2005-06-01 05:45:20',1,40);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (177,'2005-05-26 04:14:29',548,'2005-06-01 08:16:29',2,41);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (183,'2005-05-26 05:01:18',254,'2005-06-01 09:04:18',1,42);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (190,'2005-05-26 06:11:28',533,'2005-06-01 09:44:28',1,43);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (59,'2005-05-25 08:56:42',408,'2005-06-01 09:52:42',1,44);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (180,'2005-05-26 04:46:23',75,'2005-06-01 09:58:23',1,45);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (90,'2005-05-25 14:31:25',25,'2005-06-01 10:07:25',1,46);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (82,'2005-05-25 12:17:46',427,'2005-06-01 10:48:46',1,47);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (73,'2005-05-25 11:00:07',391,'2005-06-01 13:56:07',2,48);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (91,'2005-05-25 14:57:22',267,'2005-06-01 18:32:22',1,49);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (148,'2005-05-26 00:25:23',142,'2005-06-01 19:29:23',2,50);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (144,'2005-05-25 23:49:56',357,'2005-06-01 21:41:56',2,1);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (3,'2005-05-24 23:03:39',408,'2005-06-01 22:12:39',1,2);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (114,'2005-05-25 19:12:42',506,'2005-06-01 23:10:42',1,3);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (120,'2005-05-25 19:37:47',365,'2005-06-01 23:29:47',2,4);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (41,'2005-05-25 05:12:29',174,'2005-06-02 00:28:29',1,5);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (141,'2005-05-25 23:34:53',89,'2005-06-02 01:57:53',1,6);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (168,'2005-05-26 03:07:43',469,'2005-06-02 02:09:43',2,7);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (165,'2005-05-26 02:28:36',33,'2005-06-02 03:21:36',1,8);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (170,'2005-05-26 03:11:12',107,'2005-06-02 03:53:12',1,9);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (5,'2005-05-24 23:05:21',222,'2005-06-02 04:33:21',1,10);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (48,'2005-05-25 06:20:46',282,'2005-06-02 05:42:46',1,11);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (61,'2005-05-25 09:01:57',250,'2005-06-02 07:22:57',2,12);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (46,'2005-05-25 06:04:08',7,'2005-06-02 08:18:08',2,13);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (185,'2005-05-26 05:30:03',125,'2005-06-02 09:48:03',2,14);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (45,'2005-05-25 05:59:39',436,'2005-06-02 09:56:39',2,15);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (192,'2005-05-26 06:20:37',437,'2005-06-02 10:57:37',1,16);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (81,'2005-05-25 12:15:19',286,'2005-06-02 14:08:19',2,17);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (134,'2005-05-25 21:48:41',222,'2005-06-02 18:28:41',1,18);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (95,'2005-05-25 16:12:52',400,'2005-06-02 18:55:52',2,19);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (122,'2005-05-25 19:46:21',273,'2005-06-02 19:07:21',1,20);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (112,'2005-05-25 18:57:24',500,'2005-06-02 20:44:24',1,21);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (11,'2005-05-25 00:09:02',142,'2005-06-02 20:56:02',2,22);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (149,'2005-05-26 00:28:05',319,'2005-06-02 21:30:05',2,23);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (127,'2005-05-25 21:10:40',94,'2005-06-02 21:38:40',1,24);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (125,'2005-05-25 20:48:50',368,'2005-06-02 21:39:50',1,25);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (100,'2005-05-25 16:50:28',208,'2005-06-02 22:11:28',1,26);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (171,'2005-05-26 03:14:15',400,'2005-06-03 00:24:15',2,27);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (158,'2005-05-26 01:27:11',354,'2005-06-03 00:30:11',2,28);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (4,'2005-05-24 23:04:41',333,'2005-06-03 01:43:41',2,29);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (15,'2005-05-25 00:39:22',319,'2005-06-03 03:30:22',1,30);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (197,'2005-05-26 06:59:21',546,'2005-06-03 05:04:21',2,31);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (175,'2005-05-26 03:46:26',47,'2005-06-03 06:01:26',2,32);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (152,'2005-05-26 00:41:10',57,'2005-06-03 06:05:10',1,33);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (186,'2005-05-26 05:32:52',468,'2005-06-03 07:19:52',2,34);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (179,'2005-05-26 04:26:06',19,'2005-06-03 10:06:06',1,35);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (79,'2005-05-25 12:11:07',245,'2005-06-03 10:54:07',2,36);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (64,'2005-05-25 09:21:29',368,'2005-06-03 11:31:29',1,37);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (76,'2005-05-25 11:30:37',1,'2005-06-03 12:00:37',2,38);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (75,'2005-05-25 11:13:34',510,'2005-06-03 12:58:34',1,39);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (135,'2005-05-25 21:58:58',304,'2005-06-03 17:50:58',1,40);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (110,'2005-05-25 18:43:49',19,'2005-06-03 18:13:49',2,41);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (93,'2005-05-25 15:54:16',288,'2005-06-03 20:18:16',1,42);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (103,'2005-05-25 17:30:42',384,'2005-06-03 22:36:42',1,43);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (107,'2005-05-25 18:28:09',317,'2005-06-03 22:46:09',2,44);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (106,'2005-05-25 18:18:19',196,'2005-06-04 00:01:19',2,45);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (146,'2005-05-26 00:07:11',433,'2005-06-04 00:20:11',2,46);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (187,'2005-05-26 05:42:37',515,'2005-06-04 00:38:37',1,47);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (129,'2005-05-25 21:20:03',23,'2005-06-04 01:25:03',2,48);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (163,'2005-05-26 02:26:23',104,'2005-06-04 06:36:23',1,49);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (178,'2005-05-26 04:21:46',196,'2005-06-04 07:09:46',2,50);
INSERT INTO rental(rental_id,rental_date,buyer_id,return_date,employee_id,movie_id) VALUES (198,'2005-05-26 07:03:49',54,'2005-06-04 11:45:49',1,1);



INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (174,7,2,1,5.99,'2005-05-25 06:04:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (146,6,2,2,4.99,'2005-05-25 08:43:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (1,1,1,3,2.99,'2005-05-25 11:30:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (175,7,2,4,0.99,'2005-05-25 19:30:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (33,2,1,5,4.99,'2005-05-27 00:09:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (60,3,1,6,1.99,'2005-05-27 17:17:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (2,1,1,7,0.99,'2005-05-28 10:35:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (147,6,1,8,2.99,'2005-05-28 11:09:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (108,5,1,9,0.99,'2005-05-29 07:25:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (176,7,2,10,2.99,'2005-05-29 09:27:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (61,3,1,11,2.99,'2005-05-29 22:43:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (148,6,2,12,0.99,'2005-05-30 11:25:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (177,7,1,13,4.99,'2005-05-30 21:07:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (178,7,1,14,5.99,'2005-05-31 08:44:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (109,5,1,15,6.99,'2005-05-31 11:15:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (110,5,1,16,1.99,'2005-05-31 19:46:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (3,1,1,17,5.99,'2005-06-15 00:54:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (86,4,1,18,4.99,'2005-06-15 09:31:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (4,1,2,19,0.99,'2005-06-15 18:02:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (5,1,2,20,9.99,'2005-06-15 21:08:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (111,5,1,21,3.99,'2005-06-15 22:03:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (62,3,1,22,8.99,'2005-06-16 01:34:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (149,6,1,23,3.99,'2005-06-16 03:41:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (112,5,2,24,2.99,'2005-06-16 08:01:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (87,4,1,25,0.99,'2005-06-16 08:08:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (88,4,2,26,2.99,'2005-06-16 14:01:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (6,1,1,27,4.99,'2005-06-16 15:18:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (63,3,1,28,6.99,'2005-06-16 15:19:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (89,4,2,29,0.99,'2005-06-16 15:51:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (179,7,2,30,0.99,'2005-06-16 21:06:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (150,6,2,31,2.99,'2005-06-16 23:44:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (64,3,2,32,6.99,'2005-06-17 05:15:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (151,6,1,33,0.99,'2005-06-17 09:19:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (90,4,2,34,0.99,'2005-06-17 14:31:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (113,5,2,35,4.99,'2005-06-17 15:56:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (34,2,1,36,2.99,'2005-06-17 20:54:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (180,7,1,37,2.99,'2005-06-18 05:03:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (7,1,1,38,4.99,'2005-06-18 08:41:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (152,6,1,39,0.99,'2005-06-18 12:03:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (8,1,2,40,0.99,'2005-06-18 13:33:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (114,5,2,41,2.99,'2005-06-19 04:20:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (65,3,1,42,2.99,'2005-06-19 08:34:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (91,4,1,43,5.99,'2005-06-19 09:39:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (181,7,1,44,0.99,'2005-06-19 14:00:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (182,7,1,45,4.99,'2005-06-20 01:50:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (183,7,1,46,0.99,'2005-06-20 10:11:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (115,5,2,47,4.99,'2005-06-20 18:38:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (9,1,1,48,3.99,'2005-06-21 06:24:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (184,7,2,49,5.99,'2005-07-06 07:09:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (116,5,2,50,4.99,'2005-07-06 09:11:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (153,6,2,51,0.99,'2005-07-06 23:14:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (66,3,1,52,4.99,'2005-07-07 10:23:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (185,7,2,53,2.99,'2005-07-07 13:22:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (154,6,2,54,2.99,'2005-07-07 14:53:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (10,1,2,55,5.99,'2005-07-08 03:17:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (11,1,1,56,5.99,'2005-07-08 07:33:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (67,3,1,57,4.99,'2005-07-08 12:47:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (186,7,2,58,5.99,'2005-07-08 16:16:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (187,7,1,59,4.99,'2005-07-08 18:47:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (117,5,2,60,2.99,'2005-07-08 20:04:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (118,5,1,61,4.99,'2005-07-09 01:57:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (119,5,2,62,5.99,'2005-07-09 07:13:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (120,5,2,63,1.99,'2005-07-09 08:51:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (12,1,1,64,4.99,'2005-07-09 13:24:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (13,1,1,65,4.99,'2005-07-09 16:38:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (188,7,1,66,8.99,'2005-07-09 21:52:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (155,6,1,67,0.99,'2005-07-10 03:03:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (35,2,1,68,2.99,'2005-07-10 06:31:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (121,5,2,69,0.99,'2005-07-10 11:09:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (36,2,1,70,6.99,'2005-07-10 12:38:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (189,7,1,71,7.99,'2005-07-10 21:35:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (122,5,1,72,8.99,'2005-07-11 03:17:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (14,1,1,73,7.99,'2005-07-11 10:13:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (190,7,1,74,1.99,'2005-07-11 10:36:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (156,6,2,75,5.99,'2005-07-11 12:39:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (157,6,1,76,7.99,'2005-07-11 15:01:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (191,7,1,77,2.99,'2005-07-11 17:30:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (123,5,1,78,3.99,'2005-07-12 11:27:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (124,5,2,79,4.99,'2005-07-12 12:16:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (158,6,2,80,0.99,'2005-07-12 12:18:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (192,7,2,81,3.99,'2005-07-12 15:17:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (68,3,1,82,5.99,'2005-07-27 04:54:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (159,6,2,83,2.99,'2005-07-27 05:03:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (160,6,2,84,2.99,'2005-07-27 06:38:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (15,1,2,85,2.99,'2005-07-27 11:31:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (125,5,2,86,0.99,'2005-07-27 12:37:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (37,2,2,87,4.99,'2005-07-27 14:30:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (38,2,1,88,5.99,'2005-07-27 15:23:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (39,2,2,89,5.99,'2005-07-27 18:40:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (69,3,2,90,10.99,'2005-07-27 20:23:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (126,5,2,91,0.99,'2005-07-28 01:50:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (92,4,1,92,2.99,'2005-07-28 02:10:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (70,3,2,93,7.99,'2005-07-28 03:59:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (93,4,2,94,2.99,'2005-07-28 04:37:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (71,3,2,95,6.99,'2005-07-28 04:46:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (127,5,2,96,3.99,'2005-07-28 08:43:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (16,1,1,97,4.99,'2005-07-28 09:04:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (72,3,1,98,4.99,'2005-07-28 11:46:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (17,1,2,99,4.99,'2005-07-28 16:18:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (18,1,1,100,0.99,'2005-07-28 17:33:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (73,3,2,101,4.99,'2005-07-28 18:17:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (161,6,1,102,0.99,'2005-07-28 18:47:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (19,1,2,103,0.99,'2005-07-28 19:20:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (40,2,2,104,5.99,'2005-07-29 00:12:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (128,5,1,105,2.99,'2005-07-29 01:11:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (20,1,2,106,2.99,'2005-07-29 03:58:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (193,7,2,107,5.99,'2005-07-29 07:02:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (74,3,1,108,2.99,'2005-07-29 11:07:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (41,2,1,109,2.99,'2005-07-29 12:56:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (42,2,2,110,5.99,'2005-07-29 17:14:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (94,4,1,111,3.99,'2005-07-29 18:44:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (129,5,1,112,1.99,'2005-07-30 04:14:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (43,2,1,113,4.99,'2005-07-30 06:06:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (95,4,1,114,5.99,'2005-07-30 08:46:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (75,3,1,115,1.99,'2005-07-30 13:31:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (44,2,2,116,10.99,'2005-07-30 13:47:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (45,2,2,117,0.99,'2005-07-30 14:14:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (46,2,2,118,6.99,'2005-07-30 16:21:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (96,4,1,119,5.99,'2005-07-30 18:58:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (76,3,2,120,3.99,'2005-07-30 21:45:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (47,2,2,121,6.99,'2005-07-30 22:39:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (130,5,1,122,4.99,'2005-07-30 23:52:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (21,1,2,123,2.99,'2005-07-31 02:42:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (77,3,1,124,2.99,'2005-07-31 03:27:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (194,7,2,125,7.99,'2005-07-31 04:30:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (78,3,2,126,4.99,'2005-07-31 11:32:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (131,5,1,127,3.99,'2005-07-31 14:00:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (48,2,1,128,2.99,'2005-07-31 21:58:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (162,6,1,129,2.99,'2005-08-01 03:13:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (195,7,2,130,6.99,'2005-08-01 04:57:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (196,7,1,131,5.99,'2005-08-01 08:19:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (22,1,2,132,4.99,'2005-08-01 08:51:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (49,2,1,133,0.99,'2005-08-01 09:45:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (197,7,1,134,4.99,'2005-08-01 11:39:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (79,3,2,135,5.99,'2005-08-01 14:19:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (132,5,2,136,4.99,'2005-08-01 14:48:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (133,5,1,137,0.99,'2005-08-01 15:27:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (198,7,2,138,4.99,'2005-08-01 15:52:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (50,2,1,139,0.99,'2005-08-02 02:10:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (199,7,2,140,3.99,'2005-08-02 04:40:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (134,5,2,141,4.99,'2005-08-02 04:56:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (163,6,1,142,2.99,'2005-08-02 05:36:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (97,4,2,143,0.99,'2005-08-02 07:09:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (51,2,1,144,5.99,'2005-08-02 07:41:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (98,4,1,145,2.99,'2005-08-02 08:20:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (52,2,1,146,6.99,'2005-08-02 10:43:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (135,5,1,147,4.99,'2005-08-02 10:50:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (53,2,2,148,2.99,'2005-08-02 13:44:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (23,1,2,149,3.99,'2005-08-02 15:36:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (24,1,1,150,0.99,'2005-08-02 18:01:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (164,6,1,151,3.99,'2005-08-02 18:55:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (99,4,2,152,4.99,'2005-08-17 00:28:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (200,7,2,153,7.99,'2005-08-17 00:51:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (165,6,1,154,6.99,'2005-08-17 02:29:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (54,2,1,155,2.99,'2005-08-17 03:52:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (166,6,1,156,0.99,'2005-08-17 08:12:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (25,1,2,157,4.99,'2005-08-17 12:37:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (167,6,1,158,0.99,'2005-08-17 13:39:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (136,5,2,159,3.99,'2005-08-17 16:28:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (137,5,1,160,9.99,'2005-08-18 00:10:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (100,4,1,161,2.99,'2005-08-18 00:14:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (26,1,1,162,0.99,'2005-08-18 03:57:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (168,6,2,163,2.99,'2005-08-18 04:05:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (101,4,2,164,8.99,'2005-08-18 05:14:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (80,3,2,165,4.99,'2005-08-18 14:49:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (138,5,1,166,2.99,'2005-08-19 00:24:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (102,4,2,167,1.99,'2005-08-19 02:19:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (55,2,1,168,2.99,'2005-08-19 06:26:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (139,5,1,169,1.99,'2005-08-19 09:45:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (27,1,2,170,0.99,'2005-08-19 09:55:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (28,1,2,171,2.99,'2005-08-19 13:56:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (145,5,2,172,0.99,'2006-02-14 15:16:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (81,3,1,173,8.99,'2005-08-19 22:18:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (169,6,2,174,6.99,'2005-08-20 00:18:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (82,3,2,175,2.99,'2005-08-20 06:14:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (103,4,1,176,2.99,'2005-08-20 09:32:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (104,4,1,177,6.99,'2005-08-20 12:55:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (140,5,2,178,0.99,'2005-08-20 15:16:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (141,5,2,179,6.99,'2005-08-20 22:13:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (105,4,2,180,4.99,'2005-08-21 04:53:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (170,6,1,181,7.99,'2005-08-21 08:22:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (171,6,1,182,4.99,'2005-08-21 09:49:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (142,5,1,183,6.99,'2005-08-21 11:31:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (56,2,1,184,4.99,'2005-08-21 13:24:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (143,5,2,185,2.99,'2005-08-21 14:02:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (83,3,2,186,8.99,'2005-08-21 20:50:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (57,2,2,187,5.99,'2005-08-21 22:41:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (29,1,1,188,0.99,'2005-08-21 23:33:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (30,1,1,189,1.99,'2005-08-22 01:27:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (84,3,2,190,0.99,'2005-08-22 09:37:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (58,2,2,191,4.99,'2005-08-22 13:53:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (106,4,1,192,2.99,'2005-08-22 13:58:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (144,5,2,193,0.99,'2005-08-22 17:37:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (31,1,2,194,2.99,'2005-08-22 19:41:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (32,1,1,195,5.99,'2005-08-22 20:03:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (172,6,1,196,5.99,'2005-08-23 02:51:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (173,6,2,197,0.99,'2005-08-23 06:41:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (85,3,1,198,2.99,'2005-08-23 07:10:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (107,4,2,199,1.99,'2005-08-23 07:43:00');
INSERT INTO payment(payment_id,buyer_id,employee_id,rental_id,amount,payment_date) VALUES (59,2,2,200,4.99,'2005-08-23 17:39:00');


select * from movie where movie_id in (
	select movie_id from movie_category where category_id in (
		
        select category_id from movie_category where movie_id in(
		select movie_id 
		from rental 
		where buyer_id in(
			select buyer_id from buyer where lower(email)= lower('MARIA.MILLER@gmail.com')
		))
    )
); 

select amount, payment_date Date from investment where investor_id = 4 order by Date desc;



CREATE VIEW sales_by_movie_category
AS
SELECT
c.name AS category,
SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN movie  AS i ON r.movie_id = i.movie_id
INNER JOIN movie_category AS fc ON i.movie_id = fc.movie_id
INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name;

select * from payment where employee_id = 3;

SELECT tb1.eid,CONCAT(employee.first_name,' ',employee.last_name) AS Name, tb1.sum FROM
(SELECT employee_id eid, SUM(amount) sum FROM payment GROUP BY employee_id ORDER BY SUM(amount) desc) AS tb1 JOIN employee ON tb1.eid=employee.employee_id;

select *
from employee 
where email = "aayush@gmail.com"
and password = "" or 1=1 -- ""
;

select * from movie_list;