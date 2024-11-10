program TestPrograma;

uses
  SysUtils, Classes, Programa, FPImage;

// Procedimiento: TestEsNube
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

// Procedimiento: TestLectorPixeles
procedure TestLectorPixeles;
var
  Pixeles: TArregloPixeles;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Assert(Length(Pixeles) > 0, 'El arreglo de píxeles no debe estar vacío');
  Assert(Length(Pixeles[0]) > 0, 'La imagen debe tener filas de píxeles');
  WriteLn('El lector de píxeles funciona correctamente.');
end;

// Procedimiento: TestCalcularRadioCirculo
procedure TestCalcularRadioCirculo;
var
  Pixeles: TArregloPixeles;
  Radio: Integer;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Radio := CalcularRadioCirculo(Pixeles);
  Assert(Radio > 0, 'El radio del círculo debe ser mayor que cero');
  WriteLn('El cálculo del radio funciona correctamente.');
end;

// Procedimiento: TestConvertirBlancoYNegro
procedure TestConvertirBlancoYNegro;
var
  Pixeles, PixelesByN: TArregloPixeles;
  Radio: Integer;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Radio := CalcularRadioCirculo(Pixeles);
  PixelesByN := ConvertirBlancoYNegro(Pixeles, Radio);
  Assert(Length(Pixeles) = Length(PixelesByN), 'El arreglo de píxeles debe tener la misma cantidad de filas');
  WriteLn('La conversión a blanco y negro se realizó correctamente.');
end;

// Procedimiento: TestGuardarImagenRecortada
procedure TestGuardarImagenRecortada;
var
  Pixeles, PixelesByN: TArregloPixeles;
  Radio: Integer;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Radio := CalcularRadioCirculo(Pixeles);
  PixelesByN := ConvertirBlancoYNegro(Pixeles, Radio);
  GuardarImagenRecortada(PixelesByN, '../Imagenes/11838_final.png');
  Assert(FileExists('../Imagenes/11838_final.png'), 'La imagen recortada no se guardó correctamente');
  WriteLn('La imagen recortada se guardó correctamente.');
end;

// Procedimiento: TestIndice
procedure TestIndice;
var
  Pixeles, PixelesByN: TArregloPixeles;
  Radio: Integer;
  IndiceCoberturaNubosa: Real;
begin
  Pixeles := LectorPixeles('../Imagenes/11838.jpg');
  Radio := CalcularRadioCirculo(Pixeles);
  PixelesByN := ConvertirBlancoYNegro(Pixeles, Radio);
  IndiceCoberturaNubosa := CalcularIndice(PixelesByN, Radio);
  WriteLn('Índice de cobertura nubosa: ', IndiceCoberturaNubosa:0:2, '%');
end;

begin
  TestEsNube;
  TestLectorPixeles;
  TestCalcularRadioCirculo;
  TestConvertirBlancoYNegro;
  TestGuardarImagenRecortada;
  TestIndice;
  WriteLn('Todas las pruebas han pasado con éxito.');
end.
