program Ejecutable;

uses
  SysUtils, Classes, Programa;

procedure Ejecutable(const NombreArchivo: String);
var
  Pixeles: TArregloPixeles;
  Radio: Integer;
  Indice: Real;
begin
  Pixeles := LectorPixeles(NombreArchivo);
  Radio := CalcularRadioCirculo(Pixeles);
  ConvertirBlancoYNegro(Pixeles, Radio);
  GuardarImagenRecortada(Pixeles, 'Resultado.jpg');
  Indice := CalcularIndice(Pixeles, Radio);
  WriteLn('Índice de cobertura nubosa: ', Indice:0:2, '%');
end;

var
  RutaImagen: String;
begin
  Write('Ingrese la ruta de la imagen: ');
  ReadLn(RutaImagen);
  if FileExists(RutaImagen) then
    Ejecutable(RutaImagen)
  else
    WriteLn('Error: No se encontró el archivo ', RutaImagen);
end.
