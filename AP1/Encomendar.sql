/*
*   ISEL-ADEETC-SI2
*   ND 2014
*
*   Material did�tico para apoio 
*   � unidade curricular de 
*   Sistemas de Informa��o II
*
*/
use AP1;
begin tran
	set xact_abort on
	declare @id int
	
	insert into dbo.encomenda(cliente) values(123)
	set @id = @@identity
	if(rand() < 0.5)
		insert into dbo.encomenda_produto values(@id,'CD',rand()*5+1)

	insert into dbo.encomenda_produto values(@id,'Livro',rand()*5+1)

	if(rand() >= 0.5)
		insert into dbo.encomenda_produto values(@id,'Caneta',rand()*5+1)
commit

select * from dbo.encomenda
select * from dbo.encomenda_produto
