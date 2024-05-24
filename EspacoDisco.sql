USE [SeuBanco]
GO

/****** Object:  StoredProcedure [dbo].[Alerta_Espaco_Disco]    Script Date: 24/05/2024 11:37:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE OR ALTER PROCEDURE [dbo].[EspacoDisco] @email VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HTML NVARCHAR(MAX),
            @Hostname VARCHAR(50),
            @Volume CHAR(1),
            @PercentualLivre NUMERIC(10,2),
            @LimiteAlerta INT,
			@EspacoLivreGB INT,
			@CapacidadeGB INT,
			@EspacoOcupadoGB INT,
			@PercentualOcupado NUMERIC(10, 2)

    CREATE TABLE #TempResults (
        Hostname VARCHAR(50),
        Volume CHAR(1),
        PercentualLivre NVARCHAR(10), 
        LimiteAlerta NVARCHAR(10),
		EspacoLivreGB INT,
		CapacidadeGB INT,
		EspacoOcupado INT,
		PercentualOcupado NVARCHAR(10)
    );

    DECLARE dcur CURSOR LOCAL FAST_FORWARD
    FOR 
        SELECT Hostname, Volume, PercentualLivre, LimiteAlerta,EspacoLivreGB, CapacidadeGB, EspacoOcupado, PercentualOcupado 
        FROM dbo.MonitorEspacoLivre
        WHERE ExcluirMonitoramento = 1
        ORDER BY Hostname, Volume;

    OPEN dcur;
    FETCH NEXT FROM dcur INTO @Hostname, @Volume, @PercentualLivre, @LimiteAlerta, @EspacoLivreGB, @CapacidadeGB, @EspacoOcupadoGB, @PercentualOcupado;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		IF (@EspacoLivreGB < @LimiteAlerta)
        INSERT INTO #TempResults (Hostname, Volume, PercentualLivre, LimiteAlerta, EspacoLivreGB, CapacidadeGB, EspacoOcupado, PercentualOcupado )
        VALUES (@Hostname, @Volume, CAST(@PercentualLivre AS NVARCHAR(10)) + '%', @LimiteAlerta, @EspacoLivreGB, @CapacidadeGB, @EspacoOcupadoGB, CAST(@PercentualOcupado AS nvarchar(10)) + '%');

        FETCH NEXT FROM dcur INTO @Hostname, @Volume, @PercentualLivre, @LimiteAlerta, @EspacoLivreGB, @CapacidadeGB, @EspacoOcupadoGB, @PercentualOcupado;
    END
    CLOSE dcur;
    DEALLOCATE dcur;

	IF (NOT EXISTS (SELECT 1 FROM #TempResults))
	BEGIN
		SET @HTML = '<html>
        <head>
            <title>Alerta de Espaço Livre</title>
            <style type="text/css">
                body { font-family: Arial, sans-serif; margin: 0; padding: 0; width: 100%;}
				table { width: 40%; border-collapse: collapse; margin: 20px auto; }
				th, td { border: 1px solid black; padding: 5px; text-align: center; }
				th { background-color: #f2f2f2; }
				img { max-width: 100%; height: auto; display: block; margin: 0 auto; }
            </style>
        </head>
        <body>
            <h4>Não foram encontrados volumes com espaço livre abaixo do limite especificado.</h4>
			<br></br>
				 <img src="caminho.png" width="40%">
		</body>
        </html>';
	
	END
	ELSE
	BEGIN
		SET @HTML = '<html>
    <head>
        <title>Alerta de Espaço Livre</title>
        <style type="text/css">
            body { font-family: Arial, sans-serif; margin: 0; padding: 0; }
            table { border-collapse: collapse; margin: 20px auto; min-width: 60%; max-width: 95%; }
            thead { background: #001f3f; border: 1px solid #ddd; }
            th { padding: 6px; font-weight: bold; border: 1px solid #000; color: #fff; }
            tr { padding: 0; }
            td { padding: 10px; border: 1px solid #cacaca; margin:0; text-align: center; }
            img { max-width: 100%; height: auto; display: block; margin: 0 auto; }
        </style>
    </head>
    <body>
        <h2>Volumes com pouco espaço livre:</h2>
        <table>
            <thead>
                <tr>
                    <th>Hostname</th>
                    <th>Volume</th>
                    <th>Capacidade Total (GB)</th>
                    <th>Espaço Ocupado (GB)</th>
                    <th>Percentual Espaço Ocupado</th>
                    <th>Espaço Livre (GB)</th>
                    <th>Percentual Livre</th>
                </tr>
            </thead>
            <tbody>'
                 +
                CAST(
                    (SELECT td = Hostname, '', td = Volume, '', td = CapacidadeGB, '', td = EspacoOcupado, '', td = PercentualOcupado, '', td = EspacoLivreGB, '',  td =  PercentualLivre, ''
                     FROM #TempResults
                     FOR XML PATH('tr'), ELEMENTS)
                     AS NVARCHAR(MAX) )
			+'</tbody>
        </table>
		<br></br>
			 <img src="caminho.png" width="40%">
    </body>
</html>'

		END

		EXEC msdb.dbo.sp_send_dbmail
            @profile_name = '', -- perfil de email
            @recipients =  @email,
            @subject = 'ALERTA - Volume do Servidor pouco espaço Livre',
            @body = @HTML,
            @body_format = 'HTML';
	

    DROP TABLE #TempResults;
END
GO


