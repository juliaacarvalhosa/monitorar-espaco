USE [SeuBanco]
GO


CREATE PROCEDURE [dbo].[EspacoDisco] 
	@email varchar(100)
	

SET NOCOUNT ON

DECLARE @body1 varchar(100),
        @Hostname varchar(50),
        @volume char(1),
	@PercentualLivre numeric(10,2),
	@LimiteAlerta int 

DECLARE dcur CURSOR LOCAL FAST_FORWARD

-- Consulta na View MonitorEspacoLivre fazendo a exclusão de alguns servidores com o uso da Flag "ExcluirMonitoramento"

FOR SELECT Hostname,Volume,PercentualLivre, LimiteAlerta
    FROM dbo.MonitorEspacoLivre
	WHERE ExcluirMonitoramento = 0
ORDER BY Hostname, Volume

OPEN dcur

FETCH NEXT FROM dcur INTO @Hostname,@volume, @PercentualLivre, @LimiteAlerta

WHILE @@FETCH_STATUS=0
BEGIN
 
if (@percentualLivre < @LimiteAlerta)  
begin
set @body1 = 'Servidor :'+@Hostname+ ' com volume '
             +@Volume+':\ com '+cast(@percentuallivre as char(5))
             +'%, isto é menos de '+cast(@Limite as char(2))
             +'% de Espaço Livre'
EXEC msdb.dbo.sp_send_dbmail 
    @recipients		= @email,
    @subject		= 'ALERTA - Volume do Servidor pouco espaço Livre' ,
    @body			= @body1,
    @body_format	= 'HTML' ;

end -- if
FETCH NEXT FROM dcur INTO @Hostname,@volume, @PercentualLivre
end -- while

CLOSE dcur
DEALLOCATE dcur

RETURN
GO


