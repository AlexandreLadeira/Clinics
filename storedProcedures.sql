sp_help Medico
sp_help Paciente
sp_help Exame
sp_help Consulta

-----------------------------Cadastrar Paciente----------------------------------
/*Insere um paciente checando se o usuario ou e email fornecidos já exsitem no banco. Se existir
dispara um erro*/

alter proc inserirPaciente_sp
@nome			varchar(50),
@endereco		varchar(100),
@dataNascimento date,
@idade			int,
@email			varchar(100),
@celular		varchar(14),
@telefoneRes	varchar(13),
@usuario		varchar(30),
@senha			nvarchar(50),
@foto			image
as
if((select count(*) from paciente where usuario = @usuario) != 0)
	RAISERROR('Já esxiste este login',16,1)
else
if((select count(*) from paciente where email = @email) != 0)
	RAISERROR('Já esxiste login com este email',16,1)
else
insert into Paciente values(@nome, @endereco, @dataNascimento, @idade, @email, @celular, @telefoneRes, @usuario,HASHBYTES('SHA1', @senha), @foto)

inserirPaciente_sp 'alexandre','rua das margaridas 120','13/12/2000',16,'@alexandrelcampanha@hotmail.com','(19)99670-0303','(19)3256-1360','alexl7d','coxinha',null

select * from Paciente

delete from Paciente where codPaciente > 10

delete  from Paciente               
-----------------------------Cadastrar Medico----------------------------------
/*Insere um medico checando se o usuario ou e email fornecidos já exsitem no banco. Se existir
dispara um erro*/

alter proc inserirMedico_sp
@nome			varchar(50),
@dataNascimento date,
@email			varchar(100),
@celular		varchar(14),
@telefoneRes	varchar(13),
@usuario		varchar(30),
@senha			nvarchar(50),
@foto			image,
@codEspecialidade int
as
if((select count(*) from Medico where usuario = @usuario) != 0)
	RAISERROR('Já esxiste este login',16,1)
else
if((select count(*) from Medico where email = @email) != 0)
	RAISERROR('Já esxiste login com este email',16,1)
else
insert into Medico values(@nome, @dataNascimento, @email, @celular, @telefoneRes, @usuario, HASHBYTES('SHA1', @senha), @foto, @codEspecialidade)

inserirMedico_sp 'Pedro de Alcantara','15/07/1970','pedroAlc@gmail.com','(19)99885-5789','(19)3254-6789','pedo','soulegal',null,1


insert into Atendente values('Pedro', 'pedro', HASHBYTES('SHA1', '1234') ,'pp@mail.com','(19)99999-9999', '(19)9999-9999', null, '13-6-1989', 'Rua feliz')

select * from Atendente

-----------------------------Cadastrar Consulta----------------------------------
/*Insere uma consulta pendente no banco de dados, ou seja, uma vontade de fazer uma consulta 
com um determinado medico em uma determinada data que o paciente tem*/
alter proc inserirPedidoConsulta_sp
@data			date,
@hora			time,
@codMedico		int,
@codPaciente	int
as
if((select count(*) from Medico where codMedico = @codMedico) = 0)
	RAISERROR('Este médico não existe!',16,1)
else
if((select count(*) from Paciente where codPaciente = @codPaciente) = 0)
	RAISERROR('Este paciente não existe!',16,1)
else
insert into Consulta values(@data,@hora,null,null,'PENDENTE',null,@codPaciente,@codMedico)

select * from Consulta

-----------------------------Confirma Consulta----------------------------------
/*Confrima uma consulta pendente no banco de dados*/
create proc confirmarConsulta_sp
@codConsulta	int,
@codAntendete   int,
@duracao		int
as
if((select count(*) from Consulta where codConsulta = @codConsulta) = 0)
	RAISERROR('Esta consulta não existe!',16,1)
else
update Consulta set codAtendente = @codAntendete, duracao = @duracao, situacao = 'CONFIRMADA' where codConsulta = @codConsulta

-----------------------------Cancela Consulta----------------------------------
/*Confrima uma consulta pendente no banco de dados*/
create proc cancelarConsulta_sp
@codConsulta	int,
@codAntendete   int
as
if((select count(*) from Consulta where codConsulta = @codConsulta) = 0)
	RAISERROR('Esta consulta não existe!',16,1)
