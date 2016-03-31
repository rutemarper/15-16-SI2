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

IF OBJECT_ID('TEncomenda_Produto') IS NOT NULL
	DROP TABLE TEncomenda_Produto
IF OBJECT_ID('TProduto') IS NOT NULL
	DROP TABLE TProduto
IF OBJECT_ID('TEncomenda') IS NOT NULL
	DROP TABLE TEncomenda
IF OBJECT_ID('TCliente') IS NOT NULL
	DROP TABLE Tcliente
IF OBJECT_ID('Encomenda_Produto') IS NOT NULL
	DROP view Encomenda_Produto
IF OBJECT_ID('Produto') IS NOT NULL
	DROP view Produto
IF OBJECT_ID('Encomenda') IS NOT NULL
	DROP view Encomenda
IF OBJECT_ID('Cliente') IS NOT NULL
	DROP view cliente
IF OBJECT_ID('inserirEncomenda') IS NOT NULL
	DROP trigger inserirEncomenda
IF OBJECT_ID('inserirProduto') IS NOT NULL
	DROP trigger inserirProduto
IF OBJECT_ID('inserirEncomeda_Produto') IS NOT NULL
	DROP trigger inserirEncomeda_Produto

CREATE TABLE TCliente
(
	nif INT PRIMARY KEY,
	nome VARCHAR(30),
	morada VARCHAR(100)
)
go
create view Cliente as
	select * from TCliente
go
CREATE TABLE TEncomenda
(
	num INT IDENTITY(1,1) PRIMARY KEY,
	Estado  varchar(11),
	DataEnc DATETIME NOT NULL DEFAULT GETDATE(),
	DataDesp DATETIME NULL,
	cliente INT NOT NULL REFERENCES TCliente(nif),
	check (estado='em processamento' or estado='finalizada')
)
go
create view Encomenda as
	select num, dataEnc, cliente from TEncomenda
go
CREATE TABLE TProduto
(
	nome VARCHAR(30) PRIMARY KEY,
	stock int not null,
	limiteMinimo int default 3,
	check (stock>0 and limiteMinimo>0)
)
go
create view Produto as
	select nome from TProduto
go
CREATE TABLE TEncomenda_Produto
(
	encomenda INT NOT NULL REFERENCES TEncomenda(num),
	produto VARCHAR(30) NOT NULL REFERENCES Tproduto(nome),
	quantidade INT NOT NULL,	
	satisfeito varchar(3),
	PRIMARY KEY(encomenda,produto),
	check (satisfeito='sim' or satisfeito='nao')
)
go
create view Encomenda_Produto as
	select encomenda, produto, quantidade from TEncomenda_Produto
go

create trigger inserirEncomenda on dbo.Encomenda
instead of insert
as
	if(exists (select * from inserted))
	begin
		insert TEncomenda(Cliente, Estado) values ((select cliente from inserted),'em processamento')
		if(@@ERROR=1)
			print('Cliente inexistente')
	end
go
create trigger inserirProduto on dbo.Produto
instead of insert
as
	if(exists (select * from inserted))
	begin
		if((select nome from inserted) in (select nome from TProduto))
			update TProduto set stock=stock+1 where nome=(select nome from inserted)
		else
			insert TProduto(nome, stock) values ((select nome from inserted),1)
	end
	 declare @stock int, @quantidade int, @nome varchar(30)
			select @nome = (select nome from inserted)
			select @stock = (select stock from TProduto where nome=(@nome))
			select @quantidade = (select quantidade from TEncomenda_Produto where produto=@nome)
	--verficar se existem encomendas a nao com esse produto e inc
		if((select nome from TProduto) in (select produto from TEncomenda_Produto where satisfeito='nao'))
		begin
			if(@stock>=@quantidade)
			begin
				update TProduto set stock = stock-@quantidade where nome = @nome
				update  TEncomenda_Produto set satisfeito='sim'	
			end
		end 

go
create trigger inserirEncomeda_Produto on dbo.Encomenda_Produto
instead of insert
as
	if(exists (select * from inserted))
	begin
		if(not exists (select num from TEncomenda where num=(select encomenda from inserted)))
			print('Encomenda inexistente')
		else if(not exists (select nome from TProduto where nome=(select produto from inserted)))
			print('Produto inexistente')
		else
		begin
			declare @sat varchar(3), @diferenca int, @stock int, @limite int, @nome varchar(30), @msg varchar(500)
			select @nome = (select produto from inserted)
			select @stock = (select stock from TProduto where nome=(@nome))
			select @limite = (select limiteMinimo from TProduto where nome=(@nome))
			select @diferenca = (select quantidade from inserted)-(@stock)
			if((select quantidade from inserted) <= @stock)
			begin
				set @sat = 'sim'
				update TProduto set stock = @diferenca
				if(@stock<@limite)
				begin
					set @msg = 'nota de encomendenta do produto '+@nome+' com a quantidade superior a '+ (@limite-@stock)
					RAISERROR(@msg,5,1)
				end
			end	
			else
			begin
				set @sat = 'nao'
				set @msg = 'nota de encomendenta do produto '+@nome+' com a quantidade '+@diferenca
					RAISERROR(@msg,5,1)
			end
			insert TEncomenda_Produto(encomenda,produto, quantidade,satisfeito) values ((select encomenda from inserted),@nome,(select quantidade from inserted),@sat)
		end
	end	
go	


BEGIN TRAN
	SET NOCOUNT ON

COMMIT

