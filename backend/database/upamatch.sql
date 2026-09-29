IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260929055904_Inicial'
)
BEGIN
    CREATE TABLE [Usuarios] (
        [Id] uniqueidentifier NOT NULL,
        [Correo] nvarchar(254) NOT NULL,
        [ContrasenaHash] nvarchar(max) NOT NULL,
        [CreadoEn] datetime2 NOT NULL,
        CONSTRAINT [PK_Usuarios] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260929055904_Inicial'
)
BEGIN
    CREATE TABLE [Likes] (
        [DeUsuarioId] uniqueidentifier NOT NULL,
        [AUsuarioId] uniqueidentifier NOT NULL,
        [EsSuperLike] bit NOT NULL,
        [CreadoEn] datetime2 NOT NULL,
        CONSTRAINT [PK_Likes] PRIMARY KEY ([DeUsuarioId], [AUsuarioId]),
        CONSTRAINT [FK_Likes_Usuarios_AUsuarioId] FOREIGN KEY ([AUsuarioId]) REFERENCES [Usuarios] ([Id]),
        CONSTRAINT [FK_Likes_Usuarios_DeUsuarioId] FOREIGN KEY ([DeUsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260929055904_Inicial'
)
BEGIN
    CREATE TABLE [Mascotas] (
        [UsuarioId] uniqueidentifier NOT NULL,
        [Nombre] nvarchar(40) NOT NULL,
        [Edad] int NOT NULL,
        [Tipo] nvarchar(20) NOT NULL,
        [Raza] nvarchar(60) NOT NULL,
        [Ciudad] nvarchar(60) NOT NULL,
        [Descripcion] nvarchar(300) NOT NULL,
        [Instagram] nvarchar(200) NULL,
        [ActualizadoEn] datetime2 NOT NULL,
        CONSTRAINT [PK_Mascotas] PRIMARY KEY ([UsuarioId]),
        CONSTRAINT [FK_Mascotas_Usuarios_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Usuarios] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260929055904_Inicial'
)
BEGIN
    CREATE TABLE [MascotaIntereses] (
        [UsuarioId] uniqueidentifier NOT NULL,
        [Interes] nvarchar(30) NOT NULL,
        CONSTRAINT [PK_MascotaIntereses] PRIMARY KEY ([UsuarioId], [Interes]),
        CONSTRAINT [FK_MascotaIntereses_Mascotas_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Mascotas] ([UsuarioId]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260929055904_Inicial'
)
BEGIN
    CREATE INDEX [IX_Likes_AUsuarioId] ON [Likes] ([AUsuarioId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260929055904_Inicial'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Usuarios_Correo] ON [Usuarios] ([Correo]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260929055904_Inicial'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260929055904_Inicial', N'10.0.12');
END;

COMMIT;
GO