else
update Consulta set codAtendente = @codAntendete, situacao = 'CANCELADA' where codConsulta = @codConsulta


--------------------------- View de Especialidade--------------------------------
/*Exibe todas as especilidades do banco de dados*/
select * from Especialidade

alter view selecionarEspecialidade_view
as
select codEspecialidade, cast(codEspecialidade as varchar) + ' - ' + nome as descricaoEspecialidade
from Especialidade

select * from selecionarEspecialidade_view

--------------------------- View de consulta pendente--------------------------------
/*Exibe todas as consultas pendentes do banco de dados*/

create view selecionarConsultasPendentes_view
as

select c.codConsulta, c.data, c.hora, p.nome as paciente, m.nome as Medico from Consulta c
inner join Paciente p	on p.codPaciente = c.codPaciente
inner join Medico  m    on m.codMedico   = c.codMedico 
where 
c.situacao = 'PENDENTE'

select * from selecionarConsultasPendentes_view 

--------------------------- Consultas do dia--------------------------------
/*Exisbe data, hora, nome do medio, nome do paciente e situacao de todas as consultas 
de um determinado dia*/
alter proc consultasDoDia_sp
@ano int,
@mes int ,
@dia int
as
select c.data,c.hora, m.nome as Medico , p.nome as Paciente, c.situacao from Consulta c
inner join Medico m		on m.codMedico	 = c.codMedico 
inner join Paciente p	on p.codPaciente = c.codPaciente
where 
YEAR(c.data)		= @ano and
MONTH(c.data)		= @mes and 
DAY(c.data)			= @dia

consultasDoDia_sp 1,1,1

select * from Consulta 


--------------------------- Medico especialidade--------------------------------
/*Exibe todos os medicos com determinada especialidade*/
create procedure medicoEspecialidade_sp
@codEspeci int
as
select m.nome,m.codMedico  from Medico m
inner join Especialidade e on e.codEspecialidade = m.codEspecialidade
where
e.codEspecialidade = @codEspeci


---------------------------Relatorio 2 ---------------------------------------------
alter proc relatorioConsultas_sp
@codMedico	 int,
@codPaciente int
as
select c.codConsulta		as Codigo , c.dataEhora, c.diagnostico, e.nome as Exame from Consulta c 
inner join Paciente p		on p.codPaciente = c.codPaciente
inner join Medico m			on m.codMedico = c.codMedico
inner join ConsultaExame ce on c.codConsulta = ce.codConsulta
inner join Exame e			on ce.codExame = e.codExame
where 
p.codPaciente	= @codPaciente and 
m.codMedico		= @codMedico  


relatorioConsultas_sp 1,1


------------------------------testa login de paciente ------------------------
/*Testa se existe um determinado paciente no banco de dados*/
alter proc testaLoginPaciente_sp
@login varchar(30),
@senha nvarchar(50),
@logou int output
as
declare @quantosResultados int
 SET @quantosResultados = (SELECT COUNT(*) FROM Paciente WHERE usuario = @login AND senha = HASHBYTES('SHA1', @senha))

 return @quantosResultados

 testaLoginPaciente_sp 'alexlad','coxinha'

------------------------------testa login de medico ------------------------
/*Testa se existe um determinado médico no banco de dados*/

alter proc testaLoginMedico_sp
@login varchar(30),
@senha nvarchar(50),
@logou int output
as
 SET @logou = (SELECT COUNT(*) FROM Medico WHERE usuario = @login AND senha = HASHBYTES('SHA1', @senha))


 DECLARE @resultado int
 EXEC testaLoginMedico_sp 'raposa','123', @resultado output
 SELECT @resultado

 select * from Medico


------------------------------testa login de atendente----------------------
/*Testa se existe um determinado atendente no banco de dados*/

alter proc testaLoginAtendente_sp
@login varchar(30),
@senha varchar(50),
@logou int output
as
 SET @logou = (SELECT COUNT(*) FROM Atendente WHERE usuario = @login AND senha = HASHBYTES('SHA1', @senha))

 select * from Atendente


 (SELECT COUNT(*) FROM Atendente WHERE usuario = 'pedro' AND senha = HASHBYTES('SHA1', '1234'))

 delete from Atendente

 DECLARE @resultado int
 EXEC testaLoginAtendente_sp 'pedro','1234', @resultado output
 SELECT @resultado
