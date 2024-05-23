USE [SeuBanco]
GO

/****** Object:  StoredProcedure [dbo].[Alerta_Espaco_Disco]    Script Date: 23/05/2024 11:59:25 ******/
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
			@EspacoLivreGB INT

    CREATE TABLE #TempResults (
        Hostname VARCHAR(50),
        Volume CHAR(1),
        PercentualLivre NVARCHAR(10), 
        LimiteAlerta NVARCHAR(10),
		EspacoLivreGB INT
    );

    DECLARE dcur CURSOR LOCAL FAST_FORWARD
    FOR 
        SELECT Hostname, Volume, PercentualLivre, LimiteAlerta,EspacoLivreGB
        FROM dbo.MonitorEspacoLivre
        WHERE ExcluirMonitoramento = 0
        ORDER BY Hostname, Volume;

    OPEN dcur;
    FETCH NEXT FROM dcur INTO @Hostname, @Volume, @PercentualLivre, @LimiteAlerta, @EspacoLivreGB

    WHILE @@FETCH_STATUS = 0
    BEGIN
		IF (@EspacoLivreGB < @LimiteAlerta)
        INSERT INTO #TempResults (Hostname, Volume, PercentualLivre, LimiteAlerta, EspacoLivreGB)
        VALUES (@Hostname, @Volume, CAST(@PercentualLivre AS NVARCHAR(10)) + '%', @LimiteAlerta, @EspacoLivreGB);

        FETCH NEXT FROM dcur INTO @Hostname, @Volume, @PercentualLivre, @LimiteAlerta, @EspacoLivreGB;
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
			<img src="caminho_para_a_foto.png" alt="Imagem de cabeçalho" width="40%" height="100">
        </body>
        </html>';
	
	END
	ELSE
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
            <h2>Volumes com pouco espaço livre:</h2>
            <table>
                <thead>
                    <tr>
                        <th>Hostname</th>
                        <th>Volume</th>
                        <th>Percentual Livre</th>
                    </tr>
                </thead>
                <tbody>' +
                CAST(
                    (SELECT td = Hostname, '', td = Volume, '', td = PercentualLivre,''
                     FROM #TempResults
                     FOR XML PATH('tr'), ELEMENTS)
                     AS NVARCHAR(MAX)
                ) +
                '</tbody>
            </table>
			<br></br>
			 <img src="caminho_para_a_foto.png" alt="Imagem de cabeçalho" width="40%" height="100">
        </body>
        </html>';
		END

		EXEC msdb.dbo.sp_send_dbmail
            @profile_name = '' ,-- perfil do email
            @recipients = @email,
            @subject = 'ALERTA - Volume do Servidor pouco espaço Livre',
            @body = @HTML,
            @body_format = 'HTML';
	

    DROP TABLE #TempResults;
END
GO


