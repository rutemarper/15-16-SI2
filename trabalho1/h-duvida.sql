use ISEL
set nocount on
go
--(h) Realizar a compra de um artigo de venda directa
if OBJECT_ID('dbo.efetuarCompraDireta') is not null
	drop proc dbo.efetuarCompraDireta
go
create proc dbo.efetuarCompraDireta @data dateTime, @locDest varchar(2), @cc int, @email varchar(100), @artigoId int
as
	insert into dbo.Compra(dataCompra,localDestino,cartaoCredito,email,artigoId) values	(@data,@locDest,@cc,@email,@artigoId)
	declare @valorArtigo int
	select @valorArtigo=(select precoVenda FROM VendaDirecta where artigoId=@artigoId)
	print('Valor do artigo selecionado: ')
	print(@valorArtigo)
	declare @porte int
	select @porte = (select preco from Porte where moradaOrigem=(select localOrigem from Venda where artigoId=@artigoId) and moradaDestino=(select localDestino from Compra where artigoId=@artigoId))
	print('Valor do porte: ')
	print(@porte)
	declare @total int
	set @total = @valorArtigo+@porte
	print('Valor total a pagar: ')
	print(@total)
	--quando se faz o delete do artigo e da vendadireta????????????????? flag de presente
go

--test
declare @valorPorte int 
INSERT INTO dbo.Porte(preco,moradaOrigem,moradaDestino) values (1,'PT','PT')
insert into dbo.Utilizador(email,morada,palavraPasse) values ('a40602@alunos.isel.pt','Sintra','123')
insert into dbo.Artigo(dataTempo) values ('2016-03-02 22:22:22')
insert into dbo.VendaDirecta(artigoId,precoVenda) values (1,10)
insert into dbo.Venda(email,artigoId,condicao,localOrigem) values ('a40602@alunos.isel.pt',1,'Novo','PT')

exec dbo.efetuarCompraDireta @data='2016-03-13 22:22:22', @locDest='PT', @cc=1, @email='a40602@alunos.isel.pt', @artigoId=1

	delete from Compra where artigoId=1
	delete from Venda where artigoId=1
	delete from VendaDirecta where artigoId=1
	delete from Artigo where id=1
	delete from Utilizador where email='a40602@alunos.isel.pt'
	delete from Porte where preco=1