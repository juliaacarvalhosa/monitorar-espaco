CREATE TABLE [dbo].[Volume](
	[Hostname] [varchar](50) NOT NULL,
	[Volume] [char](1) NOT NULL,
	[CapacidadeGB] [numeric](10, 2) NOT NULL,
	[Coleta] [smalldatetime] NULL,
    	[ExcluirMonitoramento] BIT DEFAULT 0, -- Flag caso exista a necessidade de exlusão de algum servidor em alguma consulta
    	[LimiteAlerta] INT -- Threshold com o limite 5% da Capacidade Total (CapacidadeGB)
CONSTRAINT [PK_Volume] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Volume] ASC
)) 
GO
 
ALTER TABLE [dbo].[Volume]  WITH CHECK ADD  CONSTRAINT [FK_Servidor_Volume] FOREIGN KEY([Hostname])
REFERENCES [dbo].[Servidor] ([Hostname])
GO
