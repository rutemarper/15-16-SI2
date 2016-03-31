/*
*   ISEL-ADEETC-SI2
*   ND 2015-2016
*
*   Material didático para apoio 
*   à unidade curricular de 
*   Sistemas de Informação II
*
*/
--create database AP1
SET XACT_ABORT ON
SET NOCOUNT ON
USE AP1; 
GO

IF OBJECT_ID('Encomenda_Produto') IS NOT NULL
	DROP TABLE Encomenda_Produto
IF OBJECT_ID('Produto') IS NOT NULL
	DROP TABLE Produto
IF OBJECT_ID('Encomenda') IS NOT NULL
	DROP TABLE Encomenda
IF OBJECT_ID('Cliente') IS NOT NULL
	DROP TABLE cliente

CREATE TABLE Cliente
(
	nif INT PRIMARY KEY,
	nome VARCHAR(30),
	morada VARCHAR(100)
)

CREATE TABLE Encomenda
(
	num INT IDENTITY(1,1) PRIMARY KEY,
	DATA DATETIME NOT NULL DEFAULT GETDATE(),
	cliente INT NOT NULL REFERENCES Cliente(nif)
)

CREATE TABLE Produto
(
	nome VARCHAR(30) PRIMARY KEY
)

CREATE TABLE Encomenda_Produto
(
	encomenda INT NOT NULL REFERENCES Encomenda(num),
	produto VARCHAR(30) NOT NULL REFERENCES produto(nome),
	quantidade INT NOT NULL,	
	PRIMARY KEY(encomenda,produto)
)

BEGIN TRAN
	SET NOCOUNT ON
	INSERT INTO cliente VALUES(123,'nome1','Morada1')
	INSERT INTO cliente VALUES(456,'nome2','Morada2')

	INSERT INTO produto VALUES('Cd')
	INSERT INTO produto VALUES('Livro')
	INSERT INTO produto VALUES('Caneta')
COMMIT

