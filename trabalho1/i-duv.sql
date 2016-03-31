use ISEL
go
--(i) Determinar o valor da licitação de um artigo;
-- PROC OU VIEW
-- OS ARTIGOS DE VENDA DIR PODEM SER LICITADOS????????????????? sim mas so uma vez
if OBJECT_ID('dbo.valorLicitacao') is not null
	drop view dbo.valorLicitacao
go

create view valorLicitacao
as
select artigoId, email, preco, dataHora from Licitacao where unCheck=1
go

--test
insert into Artigo(dataTempo) values (GETDATE())
insert into VendaDirecta(artigoId,precoVenda) values(1,10)
insert into Utilizador(email,palavraPasse,morada) values ('LICITADOR1','12345','Sintra')
insert into Utilizador(email,palavraPasse,morada) values ('LICITADOR2','12345','Sintra')
insert into dbo.Licitacao(dataHora,preco,email,artigoId) values ('2016-04-04 04:04:04',10,'LICITADOR1',1)
insert into dbo.Licitacao(dataHora,preco,email,artigoId) values ('2016-04-05 04:04:04',15,'LICITADOR2',1)
insert into dbo.Licitacao(dataHora,preco,email,artigoId) values ('2016-04-06 04:04:04',19,'LICITADOR1',1)

select * from dbo.valorLicitacao

update dbo.Licitacao set unCheck=0 where preco=19 and email='LICITADOR1'

select * from dbo.valorLicitacao

delete Licitacao where artigoId=1
delete Utilizador WHERE email = 'LICITADOR1'
delete Utilizador WHERE email = 'LICITADOR2'
delete VendaDirecta where artigoId=1
delete from Artigo where id=1
