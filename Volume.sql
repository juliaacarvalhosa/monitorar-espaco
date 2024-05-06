CREATE TABLE [dbo].[Volume](
	[Hostname] [varchar](50) NOT NULL,
	[Volume] [char](1) NOT NULL,
	[CapacidadeGB] [numeric](10, 2) NOT NULL,
	[Coleta] [smalldatetime] NULL,
    [ExcluirMonitoramento] BIT DEFAULT 0, -- Flag caso exista a necessidade de exlusão de algum servidor em alguma consulta
    [LimiteAlerta] INT DEFAULT 5 -- Threshold com o limite 5
CONSTRAINT [PK_Volume] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Volume] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
 
ALTER TABLE [dbo].[Volume]  WITH CHECK ADD  CONSTRAINT [FK_Servidor_Volume] FOREIGN KEY([Hostname])
REFERENCES [dbo].[Servidor] ([Hostname])
GO
 
ALTER TABLE [dbo].[Volume] CHECK CONSTRAINT [FK_Servidor_Volume]
GO