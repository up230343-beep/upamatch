using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace UpaMatch.Api.Migrations
{
    /// <summary>
    /// Tabla Descartes: los "no" al buscar match (los "sí" ya van en Likes).
    /// </summary>
    public partial class Descartes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Descartes",
                columns: table => new
                {
                    DeUsuarioId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    AUsuarioId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    CreadoEn = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Descartes", x => new { x.DeUsuarioId, x.AUsuarioId });
                    table.ForeignKey(
                        name: "FK_Descartes_Usuarios_AUsuarioId",
                        column: x => x.AUsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_Descartes_Usuarios_DeUsuarioId",
                        column: x => x.DeUsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Descartes_AUsuarioId",
                table: "Descartes",
                column: "AUsuarioId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Descartes");
        }
    }
}
