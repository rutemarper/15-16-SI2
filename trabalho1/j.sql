use ISEL
set nocount on
go
--(j) Obter as n últimas licitações; 
--para um artigo ou por data QUE TÊM CHECK OU UNCHECK????????????????

--function 
if OBJECT_ID('dbo.nLicitacao') is not null
	drop function dbo.nLicitacao
go
create function dbo.nLicitacao(@n int)
returns table
as
   return (select top (@n) * from dbo.Licitacao order by dataHora desc)   
go 

--test
insert into dbo.Utilizador(email,palavraPasse,nome,morada) values ('email1','@pp','@nome','@morada');
insert into dbo.Utilizador(email,palavraPasse,nome,morada) values ('email2','@pp','@nome','@morada');
insert into dbo.Artigo(dataTempo) values ('2015-02-01 10:10:00');
declare @id int
set @id=@@identity;
insert into dbo.Licitacao(dataHora, preco, email, artigoId) values ('2015-02-02 10:10:00',10,'email1',1),('2015-02-02 15:10:00',15,'email2',1),('2015-02-03 10:10:00',20,'email1',1);
insert into dbo.Licitacao(dataHora, preco, email, artigoId) values ('2015-02-01 20:10:00',30,'email1',1);

select * from dbo.nLicitacao(2);

delete from Licitacao where artigoId=@id;
delete Artigo  where dataTempo='2015-02-01 10:10:00';
delete Utilizador  where email='email1';
delete Utilizador  where email='email2';