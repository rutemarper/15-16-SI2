use ISEL
set nocount on
go
--(k) Obter os portes, dadas duas localizações;
-- FUNCTION OR PROC??????????????????
--function 
if object_id('dbo.valuePorte') is not null
	drop function dbo.valuePorte
go
create function dbo.valuePorte (@locOrigem varchar(2), @locDestino varchar(2))
returns int
as
begin
	declare @valor int
	select @valor = (select preco from Porte where moradaDestino=@locDestino and moradaOrigem=@locOrigem)
	return @valor
end

go


--test
declare @valorPorte int 
insert into dbo.Porte(preco,moradaOrigem,moradaDestino) values (3,'PT','FR')
exec dbo.valorPorte	'PT', 'FR', @valorPorte output 

select dbo.valuePorte('PT','FR')

delete from dbo.Porte where moradaOrigem='PT' and moradaDestino='FR'
