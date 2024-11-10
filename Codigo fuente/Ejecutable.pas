program Ejecutable;

uses
SysUtils, Classes, Programa;

function Ejecutable(const NombreArchivo: String);
var
    Pixeles: TArregloPixeles;
    Radio: Integer;
    Indice: Real;
begin
    Pixeles := LectorPixeles(NombreArchivo);
    Radio := CalcularRadioCirculo(Pixeles);
    ConvertirBlancoYNegro(Pixeles, Radio);
    GuardarImagen(Pixeles, 'Resultado.jpg');
    Indice := CalcularIndice(Pixeles);