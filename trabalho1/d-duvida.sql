use ISEL
go
--(d) Inserir, remover e actualizar informação de um local;

if OBJECT_ID('dbo.inserirLocal') is not null
	drop proc dbo.inserirLocal
if OBJECT_ID('dbo.atualizarLocal') is not null
	drop proc dbo.atualizarLocal
if OBJECT_ID('dbo.apagarLocal') is not null
	drop proc dbo.apagarLocal
go
create proc dbo.inserirLocal @preco money, @locOrigem varchar(2), @locDestino varchar(2)
as
	insert into dbo.Porte(preco,moradaOrigem,moradaDestino) values (@preco,@locOrigem,@locDestino)
go
create proc dbo.atualizarLocal @preco money, @locOrigem varchar(2), @locDestino varchar(2)
AS
	update dbo.Porte SET preco=@preco where moradaOrigem=@locOrigem and moradaDestino=@locDestino
go
create proc dbo.apagarLocal @local varchar(2)
as
	delete from dbo.Porte where moradaDestino=@local or moradaOrigem=@local
go

--test
exec dbo.inserirLocal @preco=1, @locOrigem='PT', @locDestino='PT'
exec dbo.inserirLocal @preco=2, @locOrigem='PT', @locDestino='FR'

exec dbo.atualizarLocal @preco=3, @locOrigem='PT', @locDestino='FR'

exec dbo.apagarLocal @local='PT'