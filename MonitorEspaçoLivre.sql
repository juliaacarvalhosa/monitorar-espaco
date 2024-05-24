CREATE OR ALTER VIEW [dbo].[MonitorEspacoLivre]
AS
SELECT     v.Hostname, v.Volume, 
           v.CapacidadeGB, 
           CAST(HSV.EspacoLivre / 1024.0 AS numeric(10, 2)) AS EspacoLivreGB, 
           v.CapacidadeGB - CAST(HSV.EspacoLivre / 1024.0 AS numeric(10, 2)) as EspacoOcupado,
           CAST((v.CapacidadeGB - CAST(HSV.EspacoLivre / 1024.0 AS numeric(10, 2))) / v.CapacidadeGB * 100 AS numeric(10, 2)) AS PercentualOcupado,
           CAST(HSV.EspacoLivre / 1024.0 / v.CapacidadeGB * 100 AS numeric(10, 2)) AS PercentualLivre,
           v.ExcluirMonitoramento, v.LimiteAlerta
FROM       dbo.Volume AS v 
INNER JOIN (
    SELECT Hostname, Volume, EspacoLivre, Coleta,
           ROW_NUMBER() OVER (PARTITION BY Hostname, Volume ORDER BY Coleta DESC) AS rn
    FROM dbo.Historico_Servidor_Volume
) AS HSV ON v.Volume = HSV.Volume AND v.Hostname = HSV.Hostname AND HSV.rn = 1
WHERE      floor(cast (Hsv.Coleta as real)) + 1 > floor(cast(getdate() as real))
GO
