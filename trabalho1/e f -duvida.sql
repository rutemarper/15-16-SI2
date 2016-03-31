use ISEL
go
--(e) Inserir uma licitação;
--(f) Retirar uma licitação;
-- VERIFICAÇOES DO PREÇO SER MAIOR OU IGUAL A BLA BLA BLA!!!!!!!!!!!!!!!
--SOBRE LEILAO OU VENDA DIRRETA OU MABOS????????????????????????????? todos na venda direta so pode haver uma
if OBJECT_ID('dbo.inserirLicitacao') is not null
	drop proc dbo.inserirLicitacao
if OBJECT_ID('dbo.removerLicitacao') is not null
	drop proc dbo.removerLicitacao
go
create proc dbo.inserirLicitacao @data datetime, @preco money, @email varchar(100), @artigoId int
as
	insert into dbo.Licitacao(dataHora,preco,email,artigoId) values (@data,@preco,@email,@artigoId)
go
-- 1)remover todas as licitacoes do @email ou 2)remover a ultima insercao do 2email
create proc dbo.removerLicitacao @email varchar(100), @artigoId int
as
	update dbo.Licitacao set unCheck=0 where email=@email and artigoId=@artigoId
--FAÇO UM TRIGGER?????????????????????? sim
go

--test
insert into dbo.Artigo(dataTempo) values ('2016-03-20 22:20:20')
insert into Utilizador(email,palavraPasse,morada) values ('a40602@alunos.isel.pt','12345','Sintra')

exec dbo.inserirLicitacao @data='2016-03-24 22:20:20', @preco=2, @email='a40602@alunos.isel.pt', @artigoId=1
exec dbo.inserirLicitacao @data='2016-03-24 22:22:22', @preco=3, @email='a40602@alunos.isel.pt', @artigoId=1

exec dbo.removerLicitacao @email='a40602@alunos.isel.pt', @artigoId=1

delete from dbo.Licitacao where email='a40602@alunos.isel.pt'
delete from dbo.Artigo where dataTempo='2016-03-20 22:20:20'
delete from dbo.Utilizador where email='a40602@alunos.isel.pt'
select * from dbo.Licitacao
