CREATE TABLE [dbo].[ServidorVolume](
	[Hostname] [varchar](50) NOT NULL,
	[Volume] [char](1) NOT NULL,
	[Coleta] [smalldatetime] NOT NULL,
	[EspacoLivre] [bigint] NOT NULL,
CONSTRAINT [PK_ServidorVolume] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Volume] ASC,
	[Coleta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
 
ALTER TABLE [dbo].[ServidorVolume]  WITH CHECK ADD  CONSTRAINT [FK_ServidorVolume_Volume] FOREIGN KEY([Hostname], [Volume])
REFERENCES [dbo].[Volume] ([Hostname], [Volume])
GO
 
ALTER TABLE [dbo].[ServidorVolume] CHECK CONSTRAINT [FK_ServidorVolume_Volume]
GO