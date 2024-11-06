program TestBlancoYNegro;

uses
  SysUtils, Classes, BlancoYNegro;

procedure TestEsNube;
var
  Resultado: Boolean;
begin
  Resultado := EsNube(255, 255, 255);
  Assert(Resultado = False, 'El píxel blanco no debe ser una nube');

  Resultado := EsNube(245, 245, 245); 
  Assert(Resultado = True, 'El píxel gris claro debe ser una nube');

  Resultado := EsNube(255, 255, 0); 
  Assert(Resultado = False, 'El píxel amarillo no debe ser una nube');

  Resultado := EsNube(0, 0, 0); 
  Assert(Resultado = False, 'El píxel negro no debe ser una nube');
end;

procedure TestConvertirImagen;
var
  NombreEntrada, NombreSalida: String;
begin
  NombreEntrada := '../Imagenes/11838-clean.png';
  NombreSalida := '../Imagenes/11838-clean-convertido.png';

  if not FileExists(NombreEntrada) then
  begin
    WriteLn('Error: El archivo de entrada no existe o no se puede leer.');
    Exit;
  end;

  if not DirectoryExists(ExtractFileDir(NombreSalida)) then
  begin
    WriteLn('El directorio de salida no existe, creándolo...');
    CreateDir(ExtractFileDir(NombreSalida)); // Crear el directorio si no existe
  end;

  ConvertirImagen(NombreEntrada, NombreSalida);

  if not FileExists(NombreSalida) then
  begin
    WriteLn('Error: La imagen convertida no se ha guardado correctamente.');
    Exit;
  end;

  if not (UpperCase(ExtractFileExt(NombreSalida)) = '.PNG') then
  begin
    WriteLn('Error: El formato de la imagen de salida no es PNG.');
    Exit;
  end;

  WriteLn('La conversión y el guardado de la imagen se realizaron correctamente.');
end;

begin
  TestEsNube;
  TestConvertirImagen;
  WriteLn('Todas las pruebas han pasado con éxito.');
end.
