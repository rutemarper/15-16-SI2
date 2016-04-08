use ISEL
go
--(b) Inserir, remover e actualizar informação de um artigo;
if OBJECT_ID('dbo.deleteArtigo') is not null
	drop trigger dbo.deleteArtigo
if OBJECT_ID('dbo.inserirArtigo') is not null
	drop proc dbo.inserirArtigo
if OBJECT_ID('dbo.atualizarArtigo') is not null
	drop proc dbo.atualizarArtigo
if OBJECT_ID('dbo.apagarArtigo') is not null
	drop proc dbo.apagarArtigo
go
--fazer o mesmo para Leilao e vendaDireta
create trigger dbo.deleteArtigo on dbo.Artigo
INSTEAD OF DELETE
as
	declare @artigo varchar(100)
	select @artigo = (select id from deleted)
	UPDATE dbo.Artigo set unCheck=0 where id=@artigo
	UPDATE dbo.Compra set unCheck=0 where artigoId=@artigo
	UPDATE dbo.Licitacao set unCheck=0 where artigoId=@artigo
	UPDATE dbo.Venda set unCheck=0 where artigoId=@artigo
go

create proc dbo.inserirArtigo @data datetime
as
	insert into dbo.Artigo(dataTempo) values (@data)
go
create proc dbo.atualizarArtigo @data datetime, @artigoId int
AS
	UPDATE dbo.Artigo SET dataTempo=@data WHERE id=@artigoId
go
create proc dbo.apagarArtigo @data dateTime, @artigoId int
as
	delete from dbo.Artigo where id=@artigoId
	delete from dbo.Artigo where dataTempo=@data
go

--test
exec dbo.inserirArtigo @data='2016-03-21 22:12:12'
exec dbo.atualizarArtigo @data ='2016-03-21 22:22:22', @artigoId = 1
exec dbo.apagarArtigo '2016-03-21 22:22:22', null
exec dbo.inserirArtigo @data='2016-03-21 22:12:12'
exec dbo.apagarArtigo null, 2
select * from dbo.Artigo
